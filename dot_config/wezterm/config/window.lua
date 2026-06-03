return function(config)
    config.enable_scroll_bar = true          -- スクロールバー
    config.initial_rows = 36                 -- 画面サイズ
    config.initial_cols = 80
    config.window_background_opacity = 0.85  -- 背景透過
    config.macos_window_background_blur = 20 -- 背景ぼかし
    config.window_decorations = "RESIZE"     -- タイトルバーの削除
    config.show_new_tab_button_in_tab_bar = false
    config.window_close_confirmation = 'AlwaysPrompt'
end
