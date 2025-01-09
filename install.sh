#!/bin/bash

CURRENT_SHELL=$(basename $SHELL)
ALIAS_NAME_CREATE="gmkdir"
ALIAS_NAME_GRMDIR="grmdir"  # Changed from delrepo to grmdir
CURRENT_PATH=$(dirname "$(realpath "$0")")
VENV_DIR="$CURRENT_PATH/myenv"
KEY_FILE="$CURRENT_PATH/mykey.txt"
ALIAS_FILE="$CURRENT_PATH/alias.sh"  # Path for alias file
SHELL_CONFIG_FILES=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.config/fish/config.fish")

# Dynamically find or create the appropriate man directory
MAN_DIR=$(manpath 2>/dev/null | awk -F: '{print $1}')/man1
if [ ! -d "$MAN_DIR" ]; then
  echo "Man directory $MAN_DIR not found. Creating it..."
  sudo mkdir -p "$MAN_DIR"
fi

# Function to detect the package manager
detect_package_manager() {
  if command -v apt &>/dev/null; then
    echo "apt"
  elif command -v dnf &>/dev/null; then
    echo "dnf"
  elif command -v yum &>/dev/null; then
    echo "yum"
  elif command -v pacman &>/dev/null; then
    echo "pacman"
  elif command -v zypper &>/dev/null; then
    echo "zypper"
  else
    echo "unknown"
  fi
}

# Function to install missing dependencies
install_missing_dependencies() {
  package_manager=$(detect_package_manager)

  case "$package_manager" in
  apt)
    echo "Using apt to install dependencies..."
    sudo apt update && sudo apt install python3-venv -y || {
      echo "Failed to install python3-venv with apt.";
      exit 1;
    }
    ;;
  dnf)
    echo "Using dnf to install dependencies..."
    sudo dnf install python3-venv -y || {
      echo "Failed to install python3-venv with dnf.";
      exit 1;
    }
    ;;
  yum)
    echo "Using yum to install dependencies..."
    sudo yum install python3-venv -y || {
      echo "Failed to install python3-venv with yum.";
      exit 1;
    }
    ;;
  pacman)
    echo "Using pacman to install dependencies..."
    sudo pacman -Syu --noconfirm python || {
      echo "Failed to install Python dependencies with pacman.";
      exit 1;
    }
    ;;
  zypper)
    echo "Using zypper to install dependencies..."
    sudo zypper install -y python3-pip || {
      echo "Failed to install python3-pip with zypper.";
      exit 1;
    }
    # Install virtualenv if python3-venv is unavailable
    if ! sudo zypper install -y python3-venv; then
      echo "python3-venv not found, installing virtualenv with pip..."
      sudo pip3 install virtualenv || { echo "Failed to install virtualenv."; exit 1; }
    fi
    ;;
  *)
    echo "Unsupported package manager. Please install 'python3-venv' manually."
    exit 1
    ;;
  esac
}

# Function to set up the virtual environment
setup_virtualenv() {
  install_missing_dependencies

  # Create virtual environment if it doesn't exist
  if [ ! -d "$VENV_DIR" ]; then
    echo "Virtual environment 'myenv' not found. Creating it..."
    python3 -m venv "$VENV_DIR" || { echo "Failed to create virtual environment."; exit 1; }
    echo "Virtual environment 'myenv' created."

    echo "Installing required packages..."
    source "$VENV_DIR/bin/activate" || { echo "Failed to activate virtual environment."; exit 1; }
    pip install PyGithub || { echo "Failed to install PyGithub."; deactivate; exit 1; }
    deactivate || { echo "Failed to deactivate virtual environment."; exit 1; }
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

# Function to add an alias to the alias file
add_alias_to_file() {
  local alias_name=$1
  local alias_command=$2

  # Check if the alias already exists
  if grep -q "alias $alias_name=" "$ALIAS_FILE"; then
    echo "Alias '$alias_name' already exists in $ALIAS_FILE."
  else
    echo "alias $alias_name='$alias_command'" >> "$ALIAS_FILE"
    echo "Alias '$alias_name' added to $ALIAS_FILE."
  fi
}

# Function to set up the alias for creating repositories
setup_create_alias() {
  local create_command="source $VENV_DIR/bin/activate && pwd | python $CURRENT_PATH/getpath.py && python $CURRENT_PATH/main.py"
  add_alias_to_file "$ALIAS_NAME_CREATE" "$create_command"
}

# Function to set up the alias for removing repositories (changed from delrepo to grmdir)
setup_grmdir_alias() {
  local delete_command="source $VENV_DIR/bin/activate && python $CURRENT_PATH/deleterepo.py"
  add_alias_to_file "$ALIAS_NAME_GRMDIR" "$delete_command"
}

# Function to set up the man page
setup_man_page() {
  local commands=("gmkdir" "grmdir")  # Added grmdir here
  
  for cmd in "${commands[@]}"; do
    local man_page_file="$CURRENT_PATH/$cmd.1"
    local man_page_dest="$MAN_DIR/$cmd.1"

    if [ -f "$man_page_dest" ]; then
      echo "Man page for '$cmd' already exists. Skipping setup."
    else
      if [ -f "$man_page_file" ]; then
        echo "Setting up the man page for '$cmd'..."
        sudo cp "$man_page_file" "$MAN_DIR/" || { echo "Failed to copy man page for '$cmd'."; continue; }
        sudo mandb || { echo "Failed to update man database."; continue; }
        echo "Man page for '$cmd' is set up."
      else
        echo "Man page file '$cmd.1' not found. Skipping."
      fi
    fi
  done
}

# Function to add the source command to the shell config files
add_source_to_shell_configs() {
  for shell_config in "${SHELL_CONFIG_FILES[@]}"; do
    if [ -f "$shell_config" ]; then
      if ! grep -q "source $ALIAS_FILE" "$shell_config"; then
        echo "source $ALIAS_FILE" >> "$shell_config"
        echo "Added 'source $ALIAS_FILE' to $shell_config"
      else
        echo "'source $ALIAS_FILE' is already in $shell_config"
      fi
    else
      echo "Shell config file '$shell_config' not found. Skipping."
    fi
  done
}

# Main function to orchestrate the setup
main() {
  setup_virtualenv
  setup_key_file
  setup_create_alias
  setup_grmdir_alias
  setup_man_page
  add_source_to_shell_configs  # Add the source command to all possible shell config files
  echo "All the Setup is done!"
}

# Run the main function
main
