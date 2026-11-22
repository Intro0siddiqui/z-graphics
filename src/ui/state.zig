const std = @import("std");

pub const Rect = struct {
    x: f32,
    y: f32,
    w: f32,
    h: f32,

    pub fn contains(self: Rect, px: f32, py: f32) bool {
        return px >= self.x and px <= (self.x + self.w) and py >= self.y and py <= (self.y + self.h);
    }
};

pub const Color = struct {
    pub const bg_dark: [4]f32 = .{ 0.0588, 0.0667, 0.0824, 1.0 }; // #0f1115
    pub const sidebar_bg: [4]f32 = .{ 0.1020, 0.1333, 0.1725, 1.0 }; // #1a222c
    pub const border_subtle: [4]f32 = .{ 1.0, 1.0, 1.0, 0.05 }; // rgba(255,255,255,0.05)
    pub const border_pill: [4]f32 = .{ 1.0, 1.0, 1.0, 0.10 }; // rgba(255,255,255,0.1)
    pub const pill_bg: [4]f32 = .{ 1.0, 1.0, 1.0, 0.05 };
    pub const pill_bg_hover: [4]f32 = .{ 1.0, 1.0, 1.0, 0.10 };
    pub const text_main: [4]f32 = .{ 0.8863, 0.9098, 0.9412, 1.0 }; // #e2e8f0
    pub const text_muted: [4]f32 = .{ 0.3922, 0.4549, 0.5451, 1.0 }; // #64748b
    pub const text_header: [4]f32 = .{ 0.5804, 0.6392, 0.7216, 1.0 }; // #94a3b8
    pub const text_white: [4]f32 = .{ 1.0, 1.0, 1.0, 1.0 };
    pub const active_bg: [4]f32 = .{ 1.0, 1.0, 1.0, 0.10 };
    pub const hover_bg: [4]f32 = .{ 1.0, 1.0, 1.0, 0.05 };

    // Window control dots
    pub const dot_close: [4]f32 = .{ 1.0, 0.3725, 0.3373, 1.0 }; // #ff5f56
    pub const dot_minimize: [4]f32 = .{ 1.0, 0.7412, 0.1804, 1.0 }; // #ffbd2e
    pub const dot_maximize: [4]f32 = .{ 0.1529, 0.7882, 0.2471, 1.0 }; // #27c93f
};

pub const TabItem = struct {
    id: u32,
    title: []const u8,
    url: []const u8,
    active: bool = false,
    hovered: bool = false,
    close_hovered: bool = false,
};

pub const OmnibarInput = struct {
    buffer: [512]u8 = [_]u8{0} ** 512,
    len: usize = 0,
    cursor_pos: usize = 0,
    selection_start: ?usize = null,
    selection_end: ?usize = null,
    placeholder: []const u8 = "Search or enter address...",
    focused: bool = false,

    pub fn getText(self: *const OmnibarInput) []const u8 {
        if (self.len == 0) return "";
        return self.buffer[0..self.len];
    }

    pub fn setText(self: *OmnibarInput, text: []const u8) void {
        const copy_len = @min(text.len, self.buffer.len);
        @memcpy(self.buffer[0..copy_len], text[0..copy_len]);
        self.len = copy_len;
        self.cursor_pos = copy_len;
    }
};

pub const ExploreItem = struct {
    name: []const u8,
    icon: []const u8,
    active: bool = false,
    hovered: bool = false,
};

pub const PillItem = struct {
    name: []const u8,
    icon: []const u8,
    hovered: bool = false,
    url_template: []const u8,
};

pub const WindowControlKind = enum {
    close,
    minimize,
    maximize,
};

pub const WindowControlDot = struct {
    kind: WindowControlKind,
    color: [4]f32,
    hovered: bool = false,
};

pub const ShellLayout = struct {
    sidebar_rect: Rect,
    viewport_rect: Rect,

    // Window controls
    dot_close_rect: Rect,
    dot_minimize_rect: Rect,
    dot_maximize_rect: Rect,

    // Header
    header_logo_rect: Rect,
    header_title_pos: [2]f32,
    header_subtitle_pos: [2]f32,

    // Pills
    pill_google_rect: Rect,
    pill_duck_rect: Rect,

    // Omnibar
    omnibar_rect: Rect,
    search_icon_rect: Rect,
    address_text_pos: [2]f32,

    // Explore section
    explore_heading_pos: [2]f32,
    explore_item_rects: [5]Rect,

    // Tabs section
    tabs_heading_pos: [2]f32,
    tab_rects: [16]Rect,
    tab_count: usize,

    // Notification pill
    notification_rect: Rect,
    notification_visible: bool,
};

