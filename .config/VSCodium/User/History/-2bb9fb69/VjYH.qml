import QtQuick
import Quickshell.hyprland


Text {
    text: "󰆍"
    color: "white"

    font.family: "Roboto Mono"
    font.pixelSize: 20

    Component.onCompleted: {
        console.log("Current workspace:", Hyprland.focusedWorkspace?.id)
    }
}