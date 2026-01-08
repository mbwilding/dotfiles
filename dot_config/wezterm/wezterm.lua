local w = require("wezterm")
local a = w.action
local c = w.config_builder()
local tt = w.target_triple

local mac = tt == "x86_64-apple-darwin" or tt == "aarch64-apple-darwin"
local linux = tt == "x86_64-unknown-linux-gnu"
local windows = not mac and not linux

-- Plugins
local resurrect = w.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")
-- w.plugin.update_all()

-- Terminal Info
c.term = "wezterm"

-- Rendering
c.freetype_load_target = "Normal"
c.freetype_render_target = "Normal"

-- Window
c.initial_cols = mac and 120 or 120
c.initial_rows = mac and 30 or 36

-- Transparency
c.window_background_opacity = mac and 0.85 or 0.99

c.font = w.font("NeoSpleen Nerd Font", { weight = "Regular" })
c.line_height = 1.0
c.font_size = mac and 20.0 or 17.0

c.adjust_window_size_when_changing_font_size = false
c.bold_brightens_ansi_colors = false
c.enable_kitty_graphics = true

-- Padding
c.window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
}

-- Tab Bar
c.enable_tab_bar = true
c.hide_tab_bar_if_only_one_tab = true
c.show_tab_index_in_tab_bar = false
c.tab_bar_at_bottom = true
c.use_fancy_tab_bar = false
c.tab_and_split_indices_are_zero_based = true

-- General
c.automatically_reload_config = true
c.inactive_pane_hsb = { saturation = 1.0, brightness = 1.0 }
c.window_close_confirmation = "NeverPrompt"
c.selection_word_boundary = " \t\n{}[]()\"'`,;:"
c.warn_about_missing_glyphs = false
c.check_for_updates = false
c.pane_focus_follows_mouse = true
c.force_reverse_video_cursor = true

-- SSH Domains
-- c.ssh_domains = {
--   {
--     name = "desktop",
--     remote_address = "desktop",
--     username = "anon",
--     default_prog = { "zsh" },
--     remote_wezterm_path = "/home/anon/dev/wezterm/target/release/wezterm",
--   },
-- }

-- Platform Specific
local leader = "CTRL|SHIFT|ALT|SUPER"
if linux then
    -- Fix for https://github.com/wez/wezterm/issues/5990
    -- c.front_end = "WebGpu"
    -- c.webgpu_power_preference = "HighPerformance"
    c.max_fps = 120
    c.enable_wayland = true
elseif windows then
    -- c.front_end = "OpenGL"
    c.max_fps = 120
    c.default_prog = { "pwsh", "-NoLogo" }
    -- c.default_domain = "WSL:Arch"
elseif mac then
    c.front_end = "WebGpu" --"OpenGL"
    c.max_fps = 60
    c.native_macos_fullscreen_mode = false

    leader = "CMD"
    -- c.leader = { key = "", mods = "CMD", timeout_milliseconds = 1000 }

    -- Pad top of window when in full screen mode due to camera notch
    local function recompute_padding(window)
        local window_dims = window:get_dimensions()
        local overrides = window:get_config_overrides() or {}

        if not window_dims.is_full_screen then
            if not overrides.window_padding then
                return
            end
            overrides.window_padding = nil
        else
            local new_padding = {
                left = 0,
                right = 0,
                top = 35,
                bottom = 0,
            }
            if
                overrides.window_padding
                and new_padding.top == overrides.window_padding.top
            then
                return
            end
            overrides.window_padding = new_padding
        end
        window:set_config_overrides(overrides)
    end

    w.on("window-resized", function(window, pane)
        recompute_padding(window)
    end)

    w.on("window-config-reloaded", function(window)
        recompute_padding(window)
    end)
end

