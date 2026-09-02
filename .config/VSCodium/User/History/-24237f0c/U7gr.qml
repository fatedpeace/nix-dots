
import Quickshell
import QtQuick

PanelWindow {
    id: root

    // =========================
    // PANEL
    // =========================

    anchors.top: true
    anchors.right: true

    exclusiveZone: 0
    color: "transparent"

    implicitWidth: 360
    implicitHeight: 500

    // =========================
    // SETTINGS
    // =========================

    property bool expanded: false
    property string mainFont: "Roboto Mono"

    // =========================
    // CONTROL CENTER
    // =========================

    Rectangle {
        id: controlCenter

        width: 340
        height: root.expanded ? 460 : 50

        anchors.top: parent.top
        anchors.right: parent.right

        anchors.topMargin: 8
        anchors.rightMargin: 8

        radius: 24
        color: "#111111"

        clip: true

        Behavior on height {
            NumberAnimation {
                duration: 320
                easing.type: Easing.OutCubic
            }
        }

        // =========================
        // COMPACT MODE
        // =========================

        Row {
            id: compactContent

            anchors.centerIn: parent
            spacing: 18

            opacity: root.expanded ? 0 : 1

            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                }
            }

            Text {
                text: "󰖩"

                color: "white"

                font.family: root.mainFont
                font.pixelSize: 18
            }

            Text {
                text: "󰂯"

                color: "white"

                font.family: root.mainFont
                font.pixelSize: 18
            }

            Text {
                text: "󰕾"

                color: "white"

                font.family: root.mainFont
                font.pixelSize: 18
            }
        }

        // =========================
        // EXPANDED CONTENT
        // =========================

        Item {
            id: expandedContent

            anchors.fill: parent

            opacity: root.expanded ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutCubic
                }
            }

            // =========================
            // WIFI
            // =========================

            Rectangle {
                id: wifiCard

                width: 150
                height: 110

                anchors.left: parent.left
                anchors.top: parent.top

                anchors.leftMargin: 16
                anchors.topMargin: 70

                radius: 18
                color: "#252525"

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 15

                    anchors.top: parent.top
                    anchors.topMargin: 15

                    text: "󰖩"

                    color: "white"

                    font.family: root.mainFont
                    font.pixelSize: 20
                }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 15

                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 15

                    text: "Wi-Fi"

                    color: "white"

                    font.family: root.mainFont
                    font.pixelSize: 15
                    font.weight: Font.DemiBold
                }
            }

            // =========================
            // BLUETOOTH
            // =========================

            Rectangle {
                id: bluetoothCard

                width: 150
                height: 110

                anchors.right: parent.right
                anchors.top: parent.top

                anchors.rightMargin: 16
                anchors.topMargin: 70

                radius: 18
                color: "#252525"

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 15

                    anchors.top: parent.top
                    anchors.topMargin: 15

                    text: "󰂯"

                    color: "white"

                    font.family: root.mainFont
                    font.pixelSize: 20
                }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 15

                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 15

                    text: "Bluetooth"

                    color: "white"

                    font.family: root.mainFont
                    font.pixelSize: 15
                    font.weight: Font.DemiBold
                }
            }

            // =========================
            // SOUND
            // =========================

            Rectangle {
                id: soundCard

                width: 308
                height: 90

                anchors.horizontalCenter: parent.horizontalCenter

                anchors.top: wifiCard.bottom
                anchors.topMargin: 16

                radius: 18
                color: "#252525"

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 18

                    anchors.verticalCenter: parent.verticalCenter

                    text: "󰕾"

                    color: "white"

                    font.family: root.mainFont
                    font.pixelSize: 22
                }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 55

                    anchors.verticalCenter: parent.verticalCenter

                    text: "Sound"

                    color: "white"

                    font.family: root.mainFont
                    font.pixelSize: 15
                    font.weight: Font.DemiBold
                }
            }

            // =========================
            // POWER BUTTONS
            // =========================

            Row {
                anchors.horizontalCenter: parent.horizontalCenter

                anchors.bottom: parent.bottom
                anchors.bottomMargin: 25

                spacing: 22

                // Lock
                Rectangle {
                    width: 62
                    height: 50

                    radius: 16
                    color: "#252525"

                    Text {
                        anchors.centerIn: parent

                        text: "󰌾"

                        color: "white"

                        font.family: root.mainFont
                        font.pixelSize: 20
                    }
                }

                // Reboot
                Rectangle {
                    width: 62
                    height: 50

                    radius: 16
                    color: "#252525"

                    Text {
                        anchors.centerIn: parent

                        text: "󰜉"

                        color: "white"

                        font.family: root.mainFont
                        font.pixelSize: 20
                    }
                }

                // Shutdown
                Rectangle {
                    width: 62
                    height: 50

                    radius: 16
                    color: "#252525"

                    Text {
                        anchors.centerIn: parent

                        text: "󰐥"

                        color: "white"

                        font.family: root.mainFont
                        font.pixelSize: 20
                    }
                }
            }
        }

        // =========================
        // CLICK HANDLER
        // =========================

        MouseArea {
            anchors.fill: parent

            onClicked: {
                root.expanded = !root.expanded
            }
        }
    }
}
