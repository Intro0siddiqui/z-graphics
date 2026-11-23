const std = @import("std");
const builtin = @import("builtin");
const zgraphics = if (builtin.is_test) struct {
    pub fn Zawra_LoadURL(_: [*]const u8, _: usize) void {}
    pub fn Zawra_GetRecentHistory(_: u32, _: [*]u8, _: usize) usize {
        return 0;
    }
} else @import("lib");

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
    pub const bg_dark: [4]f32 = .{ 0.043, 0.063, 0.106, 1.0 }; // #0b101b Deep Midnight Cyber Navy
    pub const sidebar_bg: [4]f32 = .{ 0.067, 0.098, 0.161, 1.0 }; // #111929 Midnight Slate
    pub const border_subtle: [4]f32 = .{ 1.0, 1.0, 1.0, 0.06 };
    pub const border_pill: [4]f32 = .{ 1.0, 1.0, 1.0, 0.12 };
    pub const pill_bg: [4]f32 = .{ 1.0, 1.0, 1.0, 0.04 };
    pub const pill_bg_hover: [4]f32 = .{ 1.0, 1.0, 1.0, 0.09 };
    pub const text_main: [4]f32 = .{ 0.88, 0.91, 0.94, 1.0 }; // #e2e8f0
    pub const text_muted: [4]f32 = .{ 0.40, 0.48, 0.60, 1.0 }; // #64748b
    pub const text_header: [4]f32 = .{ 0.58, 0.64, 0.72, 1.0 }; // #94a3b8
    pub const text_white: [4]f32 = .{ 1.0, 1.0, 1.0, 1.0 };
    pub const text_gold: [4]f32 = .{ 0.984, 0.690, 0.251, 1.0 }; // #fbb040
    pub const accent_amber: [4]f32 = .{ 0.90, 0.60, 0.22, 1.0 }; // #e59a38
    pub const active_bg: [4]f32 = .{ 0.90, 0.60, 0.22, 0.12 };
    pub const hover_bg: [4]f32 = .{ 1.0, 1.0, 1.0, 0.06 };
    pub const tab_close_hover_bg: [4]f32 = .{ 0.90, 0.25, 0.25, 0.35 };

    // Window control dots
    pub const dot_close: [4]f32 = .{ 1.0, 0.3725, 0.3373, 1.0 }; // #ff5f56
    pub const dot_minimize: [4]f32 = .{ 1.0, 0.7412, 0.1804, 1.0 }; // #ffbd2e
    pub const dot_maximize: [4]f32 = .{ 0.1529, 0.7882, 0.2471, 1.0 }; // #27c93f
};

pub fn isStartPage(url: []const u8) bool {
    return std.mem.eql(u8, url, "zawra://start") or
        std.mem.eql(u8, url, "about:blank") or
        url.len == 0;
}

pub const FocusTarget = enum {
    none,
    omnibar,
    search_hud,
};

pub const SearchEngine = enum {
    google,
    duckduckgo,
};

pub const TabItem = struct {
    id: u32,
    title: []const u8 = "New Tab",
    title_buf: [128]u8 = [_]u8{0} ** 128,
    title_len: usize = 7,
    url: []const u8 = "zawra://start",
    url_buf: [512]u8 = [_]u8{0} ** 512,
    url_len: usize = 13,
    active: bool = false,
    hovered: bool = false,
    close_hovered: bool = false,

    pub fn getTitle(self: *const TabItem) []const u8 {
        if (self.title_len == 0) return "New Tab";
        return self.title_buf[0..self.title_len];
    }

    pub fn getUrl(self: *const TabItem) []const u8 {
        if (self.url_len == 0) return "zawra://start";
        return self.url_buf[0..self.url_len];
    }

    pub fn setTitle(self: *TabItem, new_title: []const u8) void {
        const copy_len = @min(new_title.len, self.title_buf.len);
        @memcpy(self.title_buf[0..copy_len], new_title[0..copy_len]);
        self.title_len = copy_len;
        self.title = self.title_buf[0..copy_len];
    }

    pub fn setUrl(self: *TabItem, new_url: []const u8) void {
        const copy_len = @min(new_url.len, self.url_buf.len);
        @memcpy(self.url_buf[0..copy_len], new_url[0..copy_len]);
        self.url_len = copy_len;
        self.url = self.url_buf[0..copy_len];
    }

    pub fn refreshSlices(self: *TabItem) void {
        self.title = self.title_buf[0..self.title_len];
        self.url = self.url_buf[0..self.url_len];
    }
};

