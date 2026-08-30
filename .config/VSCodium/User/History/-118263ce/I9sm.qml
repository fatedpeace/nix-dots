import Quickshell 
import QtQuick 

PanelWindow {
  anchors {
    top: true
    left: false
    right: false
  }
  exclusiveZone: 40
  margins.top: 8
  implicitHeight: 10
  implictWidth: 10
  Rectangle { 
    anchors.fill: parent
}
}