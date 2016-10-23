# Description

### gitolite-pull-all-repositories.pl

Simple Perl script to pull all repositories from your server. Usefull if your git server is powered by [gitolite](http://gitolite.com/gitolite/index.html)
```bash
mkdir -p ~/work/company/git && cd ~/work/company/git
echo git.company.com > REPO
~/bin/gitolite-pull-all-repositories.pl
```

### github-pull-all-repositories.pl

Simple Perl script to pull all repositories of specified user from [github.com](https://github.com)
```bash
mkdir -p ~/github/lhost && cd ~/github/lhost
echo github.com/lhost > REPO
~/bin/github-pull-all-repositories.pl
```

### bootstrap.sh

Simle installation script

# Installation

use bootstrap.sh script to create symlinks in your $HOME/bin directory

```bash
cd ~/git
git clone https://github.com/lhost/scripts-git
cd scripts-git
./bootstrap.sh
```


