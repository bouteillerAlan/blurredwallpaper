import QtQuick
import QtQuick.Controls
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support

Item {
  id: windowFocusDetector

  property bool hasActiveWindow: false
  property var activeWindowInfo: ({})
  property string activeWindowClass: ""
  property string activeWindowTitle: ""

  // Signal emitted when window focus changes
  signal windowFocusChanged(bool hasActive)
  signal activeWindowChanged(var windowInfo)

  // Command executor following your Cmd.qml pattern
  Plasma5Support.DataSource {
    id: executable
    engine: "executable"
    connectedSources: []
    property var isRunning: false
    property var queue: []

    function launchCmdInQueue() {
      isRunning = true
      connectSource(queue[0])
    }

    function closing() {
      isRunning = false
      if (queue.length > 0) {
        launchCmdInQueue()
      }
    }

    onNewData: function (sourceName, data) {
      var exitCode = data["exit code"]
      var exitStatus = data["exit status"]
      var stdout = data["stdout"]
      var stderr = data["stderr"]

      // Handle the window query result
      if (sourceName === "qdbus6 org.kde.KWin /KWin queryWindowInfo") {
        parseWindowInfo(stdout);
      }

      disconnectSource(sourceName)
      queue.shift() // Remove completed command
      closing()
    }

    onSourceConnected: function (source) {
      // Command connected
    }

    // Execute command using your pattern
    function exec(cmd) {
      if (!cmd) return
      queue.push(cmd)
      if (!isRunning) launchCmdInQueue()
    }
  }

  // Timer to periodically check window focus
  Timer {
    id: focusCheckTimer
    interval: 500 // Check every 500ms
    running: true
    repeat: true

    onTriggered: {
      queryActiveWindow();
    }
  }

  function queryActiveWindow() {
    // Use qdbus6 to query active window info
    executable.exec("qdbus6 org.kde.KWin /KWin queryWindowInfo");
  }

  function parseWindowInfo(output) {
    if (!output) {
      setNoActiveWindow();
      return;
    }

    // Parse the D-Bus output to extract window information
    var lines = output.split('\n');
    var windowInfo = {};
    var hasValidWindow = false;

    for (var i = 0; i < lines.length; i++) {
      var line = lines[i].trim();
      if (line.includes(':')) {
        var parts = line.split(':');
        var key = parts[0].trim();
        var value = parts.slice(1).join(':').trim();

        if (key === "resourceClass") {
          windowInfo.resourceClass = value;
          hasValidWindow = true;
        } else if (key === "caption") {
          windowInfo.caption = value;
        } else if (key === "pid") {
          windowInfo.pid = value;
        } else if (key === "geometry") {
          windowInfo.geometry = value;
        }
      }
    }

    if (hasValidWindow && windowInfo.resourceClass && windowInfo.resourceClass !== "plasmashell") {
      setActiveWindow(windowInfo);
    } else {
      setNoActiveWindow();
    }
  }

  function setActiveWindow(windowInfo) {
    var previousState = hasActiveWindow;

    hasActiveWindow = true;
    activeWindowInfo = windowInfo;
    activeWindowClass = windowInfo.resourceClass || "";
    activeWindowTitle = windowInfo.caption || "";

    if (previousState !== hasActiveWindow) {
      windowFocusChanged(hasActiveWindow);
    }

    activeWindowChanged(windowInfo);
  }

  function setNoActiveWindow() {
    var previousState = hasActiveWindow;

    hasActiveWindow = false;
    activeWindowInfo = {};
    activeWindowClass = "";
    activeWindowTitle = "";

    if (previousState !== hasActiveWindow) {
      windowFocusChanged(hasActiveWindow);
    }
  }

  // Public API functions
  function isWindowClassActive(windowClass) {
    return hasActiveWindow && activeWindowClass.toLowerCase() === windowClass.toLowerCase();
  }

  function isWindowTitleActive(title) {
    return hasActiveWindow && activeWindowTitle.toLowerCase().includes(title.toLowerCase());
  }

  function getActiveWindowDetails() {
    return {
      hasActive: hasActiveWindow,
      windowClass: activeWindowClass,
      title: activeWindowTitle,
      fullInfo: activeWindowInfo
    };
  }

  // Start monitoring immediately
  Component.onCompleted: {
    console.log("WindowFocusDetector initialized");
    queryActiveWindow();
  }
}
