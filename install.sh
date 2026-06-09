#!/bin/bash

set -e

CURRENT_PATH=$(dirname "$(realpath "$0")")
VENV_DIR="$CURRENT_PATH/myenv"
PYTHON="$VENV_DIR/bin/python"

ALIAS_FILE="$CURRENT_PATH/alias.sh"
SHELL_CONFIG_FILES=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.config/fish/config.fish")

MAN_DIR="$(manpath 2>/dev/null | awk -F: '{print $1}')/man1"
GPUSH_MAN="$CURRENT_PATH/man/gpush.1"
GMKDIR_MAN="$CURRENT_PATH/man/gmkdir.1"
GRMDIR_MAN="$CURRENT_PATH/man/grmdir.1"
GLS_MAN="$CURRENT_PATH/man/gls.1"

command_exists() {
    command -v "$1" &>/dev/null
}

# ----------------------------
# Python installation check
# ----------------------------
install_python_if_needed() {
    if ! command_exists python3; then
        echo "Python not found. Installing..."

        if command_exists apt-get; then
            sudo apt-get update
            sudo apt-get install -y python3 python3-pip python3-venv
        elif command_exists pacman; then
            sudo pacman -S --noconfirm python python-pip python-virtualenv
        else
            echo "❌ Unsupported package manager"
            exit 1
        fi
    fi
}

# ----------------------------
# Virtual environment setup
# ----------------------------
setup_virtualenv() {
    if [ ! -d "$VENV_DIR" ]; then
        echo "Creating venv..."
        python3 -m venv "$VENV_DIR"
    fi

    echo "Upgrading pip..."
    "$PYTHON" -m pip install --upgrade pip

    echo "Installing dependencies..."
    "$PYTHON" -m pip install -r "$CURRENT_PATH/requirements.txt"
}

# ----------------------------
# Key setup
# ----------------------------
setup_key_file() {
    local secure_dir="$CURRENT_PATH/.secure_keys"
    local key_file="$secure_dir/mykey.txt"

    mkdir -p "$secure_dir"
    chmod 700 "$secure_dir"

    if [ ! -f "$key_file" ]; then
        echo "Paste your GitHub token:"
        read user_key

        echo "$user_key" > "$key_file"
        chmod 600 "$key_file"

        echo "Token saved."
    fi
}

# ----------------------------
# Alias generation (FIXED)
# ----------------------------
add_dynamic_aliases() {
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
    pwd | $PYTHON $base/getpath.py
    $PYTHON $base/deleterepo.py "\$@"
}

gls() {
    $PYTHON $base/get_repo.py "\$@"
}

gpush() {
    bash $base/gpush.sh
}
EOF

    chmod +x "$ALIAS_FILE"
}

# ----------------------------
# Man pages
# ----------------------------
setup_man_directory() {
    sudo mkdir -p "$MAN_DIR"
}

install_man_page() {
    for file in "$GPUSH_MAN" "$GMKDIR_MAN" "$GRMDIR_MAN" "$GLS_MAN"; do
        name=$(basename "$file")
        if [ -f "$file" ] && [ ! -f "$MAN_DIR/$name" ]; then
            sudo cp "$file" "$MAN_DIR"
        fi
    done

    sudo mandb >/dev/null 2>&1 || true
}

# ----------------------------
# Shell config
# ----------------------------
add_source_to_shell_configs() {
    for cfg in "${SHELL_CONFIG_FILES[@]}"; do
        if [ -f "$cfg" ] && ! grep -q "alias.sh" "$cfg"; then
            echo "source $ALIAS_FILE" >> "$cfg"
        fi
    done
}

# ----------------------------
# MAIN
# ----------------------------
main() {
    install_python_if_needed
    setup_virtualenv
    setup_key_file
    add_dynamic_aliases
    setup_man_directory
    install_man_page
    add_source_to_shell_configs

    echo "✅ Installation complete!"
}

main