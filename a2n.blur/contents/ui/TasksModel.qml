import QtQuick
import QtQml.Models
import QtQuick.Window
import org.kde.plasma.core as PlasmaCore
import org.kde.taskmanager as TaskManager

import "../services" as Services

Item {
  id: plasmaTasksItem

  Services.Cmd {
    id: cmd
    onExited: function(cmd, exitCode, exitStatus, stdout, stderr) {
      console.log("Command finished:", cmd)
      console.log("Exit code:", exitCode)
      console.log("Stdout:", stdout)
      console.log("Stderr:", stderr)
    }
  }

  signal windowActivated(bool active)

  TaskManager.TasksModel {
    id: tasksModel
    sortMode: TaskManager.TasksModel.SortVirtualDesktop
    groupMode: TaskManager.TasksModel.GroupDisabled
    filterByVirtualDesktop: true
    filterByActivity: true
    filterByScreen: true
    filterHidden: false
    filterMinimized: false
    filterNotMaximized: false
    filterNotMinimized: false

    onDataChanged: {console.log("A2N.BLUR ~ TasksModel data changed")}
    onCountChanged: {console.log("A2N.BLUR ~ TasksModel count changed to ", count)}

    onActiveTaskChanged: {
      console.log("A2N.BLUR ~ TasksModel onActiveTaskChanged")
      const isActive = tasksModel.data(activeTask, TaskManager.TasksModel.IsActive)
      if (isActive) {
        windowActivated(!!isActive)
      } else {
        // call dbus and check if something isActive or alike
        cmd.exec('echo "@@@@@@@@@@@@@@@@@ pouet"')
      }
    }
  }

  Component.onCompleted: {
    console.log("A2N.BLUR ~ TasksModel onCompleted")
  }
}
