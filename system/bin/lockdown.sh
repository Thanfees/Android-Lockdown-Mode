#!/system/bin/sh
# Allowlisted packages
ALLOWLIST="/system/etc/lockdown_allowlist.txt"

# Disable all user-installed apps
for pkg in $(pm list packages -3 | cut -d':' -f2); do
    if ! grep -Fx "$pkg" "$ALLOWLIST"; then
        pm disable "$pkg" >/dev/null 2>&1
    fi
done

# Disable non-essential system apps
for pkg in $(pm list packages -s | cut -d':' -f2); do
    if ! grep -Fx "$pkg" "$ALLOWLIST"; then
        pm disable "$pkg" >/dev/null 2>&1
    fi
done

# Stop non-essential services (careful with this)
for service in $(dumpsys activity services | grep "packageName=" | cut -d'=' -f2 | cut -d' ' -f1); do
    if ! grep -Fx "$service" "$ALLOWLIST"; then
        am force-stop "$service" >/dev/null 2>&1
    fi
done

# Optional: Disable notifications from non-essential apps
settings put global heads_up_notifications_enabled 0

echo "Lockdown mode enabled"