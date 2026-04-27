#!/bin/bash

# Secret Shield Docker - Local Scanning Script
# This script provides an easy way to run the containerized Gitleaks scanner locally

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOCKER_IMAGE="${DOCKER_IMAGE:-secret-shield:latest}"
SCAN_PATH="${1:-.}"
REPORT_FORMAT="${REPORT_FORMAT:-json}"
REPORT_PATH="${REPORT_PATH:-./gitleaks-report.json}"
EXIT_ON_FINDING="${EXIT_ON_FINDING:-true}"
VERBOSE="${VERBOSE:-false}"
BASELINE_PATH="${BASELINE_PATH:-}"
CONFIG_PATH="${CONFIG_PATH:-$SCRIPT_DIR/docker/.gitleaks.toml}"
GITLEAKSIGNORE_PATH="${GITLEAKSIGNORE_PATH:-$SCRIPT_DIR/.gitleaksignore}"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Functions
print_usage() {
    cat << EOF
${BLUE}Secret Shield Docker - Local Scanning Script${NC}

Usage: $0 [OPTIONS] [SCAN_PATH]

Options:
    -f, --format FORMAT         Report format (json, csv, junit, sarif) [default: json]
    -o, --output PATH           Output report path [default: ./gitleaks-report.json]
    -b, --baseline PATH         Baseline file for ignoring known issues
    -c, --config PATH           Gitleaks configuration file
    -i, --ignore PATH           .gitleaksignore file path
    -v, --verbose               Enable verbose output
    --no-exit-on-finding        Don't exit with error code if findings are detected
    --image IMAGE               Docker image to use [default: secret-shield:latest]
    -h, --help                  Show this help message

Examples:
    # Scan current directory
    $0

    # Scan specific directory with custom report path
    $0 -o ./reports/scan.json /path/to/scan

    # Scan with verbose output and custom config
    $0 -v -c ./custom-config.toml /path/to/repo

EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--format)
            REPORT_FORMAT="$2"
            shift 2
            ;;
        -o|--output)
            REPORT_PATH="$2"
            shift 2
            ;;
        -b|--baseline)
            BASELINE_PATH="$2"
            shift 2
            ;;
        -c|--config)
            CONFIG_PATH="$2"
            shift 2
            ;;
        -i|--ignore)
            GITLEAKSIGNORE_PATH="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE="true"
            shift
            ;;
        --no-exit-on-finding)
            EXIT_ON_FINDING="false"
            shift
            ;;
        --image)
            DOCKER_IMAGE="$2"
            shift 2
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        -*)
            echo -e "${RED}Unknown option: $1${NC}"
            print_usage
            exit 1
            ;;
        *)
            SCAN_PATH="$1"
            shift
            ;;
    esac
done

# Resolve absolute paths
SCAN_PATH="$(cd "$SCAN_PATH" 2>/dev/null && pwd)" || SCAN_PATH="$1"
REPORT_PATH="$(cd "$(dirname "$REPORT_PATH")" && pwd)/$(basename "$REPORT_PATH")" 2>/dev/null || REPORT_PATH="$REPORT_PATH"

# Create report directory if it doesn't exist
mkdir -p "$(dirname "$REPORT_PATH")"

# Build Docker run command
echo -e "${GREEN}[INFO]${NC} Starting Secret Shield scan..."
echo -e "${GREEN}[INFO]${NC} Scan path: $SCAN_PATH"
echo -e "${GREEN}[INFO]${NC} Report format: $REPORT_FORMAT"
echo -e "${GREEN}[INFO]${NC} Report path: $REPORT_PATH"
echo ""

# Build volume mounts
VOLUMES="-v $SCAN_PATH:/scan"

if [ -f "$CONFIG_PATH" ]; then
    VOLUMES="$VOLUMES -v $CONFIG_PATH:/app/.gitleaks.toml:ro"
    echo -e "${GREEN}[INFO]${NC} Using config: $CONFIG_PATH"
fi

if [ -f "$GITLEAKSIGNORE_PATH" ]; then
    VOLUMES="$VOLUMES -v $GITLEAKSIGNORE_PATH:/app/.gitleaksignore:ro"
    echo -e "${GREEN}[INFO]${NC} Using gitleaksignore: $GITLEAKSIGNORE_PATH"
fi

# Build environment variables
ENV_VARS="-e SCAN_PATH=/scan"
ENV_VARS="$ENV_VARS -e REPORT_FORMAT=$REPORT_FORMAT"
ENV_VARS="$ENV_VARS -e REPORT_PATH=/app/gitleaks-report"
ENV_VARS="$ENV_VARS -e EXIT_ON_FINDING=$EXIT_ON_FINDING"
ENV_VARS="$ENV_VARS -e VERBOSE=$VERBOSE"

if [ -n "$BASELINE_PATH" ] && [ -f "$BASELINE_PATH" ]; then
    VOLUMES="$VOLUMES -v $BASELINE_PATH:/app/baseline.json:ro"
    ENV_VARS="$ENV_VARS -e BASELINE_PATH=/app/baseline.json"
    echo -e "${GREEN}[INFO]${NC} Using baseline: $BASELINE_PATH"
fi

echo ""

# Run Docker container
docker run --rm \
    $VOLUMES \
    -v "$REPORT_PATH:/app/gitleaks-report" \
    $ENV_VARS \
    "$DOCKER_IMAGE"

SCAN_EXIT_CODE=$?

# Copy report to host
if [ -f "/app/gitleaks-report" ]; then
    cp "/app/gitleaks-report" "$REPORT_PATH"
fi

# Display results
echo ""
if [ $SCAN_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✓ Scan completed successfully - no secrets detected!${NC}"
else
    echo -e "${RED}✗ Scan detected secrets!${NC}"
    if [ -f "$REPORT_PATH" ] && [ "$REPORT_FORMAT" = "json" ]; then
        echo -e "${YELLOW}Report saved to: $REPORT_PATH${NC}"
    fi
fi

exit $SCAN_EXIT_CODE
