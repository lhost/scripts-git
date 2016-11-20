#!/usr/bin/perl -w

#
# github-fetch-all-repositories.pl
#
# Developed by Lubomir Host <lubomir.host@gmail.com>
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

my %protocol_map = (
	'/'	=> 'HTTPS',
	':'	=> 'SSH',
);

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

$git_repo =~ s/^.*?([\/:])([^\/:]+)$/github.com$1$2/g; # take the last part of repo URL

my $github_user;
my $protocol;
# Server name and username can be separated by '/' and ':'
# if they are separated by '/' -> clone over https://
# if they are separated by ':' -> clone over ssh://
if ($git_repo =~ m/([\/:])([^\/:]+)$/) {
	my $protocol_code = $1;
	#warn "protocol_code=$protocol_code";
	$protocol = $protocol_map{$protocol_code} || 'HTTPS';
	$github_user = $2;
}

print "REPO = '$git_repo', USER = '$github_user', PROTOCOL=$protocol\n";

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
	my $repo = ($protocol eq 'SSH') ? $r->{ssh_url} : $r->{clone_url};
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
	
	if (-d $dir_repo and -d "$dir_repo/.git" and -f "$dir_repo/.git/config") {
		print "\tgit fetch\n";
		chdir "$cwd/$dir_repo" or die "Can't chdir to '$cwd/$dir_repo'";
		system(qw( git fetch ));
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

# vim: ts=4 fdm=marker fdl=0 fdc=3

