#!/usr/bin/env bash
# setup-hooks.sh - Setup script for Daisy pre-commit hooks template
# Compatible with Windows Git Bash, WSL, and Unix systems

# Colors for output
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

print_header "Daisy Pre-commit Hooks Template Setup"
print_info "Detected OS: $(detect_os)"
print_info "Current directory: $(pwd)"

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    print_error "Not in a Git repository. Please run this script from the root of your Git project."
    exit 1
fi

# Get template directory
TEMPLATE_DIR="$(dirname "$0")"
if [ ! -f "$TEMPLATE_DIR/shared-functions.sh" ]; then
    print_error "Cannot find template files. Please ensure all hook files are in the same directory as this script."
    exit 1
fi

# Create hooks directory if it doesn't exist
mkdir -p .git/hooks

# Copy hooks to current project
print_info "Installing hooks..."
cp "$TEMPLATE_DIR/shared-functions.sh" .git/hooks/
cp "$TEMPLATE_DIR/post-checkout" .git/hooks/
cp "$TEMPLATE_DIR/pre-commit" .git/hooks/
cp "$TEMPLATE_DIR/pre-merge" .git/hooks/
cp "$TEMPLATE_DIR/pre-push" .git/hooks/

# Make hooks executable (important on Unix systems)
chmod +x .git/hooks/shared-functions.sh
chmod +x .git/hooks/post-checkout
chmod +x .git/hooks/pre-commit
chmod +x .git/hooks/pre-merge
chmod +x .git/hooks/pre-push

print_success "Hooks installed successfully!"

# Create default pre-commit config if it doesn't exist
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
    print_success "Created default .pre-commit-config.yaml"
else
    print_info ".pre-commit-config.yaml already exists"
fi

# Install pre-commit if available
if command -v pip >/dev/null 2>&1; then
    print_info "Installing pre-commit..."
    pip install pre-commit --quiet
    
    print_info "Installing pre-commit hooks..."
    pre-commit install
    
    print_success "Pre-commit setup complete!"
    
    # Ask if user wants to run initial check
    echo
    read -p "Do you want to run an initial pre-commit check? (y/N): " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Running pre-commit on all files..."
        if pre-commit run --all-files; then
            print_success "All checks passed!"
        else
            print_warning "Some checks failed. Please review and fix the issues above."
        fi
    fi
else
    print_warning "pip not found. Please install Python and pip, then run:"
    print_info "  pip install pre-commit"
    print_info "  pre-commit install"
fi

echo
print_success "Setup complete! Your project is now configured with Daisy pre-commit hooks."
print_info "Hooks installed:"
print_info "  • post-checkout - Sets up new projects automatically"
print_info "  • pre-commit - Validates code before commits"
print_info "  • pre-merge - Ensures quality before merges"  
print_info "  • pre-push - Final checks before pushing to remote"
echo
print_info "To bypass hooks temporarily, use --no-verify flag:"
print_info "  git commit --no-verify"
print_info "  git push --no-verify"
