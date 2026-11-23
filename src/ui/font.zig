const std = @import("std");

pub const UIVertex = extern struct {
    position: [2]f32, // screen coordinates in pixels (x, y)
    tex_coord: [2]f32, // (u, v) coordinates in texture atlas
    local_pos: [2]f32, // local coordinates relative to quad center: [-half_w, -half_h]..[half_w, half_h]
    half_size: [2]f32, // half-width and half-height (w/2, h/2)
    color: [4]f32, // fill RGBA color
    border_color: [4]f32, // border RGBA color
    params: [4]f32, // x: corner_radius, y: border_width, z: mode (0=SDF, 1=glyph, 2=textured, 3=halo/glow, 4=glass), w: extra (glow_spread)
};

pub const raw_font_data = @embedFile("font_raw.bin");
pub const raw_atlas_1024 = @embedFile("ui_atlas_1024.rgba");

pub const ATLAS_WIDTH: u32 = 1024;
pub const ATLAS_HEIGHT: u32 = 1024;
pub const GLYPH_WIDTH: u32 = 8;
pub const GLYPH_HEIGHT: u32 = 16;
pub const GLYPHS_PER_ROW: u32 = 16;
pub const GLYPH_ROWS: u32 = 16;

pub const AtlasUV = struct {
    u0: f32,
    v0: f32,
    u1: f32,
    v1: f32,

    pub const circuit_bg = AtlasUV{ .u0 = 0.0, .v0 = 0.25, .u1 = 1.0, .v1 = 1.0 };
    pub const logo_sidebar = AtlasUV{ .u0 = 0.25, .v0 = 0.0, .u1 = 0.375, .v1 = 0.125 };
    pub const hero_emblem = AtlasUV{ .u0 = 0.375, .v0 = 0.0, .u1 = 0.5, .v1 = 0.125 };
    pub const icon_github = AtlasUV{ .u0 = 0.5, .v0 = 0.0, .u1 = 0.5625, .v1 = 0.0625 };
    pub const icon_rust = AtlasUV{ .u0 = 0.5625, .v0 = 0.0, .u1 = 0.625, .v1 = 0.0625 };
    pub const icon_wayland = AtlasUV{ .u0 = 0.625, .v0 = 0.0, .u1 = 0.6875, .v1 = 0.0625 };
    pub const icon_hajr = AtlasUV{ .u0 = 0.6875, .v0 = 0.0, .u1 = 0.75, .v1 = 0.0625 };
    pub const icon_sparkle = AtlasUV{ .u0 = 0.75, .v0 = 0.0, .u1 = 0.78125, .v1 = 0.03125 };
    pub const icon_toggle = AtlasUV{ .u0 = 0.78125, .v0 = 0.0, .u1 = 0.8125, .v1 = 0.03125 };
};

pub fn getAtlasRGBA() []const u8 {
    return raw_atlas_1024;
}

pub const FontMetrics = struct {
    first_cols: [256]u8,
    last_cols: [256]u8,
    advances: [256]f32,

    pub fn init() FontMetrics {
        var metrics: FontMetrics = undefined;
        for (0..256) |c_idx| {
            const c: u8 = @intCast(c_idx);
            if (c == ' ') {
                metrics.first_cols[c_idx] = 0;
                metrics.last_cols[c_idx] = 0;
                metrics.advances[c_idx] = 5.0;
                continue;
            }
            const offset = c_idx * 16;
            const slice = raw_font_data[offset .. offset + 16];

            var col_bits = [_]u8{0} ** 8;
            for (slice) |row_byte| {
                var bit: usize = 0;
                while (bit < 8) : (bit += 1) {
                    if (((row_byte >> @intCast(7 - bit)) & 1) != 0) {
                        col_bits[bit] = 1;
                    }
                }
            }

            var first_col: ?usize = null;
            var last_col: ?usize = null;
            for (col_bits, 0..) |has_bit, i| {
                if (has_bit != 0) {
                    if (first_col == null) first_col = i;
                    last_col = i;
                }
            }

            if (first_col) |first| {
                const last = last_col.?;
                metrics.first_cols[c_idx] = @intCast(first);
                metrics.last_cols[c_idx] = @intCast(last);
                const w = @as(f32, @floatFromInt(last - first + 1));
                metrics.advances[c_idx] = w + 1.0;
            } else {
                metrics.first_cols[c_idx] = 0;
                metrics.last_cols[c_idx] = 7;
                metrics.advances[c_idx] = 6.0;
            }
        }
        return metrics;
    }
};

pub var global_metrics: ?FontMetrics = null;

pub fn getMetrics() *const FontMetrics {
    if (global_metrics == null) {
        global_metrics = FontMetrics.init();
    }
    return &global_metrics.?;
}

