import QtQuick 2.15
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0
import SddmComponents 2.0

Rectangle {
    id: root
    width: 640
    height: 480

    readonly property color textColor: config.textColor 
    property int currentUsersIndex: userModel.lastIndex
    property int currentSessionsIndex: sessionModel.lastIndex
    property int usernameRole: Qt.UserRole + 1
    property int realNameRole: Qt.UserRole + 2
    property int sessionNameRole: Qt.UserRole + 4
    property string currentUsername: userModel.data(userModel.index(currentUsersIndex, 0), realNameRole) ||
                                     userModel.data(userModel.index(currentUsersIndex, 0), usernameRole)
    property string currentSession: sessionModel.data(sessionModel.index(currentSessionsIndex, 0), sessionNameRole)

    function usersCycleSelectPrev() {
        if (currentUsersIndex - 1 < 0) {
            currentUsersIndex = userModel.count - 1;
        } else {
            currentUsersIndex--;
        }
    }

    function usersCycleSelectNext() {
        if (currentUsersIndex >= userModel.count - 1) {
            currentUsersIndex = 0;
        } else {
            currentUsersIndex++;
        }
    }

    function bgFillMode() {
        switch(config.backgroundMode)
        {
            case "aspect":
                return Image.PreserveAspectCrop;

            case "fill":
                return Image.Stretch;

            case "tile":
                return Image.Tile;

            default:
                return Image.Pad;
        }
    }

    function sessionsCycleSelectPrev() {
        if (currentSessionsIndex - 1 < 0) {
            currentSessionsIndex = sessionModel.rowCount() - 1;
        } else {
            currentSessionsIndex--;
        }
    }

    function sessionsCycleSelectNext() {
        if (currentSessionsIndex >= sessionModel.rowCount() - 1) {
            currentSessionsIndex = 0;
        } else {
            currentSessionsIndex++;
        }
    }


    Connections {
        target: sddm
        function onLoginFailed() {
            background.border.width = 5;
            animateBorder.restart();
            passwordInput.clear();
        }
        function onLoginSucceeded() {
            background.border.width = 0;
            animateBorder.stop();
        }
    }

    Item {
        id: mainFrame
        property variant geometry: screenModel.geometry(screenModel.primary)
        x: geometry.x
        y: geometry.y
        width: geometry.width
        height: geometry.height
        Shortcut {
            sequences: ["Alt+U", "F2"]
            onActivated: {
                if (!username.visible) {
                    username.visible = true;
                    return;
                }
                usersCycleSelectNext();
            }
        }
        Shortcut {
            sequences: ["Alt+Ctrl+S", "Ctrl+F3"]
            onActivated: {
                if (!sessionName.visible) {
                    sessionName.visible = true;
                    return;
                }
                sessionsCycleSelectPrev();
            }
        }

        Shortcut {
            sequences: ["Alt+S", "F3"]
            onActivated: {
                if (!sessionName.visible) {
                    sessionName.visible = true;
                    return;
                }
                sessionsCycleSelectNext();
            }
        }
        Shortcut {
            sequences: ["Alt+Ctrl+U", "Ctrl+F2"]
            onActivated: {
                if (!username.visible) {
                    username.visible = true;
                    return;
                }
                usersCycleSelectPrev();
            }
        }

        Shortcut {
            sequence: "F10"
            onActivated: {
                if (sddm.canSuspend) {
                    sddm.suspend();
                }
            }
        }
        Shortcut {
            sequence: "F11"
            onActivated: {
                if (sddm.canPowerOff) {
                    sddm.powerOff();
                }
            }
        }
        Shortcut {
            sequence: "F12"
            onActivated: {
                if (sddm.canReboot) {
                    sddm.reboot();
                }
            }
        }

        Shortcut {
            sequence: "F1"
            onActivated: {
                helpMessage.visible = !helpMessage.visible
            }
        }


        Rectangle {
            id: background
            visible: true
            anchors.fill: parent
            border.color: "#ff3117"
            border.width: 0
            Behavior on border.width {
                SequentialAnimation {
                    id: animateBorder
                    running: false
                    loops: Animation.Infinite
                    NumberAnimation { from: 5; to: 10; duration: 700 }
                    NumberAnimation { from: 10; to: 5;  duration: 400 }
                }
            }

            Image {
                id: image
                anchors.fill: parent
                source: config.background
                fillMode: bgFillMode()
                z: 2
            }

            Rectangle {
                id: rectangle
                anchors.fill: parent
                color: config.backgroundFill || "transparent"
            }
        }

        TextInput {
            id: passwordInput
            width: parent.width/2
            height: 200

            font.family: config.font
            font.pointSize: 20
            font.bold: true
            font.letterSpacing: 10
            anchors {
                verticalCenter: parent.verticalCenter
                horizontalCenter: parent.horizontalCenter
            }
            echoMode: TextInput.Password
            color: textColor
            selectionColor: textColor
            selectedTextColor: config.textColor
            clip: true
            horizontalAlignment: TextInput.AlignHCenter
            verticalAlignment: TextInput.AlignVCenter
            passwordCharacter: config.passwordCharacter || "*"
            onAccepted: {
                if (text != "") {
                    sddm.login(userModel.lastUser || "123test", text, currentSessionsIndex);
                }
            }
            cursorDelegate: Rectangle {
                id: passwordInputCursor
                width: 1
                onHeightChanged: height = passwordInput.height/5
                anchors.verticalCenter: parent.verticalCenter
                color: (() => {
                        if (config.cursorColor.length == 7 && config.cursorColor[0] == "#") {
                            return config.cursorColor;
                        } else if (config.cursorColor == "constantRandom") {
                            return generateRandomColor();
                        } else {
                            return textColor
                        }
                    })()

                function generateRandomColor() {
                    var color = "#";
                    for (var i = 0; i<3; i++) {
                        var color_number = parseInt(Math.random()*255);
                        var hex_color = color_number.toString(16);
                        if (color_number < 16) {
                            hex_color = "0" + hex_color;
                        }
                        color += hex_color;
                    }
                    return color;
                }
                Connections {
                    target: passwordInput
                    function onTextEdited() {
                        if (config.cursorColor == "random") {
                            passwordInputCursor.color = generateRandomColor();
                        }
                    }
                }
            }
        }
        UsersChoose {
            id: username
            text: currentUsername
            visible: false
            width: mainFrame.width/2.5
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: passwordInput.top
                bottomMargin: 40
            }
            onPrevClicked: {
                usersCycleSelectPrev();
            }
            onNextClicked: {
                usersCycleSelectNext();
            }
        }

        SessionsChoose {
            id: sessionName
            text: currentSession
            visible: false
            width: mainFrame.width/2.5
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: 30
            }
            onPrevClicked: {
                sessionsCycleSelectPrev();
            }
            onNextClicked: {
                sessionsCycleSelectNext();
            }
        }

        Text {
            id: helpMessage
            visible: false
            text: "Show help - F1\n" +
                  "Cycle select next user - F2 or Alt+u\n" +
                  "Cycle select previous user - Ctrl+F2 or Alt+Ctrl+u\n" +
                  "Cycle select next session - F3 or Alt+s\n" +
                  "Cycle select previous session - Ctrl+F3 or Alt+Ctrl+s\n" +
                  "Suspend - F10\n" +
                  "Poweroff - F11\n" +
                  "Reboot - F12"
            color: textColor
            font.pointSize: 18
            font.family: config.font
            anchors {
                top: parent.top
                topMargin: 30
                left: parent.left
                leftMargin: 30
            }
        }

        Component.onCompleted: {
            passwordInput.forceActiveFocus();
        }

    }
}

