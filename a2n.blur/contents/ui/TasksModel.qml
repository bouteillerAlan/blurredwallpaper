import QtQuick
import org.kde.plasma.core as PlasmaCore
import org.kde.taskmanager as TaskManager

Item {
    id: windowTracker

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
            if (roles.includes(TaskManager.AbstractTasksModel.IsActive)) {
                updateActiveTask();
            }
        }

        onRowsInserted: updateActiveTask()
        onRowsRemoved: updateActiveTask()
        onModelReset: updateActiveTask()

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

        Component.onCompleted: updateActiveTask()
    }

    Component.onDestruction: {
        // Proper cleanup
        tasksModel.activeTask = null;
    }
}
