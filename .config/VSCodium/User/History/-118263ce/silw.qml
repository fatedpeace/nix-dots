import Quickshell
import QtQuick

PanelWindow {
    id: root

    // Attach the window to the top of the screen.
    anchors.top: true

    // A Dynamic Island should float above windows without
    // reserving permanent desktop space.
    exclusiveZone: 0

    // Distance from the top edge.
    margins.top: 8

    // Keep the PanelWindow exactly as large as the island.
    implicitWidth: island.width
    implicitHeight: island.height

    // Center the island horizontally.
    // PanelWindow is positioned relative to the screen, so we use
    // the screen width minus the window width.
    property bool expanded: false

    Rectangle {
        id: island

        // Island size
        width: root.expanded ? 600 : 500
        height: root.expanded ? 60 : 40

        radius: height / 2
        color: "#111111"

        Behavior on width {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }

        // =========================
        // LEFT: WORKSPACE
        // =========================

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 18
            anchors.verticalCenter: parent.verticalCenter

            text: "󰖯"

            color: "white"
            font.pixelSize: 18
        }

        // =========================
        // CENTER: CLOCK
        // =========================

        Text {
            id: clock

            anchors.centerIn: parent

            color: "white"
            font.pixelSize: 15
            font.bold: true

            text: Qt.formatTime(new Date(), "HH:mm")
        }

        // Update the clock every second.
        Timer {
            interval: 1000
            running: true
            repeat: true

            onTriggered: {
                clock.text = Qt.formatTime(
                    new Date(),
                    "HH:mm"
                )
            }
        }

        // =========================
        // RIGHT: STATUS
        // =========================

        Rectangle {
            anchors.right: parent.right
            anchors.rightMargin: 18
            anchors.verticalCenter: parent.verticalCenter

            width: 8
            height: 8
            radius: width / 2

            color: "white"
        }

        // =========================
        // INTERACTION
        // =========================

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true

            onEntered: root.expanded = true
            onExited: root.expanded = false
        }
    }
}Failed to load configuration
  caused by @shell.qml[1:1]: Expected a qualified name id
```