pub const HistoryEntryItem = struct {
    title: []const u8,
    url: []const u8,
    visit_time: u64 = 0,
    hovered: bool = false,
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

pub const ShortcutCard = struct {
    name: []const u8,
    url: []const u8,
    icon: []const u8,
    hovered: bool = false,
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

    // Nav Cluster
    nav_back_rect: Rect,
    nav_fwd_rect: Rect,
    nav_reload_rect: Rect,

    // Pills (embedded in Search HUD)
    pill_google_rect: Rect,
    pill_duck_rect: Rect,

    // Omnibar
    omnibar_rect: Rect,
    search_icon_rect: Rect,
    address_text_pos: [2]f32,

    // Explore section
    explore_heading_pos: [2]f32,
    explore_item_rects: [4]Rect,

    // Tabs section
    tabs_heading_pos: [2]f32,
    tab_new_btn_rect: Rect,
    tab_rects: [16]Rect,
    tab_close_rects: [16]Rect,
    tab_count: usize,

    // Start Page elements (viewport)
    start_logo_rect: Rect,
    start_title_pos: [2]f32,
    start_subtitle_pos: [2]f32,
    start_search_rect: Rect,
    start_search_icon_rect: Rect,
    start_search_text_pos: [2]f32,
    shortcut_rects: [4]Rect,

    // Bottom Right Icons
    sparkle_icon_rect: Rect,
    toggle_icon_rect: Rect,

    // Sidebar footer: History, Settings, Collapse
    history_btn_rect: Rect,
    history_btn_text_pos: [2]f32,
    settings_btn_rect: Rect,
    collapse_btn_rect: Rect,

    // Slide-out History Drawer
    history_drawer_rect: Rect,
    history_close_btn_rect: Rect,
    history_item_rects: [16]Rect,
    history_item_count: usize,

    // Notification pill
    notification_rect: Rect,
    notification_visible: bool,
};

pub const ShellState = struct {
    window_width: u32 = 1280,
    window_height: u32 = 800,

    tabs: std.ArrayList(TabItem) = .empty,
    next_tab_id: u32 = 1,

    focus: FocusTarget = .none,
    search_engine: SearchEngine = .google,

    omnibar: OmnibarInput = .{},
    search_hud_input: OmnibarInput = .{
        .placeholder = "Search the web or type URL...",
    },

    explore_items: [4]ExploreItem,
    pills: [2]PillItem,
    control_dots: [3]WindowControlDot,
    shortcuts: [4]ShortcutCard,

    tab_new_btn_hovered: bool = false,

    history_open: bool = false,
    history_btn_hovered: bool = false,
    history_close_hovered: bool = false,
    history_items: std.ArrayList(HistoryEntryItem) = .empty,
    history_arena: std.heap.ArenaAllocator,

    start_search_hovered: bool = false,
    notification_text: []const u8 = "✨ Zawra Native Wayland UI Shell: Live WebKit DMA-BUF Engine",
    notification_visible: bool = false,

    shift_pressed: bool = false,

    mouse_x: f32 = 0,
    mouse_y: f32 = 0,
    frame_count: u32 = 0,

    layout: ShellLayout = undefined,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, width: u32, height: u32) !ShellState {
        var state = ShellState{
            .window_width = width,
            .window_height = height,
            .tabs = .empty,
            .allocator = allocator,
            .history_arena = std.heap.ArenaAllocator.init(allocator),
            .history_items = .empty,
            .explore_items = [_]ExploreItem{
                .{ .name = "History", .icon = "H", .active = false },
                .{ .name = "Bookmarks", .icon = "B", .active = false },
                .{ .name = "Downloads", .icon = "D", .active = false },
                .{ .name = "Settings", .icon = "S", .active = false },
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
            .shortcuts = [_]ShortcutCard{
                .{ .name = "GitHub", .url = "https://github.com", .icon = "GH" },
                .{ .name = "Rust Docs", .url = "https://doc.rust-lang.org", .icon = "Rust" },
                .{ .name = "Wayland Specs", .url = "https://wayland.freedesktop.org", .icon = "Wayland" },
                .{ .name = "Hajr Dev", .url = "https://github.com", .icon = "Hajr" },
            },
        };

        // Shell boots with EXACTLY 1 clean dynamic tab: "New Tab" / "zawra://start"
        var start_tab = TabItem{
            .id = state.next_tab_id,
            .title = "New Tab",
            .url = "zawra://start",
            .active = true,
        };
        start_tab.setUrl("zawra://start");
        start_tab.setTitle("New Tab");
        state.next_tab_id += 1;
        try state.tabs.append(state.allocator, start_tab);

        state.omnibar.setText("zawra://start");
        state.focus = .search_hud;

        state.loadRecentHistory();
        state.recomputeLayout();
        return state;
    }

    pub fn deinit(self: *ShellState) void {
        self.history_items.deinit(self.allocator);
        self.history_arena.deinit();
        self.tabs.deinit(self.allocator);
    }

    pub fn addNewTab(self: *ShellState) !void {
        var tab = TabItem{
            .id = self.next_tab_id,
            .title = "New Tab",
            .url = "zawra://start",
            .active = false,
        };
        tab.setUrl("zawra://start");
        tab.setTitle("New Tab");
        self.next_tab_id += 1;
        try self.tabs.append(self.allocator, tab);
        self.setActiveTab(self.tabs.items.len - 1);
    }

    pub fn addTab(self: *ShellState, title: []const u8, url: []const u8) !void {
        var tab = TabItem{
            .id = self.next_tab_id,
            .title = title,
            .url = url,
            .active = false,
        };
        tab.setUrl(url);
        tab.setTitle(title);
        self.next_tab_id += 1;
        try self.tabs.append(self.allocator, tab);
        self.recomputeLayout();
    }

    pub fn closeTab(self: *ShellState, index: usize) !void {
        if (index >= self.tabs.items.len) return;
        const was_active = self.tabs.items[index].active;
        _ = self.tabs.orderedRemove(index);

        if (self.tabs.items.len == 0) {
            try self.addNewTab();
        } else if (was_active) {
            const new_active = if (index < self.tabs.items.len) index else self.tabs.items.len - 1;
            self.setActiveTab(new_active);
        } else {
            self.recomputeLayout();
        }
    }

    pub fn setActiveTab(self: *ShellState, index: usize) void {
        if (index >= self.tabs.items.len) return;
        for (self.tabs.items, 0..) |*tab, i| {
            tab.active = (i == index);
            if (i == index) {
                self.omnibar.setText(tab.url);
                if (isStartPage(tab.url)) {
                    self.focus = .search_hud;
                } else {
                    self.focus = .none;
                    zgraphics.Zawra_LoadURL(tab.url.ptr, tab.url.len);
                }
            }
        }
        self.recomputeLayout();
    }

    pub fn getActiveTab(self: *ShellState) ?*TabItem {
        for (self.tabs.items) |*tab| {
            if (tab.active) return tab;
        }
        if (self.tabs.items.len > 0) return &self.tabs.items[0];
        return null;
    }

    pub fn getActiveTabConst(self: *const ShellState) ?*const TabItem {
        for (self.tabs.items) |*tab| {
            if (tab.active) return tab;
        }
        if (self.tabs.items.len > 0) return &self.tabs.items[0];
        return null;
    }

    pub fn setWindowSize(self: *ShellState, width: u32, height: u32) void {
        self.window_width = width;
        self.window_height = height;
        self.recomputeLayout();
    }

    pub fn toggleHistory(self: *ShellState) void {
        self.history_open = !self.history_open;
        if (self.history_open) {
            self.loadRecentHistory();
        }
        self.recomputeLayout();
    }

    pub fn loadRecentHistory(self: *ShellState) void {
        _ = self.history_arena.reset(.retain_capacity);
        self.history_items.clearRetainingCapacity();
        const arena = self.history_arena.allocator();

        var buf: [4096]u8 = undefined;
        const len = zgraphics.Zawra_GetRecentHistory(16, &buf, buf.len);
        if (len > 0) {
            self.parseHistoryJson(arena, buf[0..len]) catch {};
        }
    }

    const HistoryJsonItem = struct {
        title: []const u8 = "",
        url: []const u8 = "",
        visit_time: u64 = 0,
    };

    pub fn parseHistoryJson(self: *ShellState, arena: std.mem.Allocator, json_str: []const u8) !void {
        const parsed = try std.json.parseFromSlice([]const HistoryJsonItem, arena, json_str, .{ .ignore_unknown_fields = true });
        defer parsed.deinit();

        for (parsed.value) |item| {
            const title = try arena.dupe(u8, item.title);
            const url = try arena.dupe(u8, item.url);
            try self.history_items.append(self.allocator, HistoryEntryItem{
                .title = title,
                .url = url,
                .visit_time = item.visit_time,
                .hovered = false,
            });
        }
    }

    pub fn normaliseSearchOrUrl(buf: *[512]u8, input: []const u8, engine: SearchEngine) []const u8 {
        const trimmed = std.mem.trim(u8, input, " \t\r\n");
        if (trimmed.len == 0) return "";

        if (std.mem.startsWith(u8, trimmed, "http://") or
            std.mem.startsWith(u8, trimmed, "https://") or
            std.mem.startsWith(u8, trimmed, "file://") or
            std.mem.startsWith(u8, trimmed, "zawra://") or
            std.mem.startsWith(u8, trimmed, "about:"))
        {
            const copy_len = @min(trimmed.len, buf.len);
            @memcpy(buf[0..copy_len], trimmed[0..copy_len]);
            return buf[0..copy_len];
        }

        const has_space = std.mem.indexOfScalar(u8, trimmed, ' ') != null;
        const has_dot = std.mem.indexOfScalar(u8, trimmed, '.') != null;

        if (!has_space and has_dot) {
            const prefix = "https://";
            const copy_len = @min(trimmed.len, buf.len - prefix.len);
            @memcpy(buf[0..prefix.len], prefix);
            @memcpy(buf[prefix.len .. prefix.len + copy_len], trimmed[0..copy_len]);
            return buf[0 .. prefix.len + copy_len];
        }

        const prefix = switch (engine) {
            .google => "https://www.google.com/search?q=",
            .duckduckgo => "https://duckduckgo.com/?q=",
        };
        var out_idx: usize = 0;
        @memcpy(buf[0..prefix.len], prefix);
        out_idx += prefix.len;

        for (trimmed) |ch| {
            if (out_idx >= buf.len) break;
            if (ch == ' ') {
                buf[out_idx] = '+';
                out_idx += 1;
            } else {
                buf[out_idx] = ch;
                out_idx += 1;
            }
        }
        return buf[0..out_idx];
    }

    pub fn normaliseUrlBuf(buf: *[512]u8, input: []const u8) []const u8 {
        return normaliseSearchOrUrl(buf, input, .duckduckgo);
    }

    pub fn navigateToUrl(self: *ShellState, input_url: []const u8) void {
        var norm_buf: [512]u8 = undefined;
        const url = normaliseSearchOrUrl(&norm_buf, input_url, self.search_engine);
        if (url.len == 0) return;

        if (self.getActiveTab()) |tab| {
            tab.setUrl(url);
            tab.setTitle(if (isStartPage(url)) "New Tab" else url);
            self.omnibar.setText(url);
        }
        self.focus = .none;
        self.omnibar.focused = false;

        zgraphics.Zawra_LoadURL(url.ptr, url.len);
        self.recomputeLayout();
    }

    fn evdevToAscii(code: u32, shift: bool) ?u8 {
        if (!shift) {
            return switch (code) {
                16 => 'q', 17 => 'w', 18 => 'e', 19 => 'r', 20 => 't',
                21 => 'y', 22 => 'u', 23 => 'i', 24 => 'o', 25 => 'p',
                26 => '[', 27 => ']',
                30 => 'a', 31 => 's', 32 => 'd', 33 => 'f', 34 => 'g',
                35 => 'h', 36 => 'j', 37 => 'k', 38 => 'l',
                39 => ';', 40 => '\'', 41 => '`', 43 => '\\',
                44 => 'z', 45 => 'x', 46 => 'c', 47 => 'v', 48 => 'b',
                49 => 'n', 50 => 'm',
                2 => '1', 3 => '2', 4 => '3', 5 => '4', 6 => '5',
                7 => '6', 8 => '7', 9 => '8', 10 => '9', 11 => '0',
                12 => '-', 13 => '=',
                51 => ',', 52 => '.', 53 => '/', 57 => ' ',
                else => null,
            };
        } else {
            return switch (code) {
                16 => 'Q', 17 => 'W', 18 => 'E', 19 => 'R', 20 => 'T',
                21 => 'Y', 22 => 'U', 23 => 'I', 24 => 'O', 25 => 'P',
                26 => '{', 27 => '}',
                30 => 'A', 31 => 'S', 32 => 'D', 33 => 'F', 34 => 'G',
                35 => 'H', 36 => 'J', 37 => 'K', 38 => 'L',
                39 => ':', 40 => '"', 41 => '~', 43 => '|',
                44 => 'Z', 45 => 'X', 46 => 'C', 47 => 'V', 48 => 'B',
                49 => 'N', 50 => 'M',
                2 => '!', 3 => '@', 4 => '#', 5 => '$', 6 => '%',
                7 => '^', 8 => '&', 9 => '*', 10 => '(', 11 => ')',
                12 => '_', 13 => '+',
                51 => '<', 52 => '>', 53 => '?', 57 => ' ',
                else => null,
            };
        }
    }

    pub fn handleKey(self: *ShellState, key: u32, is_down: bool, is_ctrl: bool) void {
        // Track shift key modifiers
        if (key == 42 or key == 54) {
            self.shift_pressed = is_down;
            return;
        }

        if (!is_down) return;

        // Ctrl+H toggles history drawer (ASCII 'h', 'H', or Linux KEY_H 35)
        if (is_ctrl and (key == 'h' or key == 'H' or key == 35 or key == 0x23)) {
            self.toggleHistory();
            return;
        }

        // Ctrl+T opens new tab
        if (is_ctrl and (key == 't' or key == 'T' or key == 20)) {
            self.addNewTab() catch {};
            return;
        }

        // Ctrl+W closes current tab
        if (is_ctrl and (key == 'w' or key == 'W' or key == 17)) {
            for (self.tabs.items, 0..) |tab, i| {
                if (tab.active) {
                    self.closeTab(i) catch {};
                    return;
                }
            }
            return;
        }

        // Auto-focus search or omnibar when typing if nothing is currently focused
        if (self.focus == .none) {
            const active_tab = self.getActiveTabConst();
            const is_start = if (active_tab) |tab| isStartPage(tab.getUrl()) else true;
            if (is_start) {
                self.focus = .search_hud;
            } else {
                const char_byte: ?u8 = if (evdevToAscii(key, self.shift_pressed)) |c|
                    c
                else if (key >= 32 and key <= 126)
                    @intCast(key)
                else
                    null;
                if (char_byte != null and !is_ctrl) {
                    self.focus = .omnibar;
                    self.omnibar.len = 0;
                    self.omnibar.cursor_pos = 0;
                }
            }
        }

        if (self.focus == .search_hud) {
            // Enter key (Linux keycode 28, '\r', '\n')
            if (key == 28 or key == '\r' or key == '\n') {
                const raw_text = self.search_hud_input.getText();
                if (raw_text.len > 0) {
                    var norm_buf: [512]u8 = undefined;
                    const url = normaliseSearchOrUrl(&norm_buf, raw_text, self.search_engine);
                    self.search_hud_input.setText("");
                    self.navigateToUrl(url);
                }
                return;
            }

            // Backspace (Linux keycode 14 or 8)
            if (key == 14 or key == 8) {
                if (self.search_hud_input.len > 0) {
                    self.search_hud_input.len -= 1;
                    self.search_hud_input.cursor_pos = self.search_hud_input.len;
                }
                return;
            }

            // Escape to unfocus
            if (key == 1 or key == 27) {
                self.focus = .none;
                return;
            }

            // Printable character (prioritize evdev keycode, fallback to direct ASCII)
            const char_byte: ?u8 = if (evdevToAscii(key, self.shift_pressed)) |c|
                c
            else if (key >= 32 and key <= 126)
                @intCast(key)
            else
                null;

            if (char_byte) |c| {
                if (self.search_hud_input.len < self.search_hud_input.buffer.len) {
                    self.search_hud_input.buffer[self.search_hud_input.len] = c;
                    self.search_hud_input.len += 1;
                    self.search_hud_input.cursor_pos = self.search_hud_input.len;
                }
            }
        } else if (self.focus == .omnibar) {
            // Enter key
            if (key == 28 or key == '\r' or key == '\n') {
                const raw_text = self.omnibar.getText();
                if (raw_text.len > 0) {
                    var norm_buf: [512]u8 = undefined;
                    const url = normaliseSearchOrUrl(&norm_buf, raw_text, self.search_engine);
                    self.navigateToUrl(url);
                }
                self.focus = .none;
                self.omnibar.focused = false;
                return;
            }

            // Backspace
            if (key == 14 or key == 8) {
                if (self.omnibar.len > 0) {
                    self.omnibar.len -= 1;
                    self.omnibar.cursor_pos = self.omnibar.len;
                }
                return;
            }

            // Escape
            if (key == 1 or key == 27) {
                self.focus = .none;
                self.omnibar.focused = false;
                return;
            }

            // Printable character (prioritize evdev keycode, fallback to direct ASCII)
            const char_byte: ?u8 = if (evdevToAscii(key, self.shift_pressed)) |c|
                c
            else if (key >= 32 and key <= 126)
                @intCast(key)
            else
                null;

            if (char_byte) |c| {
                if (self.omnibar.len < self.omnibar.buffer.len) {
                    self.omnibar.buffer[self.omnibar.len] = c;
                    self.omnibar.len += 1;
                    self.omnibar.cursor_pos = self.omnibar.len;
                }
            }
        }
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
            if (i < 4) {
                item.hovered = self.layout.explore_item_rects[i].contains(mx, my);
            }
        }

        // Check tab [+] button hover
        self.tab_new_btn_hovered = self.layout.tab_new_btn_rect.contains(mx, my);

        // Check tab cards and [x] close button hover
        for (self.tabs.items, 0..) |*tab, i| {
            if (i < self.layout.tab_count) {
                const close_hov = self.layout.tab_close_rects[i].contains(mx, my);
                tab.close_hovered = close_hov;
                tab.hovered = self.layout.tab_rects[i].contains(mx, my) and !close_hov;
            }
        }

        // Check history button in sidebar footer
        self.history_btn_hovered = self.layout.history_btn_rect.contains(mx, my);

        // Check history drawer hover
        if (self.history_open) {
            self.history_close_hovered = self.layout.history_close_btn_rect.contains(mx, my);
            for (self.history_items.items, 0..) |*item, i| {
                if (i < self.layout.history_item_count) {
                    item.hovered = self.layout.history_item_rects[i].contains(mx, my);
                }
            }
        }

        // Start page shortcuts hover
        for (&self.shortcuts, 0..) |*item, i| {
            item.hovered = self.layout.shortcut_rects[i].contains(mx, my);
        }
        self.start_search_hovered = self.layout.start_search_rect.contains(mx, my);
    }

    pub fn handleMouseDown(self: *ShellState, mx: f32, my: f32) void {
        // 0. History button click in footer
        if (self.layout.history_btn_rect.contains(mx, my)) {
            self.toggleHistory();
            return;
        }

        // If History drawer is open
        if (self.history_open) {
            if (self.layout.history_close_btn_rect.contains(mx, my)) {
                self.history_open = false;
                return;
            }
            for (self.history_items.items, 0..) |item, i| {
                if (i < self.layout.history_item_count and self.layout.history_item_rects[i].contains(mx, my)) {
                    self.navigateToUrl(item.url);
                    self.history_open = false;
                    return;
                }
            }
            if (self.layout.history_drawer_rect.contains(mx, my)) {
                return;
            }
        }

        // Tab [+] button click
        if (self.layout.tab_new_btn_rect.contains(mx, my)) {
            self.addNewTab() catch {};
            return;
        }

        // Tab [x] close click & tab selection click
        for (self.tabs.items, 0..) |_, i| {
            if (i < self.layout.tab_count) {
                if (self.layout.tab_close_rects[i].contains(mx, my)) {
                    self.closeTab(i) catch {};
                    return;
                }
                if (self.layout.tab_rects[i].contains(mx, my)) {
                    self.setActiveTab(i);
                    return;
                }
            }
        }

        // Explore click
        for (&self.explore_items, 0..) |*item, i| {
            if (i < 4 and self.layout.explore_item_rects[i].contains(mx, my)) {
                for (&self.explore_items) |*other| other.active = false;
                item.active = true;
                if (std.mem.eql(u8, item.name, "History")) {
                    self.toggleHistory();
                }
                return;
            }
        }

        // Start Page elements (viewport)
        if (self.getActiveTab()) |tab| {
            if (isStartPage(tab.url)) {
                // Search pills inside HUD
                if (self.layout.pill_google_rect.contains(mx, my)) {
                    self.search_engine = .google;
                    self.focus = .search_hud;
                    self.omnibar.focused = false;
                    return;
                }
                if (self.layout.pill_duck_rect.contains(mx, my)) {
                    self.search_engine = .duckduckgo;
                    self.focus = .search_hud;
                    self.omnibar.focused = false;
                    return;
                }

                // Shortcuts (GitHub, Rust Docs, Wayland Specs, Hajr Dev)
                for (self.shortcuts, 0..) |item, i| {
                    if (self.layout.shortcut_rects[i].contains(mx, my)) {
                        self.navigateToUrl(item.url);
                        return;
                    }
                }

                // Central Search HUD focus
                if (self.layout.start_search_rect.contains(mx, my)) {
                    self.focus = .search_hud;
                    self.omnibar.focused = false;
                    return;
                }
            }
        }

        // Omnibar focus
        if (self.layout.omnibar_rect.contains(mx, my)) {
            self.focus = .omnibar;
            self.omnibar.focused = true;
            if (self.omnibar.len > 0) {
                self.omnibar.len = 0;
                self.omnibar.cursor_pos = 0;
            }
        } else {
            self.focus = .none;
            self.omnibar.focused = false;
        }
    }

    pub fn recomputeLayout(self: *ShellState) void {
        for (self.tabs.items) |*tab| {
            tab.refreshSlices();
        }

        const w: f32 = @floatFromInt(self.window_width);
        const h: f32 = @floatFromInt(self.window_height);

        // Sidebar width is fixed at 260px matching official mockup
        const sidebar_w: f32 = 260.0;
        self.layout.sidebar_rect = Rect{ .x = 0, .y = 0, .w = sidebar_w, .h = h };
        self.layout.viewport_rect = Rect{ .x = sidebar_w, .y = 0, .w = w - sidebar_w, .h = h };

        // 1. Window controls (12px diameter dots with 8px gap)
        const dot_y: f32 = 18.0;
        const dot_size: f32 = 12.0;
        self.layout.dot_close_rect = Rect{ .x = 20.0, .y = dot_y, .w = dot_size, .h = dot_size };
        self.layout.dot_minimize_rect = Rect{ .x = 38.0, .y = dot_y, .w = dot_size, .h = dot_size };
        self.layout.dot_maximize_rect = Rect{ .x = 56.0, .y = dot_y, .w = dot_size, .h = dot_size };

        // 2. Header Area (Zawra emblem ~28x28 + bold white "Zawra")
        const header_y: f32 = 46.0;
        self.layout.header_logo_rect = Rect{ .x = 20.0, .y = header_y, .w = 26.0, .h = 26.0 };
        self.layout.header_title_pos = .{ 54.0, header_y + 4.0 };
        self.layout.header_subtitle_pos = .{ 54.0, header_y + 20.0 };

        // 3. Nav Cluster (Back, Forward, Reload)
        const nav_y: f32 = 82.0;
        self.layout.nav_back_rect = Rect{ .x = 20.0, .y = nav_y, .w = 26.0, .h = 24.0 };
        self.layout.nav_fwd_rect = Rect{ .x = 52.0, .y = nav_y, .w = 26.0, .h = 24.0 };
        self.layout.nav_reload_rect = Rect{ .x = 84.0, .y = nav_y, .w = 26.0, .h = 24.0 };

        // 4. Omnibar Container (pill with search icon)
        const omnibar_y: f32 = 116.0;
        self.layout.omnibar_rect = Rect{ .x = 16.0, .y = omnibar_y, .w = 228.0, .h = 34.0 };
        self.layout.search_icon_rect = Rect{ .x = 26.0, .y = omnibar_y + 10.0, .w = 14.0, .h = 14.0 };
        self.layout.address_text_pos = .{ 48.0, omnibar_y + 9.0 };

        // 5. Explore Section (History, Bookmarks, Downloads, Settings)
        const explore_y: f32 = 164.0;
        self.layout.explore_heading_pos = .{ 20.0, explore_y };

        const item_start_y: f32 = explore_y + 18.0;
        for (0..4) |i| {
            const item_y = item_start_y + @as(f32, @floatFromInt(i)) * 32.0;
            self.layout.explore_item_rects[i] = Rect{ .x = 16.0, .y = item_y, .w = 228.0, .h = 28.0 };
        }

        // 6. Tabs Section with interactive [+] new tab button
        const tabs_y: f32 = item_start_y + 4.0 * 32.0 + 14.0;
        self.layout.tabs_heading_pos = .{ 20.0, tabs_y };
        self.layout.tab_new_btn_rect = Rect{ .x = 216.0, .y = tabs_y - 2.0, .w = 26.0, .h = 20.0 };

        const tab_start_y: f32 = tabs_y + 22.0;
        const visible_tab_count = @min(self.tabs.items.len, 16);
        self.layout.tab_count = visible_tab_count;
        for (0..visible_tab_count) |i| {
            const ty = tab_start_y + @as(f32, @floatFromInt(i)) * 36.0;
            const trect = Rect{ .x = 16.0, .y = ty, .w = 228.0, .h = 32.0 };
            self.layout.tab_rects[i] = trect;
            self.layout.tab_close_rects[i] = Rect{
                .x = trect.x + trect.w - 22.0,
                .y = trect.y + (trect.h - 16.0) * 0.5,
                .w = 16.0,
                .h = 16.0,
            };
        }

        // 7. Sidebar footer: History, Settings, Collapse
        const footer_y: f32 = h - 38.0;
        self.layout.history_btn_rect = Rect{ .x = 16.0, .y = footer_y, .w = 70.0, .h = 28.0 };
        self.layout.history_btn_text_pos = .{ 34.0, footer_y + 6.0 };
        self.layout.settings_btn_rect = Rect{ .x = 90.0, .y = footer_y, .w = 72.0, .h = 28.0 };
        self.layout.collapse_btn_rect = Rect{ .x = 166.0, .y = footer_y, .w = 78.0, .h = 28.0 };

        // 8. History Drawer (slide-out glassmorphic panel)
        const drawer_w: f32 = 320.0;
        self.layout.history_drawer_rect = Rect{ .x = sidebar_w, .y = 0.0, .w = drawer_w, .h = h };
        self.layout.history_close_btn_rect = Rect{ .x = sidebar_w + drawer_w - 36.0, .y = 16.0, .w = 22.0, .h = 22.0 };
        const max_history_items = @min(self.history_items.items.len, 16);
        self.layout.history_item_count = max_history_items;
        for (0..max_history_items) |i| {
            self.layout.history_item_rects[i] = Rect{
                .x = sidebar_w + 14.0,
                .y = 70.0 + @as(f32, @floatFromInt(i)) * 52.0,
                .w = drawer_w - 28.0,
                .h = 44.0,
            };
        }

        // 9. Start Page Layout (viewport)
        const vp_cx = sidebar_w + (w - sidebar_w) * 0.5;
        const start_base_y: f32 = 110.0;

        self.layout.start_logo_rect = Rect{
            .x = vp_cx - 48.0,
            .y = start_base_y,
            .w = 96.0,
            .h = 96.0,
        };
        self.layout.start_title_pos = .{ vp_cx - 55.0, start_base_y + 96.0 + 16.0 };
        self.layout.start_subtitle_pos = .{ vp_cx - 140.0, start_base_y + 96.0 + 44.0 };

        const hud_w: f32 = 640.0;
        const hud_h: f32 = 46.0;
        const hud_y: f32 = start_base_y + 96.0 + 58.0;
        const hud_x: f32 = vp_cx - hud_w * 0.5;
        self.layout.start_search_rect = Rect{
            .x = hud_x,
            .y = hud_y,
            .w = hud_w,
            .h = hud_h,
        };
        self.layout.start_search_icon_rect = Rect{
            .x = hud_x + 16.0,
            .y = hud_y + 15.0,
            .w = 16.0,
            .h = 16.0,
        };
        self.layout.start_search_text_pos = .{ hud_x + 40.0, hud_y + 15.0 };

        // Embedded search pills inside HUD
        self.layout.pill_google_rect = Rect{
            .x = hud_x + hud_w - 196.0,
            .y = hud_y + 7.0,
            .w = 78.0,
            .h = 32.0,
        };
        self.layout.pill_duck_rect = Rect{
            .x = hud_x + hud_w - 110.0,
            .y = hud_y + 7.0,
            .w = 100.0,
            .h = 32.0,
        };

        // 4 Neumorphic Glass Quick-Dial Cards
        const cards_y: f32 = hud_y + hud_h + 36.0;
        const card_w: f32 = 140.0;
        const card_h: f32 = 105.0;
        const card_gap: f32 = 20.0;
        const total_cards_w = 4.0 * card_w + 3.0 * card_gap;
        const card_start_x = vp_cx - total_cards_w * 0.5;

        for (0..4) |i| {
            const fi: f32 = @floatFromInt(i);
            self.layout.shortcut_rects[i] = Rect{
                .x = card_start_x + fi * (card_w + card_gap),
                .y = cards_y,
                .w = card_w,
                .h = card_h,
            };
        }

        // Bottom right icons
        self.layout.sparkle_icon_rect = Rect{
            .x = w - 68.0,
            .y = h - 38.0,
            .w = 20.0,
            .h = 20.0,
        };
        self.layout.toggle_icon_rect = Rect{
            .x = w - 38.0,
            .y = h - 38.0,
            .w = 20.0,
            .h = 20.0,
        };

        // Notification pill
        const notif_w: f32 = 420.0;
        self.layout.notification_rect = Rect{
            .x = w - notif_w - 24.0,
            .y = h - 46.0,
            .w = notif_w,
            .h = 38.0,
        };
        self.layout.notification_visible = false;
    }
};

