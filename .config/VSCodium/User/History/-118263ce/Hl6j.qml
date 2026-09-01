import Quickshell
import Quickshell.Hyprland
import QtQuick

PanelWindow {
    id: root

    anchors.top: true

    exclusiveZone: 0

    margins.top: 8

    color: "transparent"

    implicitWidth: island.width
    implicitHeight: island.height

    property int workspaceNumber: {
        for (let i = 0; i < Hyprland.workspaces.values.length; i++) {
            const workspace = Hyprland.workspaces.values[i]

            if (workspace.focused) {
                return workspace.id
            }
        }

        return 0
    }

    Rectangle {
        id: island

        width: 500
        height: 40

        anchors.horizontalCenter: parent.horizontalCenter

        radius: height / 2
        color: "#111111"

        // =========================
        // LEFT SIDE: WORKSPACE
        // =========================

        Text {
            id: workspaceText

            anchors.left: parent.left
            anchors.leftMargin: 18
            anchors.verticalCenter: parent.verticalCenter

            text: "󰖯 " + root.workspaceNumber

            color: "white"
            font.pixelSize: 16
        }

        // =========================
        // CENTER: WORKSPACE + TIME
        // =========================

        Row {
            anchors.centerIn: parent

            spacing: 20

            Text {
                text: "󰖯 " + root.workspaceNumber

                color: "white"
                font.pixelSize: 15
                font.bold: true
            }

            Text {
                id: clock

                color: "white"
                font.pixelSize: 15
                font.bold: true

                text: Qt.formatTime(
                    new Date(),
                    "HH:mm"
                )
            }
        }

        // =========================
        // RIGHT SIDE: STATUS
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

    // Update clock
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