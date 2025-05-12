#!/system/bin/sh
# Optional: Re-apply lockdown mode or monitor state
if [ -f "/data/adb/lockdown_enabled" ]; then
    /system/bin/lockdown.sh
fi