-- Keybinds
c.debug_key_events = false
c.disable_default_key_bindings = true
c.keys = {
    -- { mods = "LEADER",     key = "Space", action = a.RotatePanes "Clockwise" },
    -- { mods = "LEADER",     key = "a",     action = a.PaneSelect { mode = "SwapWithActive" } },
    -- { mods = "LEADER",     key = "s",     action = a.SplitVertical { domain = "CurrentPaneDomain" } },
    -- { mods = "LEADER",     key = "v",     action = a.SplitHorizontal { domain = "CurrentPaneDomain" } },
    -- { mods = "LEADER",     key = "z",     action = a.TogglePaneZoomState },
    { mods = "",     key = "F11",   action = a.ToggleFullScreen },
    { mods = "CTRL", key = "-",     action = a.DecreaseFontSize },
    { mods = "CTRL", key = "0",     action = a.ResetFontSize },
    { mods = "CTRL", key = "=",     action = a.IncreaseFontSize },
    { mods = leader, key = "c",     action = a({ CopyTo = "ClipboardAndPrimarySelection" }) },
    { mods = leader, key = "h",     action = a({ ActivateTabRelative = -1 }) },
    { mods = leader, key = "l",     action = a({ ActivateTabRelative = 1 }) },
    { mods = leader, key = "q",     action = a({ CloseCurrentTab = { confirm = false } }) },
    { mods = leader, key = "n",     action = a({ SpawnTab = "CurrentPaneDomain" }) },
    { mods = leader, key = "v",     action = a({ PasteFrom = "Clipboard" }) },
    { mods = leader, key = "w",     action = a({ CloseCurrentPane = { confirm = false } }) },
    { mods = leader, key = "x",     action = "ActivateCopyMode" },
    { mods = leader, key = "Enter", action = a.ActivateCopyMode },
    { mods = leader, key = "f",     action = a.ToggleFullScreen },

    -- Resurrect
    ---- Save workspace
    { mods = leader, key = "z",     action = w.action_callback(function(win, pane) resurrect.save_state(resurrect
        .workspace_state.get_workspace_state()) end), },
    ---- Save window
    { mods = leader, key = "W",     action = resurrect.window_state.save_window_action(), },
    ---- Save tab
    { mods = leader, key = "T",     action = resurrect.tab_state.save_tab_action(), },
    ---- Save state
    { mods = leader, key = "s",     action = w.action_callback(function(win, pane) resurrect.save_state(resurrect.workspace_state.get_workspace_state()) resurrect.window_state.save_window_action() end), },
    ---- Load state
    {
        key = "r",
        mods = leader,
        action = w.action_callback(function(win, pane)
            resurrect.fuzzy_load(win, pane, function(id, label)
                local type = string.match(id, "^([^/]+)") -- match before '/'
                id = string.match(id, "([^/]+)$") -- match after '/'
                id = string.match(id, "(.+)%..+$") -- remove file extention
                local opts = {
                    relative = true,
                    restore_text = true,
                    on_pane_restore = resurrect.tab_state.default_on_pane_restore,
                }
                if type == "workspace" then
                    local state = resurrect.load_state(id, "workspace")
                    resurrect.workspace_state.restore_workspace(state, opts)
                elseif type == "window" then
                    local state = resurrect.load_state(id, "window")
                    resurrect.window_state.restore_window(pane:window(), state, opts)
                elseif type == "tab" then
                    local state = resurrect.load_state(id, "tab")
                    resurrect.tab_state.restore_tab(pane:tab(), state, opts)
                end
            end)
        end),
    },
}

---- Tab navigation (Can't use our leader with numbers)
for i = 0, 9 do
    table.insert(c.keys, {
        key = tostring(i),
        mods = leader,
        action = a.ActivateTab(i),
    })
end

-- Tab Bar
c.colors = {
    tab_bar = {
        background = 'NONE',

        new_tab = {
            bg_color = 'NONE',
            fg_color = '#ffb083',
        },
        new_tab_hover = {
            bg_color = 'NONE',
            fg_color = '#c191ff',
            italic = true,
        },
    },
}

local SOLID_LEFT_ARROW = w.nerdfonts.pl_right_hard_divider

local SOLID_RIGHT_ARROW = w.nerdfonts.pl_left_hard_divider

local function tab_title(tab_info)
    local title = tab_info.tab_title
    if title and #title > 0 then
        return title
    end
    return tab_info.active_pane.title
end

w.on(
    'format-tab-title',
    function(tab, tabs, panes, config, hover, max_width)
        local edge_background = 'NONE'
        local background = '#91c2ff'
        local foreground = '#000000'

        if tab.is_active then
            background = '#c191ff'
            foreground = '#000000'
        elseif hover then
            background = '#ffb083'
            foreground = '#ffffff'
        end

        local edge_foreground = background

        local title = tab_title(tab)

        title = w.truncate_right(title, max_width - 2)

        return {
            { Background = { Color = edge_background } },
            { Foreground = { Color = edge_foreground } },
            { Text = SOLID_LEFT_ARROW },
            { Background = { Color = background } },
            { Foreground = { Color = foreground } },
            { Text = title },
            { Background = { Color = edge_background } },
            { Foreground = { Color = edge_foreground } },
            { Text = SOLID_RIGHT_ARROW },
        }
    end
)

return c
