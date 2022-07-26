package AOC::Point;

use 5.006;
use strict;
use warnings;

use Readonly;
use Scalar::Util qw(reftype);

=head1 NAME

AOC::Point - methods to navigate (x,y) space

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

Readonly our $north => "north";
Readonly our $east => "east";
Readonly our $south => "south";
Readonly our $west => "west";

Readonly our %symbols => (
    "^" => $north,
    ">" => $east,
    "v" => $south,
    "<" => $west
);

Readonly our %moves => (
    $north => [0,1],
    $east => [1, 0],
    $south => [0, -1],
    $west => [-1, 0]
);

=head1 SYNOPSIS

This module provides methods to navigate a grid, with methods to move north, east, south, and west (by a single step)

Perhaps a little code snippet.

    use AOC::Point;

    my @xy = AOC::Point::origin;
    my @new_xy = AOC::Point::move(xy, AOC::Point::north);

=head1 EXPORT

Readonly values
=over 4
=item * $north String
=item * $east String
=item * $south String
=item * $west String
=item * %directions "^", ">", "v", "<"
=item * %moves "north", "east", "south", "west"
=item * &move
=item * origin
=back

=head1 SUBROUTINES/METHODS

=head2 origin()
returns the origin (x,y) coordinate

=cut

sub origin {
    (0, 0);
}

=head2 move($x, $y, $direction, $alt_symbols)
Calculates the new position based on a direction. The direction can be a direction name (north, east, south or west),
os a direction symbol (default "^", ">", "v", "<"). An alternative symbol hash could be used y providing a ref to a
hash mapping a symbol to the values north,east, south, and west.

The new location is calculated by adding the direction to the current (x,y), for instance:

    my @xy = AOC::Point::origin;
    my @new_xy = AOC::Point::move(xy, AOC::Point::north);
    # new_xy = (0,0) + %moves{"north"} ==>
    # new_xy = (0,0) + [0, 1]
    #
    my @new_xy = AOC::Point::move(xy, "^");
    # new_xy = (0,0) + %moves{%symbols{"^"}) ==>
    # new_xy = (0,0) + %moves{"north"} ==>
    # new_xy = (0,0) + [0, 1]
    #
    my @new_xy = AOC::Point::move(xy, "UP", {"UO =>"north, ... });
    # new_xy = (0,0) + %moves{%alt_symbols{"UP"}) ==>
    # new_xy = (0,0) + %moves{"north"} ==>
    # new_xy = (0,0) + [0, 1]
    #
    my @new_xy = AOC::Point::move(xy, [4,5]);
    # new_xy = (0,0) + [4, 5]

=cut

sub move_for_direction {
    my ($direction, $alt_symbols) = @_;
    $alt_symbols //= \%symbols;

    my $move = $moves{$direction} // $moves{$$alt_symbols{$direction}};
    die "Invalid direction for move '$direction'" if not defined $move;

    @$move;
}

sub move {
    my ($x, $y, $direction, $alt_symbols) = @_;

    my @the_direction =
        (reftype($direction) and reftype($direction) eq reftype []) ? @$direction
            : move_for_direction($direction, $alt_symbols);

    ($x + $the_direction[0], $y + $the_direction[1]);
}


=head1 AUTHOR

Rene van Putten, C<< <z669016 at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-. at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=.>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc AOC::Point


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=.>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/.>

=item * Search CPAN

L<https://metacpan.org/release/.>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2022 by Rene van Putten.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)


=cut

1; # End of AOC::Point
