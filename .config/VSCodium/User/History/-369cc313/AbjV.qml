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
                width: 4 // width of rectangle
                    height: index === 0 ? 6 :
                            index === 1 ? 14 :
                            index === 2 ? 9 :
                             5
                radius: 2 // corner raidus of rectanlge
                color: "white" // color of rectangle

                anchors.verticalCenter: parent.verticalCenter // anchored to the vertical center of row

                SequentialAnimation on height {
                    loops: Animation.Infinite

                    PauseAnimation {
                        duration: index * 120
                    }

                    NumberAnimation {
                        to: 14
                        duration: 560
                    }

                    NumberAnimation {
                        to: 6
                        duration: 440
                    }

                    NumberAnimation {
                        to: 11
                        duration: 420
                    }

                    NumberAnimation {
                        to: 4
                        duration: 490
                    }
                }
            
            }
        }
    }
}