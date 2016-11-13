# Description

### gitolite-pull-all-repositories.pl

Simple Perl script to pull all repositories from your server. Usefull if your git server is powered by [gitolite](http://gitolite.com/gitolite/index.html)
```bash
mkdir -p ~/work/company/git && cd ~/work/company/git
echo git.company.com > REPO
~/bin/gitolite-pull-all-repositories.pl
```
### gitolite-fetch-all-repositories.pl
The same as `gitolite-pull-all-repositories.pl` but do `fetch` instead of `pull` - fetch all repositories

### gitolite-mirror-all-repositories.pl
[Gitolite](http://gitolite.com/) has a great mirroring function. Sometimes you need to mirror all repositories to your slave/backup server.

### github-pull-all-repositories.pl

Simple Perl script to pull all repositories of specified user from [github.com](https://github.com)

Clone repositories using HTTPS:
```bash
mkdir -p ~/github/lhost && cd ~/github/lhost
echo github.com/lhost > REPO
~/bin/github-pull-all-repositories.pl
```

Clone repositories using SSH (clone your own github repos) - use colon ':' instead of slash '/' as seperator between hostname and username:
```bash
mkdir -p ~/github/lhost && cd ~/github/lhost
echo github.com:lhost > REPO
~/bin/github-pull-all-repositories.pl
```

### git-pull-repositories.sh

Simple script to pull all already-cloned repositores in current directory. Search for all .git subdirectories up to level 4.

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

## Installation with shell oneliner

```bash
curl -o - https://raw.githubusercontent.com/lhost/scripts-git/master/bootstrap.sh | sh
```
