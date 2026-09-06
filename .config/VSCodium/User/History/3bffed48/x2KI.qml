import QtQuick

Text { // text
    color: "white" // colored white
    font.family: "Roboto Mono" // cool font can also use google sans code
    font.pixelSize: 20 // font size
   font.weight: Font.Bold // font weight

    text: Qt.formatTime(new Date(), "HH:mm") // the text it shows is the time in 24 hr format in hh:mm

    Timer { //timer to check the time every 1 second
        interval: 1000 // check every  1 sec
        running: true // always running
        repeat: true // repeatedly running

        onTriggered: { // every time timer is up
            Qt.formatTime(new Date(), "HH:mm") //updates time
        }
    }
}