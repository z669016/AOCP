#!perl
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 3;

BEGIN {
    use_ok( 'AOC' ) || print "Bail out!\n";
    use_ok( 'AOC::Input' ) || print "Bail out!\n";
    use_ok( 'AOC::Point' ) || print "Bail out!\n";
}

diag( "Testing AOC $AOC::VERSION, Perl $], $^X" );
