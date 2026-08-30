import Quickshell 
import QtQuick 

PanelWindow {
  anchors {
    top: true
    left: false
    right: false
  }
  exclusiveZone: 40
  

  Rectangle { 
    anchors {
      top: parent.top
      left: parent.left
      right: parent.right
      bottom: parent.bottom
    }
}
}