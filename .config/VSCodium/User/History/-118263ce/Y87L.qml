import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import QtQuick

PanelWindow {
    id: root

    // Attach the panel to the very top of the screen
    anchors.top: true
    anchors.left: true
    anchors.right: true

    // Don't reserve desktop space
    exclusiveZone: 0

    // Transparent background
    color: "transparent"

    // The window needs enough height to contain the island,
    // but only the 1px trigger strip activates it.
    implicitHeight: 58

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
        property real titleWidth: root.mediaTitle.length * 8

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

        anchors.horizontalCenter: parent.horizontalCenter

        radius: height / 2
        color: "#111111"

        // When hidden, move completely above the screen.
        // When visible, leave an 8px gap.
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

        // -------------------------
        // MEDIA MODE: LEFT CONTENT
        // -------------------------

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

        // -------------------------
        // NORMAL MODE: CENTER CLOCK
        // -------------------------

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

        // -------------------------
        // MEDIA TITLE
        // -------------------------

        Text {
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
    // TOP-EDGE TRIGGER
    // =========================

    MouseArea {
        id: topTrigger

        // Match the island's current width
        width: island.width
        height: 1

        // Keep the trigger centered above the island
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top

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
