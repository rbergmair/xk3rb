use v5.12.5;

use utf8;

use strict;
use warnings
  FATAL => 'all';
use warnings
  NONFATAL => 
    qw( exec recursion internal malloc newline deprecated portable );
no warnings 'once';


# ............................................................................


package Xk3RbSpamex::MyClass;


# ............................................................................


use English;
use Carp;

use Carp::Assert;
use Try::Tiny;

use Moose;

use namespace::autoclean;

use overload (
    "0+" => \&to_int,
    "bool" => \&to_bool,
    "qr" => \&to_regex,
    q("") => \&to_str
);


# ............................................................................


# project-external imports go here


# ............................................................................


# project-internal imports go here


# ............................................................................


# has 'name'  => ( is => 'rw' );
# has 'color' => ( is => 'rw' );


# ............................................................................


sub init {

    assert( not wantarray );
    assert( @_ == 1 );
    my ( $self ) = @_;
    assert( defined $self );
    
    return scalar undef;
    
};


# sub describe {
# 
#     assert( not wantarray );
#     assert( @_ == 1 );
#     my ( $self ) = @_;
#     assert( defined $self );
# 
#     print $self->name, ' is colored ', $self->color, "\n";
# 
#     return scalar undef;
# 
# };


# ............................................................................


sub to_str { assert(0); };
sub to_int { assert(0); };
sub to_bool { assert(0); };
sub to_regex { assert(0); };

__PACKAGE__->meta->make_immutable;

1;
