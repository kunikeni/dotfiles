local wezterm = require 'wezterm'
local shell = require 'config.shell'
local input = require 'config.input'
local appearance = require 'config.appearance'
local window = require 'config.window'
local keys = require 'config.keys'
local config = {}

if wezterm.config_builder then
    config = wezterm.config_builder()
end

shell(config)
input(config)
appearance(config)
window(config)
keys(config, wezterm)

return config
