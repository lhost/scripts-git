#!/usr/bin/perl -w

#
# gitlab-fetch-all-repositories.pl
#
# Developed by Lubomir Host <lubomir.host@gmail.com>
# Licensed under terms of GNU General Public License.
# All rights reserved.
#
# Changelog:
# 2017-09-20 - created
#

use strict;
use warnings;

use LWP::UserAgent;
use JSON qw (from_json);
use Data::Dumper;
use Cwd;

$| = 1;

my $git_repo = shift;
my $protocol;
my $hostname;

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

if ($git_repo =~ m/^([^\/:]+)(?:[\/:]+)([^\/]*)$/) {
	$protocol = $1;
	$hostname = $2;
}
else {
	$protocol = 'http';
	$hostname = $git_repo;
}

print "REPO = '$git_repo', hostname='$hostname', PROTOCOL=$protocol\n";


unless ($git_repo) {
	print STDERR "Usage: $0\n";
	print STDERR "       echo 'ssh://gitlab.you.company.com' > REPO\n";
	exit 1;
}

my $git_json;
my $ua = LWP::UserAgent->new;
$ua->env_proxy; # take proxy setup from environment

my $page = 1;
my @all_ginfo = ();
while (1) {
	# https://docs.gitlab.com/ee/api/README.html#pagination-link-header
	# See HTTP Headers in response:
	# X-Next-Page: 
	# X-Page: 4
	# X-Per-Page: 20
	# X-Prev-Page: 3
	# X-Total: 23
	# X-Total-Pages: 2

	# make HTTP request: curl -i https://gitlab.your.company.com/api/v4/projects | less -S
	print "Downloading page #$page\n";
	my $response = $ua->get("http://$hostname/api/v4/projects?page=$page&per_page=10");
	if ($response->is_success) {
		$git_json = $response->decoded_content;  # or whatever
	}
	else {
		die $response->status_line;
	}

	#print Dumper($git_json, from_json($git_json));
	my $ginfo = from_json($git_json);

	last if (scalar(@{$ginfo}) == 0); # TODO: last page is emmpty, ignore HTTP Headers
	$page++;
	push @all_ginfo, @{ $ginfo };
}

print "Projects: " . scalar(@all_ginfo) . "\n";

my $cwd = getcwd();

foreach my $r (@all_ginfo) {
	#print Dumper($r);
	my $repo = ($protocol eq 'ssh') ? "$hostname:$r->{path_with_namespace}" : $r->{http_url_to_repo};
	my $dir_repo;
	if ($repo =~ m/([^\/]+)$/) { # take the last part of path
		$dir_repo = $1;
		$dir_repo =~ s/\.git$//;
	}
	else {
		warn "Invalid repo name '$repo'";
		next;
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

