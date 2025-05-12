# toggle.sh
#!/system/bin/sh
if [ -f "/data/adb/lockdown_enabled" ]; then
    /system/bin/unlock.sh
    rm /data/adb/lockdown_enabled
else
    /system/bin/lockdown.sh
    touch /data/adb/lockdown_enabled
fi