pub const ShellState = struct {
    window_width: u32 = 1280,
    window_height: u32 = 800,

    tabs: std.ArrayList(TabItem) = .empty,
    next_tab_id: u32 = 1,

    omnibar: OmnibarInput = .{},

    explore_items: [5]ExploreItem,
    pills: [2]PillItem,
    control_dots: [3]WindowControlDot,

    notification_text: []const u8 = "✨ Z-graphics smoke test complete",
    notification_visible: bool = true,

    mouse_x: f32 = 0,
    mouse_y: f32 = 0,

    layout: ShellLayout = undefined,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, width: u32, height: u32) !ShellState {
        var state = ShellState{
            .window_width = width,
            .window_height = height,
            .tabs = .empty,
            .allocator = allocator,
            .explore_items = [_]ExploreItem{
                .{ .name = "Dominion", .icon = "🔮", .active = false },
                .{ .name = "Hajr Dev", .icon = "⚙️", .active = false },
                .{ .name = "Graphics", .icon = "📐", .active = true },
                .{ .name = "Z-Net", .icon = "🌐", .active = false },
                .{ .name = "BrowserDB", .icon = "🗄️", .active = false },
            },
            .pills = [_]PillItem{
                .{ .name = "Google Search", .icon = "G", .url_template = "https://google.com/search?q=" },
                .{ .name = "DuckDuckGo", .icon = "🦆", .url_template = "https://duckduckgo.com/?q=" },
            },
            .control_dots = [_]WindowControlDot{
                .{ .kind = .close, .color = Color.dot_close },
                .{ .kind = .minimize, .color = Color.dot_minimize },
                .{ .kind = .maximize, .color = Color.dot_maximize },
            },
        };

        // Add default tabs matching ui_shell.html
        try state.addTab("M2 Chip Thread - Discussion", "https://news.ycombinator.com");
        try state.addTab("Z-Net HTTP/3 Pipeline TODO", "https://github.com/zawra/z-net");
        try state.addTab("WebKit LayerTree Docs", "https://webkit.org/docs");
        try state.addTab("Gym Schedule - MSI A15", "https://zawra.internal/schedule");

        if (state.tabs.items.len > 0) {
            state.tabs.items[0].active = true;
        }

        state.recomputeLayout();
        return state;
    }

    pub fn deinit(self: *ShellState) void {
        self.tabs.deinit(self.allocator);
    }

    pub fn addTab(self: *ShellState, title: []const u8, url: []const u8) !void {
        const tab = TabItem{
            .id = self.next_tab_id,
            .title = title,
            .url = url,
            .active = false,
        };
        self.next_tab_id += 1;
        try self.tabs.append(self.allocator, tab);
        self.recomputeLayout();
    }

    pub fn setActiveTab(self: *ShellState, index: usize) void {
        for (self.tabs.items, 0..) |*tab, i| {
            tab.active = (i == index);
        }
    }

    pub fn setWindowSize(self: *ShellState, width: u32, height: u32) void {
        self.window_width = width;
        self.window_height = height;
        self.recomputeLayout();
    }

    pub fn handleMouseMove(self: *ShellState, mx: f32, my: f32) void {
        self.mouse_x = mx;
        self.mouse_y = my;

        // Check dots hover
        self.control_dots[0].hovered = self.layout.dot_close_rect.contains(mx, my);
        self.control_dots[1].hovered = self.layout.dot_minimize_rect.contains(mx, my);
        self.control_dots[2].hovered = self.layout.dot_maximize_rect.contains(mx, my);

        // Check pills hover
        self.pills[0].hovered = self.layout.pill_google_rect.contains(mx, my);
        self.pills[1].hovered = self.layout.pill_duck_rect.contains(mx, my);

        // Check explore items hover
        for (&self.explore_items, 0..) |*item, i| {
            if (i < 5) {
                item.hovered = self.layout.explore_item_rects[i].contains(mx, my);
            }
        }

        // Check tab cards hover
        for (self.tabs.items, 0..) |*tab, i| {
            if (i < self.layout.tab_count) {
                tab.hovered = self.layout.tab_rects[i].contains(mx, my);
            }
        }
    }

    pub fn handleMouseDown(self: *ShellState, mx: f32, my: f32) void {
        // Tab click
        for (self.tabs.items, 0..) |*tab, i| {
            if (i < self.layout.tab_count and self.layout.tab_rects[i].contains(mx, my)) {
                self.setActiveTab(i);
                self.omnibar.setText(tab.url);
                return;
            }
        }

        // Explore click
        for (&self.explore_items, 0..) |*item, i| {
            if (i < 5 and self.layout.explore_item_rects[i].contains(mx, my)) {
                for (&self.explore_items) |*other| other.active = false;
                item.active = true;
                return;
            }
        }

        // Omnibar click
        if (self.layout.omnibar_rect.contains(mx, my)) {
            self.omnibar.focused = true;
        } else {
            self.omnibar.focused = false;
        }
    }

    pub fn recomputeLayout(self: *ShellState) void {
        const w: f32 = @floatFromInt(self.window_width);
        const h: f32 = @floatFromInt(self.window_height);

        // Sidebar width is fixed at 280px matching ui_shell.css
        const sidebar_w: f32 = 280.0;
        self.layout.sidebar_rect = Rect{ .x = 0, .y = 0, .w = sidebar_w, .h = h };
        self.layout.viewport_rect = Rect{ .x = sidebar_w, .y = 0, .w = w - sidebar_w, .h = h };

        // 1. Window controls (12px diameter dots with 8px gap)
        const dot_y: f32 = 16.0;
        const dot_size: f32 = 12.0;
        self.layout.dot_close_rect = Rect{ .x = 16.0, .y = dot_y, .w = dot_size, .h = dot_size };
        self.layout.dot_minimize_rect = Rect{ .x = 16.0 + 12.0 + 8.0, .y = dot_y, .w = dot_size, .h = dot_size };
        self.layout.dot_maximize_rect = Rect{ .x = 16.0 + 24.0 + 16.0, .y = dot_y, .w = dot_size, .h = dot_size };

        // 2. Header Area
        const header_y: f32 = dot_y + dot_size + 20.0; // ~48px
        self.layout.header_logo_rect = Rect{ .x = 16.0, .y = header_y, .w = 28.0, .h = 28.0 };
        self.layout.header_title_pos = .{ 54.0, header_y + 2.0 };
        self.layout.header_subtitle_pos = .{ 54.0, header_y + 20.0 };

        // 3. Quick Search Pills (border-radius 16px, height ~30px)
        const pills_y: f32 = header_y + 28.0 + 20.0;
        self.layout.pill_google_rect = Rect{ .x = 16.0, .y = pills_y, .w = 118.0, .h = 30.0 };
        self.layout.pill_duck_rect = Rect{ .x = 142.0, .y = pills_y, .w = 118.0, .h = 30.0 };

        // 4. Omnibar Container (border-radius 8px, height 38px)
        const omnibar_y: f32 = pills_y + 30.0 + 16.0;
        self.layout.omnibar_rect = Rect{ .x = 16.0, .y = omnibar_y, .w = 248.0, .h = 38.0 };
        self.layout.search_icon_rect = Rect{ .x = 28.0, .y = omnibar_y + 11.0, .w = 16.0, .h = 16.0 };
        self.layout.address_text_pos = .{ 52.0, omnibar_y + 11.0 };

        // 5. Explore Section
        const explore_y: f32 = omnibar_y + 38.0 + 20.0;
        self.layout.explore_heading_pos = .{ 16.0, explore_y };

        const item_start_y: f32 = explore_y + 20.0;
        for (0..5) |i| {
            const item_y = item_start_y + @as(f32, @floatFromInt(i)) * 34.0;
            self.layout.explore_item_rects[i] = Rect{ .x = 16.0, .y = item_y, .w = 248.0, .h = 30.0 };
        }

        // 6. Tabs Section
        const tabs_y: f32 = item_start_y + 5.0 * 34.0 + 16.0;
        self.layout.tabs_heading_pos = .{ 16.0, tabs_y };

        const tab_start_y: f32 = tabs_y + 20.0;
        const visible_tab_count = @min(self.tabs.items.len, 16);
        self.layout.tab_count = visible_tab_count;
        for (0..visible_tab_count) |i| {
            const ty = tab_start_y + @as(f32, @floatFromInt(i)) * 36.0;
            self.layout.tab_rects[i] = Rect{ .x = 16.0, .y = ty, .w = 248.0, .h = 32.0 };
        }

        // 7. Notification Pill (floating bottom-right in viewport)
        const notif_w: f32 = 270.0;
        const notif_h: f32 = 38.0;
        self.layout.notification_rect = Rect{
            .x = w - notif_w - 24.0,
            .y = h - notif_h - 24.0,
            .w = notif_w,
            .h = notif_h,
        };
        self.layout.notification_visible = self.notification_visible;
    }
};
