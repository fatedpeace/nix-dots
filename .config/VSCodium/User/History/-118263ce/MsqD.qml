
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Quickshell.Io
import QtQuick

ShellRoot {
    PanelWindow {
        id: root

        // ========================================================
        // PANEL SETTINGS
        // ========================================================

        anchors.top: true
        exclusiveZone: 0
        color: "transparent"

        implicitWidth: island.width
        implicitHeight: 58


        // ========================================================
        // FONTS
        // ========================================================

        property string mainFont: "Roboto Mono"
        property string iconFont: "Iosevka Nerd Font"


        // ========================================================
        // ISLAND STATE
        // ========================================================

        property bool islandVisible: false
        property bool islandHovered: false


        // ========================================================
        // VOLUME STATE
        // ========================================================

        property bool volumeVisible: false
        property real volumeValue: 0.5


        // ========================================================
        // WORKSPACE ICONS
        // ========================================================

        // 1 = Terminal
        // 2 = Code
        // 3 = Documents
        // 4 = Virtual Machine
        // 5 = Files
        // 6 = Packages
        // 7 = Music / Media
        // 8 = NixOS
        // 9 = System / Configuration
        // 10 = Random / Scratch
        property var workspaceIcons: [
            "",
            "󰘐",
            "",
            "",
            "",
            "",
            "",
            "",
            "󰭹",
            ""
        ]

        property int workspaceId: {
            if (Hyprland.focusedWorkspace)
                return Hyprland.focusedWorkspace.id

            return 1
        }

        property string workspaceIcon: {
            if (workspaceId >= 1
                    && workspaceId <= workspaceIcons.length) {
                return workspaceIcons[workspaceId - 1]
            }

            return "󰋜"
        }


        // ========================================================
        // MEDIA
        // ========================================================

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


        // ========================================================
        // VOLUME CONTROL
        // ========================================================

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


        // ========================================================
        // VOLUME COMMANDS
        // ========================================================

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
                            root.volumeValue = Math.max(
                                0,
                                Math.min(1, value)
                            )
                        }
                    }
                }
            }
        }


        // ========================================================
        // TIMERS
        // ========================================================

        // Read the volume after wpctl has updated it.
        Timer {
            id: volumeUpdateTimer

            interval: 100
            repeat: false

            onTriggered: volumeGet.running = true
        }


        // --------------------------------------------------------
        // VOLUME DISPLAY TIME
        // --------------------------------------------------------

        // Volume intentionally stays longer than normal mode.
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


        // Wait for the hide animation to finish before resetting
        // the volume UI. This prevents flashing back to the clock.
        Timer {
            id: volumeResetTimer

            interval: 300
            repeat: false

            onTriggered: {
                root.volumeVisible = false
            }
        }


        // --------------------------------------------------------
        // NORMAL ISLAND HIDE TIMER
        // --------------------------------------------------------

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


        // ========================================================
        // DYNAMIC ISLAND
        // ========================================================

        Rectangle {
            id: island

            property real minimumWidth: 200
            property real maximumWidth: 500

            property real titleWidth:
                root.mediaTitle.length * 9


            // ====================================================
            // DYNAMIC WIDTH
            // ====================================================

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


            // ====================================================
            // APPEARANCE
            // ====================================================

            radius: height / 2
            color: "#111111"


            // ====================================================
            // SHOW / HIDE
            // ====================================================

            y: root.islandVisible ? 8 : -height


            // ====================================================
            // ANIMATIONS
            // ====================================================

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


            // ====================================================
            // IDLE CONTENT
            // ====================================================

            Item {
                anchors.fill: parent

                visible: !root.mediaPlaying
                         && !root.volumeVisible


                // Workspace icon.
                Text {
                    id: normalWorkspaceIcon

                    text: root.workspaceIcon

                    font.family: root.iconFont
                    font.pixelSize: 23

                    color: "#FFFFFF"

                    anchors.right: centeredClock.left
                    anchors.rightMargin: 14

                    anchors.verticalCenter:
                        centeredClock.verticalCenter

                    anchors.verticalCenterOffset: 1

                    renderType: Text.NativeRendering
                }


                // Center clock.
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
            }


            // ====================================================
            // MEDIA CONTENT
            // ====================================================

            Item {
                anchors.fill: parent

                visible: root.mediaPlaying
                         && !root.volumeVisible


                // Left side: workspace + clock.
                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 25

                    anchors.verticalCenter:
                        parent.verticalCenter

                    spacing: 12


                    Text {
                        text: root.workspaceIcon

                        font.family: root.iconFont
                        font.pixelSize: 23

                        color: "#FFFFFF"

                        renderType: Text.NativeRendering
                    }


                    Text {
                        id: mediaClock

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
                }


                // Media title.
                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 25

                    anchors.verticalCenter:
                        parent.verticalCenter

                    width: Math.max(
                        0,
                        parent.width - 165
                    )

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


            // ====================================================
            // VOLUME CONTENT
            // ====================================================

            Item {
                anchors.fill: parent

                visible: root.volumeVisible


                Rectangle {
                    id: volumeBar

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
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }
            }


            // ====================================================
            // ISLAND HOVER DETECTION
            // ====================================================

            MouseArea {
                anchors.fill: parent

                hoverEnabled: true

                onEntered: {
                    // Cancel any pending disappearance.
                    islandHideTimer.stop()

                    root.islandHovered = true
                    root.islandVisible = true
                }

                onExited: {
                    root.islandHovered = false

                    // Normal mode hides shortly after leaving.
                    if (!root.volumeVisible)
                        islandHideTimer.restart()
                }
            }
        }


        // ========================================================
        // 1 PIXEL TOP EDGE TRIGGER
        // ========================================================

        MouseArea {
            id: topTrigger

            // Only trigger directly above the island.
            width: island.width
            height: 1

            anchors.top: parent.top
            anchors.horizontalCenter:
                parent.horizontalCenter

            hoverEnabled: true


            // ----------------------------------------------------
            // ENTER TOP EDGE
            // ----------------------------------------------------

            onEntered: {
                // Cancel any pending hide.
                islandHideTimer.stop()

                // Reveal island.
                root.islandVisible = true
            }


            // ----------------------------------------------------
            // LEAVE TOP EDGE
            // ----------------------------------------------------

            // This is the important fix.
            //
            // Previously, moving sideways out of the 1px trigger
            // did not start the hide timer. The island could then
            // remain visible until you returned to the trigger.
            onExited: {
                // If the mouse moved down into the actual island,
                // the island's MouseArea takes over.
                //
                // If it moved sideways or elsewhere, the island
                // will disappear after the normal short delay.
                if (!root.islandHovered
                        && !root.volumeVisible) {
                    islandHideTimer.restart()
                }
            }
        }


        // ========================================================
        // CLOCK UPDATE
        // ========================================================

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


        // ========================================================
        // GLOBAL VOLUME SHORTCUTS
        // ========================================================

        GlobalShortcut {
            name: "volume-up"
            description: "Increase volume"

            onPressed: root.changeVolume(1)
        }

        GlobalShortcut {
            name: "volume-down"
            description: "Decrease volume"

            onPressed: root.changeVolume(-1)
        }
    }
}
