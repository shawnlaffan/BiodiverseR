package BiodiverseR::Data;

use 5.026;
use strict;
use warnings;

#  A bare bones class to handle a single basedata and one tree at a time.
#  The matrix is probably not going to be used.
#  Ultimately this will be replaced by a Biodiverse::Project object.

sub new {
    my $class = shift;
    my $self = { 
        basedata => undef,
        tree     => undef,
        matrix   => undef,
    };
    return bless $self, $class;
}

sub set_basedata {
    my ($self, $object) = @_;
    $self->{basedata} = $object;
}

sub set_tree {
    my ($self, $object) = @_;
    $self->{tree} = $object;
}

sub set_matrix {
    my ($self, $object) = @_;
    $self->{tree} = $object;
}

1;


