#!/usr/bin/perl

use strict;
use Test::More tests => 12;
use Lingua::Stem::Snowball::Ca qw( stem );
use File::Spec;

my $stemmer = Lingua::Stem::Snowball::Ca->new();

# Test UTF-8 vocab.
my @before   = ();
my @after    = ();
my $utf8_voc_path = File::Spec->catfile( 't', 'test_voc', "ca.utf8" );
my $open_mode = $] >= 5.8 ? "<:utf8" : "<";
open( my $utf8_voc_fh, $open_mode, $utf8_voc_path )
    or die "Couldn't open file '$utf8_voc_path' for reading: $!";

while (<$utf8_voc_fh>) {
    chomp;
    my ( $raw, $expected ) = split;
    push @before, $raw;
    push @after,  $expected;
    test_singles( $raw, $expected );
}
test_arrays( \@before, \@after );

sub test_singles {
    my ( $raw, $expected ) = @_;

    my $got = $stemmer->stem($raw);
    is( $got, $expected, "ca \$s->stem(\$raw)" );

    $got = stem( $raw );
    is( $got, $expected, "ca stem(\$raw)" );

    $got = $stemmer->stem( uc($raw) );
    is( $got, $expected, "ca \$s->stem(uc(\$raw))" );

    $got = [$raw];
    $stemmer->stem_in_place($got);
    is( $got->[0], $expected, "ca \$s->stem_in_place(\$raw)" );
}

sub test_arrays {
    my ( $raw, $expected ) = @_;

    my @got = $stemmer->stem($raw);
    is_deeply( \@got, $expected, "ca \$s->stem(\@raw)" );

    @got = stem( $raw );
    is_deeply( \@got, $expected, "ca stem(\@raw)" );

    my @uppercased = map {uc} @$raw;
    @got = $stemmer->stem( \@uppercased );
    is_deeply( \@got, $expected, "ca \$s->stem(\@raw) (uc'd)" );

    @got = @$raw;
    $stemmer->stem_in_place( \@got );
    is_deeply( \@got, $expected, "ca \$s->stem_in_place(\@raw)" );
}
