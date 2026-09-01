
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import QtQuick

PanelWindow {
    id: root

    // Attach the window to the top edge of the screen
    anchors.top: true

    // Stretch the PanelWindow across the entire top edge
    anchors.left: true
    anchors.right: true

    // Do not reserve desktop space
    exclusiveZone: 0

    // Transparent background
    color: "transparent"

    // The trigger area is the full width of the monitor
    implicitHeight: 80

    // =========================
    // ISLAND VISIBILITY
    // =========================

    property bool islandVisible: false

    // =========================
    // WORKSPACES
    // =========================

    property var workspaceEmojis: [
        "🌐", // 1
        "💻", // 2
        "📁", // 3
        "🎵", // 4
        "💬", // 5
        "🎮", // 6
        "🎬", // 7
        "📝", // 8
        "⚙️", // 9
        "🏠"  // 10
    ]

    property int workspaceId: {
        if (Hyprland.focusedWorkspace) {
            return Hyprland.focusedWorkspace.id
        }

        return 1
    }

    property string workspaceEmoji: {
        if (workspaceId >= 1
                && workspaceId <= workspaceEmojis.length) {
            return workspaceEmojis[workspaceId - 1]
        }

        return "📍"
    }

    // =========================
    // MEDIA
    // =========================

    property var mediaPlayer:
        Mpris.players.values.length > 0
        ? Mpris.players.values[0]
        : null

    property bool mediaPlaying:
        mediaPlayer !== null
        && mediaPlayer.isPlaying

    property string mediaTitle:
        mediaPlayer !== null
        ? mediaPlayer.trackTitle
        : ""

    // =========================
    // DYNAMIC ISLAND
    // =========================

    Rectangle {
        id: island

        property real minimumWidth: 200
        property real maximumWidth: 500

        // Estimate the width needed for the media title
        property real titleWidth: root.mediaTitle.length * 8

        // Expand based on media title length
        width: {
            if (!root.mediaPlaying) {
                return minimumWidth
            }

            return Math.min(
                maximumWidth,
                Math.max(
                    minimumWidth,
                    170 + titleWidth
                )
            )
        }

        height: 50

        // Keep the island centered on the monitor
        anchors.horizontalCenter: parent.horizontalCenter

        radius: height / 2
        color: "#111111"

        // Slide above the screen when hidden
        y: root.islandVisible ? 8 : -height

        Behavior on width {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }

        Behavior on y {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }

        // =========================
        // MEDIA MODE:
        // WORKSPACE + TIME
        // =========================

        Row {
            id: leftContent

            anchors.left: parent.left
            anchors.leftMargin: 25
            anchors.verticalCenter: parent.verticalCenter

            spacing: 12

            visible: root.mediaPlaying

            Text {
                text: root.workspaceEmoji

                color: "white"
                font.pixelSize: 18
            }

            Text {
                id: mediaClock

                text: Qt.formatTime(
                    new Date(),
                    "HH:mm"
                )

                color: "white"
                font.pixelSize: 15
                font.bold: true
            }
        }

        // =========================
        // NORMAL MODE:
        // CENTERED CLOCK
        // =========================

        Text {
            id: centeredClock

            anchors.centerIn: parent

            visible: !root.mediaPlaying

            text: Qt.formatTime(
                new Date(),
                "HH:mm"
            )

            color: "white"
            font.pixelSize: 15
            font.bold: true
        }

        // =========================
        // MEDIA TITLE
        // =========================

        Text {
            id: mediaText

            anchors.right: parent.right
            anchors.rightMargin: 25
            anchors.verticalCenter: parent.verticalCenter

            width: Math.max(
                0,
                parent.width - 150
            )

            visible: root.mediaPlaying

            text: root.mediaTitle

            color: "white"
            font.pixelSize: 14

            elide: Text.ElideRight

            horizontalAlignment: Text.AlignRight

            opacity: root.mediaPlaying ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }
        }
    }

    // =========================
    // FULL TOP-EDGE TRIGGER
    // =========================

    MouseArea {
        anchors.fill: parent

        hoverEnabled: true

        onEntered: {
            root.islandVisible = true
        }

        onExited: {
            root.islandVisible = false
        }
    }

    // =========================
    // CLOCK UPDATE
    // =========================

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: {
            centeredClock.text = Qt.formatTime(
                new Date(),
                "HH:mm"
            )

            mediaClock.text = Qt.formatTime(
                new Date(),
                "HH:mm"
            )
        }
    }
}

