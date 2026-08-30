import Quickshell 
import QtQuick 

PanelWindow {
  anchors.top: true // Attaches the island window to the top of the screen
  exclusiveZone: 40 // Save 40px of space at the top of the screen for the bar to be seen clearly. Remove when done
  margins.top: 8 // Leave a 8px gap from top of the screen matches the hyprland outward margin
  implicitHeight: 40 // Height of 40px
  implicitWidth: 500 // Wdith of 500px
  Rectangle { 
    //anchors.fill: parent // Makes the anchors for the rectangle the same the ones for the panelwindow
    width: 600
    height: 40
    radius: height / 2
    color: "red"
}
}