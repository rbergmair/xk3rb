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


package Xk3RbSpamex::S12EvaluateModel;


# ............................................................................


use English;
use Carp;

use Carp::Assert;
use Try::Tiny;


# ............................................................................


# project-external imports go here


# ............................................................................


use Xk3RbSpamex::Xk3RbSpamex::Xk3RbSpamexIOUtils;
use Xk3RbSpamex::FilterFun::FilterForSpamex;
use Xk3RbSpamex::FilterFun::Evaluator;


# ............................................................................


use namespace::autoclean -except => qw( import );
use Exporter qw( import );
our @EXPORT = qw( s12_evaluate_model );


# ............................................................................


sub s12_evaluate_model {

    assert( not wantarray );
    assert( @_ == 2 );
    my ( $dtadir_, $testing_fold_ ) = @_;
    assert( defined $dtadir_ );

    my $dtadir = "$dtadir_";
    assert( $dtadir );

    my $testing_fold = int( $testing_fold_ + 0 );
    assert( "$testing_fold" eq $testing_fold_ );
    assert( scalar grep { $_ == $testing_fold } (1,2,3,4,5,6,7,8,9,10) );

    assert( -r 'xk3rb_dta/training.txt' );
    assert( -r "$dtadir/filters/filter_for_spamex_${testing_fold}.txt" );


    say "evaluating model for fold ${testing_fold}...";


    my $spamlabel_by_domain_ref
      = load_spamlabels_from_file( 'xk3rb_dta/training.txt' );

    my $fold_by_domain_ref
      = load_folds_from_file( 'xk3rb_dta/folds.txt' );


    my $filter_for_spamex
      = Xk3RbSpamex::FilterFun::FilterForSpamex->new();
    $filter_for_spamex->init();

    my $evaluator
      = Xk3RbSpamex::FilterFun::Evaluator->new();
    $evaluator->init();

    $filter_for_spamex->load_from_file(
        "$dtadir/filters/filter_for_spamex_${testing_fold}.txt"
      );

    while ( my ( $domain, $fold ) = each %$fold_by_domain_ref ) {

        if ( $fold != $testing_fold ) {
            next;
        };

        my $correct_spamlabel
          = $spamlabel_by_domain_ref->{ $domain };

        my $fetched_data
          = load_fetched_data_from_file( "$dtadir/fetched/$domain" );

        if ( not $fetched_data ) {
            next;
        };

        my $model_spamlabel
          = $filter_for_spamex->apply_filter(
                $domain, $fetched_data
              );

        $evaluator->ingest_for_evaluation(
            $correct_spamlabel, $model_spamlabel
          );

    };


    say "done.";


    $evaluator->say_report();


    return scalar undef;

};


# ............................................................................


1;
