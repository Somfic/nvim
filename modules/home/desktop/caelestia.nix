{ config, pkgs, ... }:

{
  # Create Caelestia configuration directory and files
  home.file.".config/caelestia/shell.json".text = builtins.toJSON {
    paths = {
      wallpaperDir = "/home/lucas/dot/wallpapers";
    };
    launcher = {
      maxWallpapers = 9;
    };
  };

  # Copy VPN widget QML file to Caelestia config
  home.file.".config/caelestia/VPNWidget.qml".text = ''
    import Quickshell
    import Quickshell.Io
    import QtQuick
    import QtQuick.Controls
    import QtQuick.Layouts

    Rectangle {
        id: vpnWidget
        width: 200
        height: 40
        color: "transparent"
        radius: 8

        property bool vpnConnected: false
        property string vpnName: "No VPN"
        property var availableVPNs: []

        // Check VPN status
        Process {
            id: vpnStatusProcess
            command: ["nmcli", "connection", "show", "--active"]
            running: true

            stdout: StdioCollector {
                onStreamFinished: {
                    vpnWidget.parseVPNStatus(this.text)
                }
            }

            onExited: {
                if (exitCode !== 0) {
                    console.log("VPN status check failed")
                }
            }
        }

        // Get available VPN connections
        Process {
            id: vpnListProcess
            command: ["nmcli", "connection", "show"]

            stdout: StdioCollector {
                onStreamFinished: {
                    vpnWidget.parseAvailableVPNs(this.text)
                }
            }
        }

        // Timer to periodically check status
        Timer {
            interval: 5000 // Check every 5 seconds
            running: true
            repeat: true
            onTriggered: {
                vpnStatusProcess.running = true
            }
        }

        Component.onCompleted: {
            vpnListProcess.running = true
        }

        function parseVPNStatus(output) {
            const lines = output.split('\n')
            vpnConnected = false
            vpnName = "No VPN"

            for (const line of lines) {
                if (line.includes('vpn') || line.includes('tun')) {
                    const parts = line.split(/\s+/)
                    if (parts.length > 0) {
                        vpnConnected = true
                        vpnName = parts[0]
                        break
                    }
                }
            }
        }

        function parseAvailableVPNs(output) {
            const lines = output.split('\n')
            const vpns = []

            for (const line of lines) {
                if (line.includes('vpn')) {
                    const parts = line.split(/\s+/)
                    if (parts.length > 0) {
                        vpns.push(parts[0])
                    }
                }
            }
            availableVPNs = vpns
        }

        function toggleVPN() {
            if (vpnConnected) {
                disconnectVPN()
            } else if (availableVPNs.length > 0) {
                connectVPN(availableVPNs[0])
            }
        }

        function connectVPN(vpnName) {
            const connectProcess = Process.create(["nmcli", "connection", "up", vpnName])
            connectProcess.running = true
        }

        function disconnectVPN() {
            const disconnectProcess = Process.create(["nmcli", "connection", "down", vpnName])
            disconnectProcess.running = true
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 8

            // VPN Icon
            Text {
                text: vpnConnected ? "🔒" : "🔓"
                font.pixelSize: 16
                color: vpnConnected ? "#4CAF50" : "#757575"
            }

            // VPN Status Text
            Text {
                text: vpnConnected ? "VPN: " + vpnName : "VPN: Off"
                font.pixelSize: 12
                color: vpnConnected ? "#4CAF50" : "#757575"
                Layout.fillWidth: true
            }

            // Toggle Button
            Rectangle {
                width: 60
                height: 24
                radius: 12
                color: vpnConnected ? "#4CAF50" : "#757575"

                MouseArea {
                    anchors.fill: parent
                    onClicked: vpnWidget.toggleVPN()
                    cursorShape: Qt.PointingHandCursor
                }

                Text {
                    anchors.centerIn: parent
                    text: vpnConnected ? "ON" : "OFF"
                    color: "white"
                    font.pixelSize: 10
                    font.bold: true
                }
            }
        }
    }
  '';

  # Create symlink to wallpapers in the default Pictures directory for convenience
  home.file."Pictures/Wallpapers".source = config.lib.file.mkOutOfStoreSymlink "/home/lucas/dot/wallpapers";
}