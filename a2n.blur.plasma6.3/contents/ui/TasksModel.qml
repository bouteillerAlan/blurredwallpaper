import QtQuick
import org.kde.taskmanager as TaskManager

Item {
  id: plasmaTasksItem

  readonly property bool existsWindowActive: activeTaskItem && tasksRepeater.count > 0 && activeTaskItem.isActive
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
          } else if (plasmaTasksItem.activeTaskItem === task) {
            plasmaTasksItem.activeTaskItem = null
          }
        }
        Component.onCompleted: {
          if (isActive) {
            plasmaTasksItem.activeTaskItem = task
          }
        }
      }
    }
  }
}
