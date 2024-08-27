#!/bin/bash

# Get the current date in DD_MM_YYYY format
current_date=$(date "+%d_%m_%Y")

# Define the output file name with the current date
output_file="Configsave/cisavecon_${current_date}.txt"

# List of configuration files
config_files=(
    "/etc/pam.d/system-auth"
    "/etc/login.defs"
    "/etc/securetty"
    "/etc/passwd"
    "/etc/group"
    "/etc/shadow"
    "/etc/security/pwquality.conf"
    "/etc/security/faillock.conf"
    "/etc/ssh/sshd_config"
    "/etc/motd"
    "/etc/issue"
    "/etc/sysctl.conf"
    "/etc/audit/audit.rules"
    "/etc/audit/auditd.conf"
    "/etc/logrotate.conf"
    "/etc/rsyslog.conf"
    "/var/log/secure"
    "/var/log/wtmp"
    "/etc/ntp.conf"
    "/etc/chrony.conf"
    "/etc/snmp/snmpd.conf"
    "/etc/vsftpd/vsftpd.conf"
    "/etc/sysconfig/nfs"
    "/etc/postfix/main.cf"
    "/etc/rpc"
    "/etc/samba/smb.conf"
)

# Create the Configsave directory if it doesn't exist
mkdir -p Configsave

# Get the current date and time
timestamp=$(date "+%Y-%m-%d %H:%M:%S")

# Get system information
sys_info=$(uname -a)

# Save system information and date/time to the output file
{
    echo "=============================="
    echo "Date and Time: $timestamp"
    echo "=============================="
    echo "System Information:"
    echo "$sys_info"
    echo "=============================="
} >> "$output_file"

# Iterate over the file list and save their contents to the output file
for file in "${config_files[@]}"; do
    # Check if the file exists
    if [[ -f "$file" ]]; then
        # Save the file contents
        {
            echo "=============================="
            echo "#*#*"
            echo "File: $file"
            echo "#*#*"
            echo "=============================="
            cat "$file"
            echo "=============================="
        } >> "$output_file"
    else
        {
            echo "=============================="
            echo "#*#*"
            echo "File: $file"
            echo "#*#*"
            echo "=============================="
            echo "File not found: $file"
            echo "=============================="
        } >> "$output_file"
        echo "File not found: $file" 1>&2  # Print warning to terminal
    fi
done

# Function to iterate through /etc/systemd/system/ and its subdirectories
save_systemd_files() {
    local dir="$1"
    for systemd_file in "$dir"/*; do
        if [[ -f "$systemd_file" ]]; then
            # If it's a file, save its content
            {
                echo "=============================="
                echo "#*#*"
                echo "File: $systemd_file"
                echo "#*#*"
                echo "=============================="
                cat "$systemd_file"
                echo "=============================="
            } >> "$output_file"
        elif [[ -d "$systemd_file" ]]; then
            # If it's a directory, call the function recursively
            save_systemd_files "$systemd_file"
        fi
    done
}

# Start the recursive saving from /etc/systemd/system/
save_systemd_files "/etc/systemd/system"

# Save system information and to the output file
{
    echo "=============================="
    echo ".netrc file"
    echo "=============================="
    echo "#*#*"
    echo "$(ls -al ~/.netrc 2>/dev/null)"
    echo "=============================="
} >> "$output_file"

# Save system information and to the output file
{
    echo "=============================="
    echo ".rhosts file"
    echo "=============================="
    echo "#*#*"
    echo "$(ls -al ~/.rhosts 2>/dev/null)"
    echo "=============================="
} >> "$output_file"

echo "Configuration files and system information have been saved in: $output_file"

