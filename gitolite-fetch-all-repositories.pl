#!/usr/bin/perl -w

#
# gitolite-fetch-all-repositories.pl
#
# Developed by Lubomir Host 'rajo' <lubomir.host@gmail.com>
# Licensed under terms of GNU General Public License.
# All rights reserved.
#
# Changelog:
# 2016-11-13 - created
#

use strict;

use JSON qw (from_json);
#use Data::Dumper;
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

print "REPO = '$git_repo'\n";

unless ($git_repo) {
	print STDERR "Usage: $0 <path-to-your-git-repository>\n";
	print STDERR "       echo '<path-to-your-git-repository>' > REPO\n";
	exit 1;
}

my $git_json;
{
	local $/;
	open (GIT, "/usr/bin/ssh $git_repo info --json |");
	$git_json = <GIT>;
	close (GIT);
}

#print Dumper($git_json, from_json($git_json));

my $ginfo = from_json($git_json);

my $cwd = getcwd();

foreach my $repo (sort keys %{$ginfo->{repos}}) {
	print "------- Repository: $repo\n";

	chdir $cwd || die "Can't change directory: $!";
	
	if (-d $repo) {
		chdir "$cwd/$repo";
		system(qw( git fetch --all ));
	}
	elsif ($repo =~ m/^[a-z0-9_:\.\/-\+]+$/i  && $repo !~ m(/\.\./) ) {
		mkdir "$repo" || die "Can't create directory: $!";
		print "\tMISSING\n";
		system(qw( git clone ), "$git_repo:$repo", "$repo");
	}
	else {
			print "\tMISSING but ignored (wildcard chars)\n";
	}
}

# vim: ts=4
# vim600: fdm=marker fdl=0 fdc=3

