#! /usr/bin/env fish
for i in ./**
	echo changing date of $i
	touch --date="19990101" $i
end
