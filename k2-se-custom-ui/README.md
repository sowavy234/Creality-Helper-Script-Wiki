````markdown name=README.md
# K2 SE Custom UI - DXC Extruder Revamp

A complete custom UI overhaul for the Creality K2 SE printer with DXC (Dual Extruder) support. This project provides a modern dashboard, dual extruder management, and comprehensive helper commands for seamless conversion.

## Features

✨ **Custom Dashboard Layout**
- K2 SE optimized interface
- Real-time temperature monitoring
- Dual extruder status display
- Print progress tracking
- Connection status indicator

🎨 **Modern UI Design**
- Dark theme with orange Creality accent colors
- Responsive grid layout
- Smooth animations and transitions
- Professional status indicators
- Touch-friendly controls

🔧 **DXC Extruder Management**
- Dual extruder selection (E0, E1, Mirror mode)
- Independent temperature control
- Filament runout sensors
- Pressure advance calibration
- Tool change optimization

📋 **Comprehensive Helper Commands**
- Automatic DXC initialization
- Nozzle offset calibration
- Filament loading/unloading macros
- Dual color printing setup
- Status reporting

## Quick Start

### Prerequisites
- Creality K2 SE printer
- DXC extruder kit installed
- Klipper firmware configured
- Raspberry Pi or compatible board

### Installation

1. **Clone the Repository**
   ```bash
   cd ~/printer_data/config
   git clone https://github.com/sowavy234/Creality-Helper-Script-Wiki.git k2-se-custom-ui
   cd k2-se-custom-ui
   ```

2. **Run Conversion Script**
   ```bash
   chmod +x conversion-helper.sh
   ./conversion-helper.sh
   ```

3. **Review & Accept Changes**
   - Script will show prompts for each step
   - Automatic backup created
   - Configuration files installed

4. **Restart Klipper**
   ```bash
   sudo systemctl restart klipper
   ```

## Configuration Files

### `k2-se-dxc-extruder.cfg`
Main extruder configuration with:
- Dual extruder (E0/E1) definitions
- Temperature PID tuning
- Motor pin assignments
- Filament runout sensors
- Bed mesh leveling
- BLTouch probe setup

**Key Settings:**
- E0 & E1: Step/Dir/Enable pins configured
- Temperature range: 0-300°C
- Pressure advance: 0.04 (adjustable)
- Max extrusion: 5.0mm²

### `dashboard.yaml`
Dashboard layout configuration with:
- Status bar (top)
- DXC control panel
- Bed & nozzle controls
- Movement controls
- Print controls
- Real-time widgets

