# K2 SE Installation & Setup Guide

## 🎯 Quick Installation (5 minutes)

### Step 1: Clone Repository
```bash
cd ~/printer_data/config
git clone -b k2-se-custom-ui-revamp https://github.com/sowavy234/Creality-Helper-Script-Wiki.git k2-se-ui
cd k2-se-ui
```

### Step 2: Run Conversion Script
```bash
chmod +x conversion-helper.sh
./conversion-helper.sh
```

The script will:
- ✓ Backup your current config
- ✓ Install all custom files
- ✓ Create helper macros
- ✓ Restart Klipper service

### Step 3: Initialize DXC
```gcode
CONVERT_TO_DXC
```

### Step 4: Calibrate
```gcode
CALIBRATE_NOZZLE_OFFSET
BED_MESH_CALIBRATE
```

## 📦 What's Included

| File | Purpose |
|------|---------|
| `k2-se-dxc-extruder.cfg` | Dual extruder configuration |
| `k2-se-macros.cfg` | 50+ helper commands |
| `dashboard.yaml` | Dashboard layout |
| `ui-styles.css` | UI styling (orange theme) |
| `conversion-helper.sh` | Automated installation |
| `README.md` | Full documentation |
| `QUICKSTART.md` | This file |

## 🔧 Hardware Wiring

### Extruder 1 (E0 - Factory)
- Motor: PB13 (Step), PB12 (Dir), PB14 (Enable)
- Heater: PA2
- Thermistor: PA0
- Runout: PC10

### Extruder 2 (E1 - DXC Kit)
- Motor: PB8 (Step), PB7 (Dir), PC11 (Enable)
- Heater: PC9
- Thermistor: PC4
- Runout: PA11

## 🎨 Dashboard Features

### Status Bar
- Real-time temperature display
- Print progress indicator
- Connection status
- Quick stats

### DXC Control Panel
- Independent temp control (E0/E1)
- Speed adjusters
- Extruder selector (E1/E2/All)
- Filament runout status

### Bed & Nozzle
- Bed temperature control
- Quick leveling button
- Mesh leveling toggle

### Movement
- Home All/XY/Z
- Manual Z adjustment
- Quick position presets

### Print Control
- Start/Pause/Resume/Cancel
- Print progress tracking
- Live status updates

## ⚡ Common Commands

### Filament
```gcode
LOAD_FILAMENT_E0 TEMP=200      # Load E0 at 200°C
UNLOAD_FILAMENT_E1             # Unload E1
PURGE_EXTRUDER AMOUNT=10       # Extrude 10mm
```

### Extruder Selection
```gcode
T0                             # Select E0
T1                             # Select E1
TOGGLE_EXTRUDER                # Switch between E0/E1
```

### Temperature
```gcode
SET_EXTRUDER_TEMP EXTRUDER=0 TEMP=210    # E0 to 210°C
HEAT_EXTRUDERS TEMP=210                  # Both to 210°C
COOL_EXTRUDERS                           # Turn off both
```

### Printing
```gcode
DUAL_COLOR_SETUP               # Full dual-color prep
PRIME_EXTRUDERS                # Prime both
DXC_STATUS                     # Show status
CALIBRATE_NOZZLE_OFFSET        # Calibrate offset
```

### Calibration
```gcode
PID_CALIBRATE_E0 TEMP=220      # PID tune E0
PID_CALIBRATE_E1 TEMP=220      # PID tune E1
AUTO_BED_LEVELING              # Full bed mesh
```

## 🎨 Color Scheme

The UI uses these colors:
- **Primary**: #ff6b35 (Creality Orange)
- **Secondary**: #f7931e (Lighter Orange)
- **Background**: #1a1a1a (Dark)
- **Accent**: #2d2d2d (Lighter Dark)

## 📝 Configuration Files

### Include in printer.cfg

The script automatically adds these includes:

```cfg
[include k2-se-dxc-extruder.cfg]      # Extruder definitions
[include k2-se-macros.cfg]            # Helper commands
```

Optional includes:
```cfg
[include k2-se-dashboard.yaml]        # Dashboard layout
[include k2-se-ui-styles.css]         # UI styling
```

## 🔍 Verify Installation

### Check Status
```bash
curl http://localhost:7125/printer/objects/query?extruder1
```

### Test Extruder Selection
```gcode
T0
DXC_STATUS
T1
DXC_STATUS
```

### Test Temperature
```gcode
SET_EXTRUDER_TEMP EXTRUDER=0 TEMP=210
SET_EXTRUDER_TEMP EXTRUDER=1 TEMP=210
DXC_STATUS
```

## 🐛 Troubleshooting

### Extruder 1 Not Found
- Check wiring to pins: PB8, PB7, PC11
- Verify thermistor on PC4
- Check heater on PC9

### Temperature Not Reading
- Verify sensor type in config
- Check ADC pin voltage (0-3.3V)
- Test with multimeter

### Tool Change Not Working
- Verify nozzle offset calibration
- Check retraction settings
- Review macro definitions

### Need to Restore
```bash
# Backup location created automatically
cp ~/printer_data/config_backup_YYYYMMDD_HHMMSS/* ~/printer_data/config/
sudo systemctl restart klipper
```

## 📞 Support

- 📖 [Klipper Docs](https://www.klipper3d.org/)
- 💬 [Klipper Discord](https://discord.klipper3d.org/)
- 🐙 [GitHub Issues](https://github.com/sowavy234/Creality-Helper-Script-Wiki/issues)

## 🎓 Learning Resources

- **Getting Started**: Read README.md
- **Configuration**: Edit k2-se-dxc-extruder.cfg
- **Macros**: Review k2-se-macros.cfg
- **Styling**: Customize ui-styles.css

## ✨ Next Steps

1. ✓ Clone and install
2. ✓ Run conversion script
3. ✓ Initialize DXC
4. ✓ Calibrate nozzles
5. ✓ Print test model
6. ✓ Enjoy dual extrusion!

---

**Happy Printing! 🖨️**

For detailed information, see [README.md](README.md)
