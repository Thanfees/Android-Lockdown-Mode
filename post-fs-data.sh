#!/system/bin/sh
# Check if lockdown mode is enabled (e.g., via a flag file)
if [ -f "/data/adb/lockdown_enabled" ]; then
    /system/bin/lockdown.sh
fi