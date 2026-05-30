# K2 SE KlipperScreen Setup Guide

## Overview

This guide provides complete setup instructions for the K2 SE custom KlipperScreen configuration with DXC support.

## Installation

### 1. Install KlipperScreen

```bash
# Clone KlipperScreen repository
cd ~
git clone https://github.com/jordanruthe/KlipperScreen.git
cd KlipperScreen
sudo ./install.sh
```

### 2. Copy Configuration

```bash
# Copy custom configuration
cp k2-se-custom-ui/KlipperScreen.conf ~/.config/KlipperScreen/

# Set permissions
chmod 644 ~/.config/KlipperScreen/KlipperScreen.conf
```

### 3. Restart Service

```bash
sudo systemctl restart KlipperScreen
```

## Configuration Files

### Main Config
- **Location**: `~/.config/KlipperScreen/KlipperScreen.conf`
- **Contains**: Main settings, menu structure, color scheme
- **Theme**: Creality orange (#ff6b35) with dark background

### Custom Themes
- **Location**: `~/.local/share/klipper-screen/`
- **Include**: Icons, fonts, custom layouts

## Menu Structure

### Main Menu Items

```
├── Temperature
│   ├── Hotend 1
│   ├── Hotend 2
│   ├── Bed
│   └── Preheat
├── Movement
│   ├── Home All
│   ├── Home XY
│   ├── Home Z
│   └── Babystepping
├── Extrude
│   ├── Extrude E1
│   └── Extrude E2
├── Print
│   ├── Print Jobs
│   └── Print History
├── Calibration
│   ├── Nozzle Offset
│   ├── Bed Mesh
│   └── PID Tune
├── DXC Control (Custom)
├── Macros
├── Network
└── Settings
```

## Color Scheme

```
Background: #1a1a1a (Dark)
Text: #ffffff (White)
Primary: #ff6b35 (Creality Orange)
Secondary: #f7931e (Lighter Orange)
Success: #4ade80 (Green)
Warning: #facc15 (Yellow)
Error: #ef4444 (Red)
Disabled: #666666 (Gray)
```

## Customization

### Change Color Scheme

Edit `KlipperScreen.conf`:

```ini
[colors]
background: #1a1a1a
text: #ffffff
primary: #ff6b35
secondary: #f7931e
```

### Add Custom Macros

Edit `KlipperScreen.conf`:

```ini
[displayed_macros Macros]
T0
T1
YOUR_CUSTOM_MACRO
```

### Modify Menu

Add new menu items:

```ini
[menu __main __custom]
name: Custom Item
icon: custom_icon
panel: custom_panel
```

## Macros Display

The following macros are available on the DXC Control menu:

- **T0** - Select Extruder 1
- **T1** - Select Extruder 2
- **TOGGLE_EXTRUDER** - Switch between extruders
- **LOAD_FILAMENT_E0** - Load filament E1
- **LOAD_FILAMENT_E1** - Load filament E2
- **UNLOAD_FILAMENT_E0** - Unload filament E1
- **UNLOAD_FILAMENT_E1** - Unload filament E2
- **PRIME_EXTRUDERS** - Prime both extruders
- **DXC_STATUS** - Show DXC status
- **CALIBRATE_NOZZLE_OFFSET** - Calibrate offset
- **DUAL_COLOR_SETUP** - Full dual color setup
- **CONVERT_TO_DXC** - Initialize DXC

## Display Configuration

### Screen Updates
- **Update Interval**: 1 second (responsive)
- **Error Timeout**: 120 seconds
- **Startup Brightness**: 100%
- **Idle Brightness**: 50%

### Button Configuration
- **Back Button**: Enabled
- **Menu Timeout**: 600 seconds (10 minutes)

## Troubleshooting

### Configuration Not Loading

1. Check file location: `~/.config/KlipperScreen/KlipperScreen.conf`
2. Verify file permissions: `chmod 644 KlipperScreen.conf`
3. Check logs: `~/.config/KlipperScreen/KlipperScreen.log`
4. Restart service: `sudo systemctl restart KlipperScreen`

### Colors Not Showing

1. Clear cache: `rm -rf ~/.cache/klipper-screen/`
2. Restart KlipperScreen
3. Check color hex values are valid

### Macros Not Appearing

1. Verify macros exist in `printer.cfg`
2. Check macro names in config match exactly
3. Verify includes in `printer.cfg`: `[include k2-se-macros.cfg]`
4. Restart Klipper: `sudo systemctl restart klipper`
5. Restart KlipperScreen: `sudo systemctl restart KlipperScreen`

### Menu Items Missing

1. Check menu section names in config
2. Verify panel names exist
3. Check for typos in menu definitions
4. Restart KlipperScreen

## Performance Tips

1. **Reduce Update Interval** for snappier response:
   ```ini
   update_interval: 2
   ```

2. **Increase Idle Brightness** if screen dims too quickly:
   ```ini
   on_idle: 75
   ```

3. **Disable Unused Panels** for faster startup

4. **Use Simpler Icons** for lower resources

## Advanced Configuration

### Temperature Presets

Add custom material presets:

```ini
[preheat Custom]
bed: 50
extruder: 190
extruder1: 190
```

### Custom Panels

Create custom panels in `~/.local/share/klipper-screen/panels/`

### Icon Customization

Place custom icons in `~/.local/share/klipper-screen/icons/`

## Default Preheat Profiles

### PLA
- **Bed**: 60°C
- **Extruders**: 200°C

### PETG
- **Bed**: 80°C
- **Extruders**: 230°C

### ABS
- **Bed**: 100°C
- **Extruders**: 240°C

### TPU
- **Bed**: 60°C
- **Extruders**: 220°C

## Support & Documentation

- 📖 [KlipperScreen GitHub](https://github.com/jordanruthe/KlipperScreen)
- 💬 [KlipperScreen Discord](https://discord.klipper3d.org/)
- 🔧 [Klipper Documentation](https://www.klipper3d.org/)

## License

KlipperScreen is licensed under GPL v3.
K2 SE configuration is provided as-is for community use.
