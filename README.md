# Opencode Environment Setup

## Description
This script sets up a secure, isolated environment for the `opencode` user. It creates the user, configures a shared directory with specific permissions (SGID + ACL), and prepares your current user to interact with files in that directory.

## What this script does
1.  **Creates User/Group:** Checks for user `opencode`; creates it with `/home/opencode` if missing.
2.  **Updates Membership:** Adds **your** current user to the `opencode` group so you can edit files.
3.  **Configures Directory:**
    * Creates the target directory.
    * Sets SGID (`g+s`) so new files are owned by the group.
    * Sets ACLs so new files are writable by the group.

## Usage
1.  Make executable:
    ```bash
    chmod +x setup_opencode_env.sh
    ```
2.  Run with sudo and the target shared directory:
    ```bash
    sudo ./setup_opencode_env.sh /opt/projects/my-project
    ```

## Running the Application
To run the application strictly as the `opencode` user (ensuring it cannot read your personal files), use the command provided by the script output:

```bash
sudo runuser -l opencode -c "opencode /opt/projects/my-project"
