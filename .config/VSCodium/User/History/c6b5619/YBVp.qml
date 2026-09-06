import Quickshell
import QtQuick

PanelWindow{ // the parent, outter most
    anchors.top: true // anchors the dynamic island to top of the screen
    margins.top: 8 // same as the gaps_out value from hyprland
    
    implicitHeight: island.height // the space reserved for the island to be automatically the height of the island
    implicitWidth: island.width // the space reserved for the island to be automatically the width of the island

    color: "transparent" // hides the panel windows as the main bar is going to be the rectangle

    MouseArea{ // creates a area
        width: island.width // the width of the area is the same as the width for the island(rectangle)
        height: island.height // the height is 10
        z: 1
        y: 0

        anchors.horizontalCenter: parent.horizontalCenter // being anchored to the horizontal center of the parent which here is the panel window

        hoverEnabled: true // makes sure that onEntered will run with just the presence of the mouse on the mouse area

        onEntered: { // when curosor enters selected area
            hidetimer.stop() // stops the time, allows for the island to stay even if u take ur cursor off but put it back before timer ends
            island.islandVisible = true // sets the property to true setting y of bar to 0, shows island when cursor goes up
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
            island.islandVisible = false // sets the property to false setting the y for the island to -60, basically hiding the island after time
        }
    }

    Rectangle { // the child insde the parent
         property bool islandVisible: false // creates a boolean variable(i think?) like in python its value can be true or false, controls visibility of island

        id: island // basically names the rectangle as island so it easier to refer to later  on

        width: 250 // width for rectangle
        height: 40 // height for rectangle
        
        radius: 60 // raidus allows for curved or strigh edges
        
        color:  "Black" // color 
        
        y: islandVisible ? 0 : -60 // dectects the value for the property islandVisibile and if true it sets y = 0 and if false it sets it to y = -60
    }
}