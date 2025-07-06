import QtQuick
import org.kde.plasma.core as PlasmaCore
import org.kde.taskmanager as TaskManager
import org.kde.plasma.workspace.components as WorkspaceComponents

Item {
    id: windowTracker

    property var abstractTasksModel: TaskManager.AbstractTasksModel
    property var isMaximized: abstractTasksModel.IsMaximized
    property var isActive: abstractTasksModel.IsActive
    property var isWindow: abstractTasksModel.IsWindow
    property var isFullScreen: abstractTasksModel.IsFullScreen
    property var isMinimized: abstractTasksModel.IsMinimized

    // Expose a single property for the main component to check
    readonly property bool existsWindowActive: tasksModel.activeTask !== null

    TaskManager.TasksModel {
        id: tasksModel
        sortMode: TaskManager.TasksModel.SortVirtualDesktop
        groupMode: TaskManager.TasksModel.GroupDisabled
        activity: activityInfo.currentActivity
        virtualDesktop: virtualDesktopInfo.currentDesktop
        filterByVirtualDesktop: true
        filterByActivity: true
        filterByScreen: true

        // Track active tasks
        property var activeTask: null

        // Use connections to monitor active task changes
        onDataChanged: (topLeft, bottomRight, roles) => {
            test();
            countVisibleTasks();
            if (roles.includes(TaskManager.AbstractTasksModel.IsActive)) {
                updateActiveTask();
            }
        }

        onCountChanged: {
            countVisibleTasks();
        }

        onRowsInserted: updateActiveTask()
        onRowsRemoved: updateActiveTask()
        onModelReset: updateActiveTask()

        function countVisibleTasks() {
            let model = tasksModel
            let activeCount = 0;
            let visibleCount = 0;
            let maximizedCount = 0;
            for (var i = 0; i < model.count; i++) {
                const currentTask = model.index(i, 0);
                if (currentTask === undefined) continue;
                if (model.data(currentTask, isWindow) && !model.data(currentTask, isMinimized)) {
                    visibleCount += 1;
                    if (model.data(currentTask, isMaximized) || model.data(currentTask, isFullScreen)) {
                        maximizedCount += 1;
                    }
                    if (model.data(currentTask, isActive)) {
                        activeCount += 1;
                    }
                }
            }
            console.log(JSON.stringify({
                activeCount,
                visibleCount,
                maximizedCount,
                "tasksModel.count": tasksModel.count,
                "tasksModel.rowCount": tasksModel.rowCount(),
            }, null, 0))
        }

        function updateActiveTask() {
            for (let i = 0; i < tasksModel.rowCount(); i++) {
                const idx = tasksModel.index(i, 0);
                if (tasksModel.data(idx, TaskManager.AbstractTasksModel.IsActive)) {
                    activeTask = idx;
                    return;
                }
            }
            activeTask = null;
        }

        function test() {
            console.log("@@@@@", JSON.stringify(WorkspaceComponents))
        }

        Component.onCompleted: updateActiveTask()
    }

    Component.onDestruction: {
        // Proper cleanup
        tasksModel.activeTask = null;
    }
}
