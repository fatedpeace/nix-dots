---------------
--- AUTOSTART ---
---------------

hl.on("hyprland.start", function()
	hl.exec_cmd("kitty")
	hl.exec_cmd("awww-daemon")
end)
f