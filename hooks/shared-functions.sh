#!/usr/bin/env bash
# shared-functions.sh - Common functions for git hooks
# Compatible with Windows Git Bash, WSL, and Unix systems

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Detect operating system
detect_os() {
    if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        echo "Windows (Git Bash)"
    elif [[ "$OSTYPE" == "linux"* ]]; then
        echo "Linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macOS"
    else
        echo "Unknown"
    fi
}

# Print functions with colors
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_header() {
    echo -e "${CYAN}🔧 $1${NC}"
}

# Get project name
get_project_name() {
    basename "$PWD"
}

# Check if pre-commit is installed
check_precommit_installed() {
    command -v pre-commit >/dev/null 2>&1
}

# Install pre-commit hooks
install_precommit() {
    if check_precommit_installed; then
        pre-commit install >/dev/null 2>&1
        return $?
    else
        return 1
    fi
}

# Run pre-commit with specified scope
run_precommit() {
    local scope="$1"
    if check_precommit_installed; then
        if [ "$scope" = "all-files" ]; then
            pre-commit run --all-files
        else
            pre-commit run
        fi
        return $?
    else
        print_error "pre-commit not installed"
        return 1
    fi
}

# Check pre-commit configuration
check_precommit_config() {
    local config_file=".pre-commit-config.yaml"
    
    # Check if config file exists
    if [ ! -f "$config_file" ]; then
        print_error "Missing $config_file"
        return 1
    fi
    
    # Check for required repository (either old or new URL)
    local repo_found=false
    if grep -q "repo: https://github.com/ezzine-ayoub/daisy-pre-commit-hooks" "$config_file"; then
        repo_found=true
    fi
    if grep -q "repo: https://github.com/Daisy-Consulting/daisy-pre-commit-hooks" "$config_file"; then
        repo_found=true
    fi
    
    if [ "$repo_found" = false ]; then
        print_error "$config_file doesn't include required daisy-pre-commit-hooks config"
        print_info "Expected one of:"
        print_info "  - https://github.com/ezzine-ayoub/daisy-pre-commit-hooks"
        print_info "  - https://github.com/Daisy-Consulting/daisy-pre-commit-hooks"
        return 1
    fi
    
    # Check version
    if ! grep -q "rev: v1.1.5" "$config_file"; then
        print_error "Wrong or missing 'rev' version in $config_file"
        print_info "Expected: rev: v1.1.5"
        return 1
    fi
    
    # Check for required hook
    if ! grep -q "check-manifest-fields" "$config_file"; then
        print_error "'check-manifest-fields' hook not configured in $config_file"
        return 1
    fi
    
    return 0
}

# Create default pre-commit config if it doesn't exist
create_default_config() {
    local config_file=".pre-commit-config.yaml"
    
    if [ -f "$config_file" ]; then
        return 0  # Already exists
    fi
    
    cat > "$config_file" << 'EOF'
exclude: 'daisy-pre-commit-hooks/scripts/.*|odoo18/(check_manifest|wait-for-psql)\.py|check_duplicate_ids\.py|.idea/.*'
repos:
  - repo: https://github.com/Daisy-Consulting/daisy-pre-commit-hooks
    rev: v1.1.5
    hooks:
      - id: check-xml-header
      - id: check-manifest-fields
        args:
          - "--required_keys=name,version,category,description,author"
      # - id: check-print-usage
      - id: check-sudo-comment
        pass_filenames: false
      - id: detect-raw-sql-delete-insert
      - id: check_duplicate_method_names
      - id: check-for-return
      - id: check-xml-closing-tags
      - id: check-report-template
        args:
          - "--addons="
          - '--MANDATORY_FIELDS={"ir.ui.view": ["name", "model"],"ir.actions.act_window": ["name", "res_model", "view_mode"],"ir.actions.report": ["name", "model", "report_name"]}'
      - id: check-compute-function
      - id: check-duplicate-ids
EOF
    
    return $?
}

# Install Python dependencies if needed
ensure_python_deps() {
    if command -v pip >/dev/null 2>&1; then
        if ! check_precommit_installed; then
            print_info "Installing pre-commit..."
            pip install pre-commit --quiet
        fi
        return 0
    else
        print_warning "pip not found. Please install Python and pip"
        return 1
    fi
}
