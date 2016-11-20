#!/usr/bin/perl -w

#
# Search for repositories in your directory and export information in JSON format
#
# Developed by Lubomir Host <lubomir.host@gmail.com>
# Licensed under terms of GNU General Public License.
# All rights reserved.
#
# Changelog:
# 2016-11-17 - created
#


use strict;
use warnings;

use Cwd;
use File::Find;
use JSON qw( encode_json );
#use Data::Dumper;

my %stat = ();
my $cur_dir;

sub git_parse_branches($)
{ # {{{
	my ($command) = @_;
	my $branches = {};

	open(CMD, '-|', $command) or die $@;
	my $line;
	while (defined($line = <CMD>)) {
		chomp($line);
		my ($default, $branch, $sha1, $desc) = split(/\s+/, $line, 4);
		$branches->{$branch} = {
			default => ($default eq '*' ? 1 : 0),
			sha1	=> $sha1,
			desc	=> $desc,
		};
	}
	close CMD;
	return $branches;
} # }}}

sub wanted
{ # {{{
	my $dir = $_;

	if (-d $dir and $dir =~ m/^(.*)\/\.git$/) {
		$dir = $1;
		$dir =~ s/^\.\///g;
		$dir =~ s/\/$//g;

		my $rem = `git --git-dir $dir/.git remote -v`;
		chomp($rem);
		my @remotes = split(/\s+/, $rem);
		my $remotes_hash = {};
		while (my ($origin, $remote, $operation) = splice(@remotes, 0, 3)) {
			$remotes_hash->{$origin} = $remote;
		}
		my $rev		= `git --git-dir $dir/.git rev-parse HEAD`;
		my $branch	= `git --git-dir $dir/.git rev-parse --abbrev-ref HEAD`;
		chomp($rev);
		chomp($branch);
		# git branch: --list and --no-column not supported by old git
		my $branches = git_parse_branches("git --git-dir $dir/.git branch -a --no-color --no-abbrev -v");
		$stat{$cur_dir}->{$dir} = {
			rev			=> $rev,
			branch		=> $branch,
			remotes		=> $remotes_hash,
			branches	=> $branches,
		};
	}
} # }}}

sub run(@)
{ # {{{
	my (@dirs) = @_;

# postupne pre kazdy adresar z @ARGV chceme vsestky podpriecinky ako podkluce v hashi
	my $cwd  = getcwd();
# postupne nastavi globalnu premennu na hodnotu parametra z ARGV
	my $idx = 0;
	foreach my $xdir (@dirs) {
		$cur_dir = $xdir;
		#print "$cur_dir => $idx\n";

		# riesenie pre absolutne aj relativne cesty
		chdir $cwd and chdir $xdir
			and find( { wanted => \&wanted, no_chdir => 1 }, '.'); # po chdir() hladame uz iba v aktualnom adresari
		$idx++;
	}

	#my $coder = JSON::XS->new->ascii->pretty->allow_nonref;
	my $coder = JSON::XS->new->pretty->canonical;

	print $coder->encode(\%stat);

} # }}}

# hack: this script is used in special way (eval())
if ($0 ne '-e') {
	run(@ARGV);
}

# vim: ts=4 fdm=marker fdl=0 fdc=3

