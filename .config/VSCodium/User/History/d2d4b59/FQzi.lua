----------------
----KEYBINDS----
----------------



local mainMod = "SUPER" -- Sets Windows key as the main modifier
local closeWindowBind = hl.bind(mainMod .. " + W", hl.dsp.window.close()) -- command to close windows

-- Execution of programs
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("kitty yazi"))
--hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("rofi -show drun"))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("hyprlock"))

-- Moving focus using vim key
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left"}))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down"}))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up"}))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right"}))

-- Altering windows
hl.bind(mainMod .." + F", hl.dsp.window.fullscreen({ fullscreen, action = "toggle"})) --Toggles fullscreen window
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" })) --Toggles floating window

-- Switching between workspaces and moving active windows to a workspace
for i = 1, 10 do
	local key = i % 10 -- makes 10 the 0 key
	hl.bind(mainMod .. " + " .. key,			hl.dsp.focus({ workspace = i}))
	hl.bind(mainMod .. " + SHIFT + " .. key, 		hl.dsp.window.move({ workspace = i}))
end

-- Moving and resizing windows with mouse keys
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),	{ mouse = true})
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(),	{ mouse = true})

-- Exiting hyprland
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("command -v hyprs:hutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(
    "CTRL + ALT + bracketright",
    hl.dsp.global("quickshell:volume-up")
)

hl.bind(
    "CTRL + ALT + bracketleft",
    hl.dsp.global("quickshell:volume-down")
)