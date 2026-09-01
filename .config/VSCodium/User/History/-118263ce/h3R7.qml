
import Quickshell
import Quickshell.Hyprland
import QtQuick

PanelWindow {
    id: root

    // Attach to the top of the screen
    anchors.top: true

    // Don't reserve space
    exclusiveZone: 0

    // Transparent window background
    color: "transparent"

    // Temporary trigger area
    implicitWidth: 1920
    implicitHeight: 80

    // Controls whether the island is visible
    property bool islandVisible: false

    // Find the currently focused workspace
    property int workspaceNumber: {
        for (let i = 0; i < Hyprland.workspaces.values.length; i++) {
            const workspace = Hyprland.workspaces.values[i]

            if (workspace.focused) {
                return workspace.id
            }
        }

        return 0
    }

    // =========================
    // DYNAMIC ISLAND
    // =========================

    Rectangle {
        id: island

        width: 200
        height: 50

        anchors.horizontalCenter: parent.horizontalCenter

        radius: height / 2
        color: "#111111"

        // Show or hide the island
        y: root.islandVisible ? 8 : -height

        Behavior on y {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }

        // =========================
        // CENTER CONTENT
        // =========================

        Row {
            anchors.centerIn: parent

            // Gap between workspace number and time
            spacing: 20

            // Workspace number
            Text {
                text: root.workspaceNumber

                color: "white"
                font.pixelSize: 15
                font.bold: true
            }

            // Clock
            Text {
                id: clock

                text: Qt.formatTime(
                    new Date(),
                    "HH:mm"
                )

                color: "white"
                font.pixelSize: 15
                font.bold: true
            }
        }

        // =========================
        // RIGHT STATUS INDICATOR
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
    }

    // =========================
    // TOP EDGE TRIGGER
    // =========================

    MouseArea {
        anchors.fill: parent

        hoverEnabled: true

        onEntered: {
            root.islandVisible = true
        }

        onExited: {
            root.islandVisible = false
        }
    }

    // =========================
    // CLOCK UPDATE
    // =========================

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
}
