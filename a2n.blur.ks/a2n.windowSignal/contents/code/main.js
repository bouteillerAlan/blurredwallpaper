"use strict";

// Window Signal KWin Script
// Sends signals when a user has a window focused or not

const SERVICE_NAME = "a2n.WindowSignal";
const PATH = "/WindowSignal";
const INTERFACE = "a2n.WindowSignal";

function logger(context, message) {
    console.log(`A2N.WINSIG ~ ${context}: ${message}`);
}

function callDBusMethod(service, path, intf, method, ...args) {
    try {
        return callDBus(service, path, intf, method, ...args);
    } catch (error) {
        logger("DBus Error", `Failed to call ${method}: ${error}`);
        return false;
    }
}

function getWindowInfo(client) {
    if (!client) return null;

    return {
        windowId: client.windowId || 0,
        caption: client.caption || "",
        resourceClass: client.resourceClass || "",
        resourceName: client.resourceName || "",
        pid: client.pid || 0,
        geometry: {
            x: client.frameGeometry ? client.frameGeometry.x : 0,
            y: client.frameGeometry ? client.frameGeometry.y : 0,
            width: client.frameGeometry ? client.frameGeometry.width : 0,
            height: client.frameGeometry ? client.frameGeometry.height : 0
        }
    };
}

function onWindowActivated(client) {
    if (client === null || client === undefined) {
        logger("windowFocusChanged", "User has no window focused");
        callDBusMethod(SERVICE_NAME, PATH, INTERFACE, "windowDeactivated", "");
    } else {
        const windowInfo = getWindowInfo(client);
        const jsonData = JSON.stringify(windowInfo);
        logger("windowFocusChanged", `User has a window focused: ${jsonData}`);
        callDBusMethod(SERVICE_NAME, PATH, INTERFACE, "windowActivated", jsonData);
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
