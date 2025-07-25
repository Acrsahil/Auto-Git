#!/bin/bash

# Enhanced Install Script with Dynamic Aliases and Messages

set -e          # Exit on any command failure
set -o pipefail # Catch errors in piped commands

CURRENT_PATH=$(dirname "$(realpath "$0")")
VENV_DIR="$CURRENT_PATH/myenv"
ALIAS_FILE="$CURRENT_PATH/alias.sh"
SHELL_CONFIG_FILES=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.config/fish/config.fish")
MAN_DIR="$(manpath 2>/dev/null | awk -F: '{print $1}')/man1"
GPUSH_MAN="$CURRENT_PATH/gpush.1"
GMKDIR_MAN="$CURRENT_PATH/gmkdir.1"
GRMDIR_MAN="$CURRENT_PATH/grmdir.1"
GLS_MAN="$CURRENT_PATH/gls.1"

# Function to check for a command's existence
command_exists() {
    command -v "$1" &>/dev/null
}

setup_alias_file() {
    if [ ! -f "$ALIAS_FILE" ]; then
        touch "$ALIAS_FILE"
        chmod +x "$ALIAS_FILE"
        echo "#!/bin/bash" >"$ALIAS_FILE"
        echo "Alias file created and made executable: $ALIAS_FILE"
    else
        echo "Alias file already exists: $ALIAS_FILE"
    fi
}

# Function to install Python if it's not installed
install_python_if_needed() {
    if ! command_exists python3; then
        echo "Python is not installed. Installing Python..."
        # Install Python 3 using system's package manager
        if command_exists apt-get; then
            sudo apt-get update
            sudo apt-get install -y python3 python3-venv python3-pip
        elif command_exists dnf; then
            sudo dnf install python3 python3-virtualenv python3-pip
        elif command_exists yum; then
            sudo yum install python3 python3-virtualenv python3-pip
        elif command_exists pacman; then
            sudo pacman -S python python-virtualenv python-pip
        else
            echo "Package manager not found. Please install Python manually."
            exit 1
        fi
        echo "Python installed successfully."
    else
        echo "Python is already installed."
    fi
}

# Create man directory if not exists
setup_man_directory() {
    if [ ! -d "$MAN_DIR" ]; then
        sudo mkdir -p "$MAN_DIR"
        echo "Created man directory: $MAN_DIR"
    else
        echo "Man directory already exists: $MAN_DIR"
    fi
}

# Function to set up the virtual environment
setup_virtualenv() {
    if [ ! -d "$VENV_DIR" ]; then
        python3 -m venv "$VENV_DIR"
        echo "Virtual environment created: $VENV_DIR"
    else
        echo "Virtual environment already exists: $VENV_DIR"
    fi

    source "$VENV_DIR/bin/activate"
    if ! pip show PyGithub &>/dev/null; then
        pip install --upgrade pip
        pip install PyGithub
        echo "PyGithub installed."
    else
        echo "PyGithub is already installed."
    fi
    deactivate
}

# Function to manage key file
setup_key_file() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local secure_dir="$script_dir/.secure_keys"
    local key_file="$secure_dir/mykey.txt"

    mkdir -p "$secure_dir"
    chmod 700 "$secure_dir" # Only owner can access this folder

    if [ ! -f "$key_file" ]; then
        echo "Enter your GitHub token:"
        read -r user_key
        echo "$user_key" >"$key_file"
        chmod 600 "$key_file" # Only you can read/write
        echo "🔒 Key stored securely at: $key_file"
    else
        echo "✅ Secure key file already exists: $key_file"
    fi
}
# Function to add aliases dynamically
add_dynamic_aliases() {
    local base_path="$CURRENT_PATH"

    local aliases=(
        "alias rudo='source $base_path/changepath.sh'"
        "alias gmkdir='function _gmkdir() { source $base_path/myenv/bin/activate && pwd | python $base_path/getpath.py && python $base_path/main.py \"\$@\" && source $base_path/changepath.sh && deactivate; }; _gmkdir'"
        "alias grmdir='function _grmdir() { source $base_path/myenv/bin/activate && python $base_path/deleterepo.py \"\$@\" && deactivate; }; _grmdir'"
        "alias gls='function _gls() { source $base_path/myenv/bin/activate && python $base_path/get_repo.py \"\$@\" && deactivate; }; _gls'"
        "alias gpush='bash $base_path/gpush.sh'"
    )

    for alias_cmd in "${aliases[@]}"; do
        alias_name=$(echo "$alias_cmd" | awk -F= '{print $1}' | sed "s/alias //")
        if ! grep -q "$alias_cmd" "$ALIAS_FILE"; then
            echo "$alias_cmd" >>"$ALIAS_FILE"
            echo "Alias '$alias_name' added to alias.sh"
        else
            echo "Alias '$alias_name' already exists in alias.sh"
        fi
    done
}

# Install man page, check if it exists first
install_man_page() {
    local man_page_file
    local man_page_name

    # Check and install man pages if not present
    for man_page_file in "$GPUSH_MAN" "$GMKDIR_MAN" "$GRMDIR_MAN" "$GLS_MAN"; do
        man_page_name=$(basename "$man_page_file")
        local man_page_path="$MAN_DIR/$man_page_name"

        if [ ! -f "$man_page_path" ] && [ -f "$man_page_file" ]; then
            sudo cp "$man_page_file" "$MAN_DIR"
            sudo mandb
            echo "Man page installed: $man_page_name"
        else
            echo "Man page already exists: $man_page_name"
        fi
    done
}

# Add source to shell configs
add_source_to_shell_configs() {
    for shell_config in "${SHELL_CONFIG_FILES[@]}"; do
        if [ -f "$shell_config" ] && ! grep -q "source $ALIAS_FILE" "$shell_config"; then
            echo "source $ALIAS_FILE" >>"$shell_config"
            echo "Added 'source $ALIAS_FILE' to $shell_config"
        else
            echo "'source $ALIAS_FILE' already exists in $shell_config"
        fi
    done
}

# Main Function
main() {
    install_python_if_needed # Check and install Python if necessary
    setup_virtualenv
    setup_key_file
    add_dynamic_aliases
    setup_man_directory
    install_man_page
    add_source_to_shell_configs
    echo "Installation complete!"
}

main
