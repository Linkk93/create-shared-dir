#!/bin/bash

# Usage: sudo ./setup_shared_dir.sh /path/to/directory

TARGET_DIR="$1"
GROUP_NAME="opencode"

# 1. Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Error: This script must be run as root."
  exit 1
fi

# 2. Check if a directory path was provided
if [ -z "$TARGET_DIR" ]; then
  echo "Error: No directory specified."
  echo "Usage: sudo $0 /path/to/directory"
  exit 1
fi

# 3. Create the directory if it does not exist
if [ ! -d "$TARGET_DIR" ]; then
  echo "Creating directory: $TARGET_DIR"
  mkdir -p "$TARGET_DIR"
else
  echo "Directory exists: $TARGET_DIR"
fi

# 4. Set Group Ownership
# Changes the group to 'opencode' without changing the owning user
chown :"$GROUP_NAME" "$TARGET_DIR"

# 5. Set Base Permissions
# rwxrwxr-x (775): User and Group have full access; Others can read/execute.
chmod 775 "$TARGET_DIR"

# 6. Set the SGID bit
# Ensures new files inherit the 'opencode' group ID.
chmod g+s "$TARGET_DIR"

# 7. Set Default ACLs
# Ensures new files/dirs are group-writable automatically.
# -d: default (future files)
# -m: modify
# g::rwx: group gets read, write, execute
setfacl -d -m g::rwx "$TARGET_DIR"

echo "Success: Shared directory configured at $TARGET_DIR"
echo "  - Group: $GROUP_NAME"
  echo "  - SGID: Active"
  echo "  - ACL: Default group write enabled"
