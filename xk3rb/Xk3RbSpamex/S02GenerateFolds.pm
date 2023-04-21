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


package Xk3RbSpamex::S02GenerateFolds;


# ............................................................................


use English;
use Carp;

use Carp::Assert;
use Try::Tiny;


# ............................................................................


use Xk3RbSpamex::Xk3RbSpamex::Xk3RbSpamexIOUtils;


# ............................................................................


use namespace::autoclean -except => qw( import );
use Exporter qw( import );
our @EXPORT = qw( s02_generate_folds );


# ............................................................................


sub _domains {

    assert( not wantarray );
    assert( @_ == 1 );
    my ( $dtadir ) = @_;
    assert( defined $dtadir );

    $dtadir = "$dtadir";
    assert( $dtadir );


    my $spamlabel_by_domain_ref
      = load_spamlabels_from_file( 'xk3rb_dta/training.txt' );

    my @domains = ();

    for my $domain ( keys %$spamlabel_by_domain_ref ) {

        if ( $domain eq "4ewaste.com" ) {
            next;
        };

        if ( $domain eq "poynter.org" ) {
            next;
        };

        if ( -r "$dtadir/fetched/$domain" ) {
            push @domains, $domain;
        };

    };


    return scalar \@domains;

};


sub _generate_folds {

    assert( not wantarray );
    assert( @_ == 1 );
    my ( $dtadir ) = @_;
    assert( defined $dtadir );

    $dtadir = "$dtadir";
    assert( $dtadir );

    assert( not ( -e 'xk3rb_dta/folds.txt' ) );


    say 'generating folds...';

    my $domains_ref = _domains( $dtadir );
    generate_folds_to_file( 'xk3rb_dta/folds.txt', $domains_ref );
    
    say 'done.  saved folds data in xk3rb_dta/folds.txt';


    return scalar undef;

};


sub _validate_folds {

    assert( not wantarray );
    assert( @_ == 1 );
    my ( $dtadir ) = @_;
    assert( defined $dtadir );

    $dtadir = "$dtadir";
    assert( $dtadir );

    assert( -r 'xk3rb_dta/folds.txt' );
    say 'found folds data in xk3rb_dta/folds.txt';


    say 'validating folds data...';

    my $domains_ref = _domains( $dtadir );
    my $fold_by_domain_ref = load_folds_from_file( 'xk3rb_dta/folds.txt' );

    for my $domain ( keys %$fold_by_domain_ref ) {
        assert( scalar grep { $_ eq $domain } @$domains_ref );
    };
    for my $domain ( @$domains_ref ) {
        assert( $fold_by_domain_ref->{ $domain } );
    };

    say 'done.  folds data looks valid.';


    return scalar undef;

};


sub s02_generate_folds {

    assert( not wantarray );
    assert( @_ == 1 );
    my ( $dtadir ) = @_;
    assert( defined $dtadir );

    $dtadir = "$dtadir";
    assert( $dtadir );

    if ( -r 'xk3rb_dta/folds.txt' ) {
        _validate_folds( $dtadir );
    }
    else {
        try {
            _generate_folds( $dtadir );
            _validate_folds( $dtadir );
        }
        catch {
            try { unlink 'xk3rb_dta/folds.txt' } catch {};
            croak $_;            
        };
    };

    return scalar undef;

};


# ............................................................................


1;
