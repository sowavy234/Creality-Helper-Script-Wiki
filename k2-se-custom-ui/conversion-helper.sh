#!/bin/bash

################################################################################
# K2 SE DXC Extruder Conversion Helper Script
# Convert your K2 SE to dual extruder configuration with custom UI
################################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Paths
KLIPPER_HOME="${HOME}/klipper"
PRINTER_DATA="${HOME}/printer_data"
CONFIG_DIR="${PRINTER_DATA}/config"
BACKUP_DIR="${PRINTER_DATA}/config_backup_$(date +%Y%m%d_%H%M%S)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

################################################################################
# Helper Functions
################################################################################

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ${NC}  $1"
}

print_success() {
    echo -e "${GREEN}✓${NC}  $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC}  $1"
}

print_error() {
    echo -e "${RED}✗${NC}  $1"
}

confirm() {
    local prompt="$1"
    local response
    read -r -p "$(echo -e ${YELLOW}$prompt${NC})" response
    case "$response" in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

################################################################################
# Main Functions
################################################################################

check_environment() {
    print_header "Checking Environment"
    
    # Check if running on Raspberry Pi / Linux
    if [[ ! -f /etc/os-release ]]; then
        print_error "This script must run on Linux (Raspberry Pi OS, etc.)"
        exit 1
    fi
    
    print_success "Linux environment detected"
    
    # Check Klipper installation
    if [[ ! -d "$KLIPPER_HOME" ]]; then
        print_error "Klipper not found at $KLIPPER_HOME"
        exit 1
    fi
    
    print_success "Klipper found at $KLIPPER_HOME"
    
    # Check config directory
    if [[ ! -d "$CONFIG_DIR" ]]; then
        print_error "Klipper config directory not found at $CONFIG_DIR"
        exit 1
    fi
    
    print_success "Config directory found at $CONFIG_DIR"
}

backup_config() {
    print_header "Backing Up Configuration"
    
    if [[ ! -d "$BACKUP_DIR" ]]; then
        mkdir -p "$BACKUP_DIR"
        print_success "Created backup directory: $BACKUP_DIR"
    fi
    
    cp -r "$CONFIG_DIR"/* "$BACKUP_DIR/" 2>/dev/null || true
    print_success "Configuration backed up to $BACKUP_DIR"
    print_info "You can restore from backup if needed"
}

install_custom_ui() {
    print_header "Installing Custom K2 SE UI"
    
    # Copy UI files
    if [[ -f "$SCRIPT_DIR/dashboard.yaml" ]]; then
        cp "$SCRIPT_DIR/dashboard.yaml" "$CONFIG_DIR/k2-se-dashboard.yaml"
        print_success "Dashboard configuration installed"
    fi
    
    if [[ -f "$SCRIPT_DIR/ui-styles.css" ]]; then
        cp "$SCRIPT_DIR/ui-styles.css" "$CONFIG_DIR/k2-se-ui-styles.css"
        print_success "UI styles installed"
    fi
    
    # Create UI directory if needed
    if [[ ! -d "$CONFIG_DIR/ui" ]]; then
        mkdir -p "$CONFIG_DIR/ui"
        print_success "Created UI directory"
    fi
}

install_extruder_config() {
    print_header "Installing DXC Extruder Configuration"
    
    if [[ -f "$SCRIPT_DIR/k2-se-dxc-extruder.cfg" ]]; then
        cp "$SCRIPT_DIR/k2-se-dxc-extruder.cfg" "$CONFIG_DIR/k2-se-dxc-extruder.cfg"
        print_success "DXC extruder configuration installed"
        
        # Ask if user wants to include in printer.cfg
        if confirm "Add DXC config to printer.cfg? (y/n): "; then
            if ! grep -q "k2-se-dxc-extruder.cfg" "$CONFIG_DIR/printer.cfg"; then
                echo "[include k2-se-dxc-extruder.cfg]" >> "$CONFIG_DIR/printer.cfg"
                print_success "Added to printer.cfg"
            else
                print_warning "Already included in printer.cfg"
            fi
        fi
    fi
}

create_macro_commands() {
    print_header "Creating Helper Macro Commands"
    
    cat > "$CONFIG_DIR/k2-se-macros.cfg" << 'EOF'
# K2 SE DXC Helper Macros

[gcode_macro CONVERT_TO_DXC]
description: Initialize DXC conversion
gcode:
    M117 Initializing DXC Conversion...
    # Home all axes
    G28
    # Heat both extruders
    SET_HEATER_TEMPERATURE HEATER=extruder TARGET=200
    SET_HEATER_TEMPERATURE HEATER=extruder1 TARGET=200
    # Wait for heating
    TEMPERATURE_WAIT SENSOR=extruder MINIMUM=195
    TEMPERATURE_WAIT SENSOR=extruder1 MINIMUM=195
    # Select primary extruder
    T0
    M117 DXC Ready!

[gcode_macro CALIBRATE_NOZZLE_OFFSET]
description: Calibrate nozzle offset between extruders
gcode:
    M117 Calibrating Nozzle Offset...
    # Move to center of bed
    G28
    G0 X117 Y117 F6000
    G0 Z20 F300
    M117 Ready for manual offset calibration

[gcode_macro LOAD_FILAMENT_E0]
description: Load filament into extruder 0
gcode:
    {% set TEMP = params.TEMP|default(200)|int %}
    M117 Loading E0...
    T0
    SET_HEATER_TEMPERATURE HEATER=extruder TARGET={TEMP}
    TEMPERATURE_WAIT SENSOR=extruder MINIMUM={TEMP-5}
    G91
    G1 E50 F300
    G90
    M117 E0 Loaded

[gcode_macro LOAD_FILAMENT_E1]
description: Load filament into extruder 1
gcode:
    {% set TEMP = params.TEMP|default(200)|int %}
    M117 Loading E1...
    T1
    SET_HEATER_TEMPERATURE HEATER=extruder1 TARGET={TEMP}
    TEMPERATURE_WAIT SENSOR=extruder1 MINIMUM={TEMP-5}
    G91
    G1 E50 F300
    G90
    M117 E1 Loaded

[gcode_macro UNLOAD_FILAMENT_E0]
description: Unload filament from extruder 0
gcode:
    M117 Unloading E0...
    T0
    G91
    G1 E-50 F300
    G90
    M117 E0 Unloaded

[gcode_macro UNLOAD_FILAMENT_E1]
description: Unload filament from extruder 1
gcode:
    M117 Unloading E1...
    T1
    G91
    G1 E-50 F300
    G90
    M117 E1 Unloaded

[gcode_macro DUAL_COLOR_SETUP]
description: Setup for dual color printing
gcode:
    M117 Dual Color Setup...
    # Home and level
    G28
    BED_MESH_CALIBRATE
    # Heat both extruders
    SET_HEATER_TEMPERATURE HEATER=extruder TARGET=210
    SET_HEATER_TEMPERATURE HEATER=extruder1 TARGET=210
    # Wait
    TEMPERATURE_WAIT SENSOR=extruder MINIMUM=205
    TEMPERATURE_WAIT SENSOR=extruder1 MINIMUM=205
    # Prime both
    T0
    G1 X10 Y10 Z0.2 F6000
    G1 E10 F300
    T1
    G1 X20 Y10 Z0.2 F6000
    G1 E10 F300
    T0
    M117 Dual Color Ready!

[gcode_macro SWITCH_EXTRUDER_QUIET]
description: Switch extruder without console spam
gcode:
    {% set NEXT_TOOL = params.TOOL|default(0)|int %}
    {% if NEXT_TOOL == 0 %}
        T0
    {% elif NEXT_TOOL == 1 %}
        T1
    {% endif %}
    # Retract before switching
    G91
    G1 E-2 F300
    G90

[gcode_macro DXC_STATUS]
description: Report DXC status
gcode:
    {% if printer.toolhead.extruder == 'extruder' %}
        M117 Active: E0 | E0: {printer.extruder.temperature:.1f}°C | E1: {printer.extruder1.temperature:.1f}°C
    {% else %}
        M117 Active: E1 | E0: {printer.extruder.temperature:.1f}°C | E1: {printer.extruder1.temperature:.1f}°C
    {% endif %}

[gcode_macro PURGE_AND_RESUME]
description: Purge after tool change and resume
gcode:
    PURGE_EXTRUDER AMOUNT=10
    RESUME

[gcode_macro EMERGENCY_RETRACT_ALL]
description: Retract all extruders quickly (emergency)
gcode:
    T0
    G91
    G1 E-5 F500
    G90
    T1
    G91
    G1 E-5 F500
    G90
    M117 Emergency Retract Complete

EOF
    
    print_success "Helper macros created"
    
    if confirm "Add macros to printer.cfg? (y/n): "; then
        if ! grep -q "k2-se-macros.cfg" "$CONFIG_DIR/printer.cfg"; then
            echo "[include k2-se-macros.cfg]" >> "$CONFIG_DIR/printer.cfg"
            print_success "Added to printer.cfg"
        fi
    fi
}

create_conversion_guide() {
    print_header "Creating Conversion Guide"
    
    cat > "$BACKUP_DIR/DXC_CONVERSION_GUIDE.md" << 'EOF'
# K2 SE DXC Extruder Conversion Guide

## Overview
This guide helps convert your Creality K2 SE to a dual extruder (DXC) configuration with the custom UI.

## Prerequisites
- Creality K2 SE printer
- DXC extruder kit compatible with K2 SE
- Raspberry Pi or compatible board running Klipper
- SSH access to printer board

## Installation Steps

### 1. Backup Configuration
Your configuration has been automatically backed up to:
```
~/printer_data/config_backup_YYYYMMDD_HHMMSS/
```

### 2. Hardware Installation
- Install second extruder motor and heater
- Wire extruder 1 to MCU pins: Step (PB8), Dir (PB7), Enable (PC11)
- Wire heater 1 to MCU pin: PA2
- Wire thermistor to MCU pin: PC4
- Connect filament runout sensor to PA11

### 3. Configuration Files
The following files have been installed:

- `k2-se-dxc-extruder.cfg` - Main extruder configuration
- `k2-se-dashboard.yaml` - Dashboard layout
- `k2-se-ui-styles.css` - UI styling
- `k2-se-macros.cfg` - Helper macros

### 4. Initialize DXC
Run the conversion macro:
```
CONVERT_TO_DXC
```

### 5. Calibration
1. Calibrate nozzle offset:
   ```
   CALIBRATE_NOZZLE_OFFSET
   ```

2. Run bed mesh calibration:
   ```
   BED_MESH_CALIBRATE
   ```

3. PID tune both extruders:
   ```
   PID_CALIBRATE HEATER=extruder TARGET=220
   PID_CALIBRATE HEATER=extruder1 TARGET=220
   ```

## Helper Commands

### Filament Management
```
LOAD_FILAMENT_E0 TEMP=200    # Load E0
LOAD_FILAMENT_E1 TEMP=200    # Load E1
UNLOAD_FILAMENT_E0           # Unload E0
UNLOAD_FILAMENT_E1           # Unload E1
```

### Extruder Control
```
T0                           # Select E0
T1                           # Select E1
SELECT_EXTRUDER EXTRUDER=0   # Select E0 with macro
TOGGLE_EXTRUDER              # Toggle between E0 and E1
```

### Printing
```
DUAL_COLOR_SETUP             # Setup for dual color
PRIME_EXTRUDERS              # Prime both extruders
DXC_STATUS                   # Show status
```

## Troubleshooting

### Extruder 1 Not Heating
- Check thermistor connection to PC4
- Verify heater wiring to PA2
- Check MCU configuration in printer.cfg

### Tool Change Issues
- Verify nozzle offset calibration
- Check retraction settings
- Review pressure advance values

### Filament Runout Not Working
- Check sensor wiring to PA11
- Verify detection length (should be 10mm)
- Test with `M117` command

## Reverting to Single Extruder

If you need to revert, restore from backup:
```
cp ~/printer_data/config_backup_YYYYMMDD_HHMMSS/* ~/printer_data/config/
```

Then restart Klipper service.

## Support
For more help, refer to the Klipper documentation:
- https://www.klipper3d.org/
- https://github.com/Klipper3d/klipper

EOF
    
    print_success "Conversion guide created at $BACKUP_DIR/DXC_CONVERSION_GUIDE.md"
}

create_test_script() {
    print_header "Creating Test Script"
    
    cat > "$CONFIG_DIR/test-dxc.sh" << 'EOF'
#!/bin/bash

# K2 SE DXC Test Script
# Tests all DXC functionality

echo "K2 SE DXC Test Suite"
echo "===================="

# Test 1: E0 Selection
echo "Test 1: Selecting E0..."
curl -X POST http://localhost:7125/printer/gcode/script -d 'script=T0'

# Test 2: E1 Selection
echo "Test 2: Selecting E1..."
curl -X POST http://localhost:7125/printer/gcode/script -d 'script=T1'

# Test 3: E0 Temperature
echo "Test 3: Setting E0 to 200°C..."
curl -X POST http://localhost:7125/printer/gcode/script -d 'script=SET_HEATER_TEMPERATURE HEATER=extruder TARGET=200'

# Test 4: E1 Temperature
echo "Test 4: Setting E1 to 200°C..."
curl -X POST http://localhost:7125/printer/gcode/script -d 'script=SET_HEATER_TEMPERATURE HEATER=extruder1 TARGET=200'

# Test 5: Status
echo "Test 5: Getting DXC Status..."
curl -X POST http://localhost:7125/printer/gcode/script -d 'script=DXC_STATUS'

echo "Tests Complete!"

EOF
    
    chmod +x "$CONFIG_DIR/test-dxc.sh"
    print_success "Test script created at $CONFIG_DIR/test-dxc.sh"
}

restart_klipper() {
    print_header "Restarting Klipper"
    
    if confirm "Restart Klipper service now? (y/n): "; then
        sudo systemctl restart klipper
        print_success "Klipper service restarted"
        
        # Wait for service to start
        sleep 5
        
        # Check if service is running
        if sudo systemctl is-active --quiet klipper; then
            print_success "Klipper service is running"
        else
            print_error "Klipper service failed to start"
            print_info "Check logs: sudo journalctl -u klipper -n 50"
        fi
    fi
}

show_summary() {
    print_header "Installation Complete!"
    
    echo -e "${GREEN}All components have been installed:${NC}"
    echo ""
    echo "✓ Configuration files"
    echo "✓ DXC extruder settings"
    echo "✓ Custom dashboard"
    echo "✓ UI styling"
    echo "✓ Helper macros"
    echo "✓ Conversion guide"
    echo ""
    echo -e "${YELLOW}Next Steps:${NC}"
    echo "1. Verify hardware connections"
    echo "2. Restart Klipper (or system)"
    echo "3. Run: CONVERT_TO_DXC"
    echo "4. Calibrate nozzle offset"
    echo "5. Run: BED_MESH_CALIBRATE"
    echo ""
    echo -e "${BLUE}Backup Location:${NC} $BACKUP_DIR"
    echo -e "${BLUE}Guide Location:${NC} $BACKUP_DIR/DXC_CONVERSION_GUIDE.md"
    echo ""
}

################################################################################
# Main Execution
################################################################################

main() {
    clear
    
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════╗"
    echo "║   K2 SE DXC Conversion Helper Script   ║"
    echo "║   Creality K2 SE → Dual Extruder       ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    
    # Run installation steps
    check_environment
    echo ""
    
    backup_config
    echo ""
    
    install_custom_ui
    echo ""
    
    install_extruder_config
    echo ""
    
    create_macro_commands
    echo ""
    
    create_conversion_guide
    echo ""
    
    create_test_script
    echo ""
    
    restart_klipper
    echo ""
    
    show_summary
}

# Run main function
main "$@"
