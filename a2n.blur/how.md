# Active Blur Wallpaper Plugin - Technical Documentation

This document explains how the Active Blur wallpaper plugin for KDE Plasma 6 works, focusing on the blurring effect implementation. This documentation serves as a reference for future development and maintenance.

## Overview

The Active Blur wallpaper plugin dynamically applies a blur effect to the desktop wallpaper based on window activity. The core functionality is:

1. When windows are active: Apply blur to the wallpaper
2. When no windows are active (desktop is visible): Remove blur from the wallpaper
3. Animate the transition between blurred and non-blurred states

## Core Components

The blurring functionality is implemented across three main files:

1. `main.qml`: Controls the blur effect application based on window activity
2. `TasksModel.qml`: Monitors window activity using KDE's TaskManager API
3. `ImageStackView.qml`: Handles the display of wallpaper images

## Window Activity Detection (TasksModel.qml)

The `TasksModel.qml` file is responsible for detecting when windows are active on the desktop:

```qml
// Key property that indicates if any window is active
readonly property bool existsWindowActive: tasksModel.activeTask !== null
```

The detection works through these key components:

1. **TasksModel**: Uses KDE's TaskManager API to monitor all windows
   ```qml
   TaskManager.TasksModel {
       id: tasksModel
       // Configuration to filter windows by current desktop and activity
       activity: activityInfo.currentActivity
       virtualDesktop: virtualDesktopInfo.currentDesktop
       filterByVirtualDesktop: true
       filterByActivity: true
       filterByScreen: true
       
       // Property to track the active window
       property var activeTask: null
   }
   ```

2. **Event Monitoring**: Listens for changes in window state
   ```qml
   // Monitor changes to window activity
   onDataChanged: (topLeft, bottomRight, roles) => {
       if (roles.includes(TaskManager.AbstractTasksModel.IsActive)) {
           updateActiveTask();
       }
   }
   
   onRowsInserted: updateActiveTask()
   onRowsRemoved: updateActiveTask()
   onModelReset: updateActiveTask()
   ```

3. **Active Task Detection**: The `updateActiveTask()` function checks if any window is active
   ```qml
   function updateActiveTask() {
       // Loop through all windows
       for (let i = 0; i < tasksModel.rowCount(); i++) {
           const idx = tasksModel.index(i, 0);
           // Check if this window is active
           if (tasksModel.data(idx, TaskManager.AbstractTasksModel.IsActive)) {
               activeTask = idx;
               return;
           }
       }
       // No active windows found
       activeTask = null;
   }
   ```

## Blur Effect Application (main.qml)

The `main.qml` file applies the blur effect based on the window activity state:

1. **Window Activity State**: A property that determines when to apply blur
   ```qml
   readonly property bool shouldApplyBlur: windowTracker.existsWindowActive
   ```

2. **Blur Effect Implementation**: Uses Qt's FastBlur effect
   ```qml
   layer.enabled: root.configuration.ActiveBlur
   layer.effect: FastBlur {
       anchors.fill: parent
       radius: shouldApplyBlur ? root.configuration.BlurRadius : 0
       source: Image {
           anchors.fill: parent
           fillMode: Image.PreserveAspectCrop
           source: imageView.source
       }
       // animate the blur apparition
       Behavior on radius {
           NumberAnimation {
               duration: root.configuration.AnimationDuration
               easing.type: Easing.InOutQuad
           }
       }
   }
   ```

## Animation Implementation

The blur effect is animated for smooth transitions:

1. **Radius Animation**: The blur radius is animated between 0 (no blur) and the configured value
   ```qml
   Behavior on radius {
       NumberAnimation {
           duration: root.configuration.AnimationDuration
           easing.type: Easing.InOutQuad
       }
   }
   ```

2. **Animation Duration**: Configurable through the settings UI
   ```qml
   // From config.qml
   QtControls2.SpinBox {
       Kirigami.FormData.label: "Animation Delay:"
       id: animationDurationSpinBox
       value: cfg_AnimationDuration
       onValueChanged: cfg_AnimationDuration = value
       from: 0
       to: 60000 // 1 minute in ms
   }
   ```

## Configuration Options

The blur effect can be customized through several configuration options:

1. **Active Blur Toggle**: Enable/disable the dynamic blur effect
   ```qml
   // From config.qml
   QtControls2.CheckBox {
       id: activeBlurRadioButton
       Kirigami.FormData.label: "Active Blur:"
       text: activeBlurRadioButton.checked ? "On" : "Off"
   }
   ```

2. **Blur Radius**: Controls the intensity of the blur (1-9999)
   ```qml
   QtControls2.SpinBox {
       Kirigami.FormData.label: "Blur Radius:"
       id: blurRadiusSpinBox
       value: cfg_BlurRadius
       onValueChanged: cfg_BlurRadius = value
       from: 1
       to: 9999
   }
   ```

3. **Animation Duration**: Controls how quickly the blur transitions (0-60000ms)
   ```qml
   QtControls2.SpinBox {
       Kirigami.FormData.label: "Animation Delay:"
       id: animationDurationSpinBox
       value: cfg_AnimationDuration
       onValueChanged: cfg_AnimationDuration = value
       from: 0
       to: 60000
   }
   ```

## Data Flow

The data flow for the blur effect works as follows:

1. `TasksModel.qml` monitors window activity and updates `existsWindowActive`
2. `main.qml` reads `windowTracker.existsWindowActive` to set `shouldApplyBlur`
3. The FastBlur effect's radius is set based on `shouldApplyBlur`:
   - If `shouldApplyBlur` is true: radius = `BlurRadius` (from configuration)
   - If `shouldApplyBlur` is false: radius = 0 (no blur)
4. The NumberAnimation animates the transition between these states

## Performance Considerations

- The blur effect is only enabled when `root.configuration.ActiveBlur` is true
- The FastBlur effect is applied to the entire wallpaper, which can be resource-intensive
- High blur radius values (>64) may reduce visual quality due to Qt limitations
- The animation duration affects how quickly the blur transitions, which can impact performance

## Troubleshooting

- If the blur effect is not working, check if `ActiveBlur` is enabled in the configuration
- If the blur effect is too intense or causes visual artifacts, reduce the `BlurRadius` value
- If the animation is too slow or too fast, adjust the `AnimationDuration` value