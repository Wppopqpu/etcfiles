
set device_name (fish /usr/share/user_utils/determine_current_keyboard.fish)
echo Device selected as $device_name.
/usr/bin/evremap remap /etc/evremap_user_config.toml -d 0 --device-name "$device_name"
