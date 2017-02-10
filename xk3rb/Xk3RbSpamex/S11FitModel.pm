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


package Xk3RbSpamex::S11FitModel;


# ............................................................................


use English;
use Carp;

use Carp::Assert;
use Try::Tiny;


# ............................................................................


use Xk3RbSpamex::Xk3RbSpamex::Xk3RbSpamexIOUtils;
use Xk3RbSpamex::FilterFun::FilterForSpamex;


# ............................................................................


use namespace::autoclean -except => qw( import );
use Exporter qw( import );
our @EXPORT = qw( s11_fit_model );


# ............................................................................


sub s11_fit_model {

    assert( not wantarray );
    assert( @_ == 2 );
    my ( $dtadir_, $omittable_fold_ ) = @_;
    assert( defined $dtadir_ );

    my $dtadir = "$dtadir_";
    assert( $dtadir );

    my $omittable_fold = int( $omittable_fold_ + 0 );
    assert( "$omittable_fold" eq $omittable_fold_ );
    assert( scalar grep { $_ == $omittable_fold } (1,2,3,4,5,6,7,8,9,10) );

    assert(
        not ( -e "$dtadir/filters/filter_for_spamex_${omittable_fold}.txt" )
      );


    say "fitting model for fold ${omittable_fold}...";


    my $spamlabel_by_domain_ref
      = load_spamlabels_from_file( 'xk3rb_dta/training.txt' );

    my $fold_by_domain_ref
      = load_folds_from_file( 'xk3rb_dta/folds.txt' );


    my $filter_for_spamex
      = Xk3RbSpamex::FilterFun::FilterForSpamex->new();
    $filter_for_spamex->init();

    while ( my ( $domain, $fold ) = each %$fold_by_domain_ref ) {

        if ( $fold == $omittable_fold ) {
            next;
        };

        my $spamlabel = $spamlabel_by_domain_ref->{ $domain };

        my $fetched_data
          = load_fetched_data_from_file( "$dtadir/fetched/$domain" );

        if ( not $fetched_data ) {
            next;
        };

        $filter_for_spamex->ingest_for_training(
            $domain, $fetched_data, $spamlabel
          );

    };

    $filter_for_spamex->dump_to_file(
        "$dtadir/filters/filter_for_spamex_${omittable_fold}.txt"
      );


    say
      "done.  ",
      "saved model data in ",
      "$dtadir/filters/filter_for_spamex_${omittable_fold}.txt";


    return scalar undef;

};


# ............................................................................


1;
