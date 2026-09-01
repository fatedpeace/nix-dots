
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import QtQuick

PanelWindow {
    id: root

    // Attach to the top of the screen
    anchors.top: true

    // Do not reserve space
    exclusiveZone: 0

    // Transparent window background
    color: "transparent"

    // Invisible area used to detect the mouse
    implicitWidth: 1920
    implicitHeight: 80

    // =========================
    // ISLAND VISIBILITY
    // =========================

    property bool islandVisible: false

    // =========================
    // WORKSPACES
    // =========================

    // Emoji for workspaces 1 through 10
    property var workspaceEmojis: [
        "🌐", // Workspace 1
        "💻", // Workspace 2
        "📁", // Workspace 3
        "🎵", // Workspace 4
        "💬", // Workspace 5
        "🎮", // Workspace 6
        "🎬", // Workspace 7
        "📝", // Workspace 8
        "⚙️", // Workspace 9
        "🏠"  // Workspace 10
    ]

    // Current focused workspace
    property int workspaceId: {
        if (Hyprland.focusedWorkspace) {
            return Hyprland.focusedWorkspace.id
        }

        return 1
    }

    // Get the emoji for the current workspace
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

    // Use the first available MPRIS player
    property var mediaPlayer:
        Mpris.players.values.length > 0
        ? Mpris.players.values[0]
        : null

    // True while media is actively playing
    property bool mediaPlaying:
        mediaPlayer !== null
        && mediaPlayer.isPlaying

    // Current media title
    property string mediaTitle:
        mediaPlayer !== null
        ? mediaPlayer.trackTitle
        : ""

    // =========================
    // DYNAMIC ISLAND
    // =========================

    Rectangle {
        id: island

        // 200px normally
        // 500px while media is playing
        width: root.mediaPlaying ? 500 : 200
        height: 50

        // Center horizontally
        anchors.horizontalCenter: parent.horizontalCenter

        // Rounded pill
        radius: height / 2

        color: "#111111"

        // Slide above the screen when hidden
        y: root.islandVisible ? 8 : -height

        // Smooth width expansion
        Behavior on width {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }

        // Smooth show/hide animation
        Behavior on y {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }

        // =========================
        // WORKSPACE EMOJI
        // =========================

        Text {
            id: workspaceText

            anchors.left: parent.left
            anchors.leftMargin: 25
            anchors.verticalCenter: parent.verticalCenter

            text: root.workspaceEmoji

            color: "white"
            font.pixelSize: 18
        }

        // =========================
        // CLOCK
        // =========================

        Text {
            id: clock

            anchors.left: workspaceText.right
            anchors.leftMargin: 18
            anchors.verticalCenter: parent.verticalCenter

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

            // Only show while playing
            visible: root.mediaPlaying

            // Reserve space for the title
            width: 260

            text: root.mediaTitle

            color: "white"
            font.pixelSize: 14

            // Cut off titles that are too long
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
    // TOP EDGE MOUSE TRIGGER
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
            clock.text = Qt.formatTime(
                new Date(),
                "HH:mm"
            )
        }
    }
}