import QtQuick
import QtQml.Models
import QtQuick.Window
import org.kde.plasma.core as PlasmaCore
import org.kde.taskmanager as TaskManager

Item {
  id: plasmaTasksItem

  readonly property bool existsWindowActive: root.activeTaskItem && tasksRepeater.count > 0 && activeTaskItem.isActive
  property Item activeTaskItem: null

  TaskManager.TasksModel {
    id: tasksModel
    sortMode: TaskManager.TasksModel.SortVirtualDesktop
    groupMode: TaskManager.TasksModel.GroupDisabled
    filterByVirtualDesktop: true
    filterByActivity: true
    filterByScreen: true
  }

  Item {
    id: taskList
    Repeater {
      id: tasksRepeater
      model: tasksModel
      Item {
        id: task
        readonly property bool isActive: model.IsActive
        onIsActiveChanged: {
          if (isActive) {
            plasmaTasksItem.activeTaskItem = task
          } else {
            // todo: check with qdbus6 if something else is active
          }
        }
      }
    }
  }
}
