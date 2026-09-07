import Quickshell
import QtQuick
import "../components"

PanelWindow{ // the parent, outter most
    anchors.top: true // anchors the dynamic island to top of the screen
    //margins.top: 8 // same as the gaps_out value from hyprland - remove because it made the panel start 8px off the top
    
    exclusionMode: ExclusionMode.Ignore // basically removes the resvered height that hyprland keeps as blank space

    implicitHeight: island.height + 8 // the space reserved for the island to be automatically the height of the island the plus 8 is to adjust for the 8px margins
    implicitWidth: island.width // the space reserved for the island to be automatically the width of the island

    color: "transparent" // hides the panel windows as the main bar is going to be the rectangle

    MouseArea{ // creates a area
        width: island.width // the width of the area is the same as the width for the island(rectangle)
        height: 10 // the height is 10
        z: 1 // makes the mouse area the top most layer
        y: 0 // makes the y-coordinate 0 so the area is a the direct top of the screen

        anchors.horizontalCenter: parent.horizontalCenter // being anchored to the horizontal center of the parent which here is the panel window

        hoverEnabled: true // makes sure that onEntered will run with just the presence of the mouse on the mouse area

        onEntered: { // when curosor enters selected area450
            hidetimer.stop() // stops the time, allows for the island to stay even if u take ur cursor off but put it back before timer ends
            island.islandVisible = true // sets the property to true setting y 
            enterAnimation.start() // starts the enter animation
        }
        onExited: { //when cursor leaves the selected area
            hidetimer.start() // starts the timer
        }

    }

    Timer{ // creates a timer
        id: hidetimer // basically names the timer to hidetimer

        interval: 1000 // lenght of timer
        repeat: false // when to repeat the timer

        onTriggered: { // what happens when the timer is done
            island.islandVisible = false // sets the property to false 
            exitAnimation.start() // starts the exit aimations
        }
    }

    Timer {
        id: volumeHideTimer

        interval: 1200
        repeat: false
        
        onTriggered: {
            island.showingVolume = false
        }
    }

    Rectangle { // the child insde the parent
         property bool islandVisible: false // creates a boolean variable(i think?) like in python its value can be true or false, controls visibility of island
         property bool showingVolume: false
        id: island // basically names the rectangle as island so it easier to refer to later  on

        width: showingVolume ? 350 : 200 // width for rectangle when showing volume when not showing volumes
        height: 50 // height for rectangle
        
        radius: 100 // raidus allows for curved or strigh edges
        
        color:  "Black" // color 
        
        y: -60 // hidden by default because now the y is controled by the animations

        Behavior on width {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }

        NumberAnimation {  // animations
            id: enterAnimation // names the animation to enter animatoin
            target: island // only targets the island(rectangle)
            property: "y" // what is changes
            to: 8 // what is changes the y too
            duration: 450 // duration of animation
            easing.type: Easing.OutCubic // animation curve
        }        

        NumberAnimation { // animations
            id: exitAnimation // names animation to exit animation
            target: island // affects the island
            property: "y" // only changes the y
            to: -60 // changes y to -60
            duration: 350 // duration
            easing.type: Easing.OutCubic //animation curve
        }
        Row {
            spacing: 10
            anchors.centerIn: parent


            Time {
                visible: !island.showingVolume
                id: time
                anchors.centerIn: parent
            } // brings in the time from Time.qml in components
            MediaVisual {
                visible: !island.showingVolume
                anchors.left: parent.horizontalCenter
                anchors.leftMargin: 45
                anchors.verticalCenter: parent.verticalCenter
            } // brinbgs in the media visualier.qml from components
            WorkspaceIcon {
                visible: !island.showingVolume
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.horizontalCenter
                anchors.rightMargin: 57.5
            }
            VolumeOSD {
                id: volumeOSD
                
                visible: island.showingVolume

                onCurrentVolumeChanged: {
                    island.showingVolume = true
                    volumeHideTimer.restart()
                }

                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
                