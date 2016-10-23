#!/usr/bin/perl -w

#
# github-pull-all-repositories.pl
#
# Developed by Lubomir Host 'rajo' <lubomir.host@gmail.com>
# Licensed under terms of GNU General Public License.
# All rights reserved.
#
# Changelog:
# 2016-10-24 - created
#

use strict;

use LWP::UserAgent;
use JSON qw (from_json);
use Data::Dumper;
use Cwd;

$| = 1;

my $git_repo = shift;

unless ($git_repo) {
	if (-f "REPO") {
		open (REPO, '<REPO') or die "Can't open 'REPO': $!";
		while (my $line = <REPO>) {
			next if ($line =~ m/^\s*#/
					or $line =~ m/^\s*$/
			);
			chomp($line);
			$git_repo = $line;
			last if (defined($git_repo))
		}
		close (REPO);
	}
}

$git_repo =~ s/^.*?([^\/]+)$/github.com\/$1/g; # take the last part of repo URL

my $github_user;
if ($git_repo =~ m/([^\/]+)$/) {
	$github_user = $1;
}

print "REPO = '$git_repo', USER = '$github_user'\n";

unless ($git_repo) {
	print STDERR "Usage: $0 <github_username>\n";
	print STDERR "       echo 'github.com/lhost' > REPO\n";
	exit 1;
}

my $git_json;
my $ua = LWP::UserAgent->new;
$ua->env_proxy; # take proxy setup form environment

# make HTTP request: curl -i https://api.github.com/users/lhost/repos | less -S
my $response = $ua->get("https://api.github.com/users/$github_user/repos");
if ($response->is_success) {
	$git_json = $response->decoded_content;  # or whatever
}
else {
	die $response->status_line;
}

#print Dumper($git_json, from_json($git_json));

my $ginfo = from_json($git_json);

my $cwd = getcwd();

foreach my $r (@{ $ginfo }) {
	my $repo = $r->{clone_url};
	my $dir_repo;
	if ($repo =~ m/([^\/]+)$/) { # take the last part of path
		$dir_repo = $1;
		$dir_repo =~ s/\.git$//;
	}
	else {
		die "Invalid repo name '$repo'";
	}

	print "------- Repository: $repo\n";

	chdir $cwd || die "Can't change directory: $!";
	
	if (-d $dir_repo) {
		chdir "$cwd/$repo";
		system(qw( git pull ));
	}
	elsif ($dir_repo =~ m/^[a-z0-9_:\.\/-]+$/i && $dir_repo !~ m(/\.\./) ) {
		mkdir "$dir_repo" || die "Can't create directory: $!";
		print "\tMISSING\n";
		system(qw( git clone ), $repo, $dir_repo);
	}
	else {
			print "\tMISSING but ignored (wildcard chars)\n";
	}
}

# vim: ts=4
# vim600: fdm=marker fdl=0 fdc=3

