import QtQuick
import QtQml.Models
import QtQuick.Window
import org.kde.taskmanager as TaskManager
import org.kde.kwindowsystem as Kwin

Item {
    id: plasmaTasksItem

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

                    console.log(model.AppId, 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
                    const arr = ['hasModelChildren', 'ChildCount', 'IsFullScreenable', 'IsLauncher', 'IsResizable', 'IsClosable', 'AppId', 'IsActive', 'IsWindow', 'StackingOrder']
                    arr.forEach((v) => {
                        console.log(`${v}: ${model[v]}`)
                    })

                    if (isActive) plasmaTasksItem.activeTaskItem = task
                }
            }
        }
    }
}
