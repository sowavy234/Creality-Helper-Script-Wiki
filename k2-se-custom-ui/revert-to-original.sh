#!/bin/bash

################################################################################
# K2 SE DXC Revert Script
# Restore to original Klipper configuration
################################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Paths
PRINTER_DATA="${HOME}/printer_data"
CONFIG_DIR="${PRINTER_DATA}/config"
BACKUP_DIR=""

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

find_backups() {
    print_header "Finding Available Backups"
    
    local backups=($(find "$PRINTER_DATA" -maxdepth 1 -type d -name "config_backup_*" | sort -r))
    
    if [ ${#backups[@]} -eq 0 ]; then
        print_error "No backups found in $PRINTER_DATA"
        return 1
    fi
    
    print_info "Found ${#backups[@]} backup(s):"
    for i in "${!backups[@]}"; do
        echo "  $((i+1)). ${backups[$i]##*/}"
    done
    echo ""
    
    read -p "Select backup number (1-${#backups[@]}): " selection
    
    if [[ $selection -ge 1 && $selection -le ${#backups[@]} ]]; then
        BACKUP_DIR="${backups[$((selection-1))]}"
        print_success "Selected: $BACKUP_DIR"
        return 0
    else
        print_error "Invalid selection"
        return 1
    fi
}

verify_backup() {
    print_header "Verifying Backup"
    
    if [[ ! -d "$BACKUP_DIR" ]]; then
        print_error "Backup directory not found: $BACKUP_DIR"
        return 1
    fi
    
    # Check for essential config files
    local essential_files=("printer.cfg" "stepper_*.cfg")
    
    print_info "Checking backup contents..."
    if ls "$BACKUP_DIR"/printer.cfg >/dev/null 2>&1; then
        print_success "Found printer.cfg"
    else
        print_error "printer.cfg not found in backup"
        return 1
    fi
    
    print_success "Backup verified successfully"
    return 0
}

backup_current() {
    print_header "Backing Up Current Configuration"
    
    local current_backup="${PRINTER_DATA}/config_backup_before_revert_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$current_backup"
    
    cp -r "$CONFIG_DIR"/* "$current_backup/" 2>/dev/null || true
    print_success "Current config backed up to: $current_backup"
    print_info "You can restore this if needed"
}

remove_dxc_configs() {
    print_header "Removing DXC Configuration Files"
    
    local files_to_remove=(
        "k2-se-dxc-extruder.cfg"
        "k2-se-macros.cfg"
        "k2-se-dashboard.yaml"
        "k2-se-ui-styles.css"
        "k2-se-dashboard.json"
        "k2-se-screen.conf"
    )
    
    for file in "${files_to_remove[@]}"; do
        if [[ -f "$CONFIG_DIR/$file" ]]; then
            rm "$CONFIG_DIR/$file"
            print_success "Removed $file"
        fi
    done
}

remove_dxc_includes() {
    print_header "Removing DXC Includes from printer.cfg"
    
    if [[ -f "$CONFIG_DIR/printer.cfg" ]]; then
        # Remove lines containing DXC includes
        sed -i '/k2-se-dxc-extruder.cfg/d' "$CONFIG_DIR/printer.cfg"
        sed -i '/k2-se-macros.cfg/d' "$CONFIG_DIR/printer.cfg"
        sed -i '/k2-se-dashboard/d' "$CONFIG_DIR/printer.cfg"
        
        print_success "Removed DXC includes from printer.cfg"
    fi
}

restore_from_backup() {
    print_header "Restoring Original Configuration"
    
    print_info "Copying files from backup..."
    
    # Remove current config files (except klipper-specific ones)
    find "$CONFIG_DIR" -maxdepth 1 -type f -name "*.cfg" -o -name "*.json" -o -name "*.yaml" | while read file; do
        if [[ ! "$file" =~ "gcode_macro" ]]; then
            rm -f "$file"
        fi
    done
    
    # Copy backup files
    cp "$BACKUP_DIR"/* "$CONFIG_DIR/" 2>/dev/null || true
    
    print_success "Restoration complete"
}

clean_klipper_screen() {
    print_header "Cleaning KlipperScreen Configuration"
    
    local ks_config="${HOME}/.config/KlipperScreen/KlipperScreen.conf"
    local ks_backup="${HOME}/.config/KlipperScreen/KlipperScreen.conf.backup_revert"
    
    if [[ -f "$ks_config" ]]; then
        cp "$ks_config" "$ks_backup"
        print_success "Backed up KlipperScreen config to $ks_backup"
    fi
}

remove_custom_ui_files() {
    print_header "Removing Custom UI Files"
    
    # Remove custom UI directory if it exists
    if [[ -d "$CONFIG_DIR/k2-se-custom-ui" ]]; then
        rm -rf "$CONFIG_DIR/k2-se-custom-ui"
        print_success "Removed custom UI directory"
    fi
    
    # Remove any custom theme files
    local theme_dir="${HOME}/.local/share/klipper-screen"
    if [[ -d "$theme_dir/k2-se" ]]; then
        rm -rf "$theme_dir/k2-se"
        print_success "Removed custom theme"
    fi
}

restart_services() {
    print_header "Restarting Services"
    
    if confirm "Restart Klipper service now? (y/n): "; then
        sudo systemctl restart klipper
        print_success "Klipper service restarted"
        
        sleep 5
        
        if sudo systemctl is-active --quiet klipper; then
            print_success "Klipper service is running"
        else
            print_error "Klipper service failed to start"
            print_info "Check logs: sudo journalctl -u klipper -n 50"
        fi
    fi
    
    if confirm "Restart KlipperScreen service now? (y/n): "; then
        sudo systemctl restart KlipperScreen
        print_success "KlipperScreen service restarted"
    fi
}

show_completion() {
    print_header "Revert Complete!"
    
    echo -e "${GREEN}Your K2 SE has been reverted to original configuration:${NC}"
    echo ""
    echo "✓ DXC configuration removed"
    echo "✓ Custom macros removed"
    echo "✓ Original config restored"
    echo "✓ Services restarted"
    echo ""
    echo -e "${YELLOW}Backups created:${NC}"
    echo "  Current config: $PRINTER_DATA/config_backup_before_revert_*"
    echo "  Original backup: $BACKUP_DIR"
    echo ""
    echo -e "${BLUE}If you need to re-apply DXC, run the conversion script again${NC}"
}

################################################################################
# Main Execution
################################################################################

main() {
    clear
    
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════╗"
    echo "║   K2 SE DXC Revert Script              ║"
    echo "║   Restore to Original Configuration    ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    
    print_warning "This will revert your printer to the original configuration"
    echo ""
    
    if ! confirm "Are you sure you want to continue? (y/n): "; then
        print_info "Revert cancelled"
        exit 0
    fi
    
    # Execute revert steps
    if ! find_backups; then
        print_error "No valid backups available for revert"
        exit 1
    fi
    
    echo ""
    if ! verify_backup; then
        print_error "Backup verification failed"
        exit 1
    fi
    
    echo ""
    backup_current
    echo ""
    
    remove_dxc_configs
    echo ""
    
    remove_dxc_includes
    echo ""
    
    remove_custom_ui_files
    echo ""
    
    restore_from_backup
    echo ""
    
    clean_klipper_screen
    echo ""
    
    restart_services
    echo ""
    
    show_completion
}

# Run main function
main "$@"
