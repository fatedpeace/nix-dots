```qml
import Quickshell
import QtQuick

PanelWindow {
    id: root

    // Attach the island to the top of the screen
    anchors.top: true

    // Floating island — don't reserve permanent bar space
    exclusiveZone: 0

    // Gap from the top of the screen
    margins.top: 8

    // Center the window horizontally
    implicitWidth: island.width
    implicitHeight: island.height

    // =========================
    // DYNAMIC ISLAND
    // =========================

    Rectangle {
        id: island

        // Starting / idle size
        width: 500
        height: 40

        radius: height / 2

        color: "#111111"

        // Smooth animation when the island changes size
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
        // CONTENT
        // =========================

        Item {
            anchors.fill: parent
            anchors.leftMargin: 18
            anchors.rightMargin: 18

            // -------------------------
            // LEFT SIDE
            // Workspace
            // -------------------------

            Text {
                id: workspace

                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                text: "󰖯"

                color: "white"
                font.pixelSize: 18
            }

            // -------------------------
            // CENTER
            // CLOCK
            // -------------------------

            Text {
                id: clock

                anchors.centerIn: parent

                color: "white"

                font.pixelSize: 15
                font.bold: true

                text: Qt.formatTime(
                    new Date(),
                    "HH:mm"
                )

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

            // -------------------------
            // RIGHT SIDE
            // Status indicator
            // -------------------------

            Rectangle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                width: 8
                height: 8

                radius: width / 2

                color: "#ffffff"
            }
        }

        // =========================
        // INTERACTION
        // =========================

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true

            onEntered: {
                island.width = 600
                island.height = 60
            }

            onExited: {
                island.width = 500
                island.height = 40
            }
        }
    }
}
```
