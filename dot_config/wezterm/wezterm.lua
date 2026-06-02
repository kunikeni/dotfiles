local wezterm = require 'wezterm'
local config = {}

if wezterm.config_builder then
    config = wezterm.config_builder()
end

config.default_prog = { 'pwsh' }         -- pwsh
config.use_ime = true                    -- IMEを有効にする
config.color_scheme = 'Materia (base16)' -- カラースキーム
config.font_size = 12
config.enable_scroll_bar = true          -- スクロールバー
config.initial_rows = 36                 -- 画面サイズ
config.initial_cols = 80
config.window_background_opacity = 0.85  -- 背景透過
config.macos_window_background_blur = 20 -- 背景ぼかし
config.window_decorations = "RESIZE"     -- タイトルバーの削除
config.show_new_tab_button_in_tab_bar = false
config.window_close_confirmation = 'AlwaysPrompt'
config.default_cursor_style = 'BlinkingUnderline'

local act = wezterm.action
config.keys = {
    -- クリップボードからペースト
    { key = 'v', mods = 'CTRL', action = act.PasteFrom 'Clipboard' },

    -- プライマリ選択からペースト
    { key = 'v', mods = 'CTRL', action = act.PasteFrom 'PrimarySelection' },

}

return config
