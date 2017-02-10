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


package Xk3RbSpamex::MyModule;


# ............................................................................


use English;
use Carp;

use Carp::Assert;
use Try::Tiny;


# ............................................................................


# project-external imports go here


# ............................................................................


# project-internal imports go here


# ............................................................................


use namespace::autoclean -except => qw( import );
use Exporter qw( import );
# our @EXPORT = qw( example_for_exportable_method );
our @EXPORT = qw();


# ............................................................................


# sub describe {
# 
#     assert( not wantarray );
#     assert( @_ == 1 );
#     my ( $somethingrather ) = @_;
#     assert( defined $somethingrather );
# 
#     print $somethingrather, "\n";
# 
#     return scalar undef;
# 
# };


# ............................................................................


1;
