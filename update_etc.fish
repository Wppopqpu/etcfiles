#! /usr/bin/env fish

set -l options (fish_opt --short h --long help)
set -la options (fish_opt --short p --long pretend)
set -la options (fish_opt --short a --long all)
set -la options (fish_opt --short r --long fetch)

argparse $options -- $argv

function colored_critical
	echo -e "\033[30m\033[45m$argv\033[0m"
end

function echo_critical
	echo (colored_critical $argv)
end

function colored_very_critical
	echo -e "\033[30m\033[41m$argv\033[0m"
end

function echo_very_critical
	echo (colored_very_critical $argv)
end	

if set -q _flag_help
	echo -e "Options:"
	echo -e "\t-h,\t--help:\tprint help message;"
	echo -e "\t-p,\t--pretend:\tdo nothing;"
	echo -e "\t-a,\t--all:\tforce update all;"
	echo -e "\t-r,\t--fetch:\tfetch from target;"

	echo -e "\nWARNING: need to be runned in stow dir."

	return 0
end
if set -q _flag_pretend
	function execute
		echo \t\t $argv
	end
else
	function execute
		echo -e -n "\t\t"
		echo $argv | tee /dev/tty | source
	end
end
# set TMP_DIR /tmp/update_etc
#
# function mk_tmpdir
# 	if test ! -d $TMP_DIR
# 		if test -e $TMP_DIR
# 			execute rm $TMP_DIR
# 		end
#
# 		execute mkdir $TMP_DIR
# 	end
# end

if set -q _flag_all
	set update_all true
else
	set update_all false
end

if set -q _flag_fetch
	set fetch_from_target true
else
	set fetch_from_target false
end

function install
	echo -e -n "\t$(colored_critical INSTALLING): $argv[1] -> $argv[2] \t;"
	if test -f $argv[2]
		set source_timestamp (stat -c "%Y" $argv[1])
		set target_timestamp (stat -c "%Y" $argv[2])
		if test $source_timestamp -eq $target_timestamp -a false = $update_all
			echo_critical "SKIPPED"
			return
		end
		if test $source_timestamp -lt $target_timestamp -a true = $fetch_from_target
			echo_very_critical "FETCHED"
			# if test -e $argv[1]
			# 	execute rm $argv[1]
			# end
			execute cp $argv[2] $argv[1]
			execute touch --reference=$argv[2] $argv[1]
			execute chown branch $argv[1]
			return
		end
	end
	echo_very_critical "UPDATED"
	if test -e $argv[2]
		# execute mv $argv[1] $TMP_DIR
		execute rm $argv[2]
	end
	execute cp  $argv[1] $argv[2]
	execute touch --reference=$argv[1] $argv[2]
	execute chown root $argv[2]
end

function clear_dir
	if test -L $argv
		execute rm $argv
	end
	if test -d $argv
		return
	end

	execute mkdir $argv
end

function is_package
	if test ! -d $argv
		echo false
		return
	end
	if test (string sub --end 1 $argv) = .
		echo false
		return
	end
	echo true
	return
end

function update_etc
	# set packages *
	for p in *
		if test (is_package $p) = false
			continue
		end

		cd $p
		echo (colored_critical PACKAGE): $p
		for i in **
			if test -d $i
				clear_dir /$i
			else if test -f $i
				install $i /$i
			end
		end
		cd ..
	end
end

update_etc