// ── Unit Tests ───────────────────────────────────────────────────────────────

test "boot with exactly 1 tab" {
    const allocator = std.testing.allocator;
    var state = try ShellState.init(allocator, 1280, 800);
    defer state.deinit();

    try std.testing.expectEqual(@as(usize, 1), state.tabs.items.len);
    try std.testing.expectEqualStrings("New Tab", state.tabs.items[0].title);
    try std.testing.expectEqualStrings("zawra://start", state.tabs.items[0].url);
    try std.testing.expect(state.tabs.items[0].active);
    try std.testing.expectEqual(FocusTarget.search_hud, state.focus);
}

test "addNewTab and closeTab functionality" {
    const allocator = std.testing.allocator;
    var state = try ShellState.init(allocator, 1280, 800);
    defer state.deinit();

    // Spawn 2nd tab
    try state.addNewTab();
    try std.testing.expectEqual(@as(usize, 2), state.tabs.items.len);
    try std.testing.expect(state.tabs.items[1].active);
    try std.testing.expect(!state.tabs.items[0].active);

    // Spawn 3rd tab
    try state.addNewTab();
    try std.testing.expectEqual(@as(usize, 3), state.tabs.items.len);
    try std.testing.expect(state.tabs.items[2].active);

    // Close 3rd tab -> 2nd tab becomes active
    try state.closeTab(2);
    try std.testing.expectEqual(@as(usize, 2), state.tabs.items.len);
    try std.testing.expect(state.tabs.items[1].active);

    // Close remaining tabs -> never leaves 0 tabs, spawns clean new tab
    try state.closeTab(1);
    try state.closeTab(0);
    try std.testing.expectEqual(@as(usize, 1), state.tabs.items.len);
    try std.testing.expect(state.tabs.items[0].active);
}

