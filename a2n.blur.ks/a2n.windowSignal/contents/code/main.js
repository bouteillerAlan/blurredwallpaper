"use strict";

// Window Signal KWin Script
// Sends signals when a user has a window focused or not

const SERVICE_NAME = "a2n.WindowSignal";
const PATH = "/WindowSignal";
const INTERFACE = "a2n.WindowSignal";

function logger(context, message) {
    console.log(`A2N.WINSIG ~ ${context}: ${message}`);
}

function onWindowActivated(client) {
    if (client === null) {
        logger("windowFocusChanged", "User has no window focused");
        callDBus(SERVICE_NAME, PATH, INTERFACE, "windowDeactivated", "");
    } else {
        const jsonData = JSON.stringify(client);
        logger("windowFocusChanged", `User has a window focused: ${jsonData}`);
        callDBus(SERVICE_NAME, PATH, INTERFACE, "windowActivated", jsonData);
    }
}

function init() {
    logger("init()", "Window Signal script initialized");
    // Connect to window activated/deactivated event
    workspace.windowActivated.connect(onWindowActivated);
    // Check initial state
    const activeWindow = workspace.activeWindow;
    onWindowActivated(activeWindow);
}
init();
