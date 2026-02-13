# Determine whether keyboard is going to be used by evremap

set listed_devices (evremap list-devices | grep Name:)
set selected_devices (string split \n < /etc/selected_keyboards)
# echo $listed_devices

set ans NOPE
for each in $selected_devices
	set each_prefixed "Name: $each"
	# echo $each_prefixed
	if contains $each_prefixed $listed_devices
		set ans $each
	end
end

echo $ans
