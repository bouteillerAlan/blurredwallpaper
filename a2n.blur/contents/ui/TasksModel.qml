import QtQuick
import QtQml.Models
import QtQuick.Window
import org.kde.taskmanager as TaskManager
import org.kde.kwindowsystem as KwinSys

Item {
    id: plasmaTasksItem

    property Item activeTaskItem: null

    // true if a window is focus (e.g.: firefox)
    readonly property bool existsWindowActive:
        root.activeTaskItem && tasksRepeater.count > 0 && activeTaskItem.isActive

    // true if taskbar elements are focused (e.g.: yakuake)
    readonly property bool isTaskBarFocused:
        false

    TaskManager.TasksModel {
        id: tasksModel
        sortMode: TaskManager.TasksModel.SortVirtualDesktop
        groupMode: TaskManager.TasksModel.GroupDisabled
        activity: activityInfo.currentActivity
        virtualDesktop: virtualDesktopInfo.currentDesktop
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
                    console.log('xxxxxxxxx', plasmaTasksItem.isTaskBarFocused)
                    if (isActive) plasmaTasksItem.activeTaskItem = task
                }
            }
        }
    }
}
