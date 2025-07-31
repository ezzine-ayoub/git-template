#!/usr/bin/env bash
# install-template.sh - Install Daisy hooks template in any Git project
# Usage: ./install-template.sh [target-directory]

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_header() { echo -e "${CYAN}🔧 $1${NC}"; }

# Get target directory
TARGET_DIR="${1:-.}"
TEMPLATE_DIR="$(dirname "$0")"

print_header "Daisy Hooks Template Installer"
print_info "Template source: $TEMPLATE_DIR"
print_info "Target directory: $TARGET_DIR"

# Check if target is a Git repository
if [ ! -d "$TARGET_DIR/.git" ]; then
    print_error "Target directory is not a Git repository: $TARGET_DIR"
    print_info "Initialize Git first: git init"
    exit 1
fi

# Check if template files exist
REQUIRED_FILES=("shared-functions.sh" "post-checkout" "pre-commit" "pre-merge" "pre-push")
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$TEMPLATE_DIR/$file" ]; then
        print_error "Template file missing: $file"
        exit 1
    fi
done

# Create hooks directory
mkdir -p "$TARGET_DIR/.git/hooks"

# Install hooks
print_info "Installing hooks to $TARGET_DIR/.git/hooks/"
for file in "${REQUIRED_FILES[@]}"; do
    cp "$TEMPLATE_DIR/$file" "$TARGET_DIR/.git/hooks/"
    chmod +x "$TARGET_DIR/.git/hooks/$file"
    print_success "Installed: $file"
done

# Create default config if needed
cd "$TARGET_DIR"
if [ ! -f ".pre-commit-config.yaml" ]; then
    print_info "Creating default .pre-commit-config.yaml..."
    cat > .pre-commit-config.yaml << 'EOF'
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
    print_success "Created .pre-commit-config.yaml"
fi

# Install pre-commit
if command -v pip >/dev/null 2>&1; then
    print_info "Installing pre-commit..."
    pip install pre-commit --quiet
    pre-commit install
    print_success "Pre-commit installed and configured"
else
    print_warning "pip not found. Please install Python and pip, then run:"
    print_info "  pip install pre-commit && pre-commit install"
fi

print_success "Template installation complete!"
print_info "Project: $(basename "$TARGET_DIR")"
print_info "Hooks installed: post-checkout, pre-commit, pre-merge, pre-push"
