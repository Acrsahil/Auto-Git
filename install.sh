#!/bin/bash

# Enhanced Install Script with Dynamic Aliases and Messages

set -e          # Exit on any command failure
set -o pipefail # Catch errors in piped commands

CURRENT_PATH=$(dirname "$(realpath "$0")")
VENV_DIR="$CURRENT_PATH/myenv"
ALIAS_FILE="$CURRENT_PATH/alias.sh"
SHELL_CONFIG_FILES=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.config/fish/config.fish")
MAN_DIR="$(manpath 2>/dev/null | awk -F: '{print $1}')/man1"
GPUSH_MAN="$CURRENT_PATH/man/gpush.1"
GMKDIR_MAN="$CURRENT_PATH/man/gmkdir.1"
GRMDIR_MAN="$CURRENT_PATH/man/grmdir.1"
GLS_MAN="$CURRENT_PATH/man/gls.1"

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
        if command_exists apt-get; then
            sudo apt-get update
            sudo apt-get install -y python3 python3-pip python3-venv
        elif command_exists dnf; then
            sudo dnf install -y python3 python3-pip python3-virtualenv
        elif command_exists yum; then
            sudo yum install -y python3 python3-pip python3-virtualenv
        elif command_exists pacman; then
            sudo pacman -S --noconfirm python python-pip python-virtualenv
        else
            echo "❌ Package manager not found. Please install Python manually."
            exit 1
        fi
        echo "✅ Python installed successfully."
    else
        echo "✅ Python is already installed."
        # Ensure venv is installed
        if ! python3 -m venv --help &>/dev/null; then
            echo "🛠️  'venv' module is missing. Installing it..."
            if command_exists apt-get; then
                sudo apt-get install -y python3-venv
            elif command_exists dnf; then
                sudo dnf install -y python3-virtualenv
            elif command_exists yum; then
                sudo yum install -y python3-virtualenv
            elif command_exists pacman; then
                sudo pacman -S --noconfirm python-virtualenv
            else
                echo "❌ Could not install python3-venv automatically. Please install it manually."
                exit 1
            fi
            echo "✅ 'venv' module installed."
        fi
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
        echo "Creating virtual environment at $VENV_DIR..."
        python3 -m venv "$VENV_DIR" || {
            echo "❌ Failed to create virtual environment. Make sure python3-venv is installed."
            exit 1
        }
        echo "✅ Virtual environment created."
    else
        echo "Virtual environment already exists: $VENV_DIR"
    fi

    # Activate and install PyGithub
    source "$VENV_DIR/bin/activate"
    if ! pip show PyGithub &>/dev/null; then
        pip install --upgrade pip
        pip install PyGithub
        echo "✅ PyGithub installed."
    else
        echo "PyGithub is already installed."
    fi
    deactivate
}

# Function to manage key file
# Function to manage key file
# Function to manage key file
setup_key_file() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local secure_dir="$script_dir/.secure_keys"
    local key_file="$secure_dir/mykey.txt"

    mkdir -p "$secure_dir"
    chmod 700 "$secure_dir" # Only owner can access this folder

    if [ ! -f "$key_file" ]; then
        echo "  GitHub token is required to access the GitHub API."
        echo -e "\n\033[0;32m  Please generate a Personal Access Token (Classic) by following these steps:\033[0m"
        echo -e "\033[0;32m1. Open this link in your browser: \033[38;5;208m https://github.com/settings/tokens/new\033[0m"
        echo -e "\033[0;32m2. Select the following scopes:\033[0m"
        echo -e "\033[0;32m   ✅ repo (Full control of private repositories)\033[0m"
        echo -e "\033[0;32m   ✅ read:org (Optional, if working with org repos)\033[0m"
        echo -e "\033[0;32m3. Click 'Generate token'\033[0m"
        echo -e "\033[0;32m4. Copy the token (You will not see it again!)\033[0m"
        echo

        # 👇 Make input visible (normal `read`)
        echo -n "Paste your GitHub token here: "
        read user_key

        # 🔒 Show masked version right after
        local first_part="${user_key:0:5}"
        local hidden_part_length=$((${#user_key} - 5))
        local masked_part=$(printf '%*s' "$hidden_part_length" '' | tr ' ' '*')
        echo "✅ Received token: ${first_part}${masked_part}"

        # Save securely
        echo "$user_key" >"$key_file"
        chmod 600 "$key_file"
        echo "🔒 Token saved securely at: $key_file"
    else
        echo "🔒 Secure key file already exists: $key_file"
    fi
}
# Function to add aliases dynamically
add_dynamic_aliases() {
    local base_path="$CURRENT_PATH"

    local aliases=(
        "alias rudo='source $base_path/changepath.sh'"
        "alias gmkdir='function _gmkdir() { source $base_path/myenv/bin/activate && pwd | python $base_path/getpath.py && python $base_path/gmkdir.py \"\$@\" && source $base_path/changepath.sh && deactivate; }; _gmkdir'"
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
