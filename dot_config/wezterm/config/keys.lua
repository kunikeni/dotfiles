return function(config, wezterm)
    local act = wezterm.action
    config.keys = {
        -- クリップボードからペースト
        { key = 'v', mods = 'CTRL', action = act.PasteFrom 'Clipboard' },

        -- プライマリ選択からペースト
        { key = 'v', mods = 'CTRL', action = act.PasteFrom 'PrimarySelection' },

    }
end
