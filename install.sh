#!/bin/bash

CURRENT_SHELL=$(basename $SHELL)
ALIAS_NAME_CREATE="gmkdir"
ALIAS_NAME_DELETE="delrepo"
CURRENT_PATH=$(dirname "$(realpath "$0")")
VENV_DIR="$CURRENT_PATH/myenv"
KEY_FILE="$CURRENT_PATH/mykey.txt"

# Dynamically find or create the appropriate man directory
MAN_DIR=$(manpath 2>/dev/null | awk -F: '{print $1}')/man1
if [ ! -d "$MAN_DIR" ]; then
  echo "Man directory $MAN_DIR not found. Creating it..."
  sudo mkdir -p "$MAN_DIR"
fi

# Function to set up the virtual environment
setup_virtualenv() {
  # Check if Python3 is installed
  if ! command -v python3 &>/dev/null; then
    echo "Python3 is not installed. Please install it first."
    exit 1
  fi

  # Check if pip is installed
  if ! command -v pip3 &>/dev/null; then
    echo "pip is not installed. Installing pip..."
    sudo apt update
    sudo apt install python3-pip -y
  fi

  # Check if the venv module is available
  if ! python3 -m venv --help &>/dev/null; then
    echo "Python 'venv' module is not available. Installing it..."
    sudo apt update
    sudo apt install python3-venv -y
  fi

  # Create virtual environment if it doesn't exist
  if [ ! -d "$VENV_DIR" ]; then
    echo "Virtual environment 'myenv' not found. Creating it..."
    python3 -m venv "$VENV_DIR"
    echo "Virtual environment 'myenv' created."

    echo "Installing required packages..."
    source "$VENV_DIR/bin/activate"
    pip install PyGithub
    deactivate
    echo "PyGithub installed in 'myenv'."
  else
    echo "Virtual environment 'myenv' already exists."
  fi
}

# Function to check for and create the key file
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

# Function to add an alias to the shell configuration file
add_alias() {
  local config_file=$1
  local alias_name=$2
  local alias_command=$3

  if [ -w "$config_file" ]; then
    if grep -q "alias $alias_name=" "$config_file"; then
      echo "Alias '$alias_name' already exists in $config_file."
    else
      echo "alias $alias_name='$alias_command'" >> "$config_file"
      echo "Alias '$alias_name' created in $config_file."
    fi
  else
    echo "Permission denied to write to $config_file. Please check permissions."
  fi
}

# Function to set up the alias for creating repositories
setup_create_alias() {
  local create_command="source $VENV_DIR/bin/activate && pwd | python $CURRENT_PATH/getpath.py && python $CURRENT_PATH/main.py"
  add_alias "$SHELL_RC" "$ALIAS_NAME_CREATE" "$create_command"
}

# Function to set up the alias for deleting repositories
setup_delete_alias() {
  local delete_command="source $VENV_DIR/bin/activate && python $CURRENT_PATH/deleterepo.py"
  add_alias "$SHELL_RC" "$ALIAS_NAME_DELETE" "$delete_command"
}

# Function to determine the appropriate shell configuration file
setup_shell_config() {
  if [[ $CURRENT_SHELL == "zsh" ]]; then
    SHELL_RC="$HOME/.zshrc"
  elif [[ $CURRENT_SHELL == "bash" ]]; then
    SHELL_RC="$HOME/.bashrc"
  else
    echo "Unsupported shell ($CURRENT_SHELL). Exiting."
    exit 1
  fi

  setup_create_alias
  setup_delete_alias
}

# Function to set up the man page
setup_man_page() {
  local commands=("gmkdir" "delrepo")
  
  for cmd in "${commands[@]}"; do
    local man_page_file="$CURRENT_PATH/$cmd.1"
    local man_page_dest="$MAN_DIR/$cmd.1"

    if [ -f "$man_page_dest" ]; then
      echo "Man page for '$cmd' already exists. Skipping setup."
    else
      if [ -f "$man_page_file" ]; then
        echo "Setting up the man page for '$cmd'..."
        sudo cp "$man_page_file" "$MAN_DIR/"
        sudo mandb
        echo "Man page for '$cmd' is set up."
      else
        echo "Man page file '$cmd.1' not found. Skipping."
      fi
    fi
  done
}

# Main function to orchestrate the setup
main() {
  setup_virtualenv
  setup_key_file
  setup_shell_config
  setup_man_page
  echo "All the Setup is done!"
}

# Run the main function
main
