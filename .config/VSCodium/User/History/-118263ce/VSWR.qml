
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import QtQuick

PanelWindow {
    id: root

    // =========================
    // PANEL
    // =========================

    anchors.top: true

    // Do not reserve screen space
    exclusiveZone: 0

    // Transparent background
    color: "transparent"

    // Panel only occupies the island width
    implicitWidth: island.width

    // Enough height for the island + top gap
    implicitHeight: 58

    // =========================
    // FONT
    // =========================

    // This is the actual font family name used by Qt/QML.
    property string mainFont: "Noto Sans CJK JP"

    // =========================
    // VISIBILITY
    // =========================

    property bool islandVisible: false

    // =========================
    // WORKSPACE EMOJIS
    // =========================

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

    // Get emoji for workspace
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

    // First available MPRIS player
    property var mediaPlayer:
        Mpris.players.values.length > 0
        ? Mpris.players.values[0]
        : null

    // True while media is playing
    property bool mediaPlaying:
        mediaPlayer !== null
        && mediaPlayer.isPlaying

    // Current track title
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

        // Approximate title width
        property real titleWidth:
            root.mediaTitle.length * 8

        // Normal width: 200px
        // Media width expands based on title
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

        // Center inside the PanelWindow
        anchors.horizontalCenter: parent.horizontalCenter

        radius: height / 2
        color: "#111111"

        // Show or hide the island
        y: root.islandVisible ? 8 : -height

        // =========================
        // ANIMATIONS
        // =========================

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
        // MEDIA MODE
        // WORKSPACE + TIME
        // =========================

        Row {
            id: leftContent

            anchors.left: parent.left
            anchors.leftMargin: 25
            anchors.verticalCenter: parent.verticalCenter

            spacing: 12

            // Only visible while media is playing
            visible: root.mediaPlaying

            // Workspace emoji
            Text {
                text: root.workspaceEmoji

                // No forced font family here.
                // Allows the system emoji font to be used.
                font.pixelSize: 20
            }

            // Clock during media playback
            Text {
                id: mediaClock

                text: Qt.formatTime(
                    new Date(),
                    "HH:mm"
                )

                color: "white"

                // Noto Sans CJK
                font.family: root.mainFont
                font.pixelSize: 18
                font.bold: true
            }
        }

        // =========================
        // NORMAL MODE
        // CENTERED CLOCK
        // =========================

        Text {
            id: centeredClock

            anchors.centerIn: parent

            // Only visible when no media is playing
            visible: !root.mediaPlaying

            text: Qt.formatTime(
                new Date(),
                "HH:mm"
            )

            color: "white"

            // Noto Sans CJK
            font.family: root.mainFont
            font.pixelSize: 18
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

            // Only visible while playing
            visible: root.mediaPlaying

            // Available space after workspace + clock
            width: Math.max(
                0,
                parent.width - 150
            )

            text: root.mediaTitle

            color: "white"

            // Noto Sans CJK
            font.family: root.mainFont
            font.pixelSize: 18

            elide: Text.ElideRight
            horizontalAlignment: Text.AlignRight
        }

        // =========================
        // ISLAND HOVER AREA
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
    }

    // =========================
    // 1PX TOP EDGE TRIGGER
    // =========================

    MouseArea {
        id: topTrigger

        // Same width as island
        width: island.width

        // Only trigger at the very top pixel
        height: 1

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        hoverEnabled: true

        onEntered: {
            root.islandVisible = true
        }
    }

    // =========================
    // CLOCK
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

