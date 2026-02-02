#!/bin/bash

# Usage: sudo ./setup_opencode_env.sh /path/to/directory

TARGET_DIR="$1"
USER_NAME="opencode"
GROUP_NAME="opencode"
# The binary/command you want to run (as requested)
COMMAND_TO_RUN="opencode /opt/projects/my-project"

# 1. Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Error: This script must be run as root (use sudo)."
  exit 1
fi

# 2. Check if a directory path was provided
if [ -z "$TARGET_DIR" ]; then
  echo "Error: No directory specified."
  echo "Usage: sudo $0 /path/to/directory"
  exit 1
fi

echo "--- Setting up User and Group ---"

# 3. Create the user 'opencode' if it doesn't exist
# -m: Create home directory
# -d: Specify home directory path
# -U: Create a group with the same name
# -s: Set shell to bash
if id "$USER_NAME" &>/dev/null; then
    echo "User '$USER_NAME' already exists."
else
    echo "Creating user '$USER_NAME'..."
    useradd -m -d "/home/$USER_NAME" -U -s /bin/bash "$USER_NAME"
fi

# 4. Add the CURRENT user (who called sudo) to the 'opencode' group
# We use SUDO_USER to get the real username behind the sudo command
if [ -n "$SUDO_USER" ]; then
    echo "Adding user '$SUDO_USER' to group '$GROUP_NAME'..."
    usermod -aG "$GROUP_NAME" "$SUDO_USER"
else
    echo "Warning: Could not detect sudo user. Skipping adding current user to group."
fi

echo "--- Configuring Directory: $TARGET_DIR ---"

# 5. Create directory and set permissions
if [ ! -d "$TARGET_DIR" ]; then
  mkdir -p "$TARGET_DIR"
fi

# Set ownership to root:opencode (so root owns it, but opencode group has access)
chown root:"$GROUP_NAME" "$TARGET_DIR"

# Set base permissions (775)
chmod 775 "$TARGET_DIR"

# Set SGID bit (New files inherit group 'opencode')
chmod g+s "$TARGET_DIR"

# Set Default ACLs (New files get group write permission)
setfacl -d -m g::rwx "$TARGET_DIR"

echo "Success! Environment configured."
echo "----------------------------------------------------"
echo "To run your application as the isolated user, use:"
echo ""
echo "  sudo runuser -l $USER_NAME -c \"$COMMAND_TO_RUN\""
echo ""
echo "Note: You (user $SUDO_USER) may need to log out and back in"
echo "for the group membership changes to take effect."
echo "----------------------------------------------------"
