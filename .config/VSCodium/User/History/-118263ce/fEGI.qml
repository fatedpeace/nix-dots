
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Quickshell.Io
import QtQuick

ShellRoot {
    PanelWindow {
        id: root

        anchors.top: true
        exclusiveZone: 0
        color: "transparent"

        implicitWidth: island.width
        implicitHeight: 58

        property string mainFont: "Roboto Mono"
        property string iconFont: "Iosevka Nerd Font"

        property bool islandVisible: false
        property bool islandHovered: false

        property bool volumeVisible: false
        property real volumeValue: 0.5

        property var workspaceIcons: [
            "", "󰘐", "", "", "",
            "", "", "", "󰭹", ""
        ]

        property int workspaceId: {
            if (Hyprland.focusedWorkspace)
                return Hyprland.focusedWorkspace.id
            return 1
        }

        property string workspaceIcon: {
            if (workspaceId >= 1
                    && workspaceId <= workspaceIcons.length)
                return workspaceIcons[workspaceId - 1]

            return "󰋜"
        }

        property var mediaPlayer:
            Mpris.players.values.length > 0
            ? Mpris.players.values[0]
            : null

        property bool mediaPlaying:
            mediaPlayer !== null && mediaPlayer.isPlaying

        property string mediaTitle:
            mediaPlayer !== null
            ? mediaPlayer.trackTitle
            : ""


        // ====================================================
        // CLICK-THROUGH MASK
        // ====================================================
        //
        // Only the visible island receives clicks.
        // The rest of this transparent window lets clicks pass
        // through to applications underneath.
        //


        function changeVolume(direction) {
            islandHideTimer.stop()
            volumeHideTimer.stop()
            volumeResetTimer.stop()

            if (direction > 0)
                volumeUp.running = true
            else
                volumeDown.running = true

            islandVisible = true
            volumeVisible = true

            volumeUpdateTimer.restart()
            volumeHideTimer.restart()
        }


        Process {
            id: volumeUp
            command: [
                "wpctl",
                "set-volume",
                "@DEFAULT_AUDIO_SINK@",
                "5%+"
            ]
        }

        Process {
            id: volumeDown
            command: [
                "wpctl",
                "set-volume",
                "@DEFAULT_AUDIO_SINK@",
                "5%-"
            ]
        }

        Process {
            id: volumeGet

            command: [
                "wpctl",
                "get-volume",
                "@DEFAULT_AUDIO_SINK@"
            ]

            stdout: SplitParser {
                onRead: data => {
                    const parts = data.trim().split(/\s+/)

                    if (parts.length >= 2) {
                        const value = parseFloat(parts[1])

                        if (!isNaN(value)) {
                            root.volumeValue =
                                Math.max(0, Math.min(1, value))
                        }
                    }
                }
            }
        }


        Timer {
            id: volumeUpdateTimer
            interval: 100
            repeat: false
            onTriggered: volumeGet.running = true
        }

        Timer {
            id: volumeHideTimer
            interval: 1100
            repeat: false

            onTriggered: {
                if (!root.islandHovered) {
                    root.islandVisible = false
                    volumeResetTimer.restart()
                } else {
                    root.volumeVisible = false
                }
            }
        }

        Timer {
            id: volumeResetTimer
            interval: 300
            repeat: false
            onTriggered: root.volumeVisible = false
        }

        Timer {
            id: islandHideTimer

            // Faster normal hide.
            interval: 400
            repeat: false

            onTriggered: {
                if (!root.islandHovered
                        && !root.volumeVisible) {
                    root.islandVisible = false
                }
            }
        }


        // ====================================================
        // DYNAMIC ISLAND
        // ====================================================

        Rectangle {
            id: island

            property real minimumWidth: 200
            property real maximumWidth: 500

            property real titleWidth:
                root.mediaTitle.length * 9

            width: {
                if (root.volumeVisible)
                    return 320

                if (!root.mediaPlaying)
                    return minimumWidth

                return Math.min(
                    maximumWidth,
                    Math.max(
                        minimumWidth,
                        180 + titleWidth
                    )
                )
            }

            height: 50

            anchors.horizontalCenter: parent.horizontalCenter

            radius: height / 2
            color: "#111111"

            y: root.islandVisible ? 8 : -height

            Behavior on width {
                NumberAnimation {
                    duration: 360
                    easing.type: Easing.InOutCubic
                }
            }

            Behavior on y {
                NumberAnimation {
                    duration: 280
                    easing.type: Easing.OutCubic
                }
            }


            // ================================================
            // NORMAL MODE
            // ================================================

            Item {
                anchors.fill: parent

                visible:
                    !root.mediaPlaying
                    && !root.volumeVisible

                Text {
                    id: centeredClock

                    anchors.centerIn: parent

                    text: Qt.formatTime(
                        new Date(),
                        "HH:mm"
                    )

                    color: "#FFFFFF"

                    font.family: root.mainFont
                    font.pixelSize: 18
                    font.weight: Font.DemiBold
                    font.letterSpacing: 0.2

                    renderType: Text.NativeRendering
                }

                Text {
                    id: normalWorkspaceIcon

                    text: root.workspaceIcon

                    anchors.right: centeredClock.left
                    anchors.rightMargin: 14
                    anchors.verticalCenter:
                        centeredClock.verticalCenter

                    anchors.verticalCenterOffset: 1

                    font.family: root.iconFont
                    font.pixelSize: 23

                    color: "#FFFFFF"

                    renderType: Text.NativeRendering
                }
            }


            // ================================================
            // MEDIA MODE
            // ================================================

            Item {
                anchors.fill: parent

                visible:
                    root.mediaPlaying
                    && !root.volumeVisible


                // Workspace icon.
                Text {
                    id: mediaWorkspaceIcon

                    anchors.left: parent.left
                    anchors.leftMargin: 25

                    // Explicit positioning instead of Row.
                    anchors.verticalCenter:
                        parent.verticalCenter

                    anchors.verticalCenterOffset: 1

                    text: root.workspaceIcon

                    font.family: root.iconFont
                    font.pixelSize: 23

                    color: "#FFFFFF"

                    renderType: Text.NativeRendering
                }


                // Media clock.
                Text {
                    id: mediaClock

                    anchors.left:
                        mediaWorkspaceIcon.right

                    anchors.leftMargin: 12

                    // This keeps the clock directly centered
                    // vertically instead of inheriting Row layout.
                    anchors.verticalCenter:
                        parent.verticalCenter

                    text: Qt.formatTime(
                        new Date(),
                        "HH:mm"
                    )

                    color: "#FFFFFF"

                    font.family: root.mainFont
                    font.pixelSize: 18
                    font.weight: Font.DemiBold
                    font.letterSpacing: 0.2

                    renderType: Text.NativeRendering
                }


                // Media title.
                Text {
                    id: mediaText

                    anchors.left: mediaClock.right
                    anchors.leftMargin: 22

                    anchors.right: parent.right
                    anchors.rightMargin: 25

                    anchors.verticalCenter:
                        parent.verticalCenter

                    text: root.mediaTitle

                    color: "#F5F5F5"

                    font.family: root.mainFont
                    font.pixelSize: 17
                    font.weight: Font.Medium

                    renderType: Text.NativeRendering

                    elide: Text.ElideRight

                    horizontalAlignment:
                        Text.AlignRight
                }
            }


            // ================================================
            // VOLUME MODE
            // ================================================

            Item {
                anchors.fill: parent

                visible: root.volumeVisible

                Rectangle {
                    anchors.centerIn: parent

                    width: parent.width - 50
                    height: 8

                    radius: height / 2
                    color: "#333333"

                    Rectangle {
                        width:
                            parent.width
                            * root.volumeValue

                        height: parent.height

                        radius: height / 2
                        color: "#FFFFFF"

                        Behavior on width {
                            NumberAnimation {
                                duration: 180
                                easing.type:
                                    Easing.OutCubic
                            }
                        }
                    }
                }
            }


            // ================================================
            // ISLAND HOVER
            // ================================================

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true

                onEntered: {
                    islandHideTimer.stop()

                    root.islandHovered = true
                    root.islandVisible = true
                }

                onExited: {
                    root.islandHovered = false

                    if (!root.volumeVisible)
                        islandHideTimer.restart()
                }
            }
        }


        // ====================================================
        // TOP EDGE TRIGGER
        // ====================================================

        MouseArea {
            id: topTrigger

            width: island.width
            height: 1

            anchors.top: parent.top
            anchors.horizontalCenter:
                parent.horizontalCenter

            hoverEnabled: true

            onEntered: {
                islandHideTimer.stop()
                root.islandVisible = true
            }

            onExited: {
                if (!root.islandHovered
                        && !root.volumeVisible) {
                    islandHideTimer.restart()
                }
            }
        }


        // ====================================================
        // CLOCK
        // ====================================================

        Timer {
            interval: 1000
            running: true
            repeat: true

            onTriggered: {
                const time = Qt.formatTime(
                    new Date(),
                    "HH:mm"
                )

                centeredClock.text = time
                mediaClock.text = time
            }
        }


        // ====================================================
        // GLOBAL VOLUME SHORTCUTS
        // ====================================================

        GlobalShortcut {
            name: "volume-up"
            description: "Increase volume"

            onPressed:
                root.changeVolume(1)
        }

        GlobalShortcut {
            name: "volume-down"
            description: "Decrease volume"

            onPressed:
                root.changeVolume(-1)
        }
    }
}

