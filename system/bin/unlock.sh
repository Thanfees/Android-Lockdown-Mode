#!/system/bin/sh
# Re-enable all disabled apps
for pkg in $(pm list packages -d | cut -d':' -f2); do
    pm enable "$pkg" >/dev/null 2>&1
done

# Restore notification settings
settings put global heads_up_notifications_enabled 1

echo "Lockdown mode disabled"