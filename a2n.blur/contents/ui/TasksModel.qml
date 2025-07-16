import QtQuick
import QtQml.Models
import QtQuick.Window
import org.kde.taskmanager as TaskManager

Item {
  id: plasmaTasksItem

  signal windowActivated(bool active)

  readonly property bool existsWindowActive: root.activeTaskItem && tasksRepeater.count > 0 && activeTaskItem.isActive
  property Item activeTaskItem: null

  TaskManager.TasksModel {
    id: tasksModel
    sortMode: TaskManager.TasksModel.SortVirtualDesktop
    groupMode: TaskManager.TasksModel.GroupDisabled
    activity: activityInfo.currentActivity
    virtualDesktop: virtualDesktopInfo.currentDesktop
    // filterByVirtualDesktop: true
    // filterByActivity: true
    // filterByScreen: true
  }

  Item {
    id: taskList
    Repeater {
      id: tasksRepeater
      model: tasksModel
      Item {
        id: task
        readonly property bool isActive: model.IsActive
        readonly property string windowTitle: model.display
        readonly property var windowTypes: model.windowTypes
        onIsActiveChanged: {
          console.log(`A2N.BLUR ~ onIsActiveChanged ${isActive}`)
          windowActivated(isActive ?? false)
          if (isActive) plasmaTasksItem.activeTaskItem = task
        }
      }
    }
  }
}
