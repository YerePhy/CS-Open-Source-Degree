#!/bin/bash
enhanced_ls () {
	ls -lahts --color=auto
}

marco () {
	export CDIR=$(pwd)	
}

polo () {
	cd "$CDIR"
}

until_fails () {
	i=0
	rm ./out
	while "$1" >> out;
	do
		i=$((i+1))
	done
	echo "Done ${i} iterations" >> out
	cat out
}

zip_html_files () {
	find "$1" -type f -name "*.html" -print0 | xargs -0 tar -cvzf html.tar.gz
}

ls_files_by_recency () {
	find "$1" -type f -printf "%TY-%Tm-%Td %TT %p\n" | sort -n
}
