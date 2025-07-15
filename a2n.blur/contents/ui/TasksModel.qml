import QtQuick
import QtQml.Models
import QtQuick.Window
import org.kde.plasma.core as PlasmaCore

Item {
  id: plasmaTasksItem

  readonly property bool existsWindowActive: activeTaskItem !== null && activeTaskItem.isActive
  readonly property bool isAnyWindowActive: activeTaskItem !== null && activeTaskItem.isActive
  property Item activeTaskItem: null

  // Create a dummy task item to represent the active window
  Item {
    id: activeTask
    property bool isActive: false
    property string windowTitle: ""
    property var windowTypes: []
    property var windowData: ({})
  }

  // DBus connection to receive window signals
  PlasmaCore.DataSource {
    id: dbusSource
    engine: "dbus"

    // Connect to the DBus service
    readonly property string dbusService: "a2n.WindowSignal"
    readonly property string dbusPath: "/WindowSignal"
    readonly property string dbusInterface: "a2n.WindowSignal"

    // Connect to the signals
    connectedSources: [
      dbusService + dbusPath + "." + dbusInterface + ".windowActivated",
      dbusService + dbusPath + "." + dbusInterface + ".windowDeactivated"
    ]

    // Handle DBus signals
    onNewData: function(sourceName, data) {
      // Extract the signal name from the source
      const signalParts = sourceName.split(".");
      const signalName = signalParts[signalParts.length - 1];

      if (signalName === "windowActivated" && data && data.value) {
        handleWindowActivated(data.value);
      } else if (signalName === "windowDeactivated") {
        handleWindowDeactivated();
      }
    }

    // Handle window activated signal
    function handleWindowActivated(windowData) {
      try {
        // Parse the JSON window data
        const windowProps = JSON.parse(windowData);

        console.log(`A2N -- ${windowProps}`)

        // Update the active task properties
        activeTask.windowData = windowProps;
        activeTask.isActive = true;
        activeTask.windowTitle = windowProps.caption || "";

        // Set window types based on the window properties
        const types = [];
        if (windowProps.normalWindow) types.push("Normal");
        if (windowProps.dialog) types.push("Dialog");
        if (windowProps.utility) types.push("Utility");
        if (windowProps.dock) types.push("Dock");
        if (windowProps.desktopWindow) types.push("Desktop");
        activeTask.windowTypes = types;

        // Set the active task item
        plasmaTasksItem.activeTaskItem = activeTask;
        console.log("Window activated:", windowProps.caption);
      } catch (e) {
        console.error("Error parsing window data:", e);
      }
    }

    // Handle window deactivated signal
    function handleWindowDeactivated() {
      // Reset the active task properties
      activeTask.isActive = false;
      activeTask.windowTitle = "";
      activeTask.windowTypes = [];
      activeTask.windowData = {};

      // Clear the active task item
      plasmaTasksItem.activeTaskItem = null;
      console.log("Window deactivated");
    }
  }
}
