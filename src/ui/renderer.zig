const std = @import("std");
const zgraphics = @import("lib");
const shaders = @import("shaders");
const font = @import("font.zig");
const state_mod = @import("state.zig");

pub var global_ui_renderer: ?*UIRenderer = null;

pub fn setGlobalUIRenderer(renderer: ?*UIRenderer) void {
    global_ui_renderer = renderer;
}

pub fn wpeTextureCallback(tex: ?zgraphics.ZawraGraphicsTexture) callconv(.c) void {
    if (global_ui_renderer) |renderer| {
        renderer.setWpeTexture(tex);
    }
}

pub const UIRenderer = struct {
    surface: zgraphics.ZawraGraphicsHandle,
    pipeline: zgraphics.ZawraGraphicsPipeline,
    vert_module: zgraphics.ZawraGraphicsShaderModule,
    frag_module: zgraphics.ZawraGraphicsShaderModule,
    font_texture: zgraphics.ZawraGraphicsTexture,
    vertex_buffer: zgraphics.ZawraGraphicsBuffer,
    wpe_texture: ?zgraphics.ZawraGraphicsTexture = null,

    vertices: std.ArrayList(font.UIVertex) = .empty,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, surface: zgraphics.ZawraGraphicsHandle) !UIRenderer {
        // 1. Compile shader modules
        const vert_module = zgraphics.ZG_CreateShaderModule(
            surface,
            shaders.ui_sdf_vert.ptr,
            shaders.ui_sdf_vert.len,
        ) orelse return error.ShaderModuleCreationFailed;
        errdefer zgraphics.ZG_DestroyShaderModule(surface, vert_module);

        const frag_module = zgraphics.ZG_CreateShaderModule(
            surface,
            shaders.ui_sdf_frag.ptr,
            shaders.ui_sdf_frag.len,
        ) orelse return error.ShaderModuleCreationFailed;
        errdefer zgraphics.ZG_DestroyShaderModule(surface, frag_module);

        // 2. Vertex layout bindings & attributes
        // Stride: 80 bytes (7 attributes)
        const bindings = [_]zgraphics.ZawraGraphicsVertexBinding{
            .{ .binding = 0, .stride = @sizeOf(font.UIVertex), .input_rate = 0 },
        };
        const r32g32_sfloat: u32 = 101; // VK_FORMAT_R32G32_SFLOAT
        const r32g32b32a32_sfloat: u32 = 107; // VK_FORMAT_R32G32B32A32_SFLOAT

        const attributes = [_]zgraphics.ZawraGraphicsVertexAttribute{
            .{ .location = 0, .binding = 0, .format = r32g32_sfloat, .offset = @offsetOf(font.UIVertex, "position") },
            .{ .location = 1, .binding = 0, .format = r32g32_sfloat, .offset = @offsetOf(font.UIVertex, "tex_coord") },
            .{ .location = 2, .binding = 0, .format = r32g32_sfloat, .offset = @offsetOf(font.UIVertex, "local_pos") },
            .{ .location = 3, .binding = 0, .format = r32g32_sfloat, .offset = @offsetOf(font.UIVertex, "half_size") },
            .{ .location = 4, .binding = 0, .format = r32g32b32a32_sfloat, .offset = @offsetOf(font.UIVertex, "color") },
            .{ .location = 5, .binding = 0, .format = r32g32b32a32_sfloat, .offset = @offsetOf(font.UIVertex, "border_color") },
            .{ .location = 6, .binding = 0, .format = r32g32b32a32_sfloat, .offset = @offsetOf(font.UIVertex, "params") },
        };

        // 3. Pipeline blend description for premultiplied alpha blending
        const pipeline_desc = zgraphics.PipelineDesc{
            .vertex_shader = shaders.ui_sdf_vert.ptr,
            .vertex_shader_len = shaders.ui_sdf_vert.len,
            .pixel_shader = shaders.ui_sdf_frag.ptr,
            .pixel_shader_len = shaders.ui_sdf_frag.len,
            .blend_enable = 1,
            .src_color_blend_factor = 6, // VK_BLEND_FACTOR_SRC_ALPHA
            .dst_color_blend_factor = 7, // VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA
            .color_blend_op = 0, // VK_BLEND_OP_ADD
            .src_alpha_blend_factor = 1, // VK_BLEND_FACTOR_ONE
            .dst_alpha_blend_factor = 7, // VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA
            .alpha_blend_op = 0, // VK_BLEND_OP_ADD
        };

        const pipeline = zgraphics.ZG_CreatePipelineWithLayoutDesc(
            surface,
            vert_module,
            frag_module,
            &bindings,
            bindings.len,
            &attributes,
            attributes.len,
            &pipeline_desc,
        ) orelse return error.PipelineCreationFailed;
        errdefer zgraphics.ZG_DestroyPipeline(surface, pipeline);

        // 4. Create and upload font atlas texture
        const tex_desc = zgraphics.ZawraGraphicsTextureDesc{
            .format = .R8G8B8A8_Unorm,
            .width = font.ATLAS_WIDTH,
            .height = font.ATLAS_HEIGHT,
            .external_handle = null,
        };
        const font_texture = zgraphics.ZG_CreateTexture(surface, &tex_desc) orelse return error.TextureCreationFailed;
        errdefer zgraphics.ZG_DestroyTexture(surface, font_texture);

        const atlas_pixels = font.getAtlasRGBA();
        _ = zgraphics.ZG_UploadTexture(surface, font_texture, atlas_pixels.ptr, atlas_pixels.len);
        _ = zgraphics.ZG_SetTextureParams(surface, font_texture, 0, 0, 0, 0); // Linear/Repeat

        // 5. Create vertex buffer (supports up to 16384 vertices = ~2730 quads)
        const vb_size: usize = 16384 * @sizeOf(font.UIVertex);
        const vertex_buffer = zgraphics.ZG_CreateBuffer(surface, vb_size, .Vertex) orelse return error.BufferCreationFailed;

        // Register texture setter callback with zgraphics
        zgraphics.ZG_RegisterWpeTextureSetter(&wpeTextureCallback);

        return UIRenderer{
            .surface = surface,
            .pipeline = pipeline,
            .vert_module = vert_module,
            .frag_module = frag_module,
            .font_texture = font_texture,
            .vertex_buffer = vertex_buffer,
            .vertices = .empty,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *UIRenderer) void {
        zgraphics.ZG_RegisterWpeTextureSetter(null);
        if (global_ui_renderer == self) {
            global_ui_renderer = null;
        }
        self.vertices.deinit(self.allocator);
        zgraphics.ZG_DestroyBuffer(self.surface, self.vertex_buffer);
        zgraphics.ZG_DestroyTexture(self.surface, self.font_texture);
        zgraphics.ZG_DestroyPipeline(self.surface, self.pipeline);
        zgraphics.ZG_DestroyShaderModule(self.surface, self.vert_module);
        zgraphics.ZG_DestroyShaderModule(self.surface, self.frag_module);
    }

    pub fn setWpeTexture(self: *UIRenderer, texture: ?zgraphics.ZawraGraphicsTexture) void {
        self.wpe_texture = texture;
    }

    pub fn bindWpeDMABuf(self: *UIRenderer, fd: i32, width: u32, height: u32) bool {
        return zgraphics.ZG_BindWpeDMABuf(self.surface, fd, width, height);
    }

    fn appendQuad(
        self: *UIRenderer,
        x0: f32,
        y0: f32,
        x1: f32,
        y1: f32,
        half_w: f32,
        half_h: f32,
        dummy_uv: [2]f32,
        fill_color: [4]f32,
        border_color: [4]f32,
        params: [4]f32,
    ) void {
        self.vertices.append(self.allocator, font.UIVertex{
            .position = .{ x0, y0 },
            .tex_coord = dummy_uv,
            .local_pos = .{ -half_w, -half_h },
            .half_size = .{ half_w, half_h },
            .color = fill_color,
            .border_color = border_color,
            .params = params,
        }) catch return;
        self.vertices.append(self.allocator, font.UIVertex{
            .position = .{ x1, y0 },
            .tex_coord = dummy_uv,
            .local_pos = .{ half_w, -half_h },
            .half_size = .{ half_w, half_h },
            .color = fill_color,
            .border_color = border_color,
            .params = params,
        }) catch return;
        self.vertices.append(self.allocator, font.UIVertex{
            .position = .{ x1, y1 },
            .tex_coord = dummy_uv,
            .local_pos = .{ half_w, half_h },
            .half_size = .{ half_w, half_h },
            .color = fill_color,
            .border_color = border_color,
            .params = params,
        }) catch return;

        self.vertices.append(self.allocator, font.UIVertex{
            .position = .{ x0, y0 },
            .tex_coord = dummy_uv,
            .local_pos = .{ -half_w, -half_h },
            .half_size = .{ half_w, half_h },
            .color = fill_color,
            .border_color = border_color,
            .params = params,
        }) catch return;
        self.vertices.append(self.allocator, font.UIVertex{
            .position = .{ x1, y1 },
            .tex_coord = dummy_uv,
            .local_pos = .{ half_w, half_h },
            .half_size = .{ half_w, half_h },
            .color = fill_color,
            .border_color = border_color,
            .params = params,
        }) catch return;
        self.vertices.append(self.allocator, font.UIVertex{
            .position = .{ x0, y1 },
            .tex_coord = dummy_uv,
            .local_pos = .{ -half_w, half_h },
            .half_size = .{ half_w, half_h },
            .color = fill_color,
            .border_color = border_color,
            .params = params,
        }) catch return;
    }

    pub fn drawRoundedRect(
        self: *UIRenderer,
        rect: state_mod.Rect,
        radius: f32,
        fill_color: [4]f32,
        border_width: f32,
        border_color: [4]f32,
    ) void {
        const half_w = rect.w * 0.5;
        const half_h = rect.h * 0.5;
        const x0 = rect.x;
        const y0 = rect.y;
        const x1 = rect.x + rect.w;
        const y1 = rect.y + rect.h;
        const params = [4]f32{ radius, border_width, 0.0, 0.0 }; // mode = 0 (SDF shape)
        const dummy_uv = [2]f32{ 0.0, 0.0 };

        self.appendQuad(x0, y0, x1, y1, half_w, half_h, dummy_uv, fill_color, border_color, params);
    }

    pub fn drawGlassCard(
        self: *UIRenderer,
        rect: state_mod.Rect,
        radius: f32,
        fill_color: [4]f32,
        border_width: f32,
        border_color: [4]f32,
    ) void {
        const half_w = rect.w * 0.5;
        const half_h = rect.h * 0.5;
        const x0 = rect.x;
        const y0 = rect.y;
        const x1 = rect.x + rect.w;
        const y1 = rect.y + rect.h;
        const params = [4]f32{ radius, border_width, 4.0, 0.0 }; // mode = 4 (Neumorphic Glass)
        const dummy_uv = [2]f32{ 0.0, 0.0 };

        self.appendQuad(x0, y0, x1, y1, half_w, half_h, dummy_uv, fill_color, border_color, params);
    }

    pub fn drawHalo(
        self: *UIRenderer,
        rect: state_mod.Rect,
        radius: f32,
        glow_color: [4]f32,
        spread: f32,
    ) void {
        const half_w = rect.w * 0.5 + spread;
        const half_h = rect.h * 0.5 + spread;
        const x0 = rect.x - spread;
        const y0 = rect.y - spread;
        const x1 = rect.x + rect.w + spread;
        const y1 = rect.y + rect.h + spread;
        const params = [4]f32{ radius, 0.0, 3.0, spread }; // mode = 3 (Halo glow)
        const dummy_uv = [2]f32{ 0.0, 0.0 };
        const fill_col = [4]f32{ glow_color[0], glow_color[1], glow_color[2], 0.0 };

        self.appendQuad(x0, y0, x1, y1, half_w, half_h, dummy_uv, fill_col, glow_color, params);
    }

    pub fn drawRadialGlow(
        self: *UIRenderer,
        rect: state_mod.Rect,
        radius: f32,
        glow_color: [4]f32,
        spread: f32,
    ) void {
        const half_w = rect.w * 0.5 + spread;
        const half_h = rect.h * 0.5 + spread;
        const x0 = rect.x - spread;
        const y0 = rect.y - spread;
        const x1 = rect.x + rect.w + spread;
        const y1 = rect.y + rect.h + spread;
        const params = [4]f32{ radius, 0.0, 3.0, spread }; // mode = 3 (Halo glow)
        const dummy_uv = [2]f32{ 0.0, 0.0 };
        const fill_col = [4]f32{ glow_color[0], glow_color[1], glow_color[2], glow_color[3] * 0.6 };

        self.appendQuad(x0, y0, x1, y1, half_w, half_h, dummy_uv, fill_col, glow_color, params);
    }

    pub fn drawDropShadow(
        self: *UIRenderer,
        rect: state_mod.Rect,
        radius: f32,
        offset_y: f32,
        spread: f32,
        opacity: f32,
    ) void {
        const shadow_rect = state_mod.Rect{
            .x = rect.x,
            .y = rect.y + offset_y,
            .w = rect.w,
            .h = rect.h,
        };
        const shadow_color = [4]f32{ 0.0, 0.0, 0.0, opacity };
        self.drawHalo(shadow_rect, radius, shadow_color, spread);
    }

    pub fn drawTexturedQuad(
        self: *UIRenderer,
        rect: state_mod.Rect,
        uv: font.AtlasUV,
        tint: [4]f32,
        radius: f32,
    ) void {
        const half_w = rect.w * 0.5;
        const half_h = rect.h * 0.5;
        const x0 = rect.x;
        const y0 = rect.y;
        const x1 = rect.x + rect.w;
        const y1 = rect.y + rect.h;
        const params = [4]f32{ radius, 0.0, 2.0, 0.0 }; // mode = 2 (textured quad)
        const bcol = [4]f32{ 0, 0, 0, 0 };

        // Triangle 1: (x0, y0), (x1, y0), (x1, y1)
        self.vertices.append(self.allocator, font.UIVertex{
            .position = .{ x0, y0 },
            .tex_coord = .{ uv.u0, uv.v0 },
            .local_pos = .{ -half_w, -half_h },
            .half_size = .{ half_w, half_h },
            .color = tint,
            .border_color = bcol,
            .params = params,
        }) catch return;
        self.vertices.append(self.allocator, font.UIVertex{
            .position = .{ x1, y0 },
            .tex_coord = .{ uv.u1, uv.v0 },
            .local_pos = .{ half_w, -half_h },
            .half_size = .{ half_w, half_h },
            .color = tint,
            .border_color = bcol,
            .params = params,
        }) catch return;
        self.vertices.append(self.allocator, font.UIVertex{
            .position = .{ x1, y1 },
            .tex_coord = .{ uv.u1, uv.v1 },
            .local_pos = .{ half_w, half_h },
            .half_size = .{ half_w, half_h },
            .color = tint,
            .border_color = bcol,
            .params = params,
        }) catch return;

        // Triangle 2: (x0, y0), (x1, y1), (x0, y1)
        self.vertices.append(self.allocator, font.UIVertex{
            .position = .{ x0, y0 },
            .tex_coord = .{ uv.u0, uv.v0 },
            .local_pos = .{ -half_w, -half_h },
            .half_size = .{ half_w, half_h },
            .color = tint,
            .border_color = bcol,
            .params = params,
        }) catch return;
        self.vertices.append(self.allocator, font.UIVertex{
            .position = .{ x1, y1 },
            .tex_coord = .{ uv.u1, uv.v1 },
            .local_pos = .{ half_w, half_h },
            .half_size = .{ half_w, half_h },
            .color = tint,
            .border_color = bcol,
            .params = params,
        }) catch return;
        self.vertices.append(self.allocator, font.UIVertex{
            .position = .{ x0, y1 },
            .tex_coord = .{ uv.u0, uv.v1 },
            .local_pos = .{ -half_w, half_h },
            .half_size = .{ half_w, half_h },
            .color = tint,
            .border_color = bcol,
            .params = params,
        }) catch return;
    }

    pub fn drawText(self: *UIRenderer, text: []const u8, x: f32, y: f32, color: [4]f32, scale: f32) void {
        font.appendTextQuads(self.allocator, &self.vertices, text, x, y, color, scale) catch return;
    }

    pub fn drawZawraLogo(self: *UIRenderer, rect: state_mod.Rect) void {
        const logo_col: [4]f32 = .{ 0.796, 0.835, 0.882, 1.0 };
        const thick: f32 = 2.0;

        // Top bar
        self.drawRoundedRect(
            state_mod.Rect{ .x = rect.x + 4, .y = rect.y + 4, .w = 16, .h = thick },
            1.0,
            logo_col,
            0.0,
            .{ 0, 0, 0, 0 },
        );
        // Bottom bar
        self.drawRoundedRect(
            state_mod.Rect{ .x = rect.x + 4, .y = rect.y + 20, .w = 16, .h = thick },
            1.0,
            logo_col,
            0.0,
            .{ 0, 0, 0, 0 },
        );
        // Left diagonal
        self.drawRoundedRect(
            state_mod.Rect{ .x = rect.x + 8, .y = rect.y + 6, .w = thick, .h = 12 },
            1.0,
            logo_col,
            0.0,
            .{ 0, 0, 0, 0 },
        );
        // Right diagonal
        self.drawRoundedRect(
            state_mod.Rect{ .x = rect.x + 14, .y = rect.y + 6, .w = thick, .h = 12 },
            1.0,
            logo_col,
            0.0,
            .{ 0, 0, 0, 0 },
        );
    }

    pub fn drawLargeZawraLogo(self: *UIRenderer, rect: state_mod.Rect) void {
        const logo_col = state_mod.Color.text_gold;
        const thick: f32 = 4.0;
        const pad_x = rect.w * 0.15;
        const w = rect.w - 2.0 * pad_x;

        // Top horizontal bar
        self.drawRoundedRect(
            state_mod.Rect{ .x = rect.x + pad_x, .y = rect.y + 12.0, .w = w, .h = thick },
            2.0,
            logo_col,
            0.0,
            .{ 0, 0, 0, 0 },
        );
        // Bottom horizontal bar
        self.drawRoundedRect(
            state_mod.Rect{ .x = rect.x + pad_x, .y = rect.y + rect.h - 16.0, .w = w, .h = thick },
            2.0,
            logo_col,
            0.0,
            .{ 0, 0, 0, 0 },
        );
        // Left diagonal band
        self.drawRoundedRect(
            state_mod.Rect{ .x = rect.x + rect.w * 0.32, .y = rect.y + 18.0, .w = thick, .h = rect.h - 36.0 },
            2.0,
            logo_col,
            0.0,
            .{ 0, 0, 0, 0 },
        );
        // Right diagonal band
        self.drawRoundedRect(
            state_mod.Rect{ .x = rect.x + rect.w * 0.62, .y = rect.y + 18.0, .w = thick, .h = rect.h - 36.0 },
            2.0,
            logo_col,
            0.0,
            .{ 0, 0, 0, 0 },
        );
    }

    pub fn drawSearchIcon(self: *UIRenderer, rect: state_mod.Rect) void {
        const icon_col = state_mod.Color.text_muted;
        // Lens circle (10px diameter, 1.5px border)
        self.drawRoundedRect(
            state_mod.Rect{ .x = rect.x, .y = rect.y, .w = 10, .h = 10 },
            5.0,
            .{ 0, 0, 0, 0 },
            1.5,
            icon_col,
        );
        // Lens handle stem
        self.drawRoundedRect(
            state_mod.Rect{ .x = rect.x + 8, .y = rect.y + 8, .w = 5, .h = 1.5 },
            0.75,
            icon_col,
            0.0,
            .{ 0, 0, 0, 0 },
        );
    }

    pub fn drawClockIcon(self: *UIRenderer, rect: state_mod.Rect) void {
        const icon_col = state_mod.Color.text_muted;
        // Clock outer circle (14px diameter)
        self.drawRoundedRect(
            state_mod.Rect{ .x = rect.x, .y = rect.y, .w = 14.0, .h = 14.0 },
            7.0,
            .{ 0, 0, 0, 0 },
            1.5,
            icon_col,
        );
        // Hour hand: vertical line from center (7, 7) up to (7, 3.5)
        self.drawRoundedRect(
            state_mod.Rect{ .x = rect.x + 6.25, .y = rect.y + 3.5, .w = 1.5, .h = 4.0 },
            0.75,
            icon_col,
            0.0,
            .{ 0, 0, 0, 0 },
        );
        // Minute hand: horizontal line from center (7, 7) right to (11, 7)
        self.drawRoundedRect(
            state_mod.Rect{ .x = rect.x + 6.25, .y = rect.y + 6.25, .w = 4.5, .h = 1.5 },
            0.75,
            icon_col,
            0.0,
            .{ 0, 0, 0, 0 },
        );
    }

    pub fn render(self: *UIRenderer, state: *const state_mod.ShellState) void {
        self.vertices.clearRetainingCapacity();

        const active_tab = state.getActiveTabConst();
        const is_start = if (active_tab) |tab| state_mod.isStartPage(tab.getUrl()) else true;
        const active_tex = self.wpe_texture orelse zgraphics.ZG_GetWpeTexture();
        var wpe_vertex_count: u32 = 0;

        // ── 1. Viewport: WPE DMA-BUF Live Quad vs Start Page ─────────────────────────
        const vp = state.layout.viewport_rect;
        if (!is_start and active_tex != null) {
            // Draw live WPE WebKit frame as textured quad (Mode 2)
            const half_w = vp.w * 0.5;
            const half_h = vp.h * 0.5;
            const p = [4]f32{ 0.0, 0.0, 2.0, 0.0 }; // mode = 2.0 (textured quad)
            const white = [4]f32{ 1.0, 1.0, 1.0, 1.0 };
            const bcol = [4]f32{ 0, 0, 0, 0 };

            self.vertices.append(self.allocator, font.UIVertex{ .position = .{ vp.x, vp.y }, .tex_coord = .{ 0, 0 }, .local_pos = .{ -half_w, -half_h }, .half_size = .{ half_w, half_h }, .color = white, .border_color = bcol, .params = p }) catch return;
            self.vertices.append(self.allocator, font.UIVertex{ .position = .{ vp.x + vp.w, vp.y }, .tex_coord = .{ 1, 0 }, .local_pos = .{ half_w, -half_h }, .half_size = .{ half_w, half_h }, .color = white, .border_color = bcol, .params = p }) catch return;
            self.vertices.append(self.allocator, font.UIVertex{ .position = .{ vp.x + vp.w, vp.y + vp.h }, .tex_coord = .{ 1, 1 }, .local_pos = .{ half_w, half_h }, .half_size = .{ half_w, half_h }, .color = white, .border_color = bcol, .params = p }) catch return;
            self.vertices.append(self.allocator, font.UIVertex{ .position = .{ vp.x, vp.y }, .tex_coord = .{ 0, 0 }, .local_pos = .{ -half_w, -half_h }, .half_size = .{ half_w, half_h }, .color = white, .border_color = bcol, .params = p }) catch return;
            self.vertices.append(self.allocator, font.UIVertex{ .position = .{ vp.x + vp.w, vp.y + vp.h }, .tex_coord = .{ 1, 1 }, .local_pos = .{ half_w, half_h }, .half_size = .{ half_w, half_h }, .color = white, .border_color = bcol, .params = p }) catch return;
            self.vertices.append(self.allocator, font.UIVertex{ .position = .{ vp.x, vp.y + vp.h }, .tex_coord = .{ 0, 1 }, .local_pos = .{ -half_w, half_h }, .half_size = .{ half_w, half_h }, .color = white, .border_color = bcol, .params = p }) catch return;
            wpe_vertex_count = 6;
        } else if (!is_start) {
            // Dark viewport placeholder while connecting to WPE
            self.drawRoundedRect(vp, 0.0, state_mod.Color.bg_dark, 0.0, .{ 0, 0, 0, 0 });
            self.drawGlassCard(
                state_mod.Rect{ .x = vp.x + 32.0, .y = vp.y + 32.0, .w = vp.w - 64.0, .h = vp.h - 64.0 },
                12.0,
                state_mod.Color.sidebar_bg,
                1.0,
                state_mod.Color.border_subtle,
            );
            self.drawText("Connecting to live WebKit engine...", vp.x + 56.0, vp.y + 64.0, state_mod.Color.text_white, 1.1);
            if (active_tab) |tab| {
                self.drawText(tab.url, vp.x + 56.0, vp.y + 96.0, state_mod.Color.accent_amber, 0.85);
            }
        } else {
            // ── 1. Start Page Viewport Canvas (zawra://start) ────────────────────────
            // Draw glowing dark cybernetic circuit board texture across viewport
            self.drawTexturedQuad(vp, font.AtlasUV.circuit_bg, .{ 1.0, 1.0, 1.0, 1.0 }, 0.0);

            // Ambient warm radial amber glow behind 3D hero emblem
            self.drawRadialGlow(state.layout.start_logo_rect, 48.0, state_mod.Color.accent_amber, 55.0);

            // 3D Hero Emblem (~96x96)
            self.drawTexturedQuad(state.layout.start_logo_rect, font.AtlasUV.hero_emblem, .{ 1.0, 1.0, 1.0, 1.0 }, 0.0);

            // Centered Bold Typography: "Z A W R A"
            self.drawText("Z A W R A", state.layout.start_title_pos[0], state.layout.start_title_pos[1], state_mod.Color.text_white, 2.0);

            // Recessed Search HUD Container (interactive with active focus halo & border)
            const hud = state.layout.start_search_rect;
            if (state.focus == .search_hud) {
                self.drawHalo(hud, 8.0, state_mod.Color.accent_amber, 6.0);
                self.drawRoundedRect(hud, 8.0, .{ 0.04, 0.06, 0.10, 0.96 }, 1.5, state_mod.Color.accent_amber);
            } else {
                self.drawDropShadow(hud, 8.0, 4.0, 10.0, 0.45);
                self.drawRoundedRect(hud, 8.0, .{ 0.04, 0.06, 0.10, 0.94 }, 1.0, .{ 1.0, 1.0, 1.0, 0.10 });
            }
            self.drawSearchIcon(state.layout.start_search_icon_rect);

            // Render typed search query or placeholder + cursor
            const search_text = state.search_hud_input.getText();
            const tx = state.layout.start_search_text_pos[0];
            const ty = state.layout.start_search_text_pos[1];
            if (search_text.len > 0) {
                self.drawText(search_text, tx, ty, state_mod.Color.text_white, 0.85);
                if (state.focus == .search_hud) {
                    const tw = font.getTextWidth(search_text, 0.85);
                    self.drawText("|", tx + tw + 2.0, ty, state_mod.Color.accent_amber, 0.85);
                }
            } else {
                if (state.focus == .search_hud) {
                    self.drawText("|", tx, ty, state_mod.Color.accent_amber, 0.85);
                    self.drawText(state.search_hud_input.placeholder, tx + 8.0, ty, state_mod.Color.text_muted, 0.85);
                } else {
                    self.drawText(state.search_hud_input.placeholder, tx, ty, state_mod.Color.text_muted, 0.85);
                }
            }

            // Embedded Pill Toggles inside Search HUD:
            // Google Pill
            const gp = state.layout.pill_google_rect;
            if (state.search_engine == .google) {
                self.drawHalo(gp, 14.0, state_mod.Color.accent_amber, 6.0);
                self.drawRoundedRect(gp, 14.0, .{ 0.90, 0.60, 0.22, 0.16 }, 1.5, state_mod.Color.accent_amber);
                self.drawText("Google", gp.x + 15.0, gp.y + 7.0, state_mod.Color.text_white, 0.8);
            } else {
                self.drawRoundedRect(gp, 14.0, .{ 1.0, 1.0, 1.0, 0.04 }, 1.0, state_mod.Color.border_subtle);
                self.drawText("Google", gp.x + 15.0, gp.y + 7.0, state_mod.Color.text_muted, 0.8);
            }

            // DuckDuckGo Pill
            const dp = state.layout.pill_duck_rect;
            if (state.search_engine == .duckduckgo) {
                self.drawHalo(dp, 14.0, state_mod.Color.accent_amber, 6.0);
                self.drawRoundedRect(dp, 14.0, .{ 0.90, 0.60, 0.22, 0.16 }, 1.5, state_mod.Color.accent_amber);
                self.drawText("DuckDuckGo", dp.x + 10.0, dp.y + 7.0, state_mod.Color.text_white, 0.8);
            } else {
                self.drawRoundedRect(dp, 14.0, .{ 1.0, 1.0, 1.0, 0.04 }, 1.0, state_mod.Color.border_subtle);
                self.drawText("DuckDuckGo", dp.x + 10.0, dp.y + 7.0, state_mod.Color.text_muted, 0.8);
            }

            // 4 Neumorphic Glass Quick-Dial Cards
            const card_data = [_]struct { title: []const u8, uv: font.AtlasUV }{
                .{ .title = "GitHub", .uv = font.AtlasUV.icon_github },
                .{ .title = "Rust Docs", .uv = font.AtlasUV.icon_rust },
                .{ .title = "Wayland Specs", .uv = font.AtlasUV.icon_wayland },
                .{ .title = "Hajr Dev", .uv = font.AtlasUV.icon_hajr },
            };

            for (card_data, 0..) |cinfo, i| {
                const srect = state.layout.shortcut_rects[i];
                const shover = state.shortcuts[i].hovered;

                // Soft drop shadow
                self.drawDropShadow(srect, 12.0, 6.0, 12.0, 0.4);

                // Neumorphic glass card (frosted translucent glass fill + beveled top-left rim highlight)
                self.drawGlassCard(
                    srect,
                    12.0,
                    if (shover) .{ 1.0, 1.0, 1.0, 0.09 } else .{ 1.0, 1.0, 1.0, 0.05 },
                    1.0,
                    if (shover) state_mod.Color.accent_amber else .{ 1.0, 1.0, 1.0, 0.15 },
                );

                // Centered icon (36x36)
                const icon_x = srect.x + (srect.w - 36.0) * 0.5;
                const icon_y = srect.y + 16.0;
                self.drawTexturedQuad(state_mod.Rect{ .x = icon_x, .y = icon_y, .w = 36.0, .h = 36.0 }, cinfo.uv, .{ 1.0, 1.0, 1.0, 1.0 }, 0.0);

                // Centered title below icon
                const tw = font.getTextWidth(cinfo.title, 0.82);
                const tx_c = srect.x + (srect.w - tw) * 0.5;
                self.drawText(cinfo.title, tx_c, srect.y + 68.0, if (shover) state_mod.Color.text_gold else state_mod.Color.text_white, 0.82);
            }

            // Bottom Right Icons: ✨ Sparkle & Toggle
            self.drawTexturedQuad(state.layout.sparkle_icon_rect, font.AtlasUV.icon_sparkle, .{ 1.0, 1.0, 1.0, 0.85 }, 0.0);
            self.drawTexturedQuad(state.layout.toggle_icon_rect, font.AtlasUV.icon_toggle, .{ 1.0, 1.0, 1.0, 0.85 }, 0.0);
        }

        // ── 2. Sidebar Background & Border ───────────────────────────────────────────
        self.drawRoundedRect(
            state.layout.sidebar_rect,
            0.0,
            state_mod.Color.sidebar_bg,
            1.0,
            state_mod.Color.border_subtle,
        );

        // ── 3. Window Control Dots (12px diameter) ──────────────────────────────────
        const dot_r = 6.0;
        self.drawRoundedRect(state.layout.dot_close_rect, dot_r, state_mod.Color.dot_close, 0.0, .{ 0, 0, 0, 0 });
        self.drawRoundedRect(state.layout.dot_minimize_rect, dot_r, state_mod.Color.dot_minimize, 0.0, .{ 0, 0, 0, 0 });
        self.drawRoundedRect(state.layout.dot_maximize_rect, dot_r, state_mod.Color.dot_maximize, 0.0, .{ 0, 0, 0, 0 });

        // ── 4. Header Area (Zawra emblem ~26x26 + bold white "Zawra") ────────────────
        self.drawTexturedQuad(state.layout.header_logo_rect, font.AtlasUV.logo_sidebar, .{ 1.0, 1.0, 1.0, 1.0 }, 0.0);
        self.drawText("Zawra", state.layout.header_title_pos[0], state.layout.header_title_pos[1], state_mod.Color.text_white, 1.25);

        // ── 5. Nav Cluster: Back ←, Forward →, Reload ↻ ─────────────────────────────
        self.drawRoundedRect(state.layout.nav_back_rect, 4.0, state_mod.Color.bg_dark, 1.0, state_mod.Color.border_subtle);
        self.drawText("<", state.layout.nav_back_rect.x + 8.0, state.layout.nav_back_rect.y + 4.0, state_mod.Color.text_main, 0.85);

        self.drawRoundedRect(state.layout.nav_fwd_rect, 4.0, state_mod.Color.bg_dark, 1.0, state_mod.Color.border_subtle);
        self.drawText(">", state.layout.nav_fwd_rect.x + 8.0, state.layout.nav_fwd_rect.y + 4.0, state_mod.Color.text_main, 0.85);

        self.drawRoundedRect(state.layout.nav_reload_rect, 4.0, state_mod.Color.bg_dark, 1.0, state_mod.Color.border_subtle);
        self.drawText("r", state.layout.nav_reload_rect.x + 8.0, state.layout.nav_reload_rect.y + 4.0, state_mod.Color.text_main, 0.85);

        // ── 6. Omnibar / Address Container ──────────────────────────────────────────
        self.drawRoundedRect(
            state.layout.omnibar_rect,
            16.0,
            state_mod.Color.bg_dark,
            1.0,
            if (state.focus == .omnibar) state_mod.Color.accent_amber else state_mod.Color.border_subtle,
        );
        self.drawSearchIcon(state.layout.search_icon_rect);

        const omnibar_text = state.omnibar.getText();
        if (omnibar_text.len > 0) {
            self.drawText(omnibar_text, state.layout.address_text_pos[0], state.layout.address_text_pos[1], state_mod.Color.text_white, 0.82);
            if (state.focus == .omnibar) {
                const otw = font.getTextWidth(omnibar_text, 0.82);
                self.drawText("|", state.layout.address_text_pos[0] + otw + 2.0, state.layout.address_text_pos[1], state_mod.Color.accent_amber, 0.82);
            }
        } else {
            if (state.focus == .omnibar) {
                self.drawText("|", state.layout.address_text_pos[0], state.layout.address_text_pos[1], state_mod.Color.accent_amber, 0.82);
                self.drawText(state.omnibar.placeholder, state.layout.address_text_pos[0] + 8.0, state.layout.address_text_pos[1], state_mod.Color.text_muted, 0.82);
            } else {
                self.drawText(state.omnibar.placeholder, state.layout.address_text_pos[0], state.layout.address_text_pos[1], state_mod.Color.text_muted, 0.82);
            }
        }

        // ── 7. Navigation Explore Section ───────────────────────────────────────────
        self.drawText("Explore", state.layout.explore_heading_pos[0], state.layout.explore_heading_pos[1], state_mod.Color.text_muted, 0.75);

        for (state.explore_items, 0..) |item, i| {
            if (i < 4) {
                const irect = state.layout.explore_item_rects[i];
                if (item.active) {
                    self.drawRoundedRect(irect, 6.0, state_mod.Color.active_bg, 0.0, .{ 0, 0, 0, 0 });
                } else if (item.hovered) {
                    self.drawRoundedRect(irect, 6.0, state_mod.Color.hover_bg, 0.0, .{ 0, 0, 0, 0 });
                }

                const col = if (item.active) state_mod.Color.text_white else state_mod.Color.text_main;
                self.drawText(item.name, irect.x + 12.0, irect.y + 6.0, col, 0.82);
            }
        }

        // ── 8. Tabs Section ─────────────────────────────────────────────────────────
        self.drawText("Tabs", state.layout.tabs_heading_pos[0], state.layout.tabs_heading_pos[1], state_mod.Color.text_muted, 0.75);

        // Interactive [+] button next to Tabs heading
        const plus_rect = state.layout.tab_new_btn_rect;
        const plus_bg = if (state.tab_new_btn_hovered) state_mod.Color.hover_bg else state_mod.Color.pill_bg;
        const plus_border = if (state.tab_new_btn_hovered) state_mod.Color.accent_amber else state_mod.Color.border_subtle;
        self.drawRoundedRect(plus_rect, 4.0, plus_bg, 1.0, plus_border);
        self.drawText("+", plus_rect.x + 8.0, plus_rect.y + 2.0, if (state.tab_new_btn_hovered) state_mod.Color.text_gold else state_mod.Color.text_white, 0.85);

        for (state.tabs.items, 0..) |tab, i| {
            if (i < state.layout.tab_count) {
                const trect = state.layout.tab_rects[i];
                const crect = state.layout.tab_close_rects[i];

                if (tab.active) {
                    // Active Tab Capsule with glowing copper/amber halo outline (#e59a38)
                    self.drawHalo(trect, 8.0, state_mod.Color.accent_amber, 6.0);
                    self.drawRoundedRect(trect, 8.0, .{ 0.90, 0.60, 0.22, 0.15 }, 1.5, state_mod.Color.accent_amber);
                } else {
                    // Inactive tabs: subtle rounded rectangle pills with dark borders
                    const bg_col = if (tab.hovered) state_mod.Color.hover_bg else state_mod.Color.bg_dark;
                    const border_col = if (tab.hovered) state_mod.Color.border_pill else state_mod.Color.border_subtle;
                    self.drawRoundedRect(trect, 6.0, bg_col, 1.0, border_col);
                }

                // Tab Title (truncated to fit before close button)
                const col = if (tab.active) state_mod.Color.text_white else (if (tab.hovered) state_mod.Color.text_white else state_mod.Color.text_muted);
                const title_slice = if (tab.title.len > 20) tab.title[0..20] else tab.title;
                self.drawText(title_slice, trect.x + 10.0, trect.y + 8.0, col, 0.8);

                // Tab [x] Close button
                const close_bg = if (tab.close_hovered) state_mod.Color.tab_close_hover_bg else .{ 0, 0, 0, 0 };
                const close_border = if (tab.close_hovered) state_mod.Color.dot_close else .{ 0, 0, 0, 0 };
                self.drawRoundedRect(crect, 3.0, close_bg, if (tab.close_hovered) 1.0 else 0.0, close_border);
                self.drawText("x", crect.x + 4.5, crect.y + 1.0, if (tab.close_hovered) state_mod.Color.text_white else state_mod.Color.text_muted, 0.75);
            }
        }

        // ── 9. Sidebar Footer: History, Settings, Collapse ─────────────────────────
        // History button
        const hrect = state.layout.history_btn_rect;
        const h_active = state.history_open or state.history_btn_hovered;
        self.drawRoundedRect(hrect, 4.0, if (h_active) state_mod.Color.hover_bg else state_mod.Color.bg_dark, 1.0, if (h_active) state_mod.Color.border_pill else state_mod.Color.border_subtle);
        self.drawClockIcon(state_mod.Rect{ .x = hrect.x + 6.0, .y = hrect.y + 7.0, .w = 12.0, .h = 12.0 });
        self.drawText("History", hrect.x + 22.0, hrect.y + 6.0, if (h_active) state_mod.Color.text_gold else state_mod.Color.text_muted, 0.75);

        // Settings button
        const srect = state.layout.settings_btn_rect;
        self.drawRoundedRect(srect, 4.0, state_mod.Color.bg_dark, 1.0, state_mod.Color.border_subtle);
        self.drawText("Settings", srect.x + 10.0, srect.y + 6.0, state_mod.Color.text_muted, 0.75);

        // Collapse button (Ctrl+B)
        const crect = state.layout.collapse_btn_rect;
        self.drawRoundedRect(crect, 4.0, state_mod.Color.bg_dark, 1.0, state_mod.Color.border_subtle);
        self.drawText("Collapse", crect.x + 8.0, crect.y + 6.0, state_mod.Color.text_muted, 0.75);

        // ── 10. Slide-out Glassmorphic History Drawer ───────────────────────────────
        if (state.history_open) {
            const drect = state.layout.history_drawer_rect;

            // Frosted glass background
            self.drawGlassCard(drect, 0.0, state_mod.Color.sidebar_bg, 1.0, state_mod.Color.border_pill);

            // Drawer Header
            self.drawClockIcon(state_mod.Rect{ .x = drect.x + 16.0, .y = 18.0, .w = 14.0, .h = 14.0 });
            self.drawText("Browsing History", drect.x + 36.0, 18.0, state_mod.Color.text_white, 1.0);
            self.drawText("Recent visits from BrowserDB", drect.x + 16.0, 42.0, state_mod.Color.text_muted, 0.72);

            // Close button
            const close_rect = state.layout.history_close_btn_rect;
            self.drawRoundedRect(
                close_rect,
                4.0,
                if (state.history_close_hovered) state_mod.Color.tab_close_hover_bg else state_mod.Color.pill_bg,
                1.0,
                state_mod.Color.border_subtle,
            );
            self.drawText("x", close_rect.x + 6.0, close_rect.y + 3.0, state_mod.Color.text_white, 0.85);

            // Divider line
            self.drawRoundedRect(
                state_mod.Rect{ .x = drect.x + 14.0, .y = 62.0, .w = drect.w - 28.0, .h = 1.0 },
                0.0,
                state_mod.Color.border_subtle,
                0.0,
                .{ 0, 0, 0, 0 },
            );

            // History entries
            if (state.history_items.items.len == 0) {
                self.drawText("No browsing history recorded yet.", drect.x + 16.0, 80.0, state_mod.Color.text_muted, 0.8);
            } else {
                for (state.history_items.items, 0..) |item, i| {
                    if (i < state.layout.history_item_count) {
                        const irect = state.layout.history_item_rects[i];
                        const hovered = item.hovered;

                        self.drawRoundedRect(
                            irect,
                            6.0,
                            if (hovered) state_mod.Color.hover_bg else state_mod.Color.pill_bg,
                            1.0,
                            if (hovered) state_mod.Color.border_pill else state_mod.Color.border_subtle,
                        );

                        // Truncate title if long
                        const title_slice = if (item.title.len > 34) item.title[0..34] else item.title;
                        self.drawText(
                            title_slice,
                            irect.x + 10.0,
                            irect.y + 6.0,
                            if (hovered) state_mod.Color.text_gold else state_mod.Color.text_white,
                            0.8,
                        );

                        // Truncate URL if long
                        const url_slice = if (item.url.len > 38) item.url[0..38] else item.url;
                        self.drawText(url_slice, irect.x + 10.0, irect.y + 24.0, state_mod.Color.accent_amber, 0.7);
                    }
                }
            }
        }

        // ── 11. Floating Notification Pill (bottom right in viewport) ───────────────
        if (state.layout.notification_visible) {
            const nrect = state.layout.notification_rect;
            self.drawRoundedRect(nrect, 19.0, state_mod.Color.sidebar_bg, 1.0, state_mod.Color.border_pill);
            self.drawText(state.notification_text, nrect.x + 16.0, nrect.y + 11.0, state_mod.Color.text_main, 0.85);
        }

        // ── 12. Upload Vertices and Submit Dual Draw Pass ────────────────────────────
        if (self.vertices.items.len > 0) {
            const total_vertices: usize = @min(self.vertices.items.len, @as(usize, 16384));
            const upload_bytes: usize = total_vertices * @sizeOf(font.UIVertex);
            _ = zgraphics.ZG_UploadBuffer(
                self.surface,
                self.vertex_buffer,
                self.vertices.items.ptr,
                upload_bytes,
            );

            const cmd = zgraphics.ZG_BeginCommandBuffer(self.surface) orelse return;

            // Clear color to main dark background
            zgraphics.ZG_CmdClearColor(
                cmd,
                state_mod.Color.bg_dark[0],
                state_mod.Color.bg_dark[1],
                state_mod.Color.bg_dark[2],
                1.0,
            );

            zgraphics.ZG_CmdBindPipeline(cmd, self.pipeline);

            // Pass screen dimensions via push constants
            zgraphics.ZG_BeginLayer(
                cmd,
                0,
                @floatFromInt(state.window_width),
                @floatFromInt(state.window_height),
                0.0,
                0.0,
                1.0,
            );

            const buf_ptrs = [_]zgraphics.ZawraGraphicsBuffer{self.vertex_buffer};
            const offsets = [_]u64{0};
            zgraphics.ZG_CmdBindVertexBuffers(cmd, 0, &buf_ptrs, &offsets, 1);

            if (wpe_vertex_count > 0 and active_tex != null) {
                // Pass 1: Bind WPE DMA-BUF texture to slot 0 and draw viewport quad
                zgraphics.ZG_BindTexture(cmd, active_tex.?, 0);
                zgraphics.ZG_CmdDraw(cmd, wpe_vertex_count, 1, 0, 0);

                // Pass 2: Bind Font Atlas texture to slot 0 and draw UI elements
                const ui_vertex_count: u32 = @intCast(total_vertices - wpe_vertex_count);
                if (ui_vertex_count > 0) {
                    zgraphics.ZG_BindTexture(cmd, self.font_texture, 0);
                    zgraphics.ZG_CmdDraw(cmd, ui_vertex_count, 1, wpe_vertex_count, 0);
                }
            } else {
                // Single Pass: Bind Font Atlas texture to slot 0 and draw all UI quads
                zgraphics.ZG_BindTexture(cmd, self.font_texture, 0);
                zgraphics.ZG_CmdDraw(cmd, @intCast(total_vertices), 1, 0, 0);
            }

            zgraphics.ZG_SubmitCommandBuffer(self.surface, cmd);
            zgraphics.ZG_SwapBuffers(self.surface);
        }
    }
};
