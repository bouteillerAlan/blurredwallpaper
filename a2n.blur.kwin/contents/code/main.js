// KWin script to blur the wallpaper when a window is active
// Based on the a2n.blur plasma wallpaper plugin

var activeBlur = true;
var blurRadius = 40;
var animationDuration = 250;

// Effect properties
var effect = {
    loaded: false,
    active: false,
    targetBlur: 0,
    currentBlur: 0,
    animationTimer: null
};

// Configuration
var config = {
    activeBlur: true,
    blurRadius: 40,
    animationDuration: 250
};

// Load configuration
function loadConfig() {
    config.activeBlur = readConfig("ActiveBlur", true);
    config.blurRadius = readConfig("BlurRadius", 40);
    config.animationDuration = readConfig("AnimationDuration", 250);
}

// Initialize the effect
function init() {
    loadConfig();

    // Connect to window signals
    workspace.clientAdded.connect(onClientAdded);
    workspace.clientRemoved.connect(onClientRemoved);
    workspace.clientActivated.connect(onClientActivated);

    // Check current windows
    checkActiveWindows();

    effect.loaded = true;
    print("Active Blur KWin script initialized");
}

// Check if there are any active windows
function checkActiveWindows() {
    var hasActiveWindow = false;
    var clients = workspace.clientList();

    for (var i = 0; i < clients.length; i++) {
        var client = clients[i];
        if (isRelevantWindow(client) && client.active) {
            hasActiveWindow = true;
            break;
        }
    }

    updateBlurEffect(hasActiveWindow);
}

// Determine if a window should be considered for the blur effect
function isRelevantWindow(client) {
    // Skip certain window types that shouldn't trigger the blur
    if (!client.normalWindow) return false;
    if (client.desktopWindow) return false;
    if (client.dock) return false;
    if (client.skipTaskbar) return false;

    return true;
}

// Handle new clients
function onClientAdded(client) {
    if (isRelevantWindow(client) && client.active) {
        updateBlurEffect(true);
    }
}

// Handle removed clients
function onClientRemoved(client) {
    // Check remaining windows after a short delay
    // to ensure the state is stable
    setTimeout(checkActiveWindows, 100);
}

// Handle client activation changes
function onClientActivated(client) {
    if (client === null) {
        // No active client
        updateBlurEffect(false);
    } else if (isRelevantWindow(client)) {
        updateBlurEffect(true);
    }
}

// Update the blur effect based on window state
function updateBlurEffect(shouldBlur) {
    if (!config.activeBlur) {
        return;
    }

    effect.targetBlur = shouldBlur ? config.blurRadius : 0;

    // If we're already at the target blur level, do nothing
    if (effect.currentBlur === effect.targetBlur) {
        return;
    }

    // If an animation is already running, clear it
    if (effect.animationTimer !== null) {
        clearInterval(effect.animationTimer);
        effect.animationTimer = null;
    }

    // Set up animation
    var startTime = Date.now();
    var startBlur = effect.currentBlur;
    var blurDiff = effect.targetBlur - startBlur;
    var duration = config.animationDuration;

    effect.animationTimer = setInterval(function() {
        var elapsed = Date.now() - startTime;
        var progress = Math.min(elapsed / duration, 1);

        // Ease in-out quad
        var easeProgress;
        if (progress < 0.5) {
            easeProgress = 2 * progress * progress;
        } else {
            easeProgress = 1 - Math.pow(-2 * progress + 2, 2) / 2;
        }

        effect.currentBlur = startBlur + blurDiff * easeProgress;

        // Apply the blur effect to the wallpaper
        applyWallpaperBlur(effect.currentBlur);

        if (progress >= 1) {
            clearInterval(effect.animationTimer);
            effect.animationTimer = null;
            effect.currentBlur = effect.targetBlur;
        }
    }, 16); // ~60fps
}

// Apply the blur effect to the wallpaper
// This function uses KWin's DBus interface to communicate with the Plasma shell
function applyWallpaperBlur(blurAmount) {
    // Round to integer for cleaner values
    blurAmount = Math.round(blurAmount);

    // Use KWin's DBus interface to set a property that the wallpaper can read
    // This requires a corresponding mechanism in Plasma to read this value
    callDBus(
        "org.kde.plasmashell",
        "/PlasmaShell",
        "org.kde.PlasmaShell",
        "evaluateScript",
        "var allDesktops = desktops();" +
        "for (var i = 0; i < allDesktops.length; i++) {" +
        "    var desktop = allDesktops[i];" +
        "    desktop.wallpaperPlugin = 'org.kde.image';" +
        "    desktop.currentConfigGroup = ['Wallpaper', 'org.kde.image', 'General'];" +
        "    desktop.writeConfig('BlurEffect', " + blurAmount + ");" +
        "}"
    );
}

// Handle configuration changes
function configChanged() {
    loadConfig();

    // Update the effect with new settings
    if (effect.loaded) {
        checkActiveWindows();
    }
}

// Initialize the script
init();
