import Quickshell 
import QtQuick 

PanelWindow {
  anchors.top: true
 // Attaches the island window to the top of the screen
  exclusiveZone: 40
  margins.top: 8
  implicitHeight: 40
  implicitWidth: 500
  Rectangle { 
    anchors.fill: parent
}
}