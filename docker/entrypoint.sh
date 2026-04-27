#!/bin/bash

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
SCAN_PATH="${SCAN_PATH:-.}"
CONFIG_PATH="${CONFIG_PATH:-/app/.gitleaks.toml}"
REPORT_FORMAT="${REPORT_FORMAT:-json}"
REPORT_PATH="${REPORT_PATH:-/app/gitleaks-report.json}"
EXIT_ON_FINDING="${EXIT_ON_FINDING:-true}"
VERBOSE="${VERBOSE:-false}"
BASELINE_PATH="${BASELINE_PATH:-}"

# Log function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Display banner
display_banner() {
    cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║                   🛡️  SECRET SHIELD DOCKER                   ║
║              Containerized Secret Scanning with Gitleaks      ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
}

# Validate configuration
validate_config() {
    if [ ! -f "$CONFIG_PATH" ]; then
        warning "Config file not found at $CONFIG_PATH, using default Gitleaks config"
    else
        log "Using config file: $CONFIG_PATH"
    fi
}

# Build gitleaks command
build_command() {
    local cmd="gitleaks"
    
    # Determine scan mode
    if [ -d "$SCAN_PATH/.git" ]; then
        cmd="$cmd git"
    else
        cmd="$cmd dir"
    fi
    
    cmd="$cmd $SCAN_PATH"
    
    # Add config if it exists
    if [ -f "$CONFIG_PATH" ]; then
        cmd="$cmd --config $CONFIG_PATH"
    fi
    
    # Add baseline if specified
    if [ -n "$BASELINE_PATH" ] && [ -f "$BASELINE_PATH" ]; then
        cmd="$cmd --baseline-path $BASELINE_PATH"
    fi
    
    # Add report format and path
    cmd="$cmd --report-format $REPORT_FORMAT"
    cmd="$cmd --report-path $REPORT_PATH"
    
    # Add verbose flag
    if [ "$VERBOSE" = "true" ]; then
        cmd="$cmd -v"
    fi
    
    # Add exit code
    cmd="$cmd --exit-code 1"
    
    echo "$cmd"
}

# Run scan
run_scan() {
    local cmd=$(build_command)
    
    log "Starting secret scan..."
    log "Scan path: $SCAN_PATH"
    log "Report format: $REPORT_FORMAT"
    log "Report path: $REPORT_PATH"
    echo ""
    
    # Execute scan
    if eval "$cmd"; then
        log "✓ Scan completed successfully - no secrets detected!"
        return 0
    else
        local exit_code=$?
        
        if [ $exit_code -eq 1 ]; then
            error "Secrets detected during scan!"
            
            # Display report summary
            if [ -f "$REPORT_PATH" ] && [ "$REPORT_FORMAT" = "json" ]; then
                local finding_count=$(jq 'length' "$REPORT_PATH" 2>/dev/null || echo "unknown")
                error "Number of findings: $finding_count"
                
                if [ "$finding_count" != "0" ] && [ "$finding_count" != "unknown" ]; then
                    log "First few findings:"
                    jq '.[:3] | .[] | "\(.File):\(.Line) - \(.RuleID)"' "$REPORT_PATH" 2>/dev/null || true
                fi
            fi
            
            if [ "$EXIT_ON_FINDING" = "true" ]; then
                return 1
            else
                warning "EXIT_ON_FINDING is false, continuing despite findings..."
                return 0
            fi
        else
            error "Scan failed with exit code $exit_code"
            return $exit_code
        fi
    fi
}

# Post-scan actions
post_scan() {
    if [ -f "$REPORT_PATH" ]; then
        log "Report saved to: $REPORT_PATH"
        
        # Print report summary if JSON
        if [ "$REPORT_FORMAT" = "json" ]; then
            log "Report summary:"
            jq '.[0] | {File, Line, RuleID, Entropy}' "$REPORT_PATH" 2>/dev/null || true
        fi
    fi
}

# Main execution
main() {
    display_banner
    echo ""
    
    validate_config
    run_scan
    local scan_result=$?
    
    echo ""
    post_scan
    
    return $scan_result
}

# Execute main function
main "$@"
