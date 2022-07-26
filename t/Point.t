#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

use AOC::Point;

my @origin = AOC::Point::origin;
is_deeply(\@origin, [0,0], "origin");

my @new_xy = AOC::Point::move(@origin, "north");
is_deeply(\@new_xy, [0,1], "move north by name");
@new_xy = AOC::Point::move(@origin, "^");
is_deeply(\@new_xy, [0,1], "move north bby symbol");
@new_xy = AOC::Point::move(@origin, [0,3]);
is_deeply(\@new_xy, [0,3], "move north by (x,y)");
@new_xy = AOC::Point::move(@origin, "UP", {"UP", $AOC::Point::north});
is_deeply(\@new_xy, [0,1], "move north by alt_symbol");

@new_xy = AOC::Point::move(@origin, "east");
is_deeply(\@new_xy, [1,0], "move east by name");
@new_xy = AOC::Point::move(@origin, ">");
is_deeply(\@new_xy, [1,0], "move east by symbol");
@new_xy = AOC::Point::move(@origin, [3,0]);
is_deeply(\@new_xy, [3,0], "move east by (x,y)");
@new_xy = AOC::Point::move(@origin, "RIGHT", {"RIGHT", $AOC::Point::east});
is_deeply(\@new_xy, [1,0], "move east by alt_symbol");

@new_xy = AOC::Point::move(@origin, "south");
is_deeply(\@new_xy, [0,-1], "move south by name");
@new_xy = AOC::Point::move(@origin, "v");
is_deeply(\@new_xy, [0,-1], "move south by symbol");
@new_xy = AOC::Point::move(@origin, [0,-3]);
is_deeply(\@new_xy, [0,-3], "move south by (x,y)");
@new_xy = AOC::Point::move(@origin, "DOWN", {"DOWN", $AOC::Point::south});
is_deeply(\@new_xy, [0,-1], "move south by alt_symbol");

@new_xy = AOC::Point::move(@origin, "west");
is_deeply(\@new_xy, [-1,0], "move west by name");
@new_xy = AOC::Point::move(@origin, "<");
is_deeply(\@new_xy, [-1,0], "move west by symbol");
@new_xy = AOC::Point::move(@origin, [-3,0]);
is_deeply(\@new_xy, [-3,0], "move west by (x,y)");
@new_xy = AOC::Point::move(@origin, "LEFT", {"LEFT", $AOC::Point::west});
is_deeply(\@new_xy, [-1,0], "move west by alt_symbol");

done_testing();

