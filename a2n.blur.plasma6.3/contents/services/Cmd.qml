import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as Plasma5Support

Plasma5Support.DataSource {
  id: executable
  engine: "executable"
  connectedSources: []
  property var isRunning: false
  property var queue: []

  function launchCmdInQueue() {
    console.log("A2N.BLUR.CMD ~ Launch");
    isRunning = true
    connectSource(queue[0])
  }

  function closing() {
    console.log("A2N.BLUR.CMD ~ Closing");
    isRunning = false; // Set isRunning to false after 1 second delay
    if (queue.length > 0) {
      launchCmdInQueue(); // If a cmd is still in queue launch it
    } else {
      console.log("A2N.BLUR.CMD ~ Queue is empty ", queue);
    }
  }

  onNewData: function (sourceName, data) {
    console.log("A2N.BLUR.CMD ~ OnNewData");
    const exitCode = data["exit code"]
    const exitStatus = data["exit status"];
    const stdout = data["stdout"]
    const stderr = data["stderr"]
    exited(sourceName, exitCode, exitStatus, stdout, stderr)
    disconnectSource(sourceName)
  }

  onSourceConnected: function (source) {
    console.log("A2N.BLUR.CMD ~ Source connected");
    connected(source)
  }

  onExited: function (cmd, exitCode, exitStatus, stdout, stderr) {
    console.log("A2N.BLUR.CMD ~ onExited");
    queue.shift() // delete the first value, so this exited cmd
    closing()
  }

  // execute the given cmd
  function exec(cmd: string) {
    console.log("A2N.BLUR.CMD ~ Exec");
    if (!cmd) return
    queue.push(cmd)
    if (!isRunning) launchCmdInQueue()
  }

  signal connected(string source)
  signal exited(string cmd, int exitCode, int exitStatus, string stdout, string stderr)
}
