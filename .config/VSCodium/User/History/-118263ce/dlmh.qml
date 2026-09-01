
import Quickshell
import QtQuick

PanelWindow {
    id: root

    // Attach to the top of the screen
    anchors.top: true

    // Don't reserve space on the desktop
    exclusiveZone: 0

    // Transparent PanelWindow background
    color: "transparent"

    // Trigger area size
    implicitWidth: 1920
    implicitHeight: 80

    // Controls whether the island is shown
    property bool islandVisible: false

    // =========================
    // DYNAMIC ISLAND
    // =========================

    Rectangle {
        id: island

        // Island size
        width: 500
        height: 40

        // Center horizontally
        anchors.horizontalCenter: parent.horizontalCenter

        // Pill shape
        radius: height / 2

        // Island color
        color: "#111111"

        // Hidden above the screen
        // Visible with an 8px gap from the top
        y: root.islandVisible ? 8 : -height

        // Smooth slide animation
        Behavior on y {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }

        // =========================
        // LEFT SIDE
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
        // CENTER CLOCK
        // =========================

        Text {
            id: clock

            anchors.centerIn: parent

            color: "white"
            font.pixelSize: 15
            font.bold: true

            text: Qt.formatTime(new Date(), "HH:mm")
        }

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
        // RIGHT SIDE
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
}
