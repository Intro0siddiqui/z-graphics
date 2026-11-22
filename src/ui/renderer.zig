const std = @import("std");
const zgraphics = @import("lib");
const shaders = @import("shaders");
const font = @import("font.zig");
const state_mod = @import("state.zig");

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

        const atlas_pixels = font.generateAtlasRGBA();
        _ = zgraphics.ZG_UploadTexture(surface, font_texture, &atlas_pixels, atlas_pixels.len);
        _ = zgraphics.ZG_SetTextureParams(surface, font_texture, 0, 0, 0, 0); // Linear/Repeat

        // 5. Create vertex buffer (supports up to 16384 vertices = ~2730 quads)
        const vb_size: usize = 16384 * @sizeOf(font.UIVertex);
        const vertex_buffer = zgraphics.ZG_CreateBuffer(surface, vb_size, .Vertex) orelse return error.BufferCreationFailed;

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

        // Triangle 1: (x0, y0), (x1, y0), (x1, y1)
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

        // Triangle 2: (x0, y0), (x1, y1), (x0, y1)
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

    pub fn drawText(self: *UIRenderer, text: []const u8, x: f32, y: f32, color: [4]f32, scale: f32) void {
        font.appendTextQuads(self.allocator, &self.vertices, text, x, y, color, scale) catch return;
    }

    pub fn drawZawraLogo(self: *UIRenderer, rect: state_mod.Rect) void {
        // Draw the Zawra Infinity/Hourglass logo matching svg path:
        // M4 4l16 0M4 4l8 16M20 4l-8 16M4 20l16 0
        const logo_col: [4]f32 = .{ 0.796, 0.835, 0.882, 1.0 };
        const thick: f32 = 2.0;

        // Top bar: (4,4) to (20,4)
        self.drawRoundedRect(
            state_mod.Rect{ .x = rect.x + 4, .y = rect.y + 4, .w = 16, .h = thick },
            1.0,
            logo_col,
            0.0,
            .{ 0, 0, 0, 0 },
        );
        // Bottom bar: (4,20) to (20,20)
        self.drawRoundedRect(
            state_mod.Rect{ .x = rect.x + 4, .y = rect.y + 20, .w = 16, .h = thick },
            1.0,
            logo_col,
            0.0,
            .{ 0, 0, 0, 0 },
        );
        // Left diagonal: (4,4) to (12,20)
        self.drawRoundedRect(
            state_mod.Rect{ .x = rect.x + 8, .y = rect.y + 6, .w = thick, .h = 12 },
            1.0,
            logo_col,
            0.0,
            .{ 0, 0, 0, 0 },
        );
        // Right diagonal: (20,4) to (12,20)
        self.drawRoundedRect(
            state_mod.Rect{ .x = rect.x + 14, .y = rect.y + 6, .w = thick, .h = 12 },
            1.0,
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

    pub fn render(self: *UIRenderer, state: *const state_mod.ShellState) void {
        self.vertices.clearRetainingCapacity();

        // 1. Viewport background (and hook for WPE DMA-BUF texture)
        const vp = state.layout.viewport_rect;
        if (self.wpe_texture) |_| {
            // Draw textured quad using mode 2
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
        } else {
            self.drawRoundedRect(vp, 0.0, state_mod.Color.bg_dark, 0.0, .{ 0, 0, 0, 0 });
        }

        // 2. Sidebar background (280px wide, #1a222c) with right 1px border
        self.drawRoundedRect(
            state.layout.sidebar_rect,
            0.0,
            state_mod.Color.sidebar_bg,
            1.0,
            state_mod.Color.border_subtle,
        );

        // 3. Window Control Dots (12px diameter)
        const dot_r = 6.0;
        self.drawRoundedRect(state.layout.dot_close_rect, dot_r, state_mod.Color.dot_close, 0.0, .{ 0, 0, 0, 0 });
        self.drawRoundedRect(state.layout.dot_minimize_rect, dot_r, state_mod.Color.dot_minimize, 0.0, .{ 0, 0, 0, 0 });
        self.drawRoundedRect(state.layout.dot_maximize_rect, dot_r, state_mod.Color.dot_maximize, 0.0, .{ 0, 0, 0, 0 });

        // 4. Header Area
        self.drawZawraLogo(state.layout.header_logo_rect);
        self.drawText("Zawra", state.layout.header_title_pos[0], state.layout.header_title_pos[1], state_mod.Color.text_white, 1.25);
        self.drawText("The Infinity Point", state.layout.header_subtitle_pos[0], state.layout.header_subtitle_pos[1], state_mod.Color.text_muted, 0.75);

        // 5. Quick Search Pills (16px corner radius)
        const pill_r = 15.0;
        const g_hover = state.pills[0].hovered;
        self.drawRoundedRect(
            state.layout.pill_google_rect,
            pill_r,
            if (g_hover) state_mod.Color.pill_bg_hover else state_mod.Color.pill_bg,
            1.0,
            state_mod.Color.border_pill,
        );
        self.drawText("G  Google Search", state.layout.pill_google_rect.x + 10.0, state.layout.pill_google_rect.y + 7.0, state_mod.Color.text_main, 0.8);

        const d_hover = state.pills[1].hovered;
        self.drawRoundedRect(
            state.layout.pill_duck_rect,
            pill_r,
            if (d_hover) state_mod.Color.pill_bg_hover else state_mod.Color.pill_bg,
            1.0,
            state_mod.Color.border_pill,
        );
        self.drawText("D  DuckDuckGo", state.layout.pill_duck_rect.x + 10.0, state.layout.pill_duck_rect.y + 7.0, state_mod.Color.text_main, 0.8);

        // 6. Omnibar / Address Container (8px corner radius, #0f1115)
        self.drawRoundedRect(
            state.layout.omnibar_rect,
            8.0,
            state_mod.Color.bg_dark,
            1.0,
            if (state.omnibar.focused) state_mod.Color.border_pill else state_mod.Color.border_subtle,
        );
        self.drawSearchIcon(state.layout.search_icon_rect);

        const omnibar_text = state.omnibar.getText();
        if (omnibar_text.len > 0) {
            self.drawText(omnibar_text, state.layout.address_text_pos[0], state.layout.address_text_pos[1], state_mod.Color.text_white, 0.85);
        } else {
            self.drawText(state.omnibar.placeholder, state.layout.address_text_pos[0], state.layout.address_text_pos[1], state_mod.Color.text_muted, 0.85);
        }

        // 7. Navigation Explore Section
        self.drawText("EXPLORE", state.layout.explore_heading_pos[0], state.layout.explore_heading_pos[1], state_mod.Color.text_header, 0.75);

        for (state.explore_items, 0..) |item, i| {
            if (i < 5) {
                const irect = state.layout.explore_item_rects[i];
                if (item.active) {
                    self.drawRoundedRect(irect, 6.0, state_mod.Color.active_bg, 0.0, .{ 0, 0, 0, 0 });
                } else if (item.hovered) {
                    self.drawRoundedRect(irect, 6.0, state_mod.Color.hover_bg, 0.0, .{ 0, 0, 0, 0 });
                }

                const col = if (item.active) state_mod.Color.text_white else state_mod.Color.text_main;
                self.drawText(item.name, irect.x + 12.0, irect.y + 7.0, col, 0.85);
            }
        }

        // 8. Tabs Section
        self.drawText("TABS", state.layout.tabs_heading_pos[0], state.layout.tabs_heading_pos[1], state_mod.Color.text_header, 0.75);

        for (state.tabs.items, 0..) |tab, i| {
            if (i < state.layout.tab_count) {
                const trect = state.layout.tab_rects[i];
                const bg_col = if (tab.active)
                    state_mod.Color.active_bg
                else if (tab.hovered)
                    state_mod.Color.hover_bg
                else
                    state_mod.Color.bg_dark;

                const border_col = if (tab.active or tab.hovered)
                    state_mod.Color.border_pill
                else
                    state_mod.Color.border_subtle;

                self.drawRoundedRect(trect, 6.0, bg_col, 1.0, border_col);
                const col = if (tab.active) state_mod.Color.text_white else state_mod.Color.text_main;
                self.drawText(tab.title, trect.x + 12.0, trect.y + 8.0, col, 0.8);
            }
        }

        // 9. Floating Notification Pill (bottom right in viewport)
        if (state.layout.notification_visible) {
            const nrect = state.layout.notification_rect;
            self.drawRoundedRect(nrect, 19.0, state_mod.Color.sidebar_bg, 1.0, state_mod.Color.border_pill);
            self.drawText(state.notification_text, nrect.x + 16.0, nrect.y + 11.0, state_mod.Color.text_main, 0.85);
        }

        // 10. Upload vertices and submit draw call
        if (self.vertices.items.len > 0) {
            _ = zgraphics.ZG_UploadBuffer(
                self.surface,
                self.vertex_buffer,
                self.vertices.items.ptr,
                self.vertices.items.len * @sizeOf(font.UIVertex),
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
            zgraphics.ZG_BindTexture(cmd, self.font_texture, 0);

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
            zgraphics.ZG_CmdDraw(cmd, @intCast(self.vertices.items.len), 1, 0, 0);

            zgraphics.ZG_SubmitCommandBuffer(self.surface, cmd);
            zgraphics.ZG_SwapBuffers(self.surface);
        }
    }
};
