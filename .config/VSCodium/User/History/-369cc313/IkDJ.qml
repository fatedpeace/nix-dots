import QtQuick

Item { // invisible container that can or cannot display anything
    width: 50 // dimensions for container
    height: 24 // dimensions for container

    Row { // layout container so everything in this will be inline horizontally
        anchors.centerIn: parent // anchored to the center of parent
        spacing: 4 // how far apart is each thing 

        Repeater { // repeats
            model: 4 // repeates 7 times

            Rectangle { // visible container that is a rectangle
                property int targetHeight: 8
                Timer {
                    interval: 700
                    running: true
                    repeat: true

                    onTriggered: {
                        targetHeight = 4 + Math.random() * 12
                    }
                }
                width: 4 // width of rectangle
                    height: targetHeight
                radius: 2 // corner raidus of rectanlge
                color: "white" // color of rectangle

                anchors.verticalCenter: parent.verticalCenter // anchored to the vertical center of row

                Behavior on height {
                    NumberAnimation {
                        duration: 500
                        easing.type: Easing.InOutSine
                    }
                }
            
            }
        }
    }
}