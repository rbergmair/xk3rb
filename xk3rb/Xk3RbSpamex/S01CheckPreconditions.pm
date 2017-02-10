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


package Xk3RbSpamex::S01CheckPreconditions;


# ............................................................................


use English;
use Carp;

use Carp::Assert;
use Try::Tiny;


# ............................................................................


use Digest::MD5;
use File::Basename;


# ............................................................................


use Xk3RbSpamex::Xk3RbSpamex::Xk3RbSpamexIOUtils;


# ............................................................................


use namespace::autoclean -except => qw( import );
use Exporter qw( import );
our @EXPORT = qw( s01_check_preconditions );


# ............................................................................


sub _md5 {

    assert( not wantarray );
    assert( @_ == 1 );
    my ( $fn ) = @_;
    assert( defined $fn );

    $fn = "$fn";
    assert( $fn );

    my $digest = undef;

    open my $f, '<', $fn  or croak "$OS_ERROR";

    try {

        my $digest_ = Digest::MD5->new();
        $digest_->addfile( $f );
        $digest = $digest_->hexdigest();

    }
    catch {

        croak $_;

    }
    finally {

        close $f  or croak "$OS_ERROR";

    };

    assert( ( length $digest ) == 32 );

    return scalar $digest;

};


sub _validate_training_and_fetched {

    assert( not wantarray );
    assert( @_ == 1 );
    my ( $dtadir ) = @_;
    assert( defined $dtadir );

    $dtadir = "$dtadir";
    assert( $dtadir );


    assert( -r 'xk3rb_dta/training.txt' );
    say 'found training data in xk3rb_dta/training.txt';

    assert( -d "$dtadir/fetched" );
    say "found fetched data in $dtadir/fetched";


    say 'validating training data against fetched data...';

    assert( -r "$dtadir/fetched/training.txt" );

    assert(
            _md5( 'xk3rb_dta/training.txt' )
        eq  _md5( "$dtadir/fetched/training.txt" )
      );


    my $spamlabel_by_domain_ref
      = load_spamlabels_from_file( 'xk3rb_dta/training.txt' );


    my $missing_among_fetched_cnt = 0;
    my %domains = ();
    my $total_checked = 0;

    for my $domain ( keys %$spamlabel_by_domain_ref ) {

        $domains{ $domain } = 1;        

        if ( not ( -r "$dtadir/fetched/$domain" ) ) {
            say "file $dtadir/fetched/$domain is missing.";
            $missing_among_fetched_cnt += 1;
        };

        $total_checked += 1;

    };

    assert( $total_checked );


    my $missing_in_training_cnt = 0;

    $total_checked = 0;

    for my $fn ( glob("$dtadir/fetched/*") ) {

        $fn = basename($fn);
        
        if ( not $domains{$fn} ) {
            say "training data for $fn is missing.";
            $missing_in_training_cnt += 1;
        };
        
        $total_checked += 1;

    };

    assert( $total_checked );


    if ( $missing_among_fetched_cnt ) {
        say "$missing_among_fetched_cnt are missing among the fetched files.";
    };

    if ( $missing_in_training_cnt ) {
        say "$missing_in_training_cnt are missing in training data.";
    };

    # assert(
    #     not ( $missing_among_fetched_cnt or $missing_in_training_cnt )
    #   );


    say 'done.  training data & fetched data looks valid.';

    return scalar undef;

};


sub _validate_misc {

    assert( not wantarray );
    assert( @_ == 1 );
    my ( $dtadir ) = @_;
    assert( defined $dtadir );

    $dtadir = "$dtadir";
    assert( $dtadir );

    say 'validating further preconditions...';

    assert( -d "$dtadir/filters" );

    say 'done.  further preconditions check out.';

    return scalar undef;

};


sub s01_check_preconditions {

    assert( not wantarray );
    assert( @_ == 1 );
    my ( $dtadir ) = @_;
    assert( defined $dtadir );

    $dtadir = "$dtadir";
    assert( $dtadir );

    _validate_training_and_fetched( $dtadir );
    _validate_misc( $dtadir );

    return scalar undef;

};


# ............................................................................


1;
