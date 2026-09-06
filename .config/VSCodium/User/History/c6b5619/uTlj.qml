import Quickshell
import QtQuick

PanelWindow{ // the parent, outter most
    anchors.top: true // anchors the dynamic island to top of the screen
    margins.top: 8 // same as the gaps_out value from hyprland
    
    implicitHeight: island.height // the space reserved for the island to be automatically the height of the island
    implicitWidth: island.width // the space reserved for the island to be automatically the width of the island

    color: "transparent" // hides the panel windows as the main bar is going to be the rectangle

    Rectangle { // the child insde the parent
         property bool islandVisible: true // creates a boolean variable(i think?) like in python its value can be true or false, controls visibility of island

        id:island // basically names the rectangle as island so it easier to refer to later  on

        width: 500 // width for rectangle
        height: 60 // height for rectangle
        
        radius: 60 // raidus allows for curved or strigh edges
        
        color:  "Black" // color 
        
        y: islandVisible ? 0 : -60 // dectects the value for the property islandVisibile and if true it sets y = 0 and if false it sets it to y = -60

        MouseArea{
            anchors.fill: parent

            onEntered {
                island.islandVisibile = false
            }
        }
    
    }
}