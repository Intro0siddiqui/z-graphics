const std = @import("std");

pub const UIVertex = extern struct {
    position: [2]f32, // screen coordinates in pixels (x, y)
    tex_coord: [2]f32, // (u, v) coordinates in texture atlas
    local_pos: [2]f32, // local coordinates relative to quad center: [-half_w, -half_h]..[half_w, half_h]
    half_size: [2]f32, // half-width and half-height (w/2, h/2)
    color: [4]f32, // fill RGBA color
    border_color: [4]f32, // border RGBA color
    params: [4]f32, // x: corner_radius, y: border_width, z: mode (0=SDF shape, 1=font glyph, 2=textured quad), w: unused
};

pub const raw_font_data = @embedFile("font_raw.bin");

pub const ATLAS_WIDTH: u32 = 128;
pub const ATLAS_HEIGHT: u32 = 256;
pub const GLYPH_WIDTH: u32 = 8;
pub const GLYPH_HEIGHT: u32 = 16;
pub const GLYPHS_PER_ROW: u32 = 16;
pub const GLYPH_ROWS: u32 = 16;

pub const FontMetrics = struct {
    widths: [256]f32,

    pub fn init() FontMetrics {
        var metrics: FontMetrics = undefined;
        for (0..256) |c_idx| {
            const c: u8 = @intCast(c_idx);
            if (c == ' ') {
                metrics.widths[c_idx] = 5.0;
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
                const w = @as(f32, @floatFromInt(last_col.? - first + 2));
                metrics.widths[c_idx] = @min(8.0, @max(4.0, w));
            } else {
                metrics.widths[c_idx] = 6.0;
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

pub fn generateAtlasRGBA() [ATLAS_WIDTH * ATLAS_HEIGHT * 4]u8 {
    var pixels: [ATLAS_WIDTH * ATLAS_HEIGHT * 4]u8 = [_]u8{0} ** (ATLAS_WIDTH * ATLAS_HEIGHT * 4);

    for (0..256) |c_idx| {
        const col: u32 = @intCast(c_idx % GLYPHS_PER_ROW);
        const row: u32 = @intCast(c_idx / GLYPHS_PER_ROW);
        const glyph_offset = c_idx * 16;
        const glyph_bytes = raw_font_data[glyph_offset .. glyph_offset + 16];

        for (glyph_bytes, 0..) |row_byte, y| {
            var x: u32 = 0;
            while (x < 8) : (x += 1) {
                const bit = (row_byte >> @intCast(7 - x)) & 1;
                const px = col * GLYPH_WIDTH + x;
                const py = row * GLYPH_HEIGHT + @as(u32, @intCast(y));
                const p_idx = (py * ATLAS_WIDTH + px) * 4;

                if (bit != 0) {
                    pixels[p_idx + 0] = 255;
                    pixels[p_idx + 1] = 255;
                    pixels[p_idx + 2] = 255;
                    pixels[p_idx + 3] = 255;
                } else {
                    pixels[p_idx + 0] = 0;
                    pixels[p_idx + 1] = 0;
                    pixels[p_idx + 2] = 0;
                    pixels[p_idx + 3] = 0;
                }
            }
        }
    }

    return pixels;
}

pub fn getTextWidth(text: []const u8, scale: f32) f32 {
    const metrics = getMetrics();
    var width: f32 = 0;
    var i: usize = 0;
    while (i < text.len) {
        const b = text[i];
        if (b < 128) {
            width += metrics.widths[b] * scale;
            i += 1;
        } else {
            // Basic UTF-8 skip (treat multi-byte glyphs as ~12px wide icon)
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
                cur_x += metrics.widths[' '] * scale;
                continue;
            }

            const col: f32 = @floatFromInt(b % 16);
            const row: f32 = @floatFromInt(b / 16);

            const uv_u0 = (col * 8.0) / @as(f32, @floatFromInt(ATLAS_WIDTH));
            const uv_v0 = (row * 16.0) / @as(f32, @floatFromInt(ATLAS_HEIGHT));
            const uv_u1 = ((col + 1.0) * 8.0) / @as(f32, @floatFromInt(ATLAS_WIDTH));
            const uv_v1 = ((row + 1.0) * 16.0) / @as(f32, @floatFromInt(ATLAS_HEIGHT));

            const char_w = 8.0 * scale;
            const char_h = 16.0 * scale;
            const x0 = cur_x;
            const y0 = y;
            const x1 = cur_x + char_w;
            const y1 = y + char_h;

            const half_w = char_w * 0.5;
            const half_h = char_h * 0.5;

            // 2 Triangles for the glyph quad (Mode = 1.0 for font glyph)
            const p = [4]f32{ 0.0, 0.0, 1.0, 0.0 }; // mode = 1.0
            const bcol = [4]f32{ 0.0, 0.0, 0.0, 0.0 };

            // Triangle 1: (x0, y0), (x1, y0), (x1, y1)
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

            // Triangle 2: (x0, y0), (x1, y1), (x0, y1)
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

            cur_x += metrics.widths[b] * scale;
        } else {
            // UTF-8 multibyte character: advance by icon width
            const seq_len = std.unicode.utf8ByteSequenceLength(b) catch 1;
            i += seq_len;
            cur_x += 12.0 * scale;
        }
    }
}
