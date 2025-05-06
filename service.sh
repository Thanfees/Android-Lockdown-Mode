#!/system/bin/sh
#!/data/adb/magisk/busybox sh

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
sh /data/adb/modules/lockdown/adblock.sh


echo "Lockdown mode is now ENABLED"
echo "Now running GMS Doze"

set -o standalone

#
# Universal GMS Doze by the
# open-source loving GL-DP and all contributors;
# Patches Google Play services app and certain processes/services to be able to use battery optimization
#

(   
# Wait until boot completed
until [ $(resetprop sys.boot_completed) -eq 1 ] &&
[ -d /sdcard ]; do
sleep 100
done

# GMS components
GMS="com.google.android.gms"
GC1="auth.managed.admin.DeviceAdminReceiver"
GC2="mdm.receivers.MdmDeviceAdminReceiver"
NLL="/dev/null"

# Disable collective device administrators
for U in $(ls /data/user); do
for C in $GC1 $GC2 $GC3; do
pm disable --user $U "$GMS/$GMS.$C" &> $NLL
done
done

# Add GMS to battery optimization
dumpsys deviceidle whitelist -com.google.android.gms &> $NLL

exit 0
)
