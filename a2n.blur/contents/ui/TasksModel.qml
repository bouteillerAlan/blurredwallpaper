import QtQuick
import QtQml.Models
import QtQuick.Window
import org.kde.plasma.core as PlasmaCore
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
    filterByVirtualDesktop: true
    filterByActivity: true
    filterByScreen: true
    filterHidden: false
    filterMinimized: false
    filterNotMaximized: false
    filterNotMinimized: false

    onDataChanged: {
      console.log("TasksModel data changed - logging all windows")
    }

    onActiveTaskChanged: {
      console.log("TasksModel signal: activeTaskChanged", activeTask)
    }

    onCountChanged: {
      console.log("TasksModel signal: countChanged to", count)
    }
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
          /** @type {TasksModelItem} */
          const typedModel = model;
          console.log(`A2N.BLUR ~ onIsActiveChanged ${JSON.stringify({
            appName: typedModel.AppName,
            appId: typedModel.AppId,
            appPid: typedModel.AppPid,
            windowTitle: typedModel.display,
            isActive: typedModel.IsActive,
            isMinimized: typedModel.IsMinimized,
            isMaximized: typedModel.IsMaximized,
            isFullScreen: typedModel.IsFullScreen,
            geometry: typedModel.Geometry,
            stackingOrder: typedModel.StackingOrder,
            activities: typedModel.Activities,
            virtualDesktops: typedModel.VirtualDesktops,
            isOnAllVirtualDesktops: typedModel.IsOnAllVirtualDesktops,
            genericName: typedModel.GenericName,
            windowTypes: typedModel.windowTypes,
            lastActivated: typedModel.LastActivated,
            decoration: typedModel.decoration,
            IsWindow: typedModel.IsWindow,
            IsMovable: typedModel.IsMovable,
            IsKeepAbove: typedModel.IsKeepAbove,
            IsLauncher: typedModel.IsLauncher,
            IsFullScreenable: typedModel.IsFullScreenable
          }, null, 2)}`)
          windowActivated(isActive ?? false)
          if (isActive) plasmaTasksItem.activeTaskItem = task
        }
        Component.onCompleted: {}
      }
    }
  }
}
