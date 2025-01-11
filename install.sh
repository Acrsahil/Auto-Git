#!/bin/bash

# Enhanced Install Script with Check for Existing Man Pages

set -e  # Exit on any command failure
set -o pipefail  # Catch errors in piped commands

CURRENT_SHELL=$(basename "$SHELL")
ALIAS_NAME_CREATE="gmkdir"
ALIAS_NAME_GRMDIR="grmdir"
ALIAS_NAME_GLS="gls"
ALIAS_NAME_GPUSH="gpush"
CURRENT_PATH=$(dirname "$(realpath "$0")")
VENV_DIR="$CURRENT_PATH/myenv"
KEY_FILE="$CURRENT_PATH/mykey.txt"
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

# Create man directory if not exists
setup_man_directory() {
  if [ ! -d "$MAN_DIR" ]; then
    echo "Creating man directory: $MAN_DIR"
    sudo mkdir -p "$MAN_DIR"
  fi
}

# Function to set up the virtual environment
setup_virtualenv() {
  echo "Setting up the virtual environment..."
  if [ ! -d "$VENV_DIR" ]; then
    python3 -m venv "$VENV_DIR"
    echo "Virtual environment created."
  else
    echo "Virtual environment already exists."
  fi

  echo "Checking for PyGithub installation..."
  source "$VENV_DIR/bin/activate"
  if ! pip show PyGithub &>/dev/null; then
    echo "PyGithub is not installed. Installing now..."
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
  if [ ! -f "$KEY_FILE" ]; then
    echo "File 'mykey.txt' not found. Please enter your key:"
    read -r user_key
    echo "$user_key" > "$KEY_FILE"
    echo "Key saved to 'mykey.txt'."
  else
    echo "Key file 'mykey.txt' already exists."
  fi
}

# Add alias to alias file
add_alias_to_file() {
  local alias_name=$1
  local alias_command=$2
  if ! grep -q "alias $alias_name=" "$ALIAS_FILE"; then
    echo "alias $alias_name='$alias_command'" >> "$ALIAS_FILE"
    echo "Alias '$alias_name' added to $ALIAS_FILE."
  else
    echo "Alias '$alias_name' already exists in $ALIAS_FILE."
  fi
}

setup_create_alias() {
  add_alias_to_file "$ALIAS_NAME_CREATE" "source $VENV_DIR/bin/activate && python $CURRENT_PATH/main.py"
}

setup_grmdir_alias() {
  add_alias_to_file "$ALIAS_NAME_GRMDIR" "source $VENV_DIR/bin/activate && python $CURRENT_PATH/deleterepo.py"
}

setup_gls_alias() {
  add_alias_to_file "$ALIAS_NAME_GLS" "source $VENV_DIR/bin/activate && python $CURRENT_PATH/get_repo.py"
}

setup_gpush_alias() {
  add_alias_to_file "$ALIAS_NAME_GPUSH" "bash $CURRENT_PATH/gpush.sh"
}

# Install man page, check if it exists first
install_man_page() {
  local man_page_file
  local man_page_name
  
  # Check and install man pages if not present
  for man_page_file in "$GPUSH_MAN" "$GMKDIR_MAN" "$GRMDIR_MAN" "$GLS_MAN"; do
    man_page_name=$(basename "$man_page_file")
    local man_page_path="$MAN_DIR/$man_page_name"

    if [ -f "$man_page_path" ]; then
      echo "Man page '$man_page_path' already exists. Skipping installation."
    else
      if [ -f "$man_page_file" ]; then
        echo "Installing man page '$man_page_name'..."
        sudo cp "$man_page_file" "$MAN_DIR"
        sudo mandb
        echo "Man page '$man_page_name' installed successfully."
      else
        echo "Man page file '$man_page_file' not found. Skipping man page installation."
      fi
    fi
  done
}

# Add source to shell configs
add_source_to_shell_configs() {
  for shell_config in "${SHELL_CONFIG_FILES[@]}"; do
    if [ -f "$shell_config" ] && ! grep -q "source $ALIAS_FILE" "$shell_config"; then
      echo "source $ALIAS_FILE" >> "$shell_config"
      echo "Added source command to $shell_config"
    fi
  done
}

# Main Function
main() {
  setup_virtualenv
  setup_key_file
  setup_create_alias
  setup_grmdir_alias
  setup_gls_alias
  setup_gpush_alias
  setup_man_directory
  install_man_page
  add_source_to_shell_configs
  echo "Installation complete!"
}

main
