# Description

### gitlab-fetch-all-repositories.pl

Simple Perl script to pull all repositories from your [https://about.gitlab.com/](Gitlab) server.

```bash
mkdir -p ~/work/company/git && cd ~/work/company/git
echo ssh://gitlab.company.com > REPO
~/bin/gitlab-fetch-all-repositories.pl
```

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

### github-fetch-all-repositories.pl

Simple Perl script to fetch all repositories of specified user from [github.com](https://github.com)

Clone repositories using HTTPS:
```bash
mkdir -p ~/github/lhost && cd ~/github/lhost
echo github.com/lhost > REPO
~/bin/github-fetch-all-repositories.pl
```

Clone repositories using SSH (clone your own github repos) - use colon ':' instead of slash '/' as seperator between hostname and username:
```bash
mkdir -p ~/github/lhost && cd ~/github/lhost
echo github.com:lhost > REPO
~/bin/github-fetch-all-repositories.pl
```

### git-pull-repositories.sh

Simple script to pull all already-cloned repositores in current directory. Search for all .git subdirectories up to level 4.

### git-status.pl

Search for git repositories in specified directories and export this information as JSON:

```bash
./github.com-lhost/scripts-git/git-status.pl ./github.com-lhost/scripts-git
```
```json
{
   "./github.com-lhost/scripts-git" : {
      "." : {
         "branch" : "master",
         "branches" : {
            "master" : {
               "default" : 1,
               "desc" : "Do fetch insteead of pull",
               "sha1" : "7bcb147ffdc19e4cb8e2218880554eabdc1f555a"
            },
            "remotes/origin/HEAD" : {
               "default" : 0,
               "desc" : "origin/master",
               "sha1" : "->"
            },
            "remotes/origin/master" : {
               "default" : 0,
               "desc" : "Do fetch insteead of pull",
               "sha1" : "7bcb147ffdc19e4cb8e2218880554eabdc1f555a"
            }
         },
         "remotes" : {
            "origin" : "https://github.com/lhost/scripts-git.git"
         },
         "rev" : "7bcb147ffdc19e4cb8e2218880554eabdc1f555a"
      }
   }
}
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

## Installation with shell oneliner

```bash
curl -o - https://raw.githubusercontent.com/lhost/scripts-git/master/bootstrap.sh | sh
```
