# Don't modify anything after this
if [ -f $INFO ]; then
  while read LINE; do
    if [ "$(echo -n $LINE | tail -c 1)" == "~" ]; then
      continue
    elif [ -f "$LINE~" ]; then
      mv -f $LINE~ $LINE
    else
      rm -f $LINE
      while true; do
        LINE=$(dirname $LINE)
        [ "$(ls -A $LINE 2>/dev/null)" ] && break 1 || rm -rf $LINE
      done
    fi
  done < $INFO
  rm -f $INFO
fi

## gms doze uninstall
# GMS components
GMS="com.google.android.gms"
GC1="auth.managed.admin.DeviceAdminReceiver"
GC2="mdm.receivers.MdmDeviceAdminReceiver"
NLL="/dev/null"

# Enable collective device administrators
for U in $(ls /data/user); do
for C in $GC1 $GC2 $GC3; do
pm enable --user $U "$GMS/$GMS.$C" &> $NLL
done
done

# Remove GMS from battery optimization
dumpsys deviceidle whitelist +com.google.android.gms &> $NLL

exit 0
)

# Remove all module files after un-installation
rm -rf /data/adb/universal-gms-doze
rm -rf /data/adb/modules/universal-gms-doze