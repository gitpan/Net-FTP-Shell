#!/usr/local/bin/perl

use Net::FTP::Shell;

my $x= Net::FTP::Shell->new(\@ARGV);

$x->parse();
