use v5.12.5;

use utf8;

use strict;
use warnings
  FATAL => 'all';
use warnings
  NONFATAL => 
    qw( exec recursion internal malloc newline deprecated portable );
no warnings 'once';

use English;
use Carp;

use Carp::Assert;
use Try::Tiny;

use Xk3RbSpamex::S01CheckPreconditions;
use Xk3RbSpamex::S02GenerateFolds;
use Xk3RbSpamex::S11FitModel;
use Xk3RbSpamex::S12EvaluateModel;


# ............................................................................


my $subprogram = shift @ARGV;

do {
    no strict;
    &{ $subprogram }( @ARGV );
    use strict;
};
