import QtQuick
import Quickshell.Hyprland


Text {
    text: "󰆍"
    color: "white"

    font.family: "Roboto Mono"
    font.pixelSize: 20

    Component.onCompleted: {
        console.log("Monitors:", Hyprland.monitors.values)
    }
}