---------------
---AUTOSTART---
---------------

hl.on("hyprland.start", function ()
	hl.exec_cmd(terminal)
	hl.exec_cmd("waybar")
	hl.exec_cm("awww-daemon")
end)
