#! /usr/bin/env fish

set -l options (fish_opt --short h --long help)
set -la options (fish_opt --short p --long pretend)
set -la options (fish_opt --short a --long all)

argparse $options -- $argv

if set -q _flag_help
	echo -e "Options:"
	echo -e "\t-h,\t--help:\tprint help message;"
	echo -e "\t-p,\t--pretend:\tdo nothing;"
	echo -e "\t-a,\t--all:\tforce update all;"

	echo -e "\nWARNING: need to be runned in stow dir."

	return 0
end
if set -q _flag_pretend
	function execute
		echo $argv
	end
else
	function execute
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

function install
	if test -f argv[2] && test (stat -c "%Y" $argv[1]) -le (stat -c "%Y" $argv[2]) -a false = $update_all
		return
	end
	if test -e $argv[2]
		# execute mv $argv[1] $TMP_DIR
		execute rm $argv[2]
	end
	execute cp  $argv[1] $argv[2]
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

		execute cd $p
		for i in **
			if test -d $i
				clear_dir /$i
			else if test -f $i
				install $i /$i
			end
		end
		execute cd ..
	end
end

update_etc
