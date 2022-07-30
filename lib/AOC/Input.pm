package AOC::Input;

use 5.006;
use strict;
use warnings;

use feature qw/fc/;

use File::Basename;
use Text::CSV;
use JSON 'decode_json';

use Readonly;

=head1 NAME

AOC::Input - The great new AOC::Input!

=head1 VERSION

Version 0.04

=cut

our $VERSION = '0.03';

Readonly my $TXT => ".txt";
Readonly my $CSV => ".csv";
Readonly my $REG => ".reg";
Readonly my $JSON => ".json";
Readonly my @SUPPORTED_TYPES => ($TXT, $CSV, $REG, $JSON);

Readonly my $SLICE => "slice";
Readonly my $MAP => "map";
Readonly my $REGEXP => "regexp";
Readonly my $SEP_CHAR => "sep_char";
Readonly my $SORTED => "sort";

=head1 SYNOPSIS

The AOC::Input module provides functions to load data for an AOC assignment from an input file. Different input files
can contain data in different formats. This module enables loading of an input file using a single statement

    use AOC::Input;

    my $data = AOC::Input::load("./resources/input-file.txt");
    ...

=head1 EXPORT

AOC::Input::load can be used to load a data file into an array. If the array only contains a single element,
the method will return a scalar. The load method will return a reference to the loaded data.

Based on the file extension, the data will be handled differently. An additional $options parameter (hash reference)
could provide required or optional settings for the data parsing process.

The data processing will depend on the file type, which is identified through the file extension. The file will be
loaded into an array and every 'chomped' line will be a separate entry in the resulting array. When the array only
contains a single element, that element will be returned as a scalar:
=over 4
=item * ".txt" lines will not be processed, just copied into the array.
=item * ".csv" lines will be split at the comma, and each entry will be an array reference of the split line.
=item * ".reg" lines will be matched against a regexp, each entry will be the match result (e.g. matched groups).
=item * ".json" will return the parsed JSON
=back

=head1 SUBROUTINES/METHODS

=head2 load($path, $options)

Load the data from the file identified by $path. When the file does not exist the program will die.
$options must be a hash reference if provided. Some options are specific for a file type, while others are generic.

Specific options and generic options may be combined. Irrelevant options for the file type being parsed will be ignored.

Generic options (will be ignored on json input files):
=over 4
=item * slice => [<slice>]: return only a slice of the data (e.g. {slice => [0]} to return only the first line)
=item * map => &$mapper: apply the mapper on all elements of the result
=item * sorted => <true value> | <sub routine ref taking 2 parameters to compare> return the sorted list
=back

CSV options:
=over 4
=item * sep_char => "<char>": use the character defined as the separating character (comma is default)
=back

REG options:
=over 4
=item * regexp => qr/<regexp>/: use the regexp to parse the individual input file lines
=back

=cut

sub load {
    my ($path, $options) = @_;
    $options //= {};

    if (ref $options eq ref qr//) {
        $options = { $REGEXP => $options };
    }

    must_exist($path);
    open my $fh, "<", $path or die "Couldn't open input file '$path': $!";

    my $data;
    if (is_txt($path)) {
        $data = load_text($fh);
    }
    elsif (is_csv($path)) {
        $data = load_csv($fh, $options);
    }
    elsif (is_reg($path)) {
        $data = load_reg($fh, $options);
    }
    elsif (is_json($path)) {
        $data = load_json($fh, $options);
    }
    else {
        die "Unknown input file type for '$path'";
    }
    close $fh;

    my $slice = $$options{$SLICE};
    if (defined $slice) {
        $data = [ (@$data)[@$slice] ];
    }

    return $data if is_json($path);

    my $map = $$options{$MAP};
    if (defined($map)) {
        my @data = map {&$map($_)} @$data;
        $data = \@data;
    }

    my $sorted = $$options{$SORTED};
    if (defined($sorted)) {
        my @data;
        if (ref $sorted eq ref sub {}) {
            @data = sort {&$sorted($a,$b)} @$data;
        } else {
            @data = sort @$data;
        }
        $data = \@data;
    }

    @$data > 1 ? $data : $data->[0];
}

=head1 AUTHOR

Rene van Putten, C<< <z669016 at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-aoc at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=AOC>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc AOC::Input


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=AOC>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/AOC>

=item * Search CPAN

L<https://metacpan.org/release/AOC>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2022 by Rene van Putten.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)


=cut

sub must_exist {
    my $path = shift;
    -e $path or die "File '$path' doesn't exist";
}

sub cmp_ext {
    my ($path, $expected) = @_;
    my (undef, undef, $ext) = fileparse($path, @SUPPORTED_TYPES);
    fc($ext) eq fc($expected);
}

sub is_csv {
    my $path = shift;
    cmp_ext($path, $CSV);
}

sub is_txt {
    my $path = shift;
    cmp_ext($path, $TXT);
}

sub is_reg {
    my $path = shift;
    cmp_ext($path, $REG);
}

sub is_json {
    my $path = shift;
    cmp_ext($path, $JSON);
}

sub load_text {
    my $fh = shift;
    chomp(my @data = <$fh>);
    return \@data;
}

sub load_csv {
    my ($fh, $options) = @_;
    my @data = ();
    my $sep_char = $$options{$SEP_CHAR} // ',';
    my $csv = Text::CSV->new({ $SEP_CHAR => $sep_char });
    while (<$fh>) {
        chomp;

        if ($csv->parse($_)) {
            push @data, [ $csv->fields() ];
        }
        else {
            warn "Line could not be parsed: $_\n";
        }
    }
    return \@data;
}

sub load_reg {
    my ($fh, $options) = @_;

    unless (defined $$options{$REGEXP}) {
        die "Missing option{regexp} for loading parseable text file.";
    }

    my $data = load_text($fh);
    my $regexp = $$options{$REGEXP};
    foreach (@$data) {
        my @line = $_ =~ /$regexp/;
        $_ = \@line;
    }

    return $data;
}

sub load_json {
    my ($fh, $options) = @_;

    local $/ = undef;
    my $json_str = <$fh>;
    decode_json($json_str);
}

1; # End of AOC::Input
