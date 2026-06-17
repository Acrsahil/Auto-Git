#!/bin/bash

set -e

# ============================
# Message Helpers
# ============================
info() {
    echo "ℹ️  $1"
}

success() {
    echo "✅ $1"
}

warn() {
    echo "⚠️  $1"
}

error() {
    echo "❌ $1"
}

echo
echo "======================================"
echo "        Auto-Git Installer"
echo "======================================"
echo

# ============================
# Paths
# ============================
CURRENT_PATH=$(dirname "$(realpath "$0")")
VENV_DIR="$CURRENT_PATH/myenv"
PYTHON="$VENV_DIR/bin/python"

ALIAS_FILE="$CURRENT_PATH/alias.sh"

SHELL_CONFIG_FILES=(
    "$HOME/.bashrc"
    "$HOME/.zshrc"
    "$HOME/.config/fish/config.fish"
)

MAN_DIR="$(manpath 2>/dev/null | awk -F: '{print $1}')/man1"

GPUSH_MAN="$CURRENT_PATH/man/gpush.1"
GMKDIR_MAN="$CURRENT_PATH/man/gmkdir.1"
GRMDIR_MAN="$CURRENT_PATH/man/grmdir.1"
GLS_MAN="$CURRENT_PATH/man/gls.1"

# ============================
# Utils
# ============================
command_exists() {
    command -v "$1" &>/dev/null
}

# ============================
# Python setup
# ============================
install_python_if_needed() {
    info "Checking Python installation..."

    if ! command_exists python3; then
        warn "Python not found. Installing..."

        if command_exists apt-get; then
            sudo apt-get update
            sudo apt-get install -y python3 python3-pip python3-venv
        elif command_exists pacman; then
            sudo pacman -S --noconfirm python python-pip python-virtualenv
        else
            error "Unsupported package manager"
            exit 1
        fi

        success "Python installed"
    else
        success "Python already installed"
    fi
}

# ============================
# Virtual environment
# ============================
setup_virtualenv() {
    info "Setting up virtual environment..."

    if [ ! -d "$VENV_DIR" ]; then
        python3 -m venv "$VENV_DIR"
        success "Virtual environment created"
    else
        success "Virtual environment already exists"
    fi

    info "Upgrading pip..."
    "$PYTHON" -m pip install --upgrade pip
    success "pip upgraded"

    info "Installing dependencies..."
    "$PYTHON" -m pip install -r "$CURRENT_PATH/requirements.txt"
    success "Dependencies installed"
}

# ============================
# GitHub token setup
# ============================
setup_key_file() {
    info "Setting up GitHub token storage..."

    local secure_dir="$CURRENT_PATH/.secure_keys"
    local key_file="$secure_dir/mykey.txt"

    mkdir -p "$secure_dir"
    chmod 700 "$secure_dir"

    if [ ! -f "$key_file" ]; then
        warn "GitHub token not found"
        echo "Paste your GitHub token:"
        read user_key

        echo "$user_key" > "$key_file"
        chmod 600 "$key_file"

        success "GitHub token saved securely"
    else
        success "GitHub token already exists"
    fi
}

# ============================
# Aliases (NO activation)
# ============================
add_dynamic_aliases() {
    info "Generating command aliases..."

    local base="$CURRENT_PATH"

    cat > "$ALIAS_FILE" <<EOF
#!/bin/bash

alias rudo='source $base/changepath.sh'

gmkdir() {
    pwd | $PYTHON $base/getpath.py
    $PYTHON $base/gmkdir.py "\$@"
    source $base/changepath.sh
}

grmdir() {
    pwd | $PYTHON $base/deleterepo.py "\$@"
}

gls() {
    $PYTHON $base/get_repo.py "\$@"
}

gpush() {
    bash $base/gpush.sh
}
EOF

    chmod +x "$ALIAS_FILE"

    success "Aliases created"
}

# ============================
# Man pages
# ============================
setup_man_directory() {
    info "Setting up man directory..."
    sudo mkdir -p "$MAN_DIR"
}

install_man_page() {
    info "Installing man pages..."

    for file in "$GPUSH_MAN" "$GMKDIR_MAN" "$GRMDIR_MAN" "$GLS_MAN"; do
        name=$(basename "$file")

        if [ -f "$file" ] && [ ! -f "$MAN_DIR/$name" ]; then
            sudo cp "$file" "$MAN_DIR"
            success "$name installed"
        else
            info "$name already exists"
        fi
    done

    sudo mandb >/dev/null 2>&1 || true
}

# ============================
# Shell integration
# ============================
add_source_to_shell_configs() {
    info "Configuring shell integration..."

    for cfg in "${SHELL_CONFIG_FILES[@]}"; do
        if [ -f "$cfg" ] && ! grep -q "alias.sh" "$cfg"; then
            echo "source $ALIAS_FILE" >> "$cfg"
            success "Updated $(basename "$cfg")"
        fi
    done
}

# ============================
# MAIN
# ============================
main() {
    install_python_if_needed
    setup_virtualenv
    setup_key_file
    add_dynamic_aliases
    setup_man_directory
    install_man_page
    add_source_to_shell_configs

    echo
    success "Installation complete!"
    echo
    info "Run this to activate commands:"
    echo "source $ALIAS_FILE"
    echo
}

main