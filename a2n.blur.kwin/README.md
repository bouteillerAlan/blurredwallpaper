# Active Blur KWin Script

A KWin script for KDE Plasma 6 that blurs the wallpaper when a window is active.

## Description

This KWin script replicates the functionality of the "Active Blur" Plasma wallpaper plugin as a KWin effect. When a window is active on your desktop, the wallpaper will be blurred, creating a visual distinction between the desktop with and without active windows.

## Features

- Automatically blurs the wallpaper when a window is active
- Smooth animation when transitioning between blurred and non-blurred states
- Configurable blur radius and animation duration
- Compatible with KDE Plasma 6

## Installation

### Manual Installation

1. Create the KWin scripts directory if it doesn't exist:
   ```
   mkdir -p ~/.local/share/kwin/scripts/
   ```

2. Copy the `a2n.blur.kwin` folder to the KWin scripts directory:
   ```
   cp -r a2n.blur.kwin ~/.local/share/kwin/scripts/
   ```

3. Enable the script in KWin:
   - Open System Settings
   - Go to Window Management > KWin Scripts
   - Check the "Active Blur" script in the list
   - Click Apply

### From KDE Store (When Available)

1. Open System Settings
2. Go to Window Management > KWin Scripts
3. Click "Get New Scripts..."
4. Search for "Active Blur"
5. Click Install
6. Enable the script and click Apply

## Configuration

To configure the script:

1. Open System Settings
2. Go to Window Management > KWin Scripts
3. Select "Active Blur" and click the configuration button
4. Adjust the following settings:
   - Enable/disable the blur effect
   - Blur radius (1-100)
   - Animation duration (0-1000ms)

## How It Works

The script monitors window activity using KWin's window management API. When a window becomes active, it applies a blur effect to the wallpaper with a smooth animation. When all windows are closed or minimized, the blur effect is removed.

## Compatibility

This script is designed for KDE Plasma 6. It may not work with earlier versions of Plasma.

## License

GPL-2.0-or-later

## Credits

Based on the "Active Blur" Plasma wallpaper plugin by a2n.
