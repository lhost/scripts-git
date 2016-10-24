#!/bin/sh -x

if [ ! -d .git ]; then
	git clone https://github.com/lhost/scripts-git \
		&& cd scripts-git \
		&& ./bootstrap.sh
	exit 0
fi

cwd=`pwd`

if [ ! -d "$HOME/bin" ]; then
	mkdir $HOME/bin 
fi

# create symlink for every Perl script in repository
cd $HOME/bin
for i in $cwd/*.pl; do
	ln -s $i
done
