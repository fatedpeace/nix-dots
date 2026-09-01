
import Quickshell
import QtQuick

PanelWindow {
    id: root

    anchors.top: true

    exclusiveZone: 0
    margins.top: 8

    // The panel is transparent.
    color: "transparent"

    implicitWidth: island.width
    implicitHeight: island.height

    property bool expanded: false

    Rectangle {
        id: island

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

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 18
            anchors.verticalCenter: parent.verticalCenter

            text: "󰖯"
            color: "white"
            font.pixelSize: 18
        }

        Text {
            id: clock

            anchors.centerIn: parent

            text: Qt.formatTime(new Date(), "HH:mm")

            color: "white"
            font.pixelSize: 15
            font.bold: true
        }

        Timer {
            interval: 1000
            running: true
            repeat: true

            onTriggered: {
                clock.text = Qt.formatTime(new Date(), "HH:mm")
            }
        }

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
}

