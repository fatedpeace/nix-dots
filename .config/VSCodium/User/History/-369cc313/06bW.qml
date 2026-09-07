import QtQuick

Item { // invisible container that can or cannot display anything
    width: 50 // dimensions for container
    height: 24 // dimensions for container

    Row { // layout container so everything in this will be inline horizontally
        anchors.centerIn: parent // anchored to the center of parent
        spacing: 4 // how far apart each thing is

        Repeater { // repeats
            model: 4 // repeats 4 times

            Rectangle { // visible rectangle
                property int targetHeight: 8

                Timer {
                    interval: 900
                    running: true
                    repeat: true

                    onTriggered: {
                        targetHeight = 6 + Math.random() * 8
                    }
                }

                width: 4
                height: targetHeight

                radius: 2
                color: "white"

                anchors.verticalCenter: parent.verticalCenter

                Behavior on height {
                    NumberAnimation {
                        duration: 900
                        easing.type: Easing.InOutSine
                    }
                }
            }
        }
    }
}