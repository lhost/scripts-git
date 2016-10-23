#!/bin/sh

#
# git-pull-repositories.sh
#
# Developed by Lubomir Host 'rajo' <lubomir.host@gmail.com>
# Licensed under terms of GNU General Public License.
# All rights reserved.
#
# Changelog:
# 2014-07-16 - created
#

DEST=`pwd`
for i in `find . -maxdepth 4 -type d -name .git -exec dirname {} \;`; do
	if [ -d "$i" ] ; then
		echo ------ $i
		cd $DEST/$i && git pull
		cd $DEST
	fi
done