test "normaliseSearchOrUrl resolution" {
    var buf: [512]u8 = undefined;

    // Direct URLs
    const url1 = ShellState.normaliseSearchOrUrl(&buf, "https://example.com", .google);
    try std.testing.expectEqualStrings("https://example.com", url1);

    const url2 = ShellState.normaliseSearchOrUrl(&buf, "github.com", .google);
    try std.testing.expectEqualStrings("https://github.com", url2);

    // Search query with Google
    const q1 = ShellState.normaliseSearchOrUrl(&buf, "vulkan graphics guide", .google);
    try std.testing.expectEqualStrings("https://www.google.com/search?q=vulkan+graphics+guide", q1);

    // Search query with DuckDuckGo
    const q2 = ShellState.normaliseSearchOrUrl(&buf, "vulkan graphics guide", .duckduckgo);
    try std.testing.expectEqualStrings("https://duckduckgo.com/?q=vulkan+graphics+guide", q2);
}

test "search hud click to focus, typing and navigation" {
    const allocator = std.testing.allocator;
    var state = try ShellState.init(allocator, 1280, 800);
    defer state.deinit();

    // Click outside unfocuses
    state.handleMouseDown(500, 50);
    try std.testing.expectEqual(FocusTarget.none, state.focus);

    // Click on search hud focuses
    const hud = state.layout.start_search_rect;
    state.handleMouseDown(hud.x + 10, hud.y + 10);
    try std.testing.expectEqual(FocusTarget.search_hud, state.focus);

    // Type "wayland" (keycodes 17, 30, 21, 38, 30, 49, 32)
    state.handleKey(17, true, false); // w
    state.handleKey(30, true, false); // a
    state.handleKey(21, true, false); // y
    state.handleKey(38, true, false); // l
    state.handleKey(30, true, false); // a
    state.handleKey(49, true, false); // n
    state.handleKey(32, true, false); // d
    try std.testing.expectEqualStrings("wayland", state.search_hud_input.getText());

    // Backspace
    state.handleKey(14, true, false); // backspace deletes 'd'
    try std.testing.expectEqualStrings("waylan", state.search_hud_input.getText());

    // Switch search engine to DuckDuckGo via pill click
    const dp = state.layout.pill_duck_rect;
    state.handleMouseDown(dp.x + 5, dp.y + 5);
    try std.testing.expectEqual(SearchEngine.duckduckgo, state.search_engine);
    try std.testing.expectEqual(FocusTarget.search_hud, state.focus);

    // Press Enter (keycode 28)
    state.handleKey(28, true, false);
    // Tab url should now be navigated to duckduckgo search
    const active_tab = state.getActiveTab().?;
    try std.testing.expectEqualStrings("https://duckduckgo.com/?q=waylan", active_tab.url);
    try std.testing.expectEqual(FocusTarget.none, state.focus);
}
