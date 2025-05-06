#!/system/bin/sh

LOCKDOWN_FLAG="/data/adb/modules/lockdown/.lockdown_enabled"
ALLOWLIST="/system/etc/lockdown_allowlist.txt"

# Only proceed if lockdown flag is set
if [ ! -f "$LOCKDOWN_FLAG" ]; then
    exit 0
fi

# Disable third-party apps except allowed ones
pm list packages -3 | cut -d ":" -f 2 | while read pkg; do
    if ! grep -q "$pkg" "$ALLOWLIST"; then
        pm disable "$pkg"
    fi
done

# Deny mic and camera access
pm list packages -3 | cut -d ":" -f 2 | while read pkg; do
    if ! grep -q "$pkg" "$ALLOWLIST"; then
        appops set "$pkg" CAMERA deny
        appops set "$pkg" RECORD_AUDIO deny
    fi
done

# Stop non-allowlisted services
dumpsys activity services | grep "packageName=" | cut -d'=' -f2 | cut -d' ' -f1 | while read service; do
    if ! grep -q "$service" "$ALLOWLIST"; then
        am force-stop "$service" >/dev/null 2>&1
    fi
done

# Disable heads-up notifications
settings put global heads_up_notifications_enabled 0

# Disable Wi-Fi, data, Bluetooth
svc wifi disable
svc data disable
rfkill block all

# Force 2G only mode
settings put global preferred_network_mode 1

# Disable location and NFC
settings put secure location_mode 0
settings put global nfc_on 0


# Download and apply adblock hosts file
ADBLOCK_HOSTS="/data/adb/modules/lockdown/hosts.adblock"
if [ ! -f "$ADBLOCK_HOSTS" ]; then
    curl -s -L -o "$ADBLOCK_HOSTS" "https://o0.pages.dev/Pro/hosts.txt"
fi

# Backup original hosts file only once
ORIGINAL_HOSTS="/data/adb/modules/lockdown/hosts.original"
if [ ! -f "$ORIGINAL_HOSTS" ]; then
    cp /system/etc/hosts "$ORIGINAL_HOSTS"
fi

# Bind the new hosts file
mount -o bind "$ADBLOCK_HOSTS" /system/etc/hosts

echo "Lockdown mode is now ENABLED"