### `ui-styles.css`
Complete styling with:
- Color scheme (primary: #ff6b35 - Creality orange)
- Responsive grid system
- Smooth animations
- Status indicators
- Button styles
- Progress bars

### `k2-se-macros.cfg`
Helper macros including:
- `CONVERT_TO_DXC` - Initialize conversion
- `LOAD_FILAMENT_E0/E1` - Load filament
- `UNLOAD_FILAMENT_E0/E1` - Unload filament
- `DUAL_COLOR_SETUP` - Setup dual color printing
- `DXC_STATUS` - Display status
- `CALIBRATE_NOZZLE_OFFSET` - Offset calibration
- `SWITCH_EXTRUDER_QUIET` - Silent tool changes

## Usage

### Initial Setup

1. **Convert to DXC**
   ```gcode
   CONVERT_TO_DXC
   ```
   - Homes all axes
   - Heats both extruders to 200°C
   - Selects primary extruder (E0)

2. **Calibrate Nozzle Offset**
   ```gcode
   CALIBRATE_NOZZLE_OFFSET
   ```
   - Manually adjust offset using paper method
   - Note the Z offset difference
   - Update in configuration

3. **Calibrate Bed Mesh**
   ```gcode
   BED_MESH_CALIBRATE
   ```

### Filament Management

**Load Filament**
```gcode
LOAD_FILAMENT_E0 TEMP=200    # Load extruder 0
LOAD_FILAMENT_E1 TEMP=210    # Load extruder 1 at 210°C
```

**Unload Filament**
```gcode
UNLOAD_FILAMENT_E0
UNLOAD_FILAMENT_E1
```

### Extruder Selection

**Select Extruder**
```gcode
T0                           # Select E0 (quick)
T1                           # Select E1 (quick)
SELECT_EXTRUDER EXTRUDER=0   # Select E0 (with macro)
TOGGLE_EXTRUDER              # Toggle between E0 and E1
```

### Dual Color Printing

**Setup**
```gcode
DUAL_COLOR_SETUP
```
- Homes and levels bed
- Heats both extruders to 210°C
- Primes both nozzles
- Ready for printing

**During Print**
```gcode
T0          # Switch to extruder 0
G1 E-2 F300 # Retract to prevent oozing
T1          # Switch to extruder 1
G1 E10 F300 # Prime new extruder
```

### Status & Monitoring

**Get Status**
```gcode
DXC_STATUS
```
Output: `Active: E0 | E0: 195.2°C | E1: 180.5°C`

**Print Progress**
Use dashboard widget or query:
```bash
curl http://localhost:7125/printer/objects/query?virtual_sdcard
```

## Dashboard Widgets

### Status Bar
- **Printer Status** - Online/Offline indicator
- **Temperatures** - E0, E1, Bed readings
- **Print Progress** - Percentage and time
- **Connection** - Network status

### DXC Control Panel
- **E0/E1 Temperature Controls** - Set and monitor
- **E0/E1 Speed Sliders** - 10-150% adjustment
- **Extruder Selector** - Quick E0/E1/All buttons
- **Filament Runout Status** - Loaded/Low/Runout

### Bed & Nozzle Panel
- **Bed Temperature** - Monitor and control
- **Nozzle Heater Status** - On/Off indicator
- **Quick Level** - Single-click bed leveling
- **Mesh Leveling** - Toggle mesh loading

### Movement Panel
- **Home All** - Full XYZ homing
- **Home XY** - Horizontal homing only
- **Home Z** - Z-axis homing only
- **Move Up/Down** - Manual Z adjustment

### Print Control Panel
- **Start Print** - Resume print
- **Pause** - Pause current print
- **Resume** - Continue paused print
- **Cancel** - Stop print

## Customization

### Change Color Scheme

Edit `ui-styles.css`:
```css
:root {
  --primary-color: #ff6b35;      /* Creality Orange */
  --secondary-color: #f7931e;    /* Lighter Orange */
  --background-dark: #1a1a1a;
  --success-color: #4ade80;      /* Green */
  --warning-color: #facc15;      /* Yellow */
  --danger-color: #ef4444;       /* Red */
}
```

### Modify Dashboard Layout

Edit `dashboard.yaml`:
```yaml
sections:
  - id: "your_section"
    type: "panel"
    position: [0, 0, 2, 1]  # [x, y, width, height]
    title: "Your Title"
    widgets:
      - your_widget_1
      - your_widget_2
```

### Add Custom Macros

Add to `k2-se-macros.cfg`:
```gcode
[gcode_macro YOUR_MACRO]
description: Your macro description
gcode:
    # Your gcode commands
    M117 Your Message
```

## Temperature Tuning

### PID Calibration

**Extruder 0**
```gcode
PID_CALIBRATE HEATER=extruder TARGET=220
```

**Extruder 1**
```gcode
PID_CALIBRATE HEATER=extruder1 TARGET=220
```

Update `k2-se-dxc-extruder.cfg` with generated values:
```
pid_Kp: XX.XXX
pid_Ki: X.XXX
pid_Kd: XXXX.XXX
```

## Troubleshooting

### Extruder 1 Not Responding

**Check Wiring:**
- Motor: PB8 (Step), PB7 (Dir), PC11 (Enable)
- Heater: PC9 (Pin), PC4 (Thermistor)
- Power: 12V supply

**Test Connection:**
```bash
curl http://localhost:7125/printer/objects/query?extruder1
```

### Temperature Sensor Not Reading

**Verify Configuration:**
```cfg
sensor_pin: PC4
sensor_type: EPCOS 100K B57860S104F
```

**Check Wiring:** ADC pin PC4 voltage (0-3.3V)

### Filament Runout Not Triggering

**Check Sensor Pins:**
- E0: PC10
- E1: PA11

**Test Sensor:**
```bash
curl http://localhost:7125/printer/objects/query?filament_motion_sensor
```

### Tool Change Not Working

**Verify Extruder Selection:**
```gcode
T0
M117 {printer.toolhead.extruder}
```

**Check Macros Loaded:**
```bash
curl http://localhost:7125/printer/objects/query?gcode_macro
```

## Performance Optimization

### Pressure Advance Tuning

Print a pressure advance tower:
```gcode
; Your slicer should generate this
TUNING_TOWER COMMAND="SET_PRESSURE_ADVANCE ADVANCE={print_pos.z*(-0.005)+0.0}" PARAMETER=SPEED START=20 FACTOR=2
```

### Nozzle Offset Fine-Tuning

Use paper method:
1. Heat both to printing temp
2. Manually adjust Z with G-code:
   ```gcode
   G1 Z-0.1  # Lower Z
   G1 Z+0.1  # Raise Z
   ```
3. Note offset and update config

## File Locations

```
~/printer_data/
├── config/
│   ├── printer.cfg                    (main config)
│   ├── k2-se-dxc-extruder.cfg        (new extruder config)
│   ├── k2-se-dashboard.yaml          (new dashboard)
│   ├── k2-se-ui-styles.css           (new styles)
│   ├── k2-se-macros.cfg              (new macros)
│   └── config_backup_YYYYMMDD_HHMMSS/ (automatic backup)
└── logs/
    └── klippy.log                     (debug logs)
```

## Backup & Recovery

### Backup Location
Automatically created during installation:
```
~/printer_data/config_backup_YYYYMMDD_HHMMSS/
```

### Restore from Backup
```bash
cp ~/printer_data/config_backup_YYYYMMDD_HHMMSS/* ~/printer_data/config/
sudo systemctl restart klipper
```

## Version History

**v1.0 - Initial Release**
- ✅ Complete K2 SE UI revamp
- ✅ DXC extruder support
- ✅ Custom dashboard
- ✅ Helper commands
- ✅ Macro suite
- ✅ Conversion script

## Support & Contributing

### Report Issues
1. Check troubleshooting section
2. Provide logs: `~/printer_data/logs/klippy.log`
3. Open issue on GitHub with details

### Contribute Improvements
1. Fork repository
2. Create feature branch
3. Make improvements
4. Submit pull request

## Credits

- **Creality** - K2 SE Printer
- **Klipper** - Firmware
- **Community** - Dual extrusion expertise

## License

This project is provided as-is for the community. Feel free to modify and share.

## Disclaimer

⚠️ **Use at Your Own Risk**

- Follow all safety procedures
- Verify all connections before powering on
- Test with non-critical prints first
- Keep backups of working configurations
- Monitor printer operation

---

**Last Updated:** 2026-05-29
**Version:** 1.0
**Status:** Stable

For more information, visit:
- 🔗 [Klipper Documentation](https://www.klipper3d.org/)
- 🔗 [GitHub Repository](https://github.com/sowavy234/Creality-Helper-Script-Wiki)
- 🔗 [Creality Community](https://www.creality.com/)
````