pub fn getTextWidth(text: []const u8, scale: f32) f32 {
    const metrics = getMetrics();
    var width: f32 = 0;
    var i: usize = 0;
    while (i < text.len) {
        const b = text[i];
        if (b < 128) {
            width += metrics.advances[b] * scale;
            i += 1;
        } else {
            const seq_len = std.unicode.utf8ByteSequenceLength(b) catch 1;
            width += 10.0 * scale;
            i += seq_len;
        }
    }
    return width;
}

pub fn appendTextQuads(
    allocator: std.mem.Allocator,
    vertices: *std.ArrayList(UIVertex),
    text: []const u8,
    x: f32,
    y: f32,
    color: [4]f32,
    scale: f32,
) !void {
    const metrics = getMetrics();
    var cur_x = x;
    var i: usize = 0;

    while (i < text.len) {
        const b = text[i];
        if (b < 128) {
            i += 1;
            if (b == ' ') {
                cur_x += metrics.advances[' '] * scale;
                continue;
            }

            const first_c = metrics.first_cols[b];
            const last_c = metrics.last_cols[b];
            const glyph_w_px = @as(f32, @floatFromInt(last_c - first_c + 1));

            const col: f32 = @floatFromInt(b % 16);
            const row: f32 = @floatFromInt(b / 16);

            const px0 = col * 8.0 + @as(f32, @floatFromInt(first_c));
            const px1 = col * 8.0 + @as(f32, @floatFromInt(last_c + 1));
            const py0 = row * 16.0;
            const py1 = (row + 1.0) * 16.0;

            const uv_u0 = px0 / @as(f32, @floatFromInt(ATLAS_WIDTH));
            const uv_v0 = py0 / @as(f32, @floatFromInt(ATLAS_HEIGHT));
            const uv_u1 = px1 / @as(f32, @floatFromInt(ATLAS_WIDTH));
            const uv_v1 = py1 / @as(f32, @floatFromInt(ATLAS_HEIGHT));

            const char_w = glyph_w_px * scale;
            const char_h = 16.0 * scale;
            const x0 = cur_x;
            const y0 = y;
            const x1 = cur_x + char_w;
            const y1 = y + char_h;

            const half_w = char_w * 0.5;
            const half_h = char_h * 0.5;

            // Mode = 1.0 for font glyph
            const p = [4]f32{ 0.0, 0.0, 1.0, 0.0 };
            const bcol = [4]f32{ 0.0, 0.0, 0.0, 0.0 };

            try vertices.append(allocator, UIVertex{
                .position = .{ x0, y0 },
                .tex_coord = .{ uv_u0, uv_v0 },
                .local_pos = .{ -half_w, -half_h },
                .half_size = .{ half_w, half_h },
                .color = color,
                .border_color = bcol,
                .params = p,
            });
            try vertices.append(allocator, UIVertex{
                .position = .{ x1, y0 },
                .tex_coord = .{ uv_u1, uv_v0 },
                .local_pos = .{ half_w, -half_h },
                .half_size = .{ half_w, half_h },
                .color = color,
                .border_color = bcol,
                .params = p,
            });
            try vertices.append(allocator, UIVertex{
                .position = .{ x1, y1 },
                .tex_coord = .{ uv_u1, uv_v1 },
                .local_pos = .{ half_w, half_h },
                .half_size = .{ half_w, half_h },
                .color = color,
                .border_color = bcol,
                .params = p,
            });

            try vertices.append(allocator, UIVertex{
                .position = .{ x0, y0 },
                .tex_coord = .{ uv_u0, uv_v0 },
                .local_pos = .{ -half_w, -half_h },
                .half_size = .{ half_w, half_h },
                .color = color,
                .border_color = bcol,
                .params = p,
            });
            try vertices.append(allocator, UIVertex{
                .position = .{ x1, y1 },
                .tex_coord = .{ uv_u1, uv_v1 },
                .local_pos = .{ half_w, half_h },
                .half_size = .{ half_w, half_h },
                .color = color,
                .border_color = bcol,
                .params = p,
            });
            try vertices.append(allocator, UIVertex{
                .position = .{ x0, y1 },
                .tex_coord = .{ uv_u0, uv_v1 },
                .local_pos = .{ -half_w, half_h },
                .half_size = .{ half_w, half_h },
                .color = color,
                .border_color = bcol,
                .params = p,
            });

            cur_x += metrics.advances[b] * scale;
        } else {
            const seq_len = std.unicode.utf8ByteSequenceLength(b) catch 1;
            i += seq_len;
            cur_x += 10.0 * scale;
        }
    }
}
