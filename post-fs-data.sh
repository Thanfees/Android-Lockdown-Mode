#!/system/bin/sh


chmod 755 /data/adb/modules/lockdown/system/bin/lockdown
ln -sf /data/adb/modules/lockdown/bin/lockdown /system/bin/lockdown

LOCKDOWN_FLAG="/data/adb/lockdown_mode_active"

if [ -f "$LOCKDOWN_FLAG" ]; then
    echo "[Lockdown] Activating lockdown restrictions..."

    # Disable all non-essential apps
    pm list packages -3 | cut -f 2 -d ":" | while read pkg; do
        if [ "$pkg" != "com.your.lockdownapp" ]; then
            pm disable "$pkg"
        fi
    done

    # Disable access from all apps accessing mic and camera
    pm list packages -3 | cut -d ":" -f 2 | while read pkg; do
        if [ "$pkg" != "com.your.allowedapp" ]; then
            appops set "$pkg" CAMERA deny
            appops set "$pkg" RECORD_AUDIO deny
        fi
    done

    # Disable Wi-Fi, Mobile Data, and Bluetooth
    svc wifi disable
    svc data disable
    rfkill block all

    # Force 2G only mode (device-specific)
    settings put global preferred_network_mode 1
fi

                       