#!/usr/bin/env perl

use strict;
use warnings;
use IPC::Open2;

sub tex2typst {
  my ($tex) = @_;
  my $pid = open2(my $out, my $in, 'pandoc', '-f', 'latex', '-t', 'typst') or die "can't run pandoc: $!";
  print $in $tex;
  close $in;
  local $/;
  my $typst = <$out>;
  close $out;
  waitpid $pid, 0;
  $? == 0 or die "pandoc failed at $tex\n";
  $typst =~ s/\s+\z//;
  return $typst;
}

while  (my $line = <>) {
  $line =~ s/^(\s*\w+\s*=\s*)"(.*)"(\s*,?\s*)$/$1\{$2\}$3/;
  $line =~ s/\$[^\$]+\$/tex2typst($&)/ge;
  print $line;
}
