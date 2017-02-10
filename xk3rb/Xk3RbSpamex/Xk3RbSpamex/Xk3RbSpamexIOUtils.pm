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


package Xk3RbSpamex::Xk3RbSpamex::Xk3RbSpamexIOUtils;


# ............................................................................


use English;
use Carp;

use Carp::Assert;
use Try::Tiny;


# ............................................................................


use Encode qw( decode encode );
use Encode::Guess;


# ............................................................................


#use namespace::autoclean -except => qw( import );
use Exporter qw( import );
our @EXPORT
  = qw( load_spamlabels_from_file
        generate_folds_to_file
        load_folds_from_file
        load_fetched_data_from_file );


# ............................................................................


sub load_spamlabels_from_file {

    assert( not wantarray );
    assert( @_ == 1 );
    my ( $fn ) = @_;
    assert( defined $fn );
    assert( $fn );

    my %spamlabel_by_domain = ();

    open my $spamlabels_f, '<', $fn  or croak "$OS_ERROR";

    try {

        while ( my $spamlabels_ln = <$spamlabels_f> ) {

            chomp $spamlabels_ln;

            my ( $domain_, $is_spam_, $rest_ )
                = split "\t", $spamlabels_ln, 3;

            assert( not $rest_ );

            my $domain = $domain_;

            my $is_spam = $is_spam_ + 0;
            assert( "$is_spam" eq $is_spam_ );
            assert( ( $is_spam == 0 ) or ( $is_spam == 1 ) );            

            if ( $spamlabel_by_domain{$domain} ) {
                assert( $spamlabel_by_domain{$domain} == $is_spam )
            }
            else {
                $spamlabel_by_domain{ $domain } = $is_spam;                
            };

        };

    }
    catch {

        croak $_;

    }
    finally {

        close $spamlabels_f  or croak "$OS_ERROR";

    };

    return scalar \%spamlabel_by_domain;

};


sub generate_folds_to_file {

    assert( not wantarray );
    assert( @_ == 2 );
    my ( $fn, $domains_ref ) = @_;
    assert( defined $fn );
    assert( $fn );
    assert( defined $domains_ref );
    assert( ref $domains_ref );

    open my $folds_f, '>', $fn  or croak "$OS_ERROR";

    try {

        for my $domain ( @$domains_ref ) {

            my $fold = int( rand(10.0) + 1.0 );

            assert( index( $domain, "\t" ) == -1 );
            assert( index( $domain, "\n" ) == -1 );
            print {$folds_f} "$domain\t$fold\n";

        };

    }
    catch {

        croak $_;

    }
    finally {

        close $folds_f  or croak "$OS_ERROR";

    };

    return scalar undef;

};


sub load_folds_from_file {

    assert( not wantarray );
    assert( @_ == 1 );
    my ( $fn ) = @_;
    assert( defined $fn );
    assert( $fn );

    my %fold_by_domain = ();


    open my $folds_f, '<', $fn  or croak "$OS_ERROR";

    try {

        while ( my $folds_ln = <$folds_f> ) {

            chomp $folds_ln;

            my ( $domain_, $fold_, $rest_ )
                = split "\t", $folds_ln, 3;

            assert( not $rest_ );

            my $domain = $domain_;

            my $fold = int( $fold_ + 0 );
            assert( "$fold" eq $fold_ );
            assert( scalar grep { $_ == $fold } (1,2,3,4,5,6,7,8,9,10) );

            $fold_by_domain{ $domain } = $fold;

        };

    }
    catch {

        croak $_;

    }
    finally {

        close $folds_f  or croak "$OS_ERROR";

    };
    

    return scalar \%fold_by_domain;

};


sub load_fetched_data_from_file {

    assert( not wantarray );
    assert( @_ == 1 );
    my ( $fn ) = @_;
    assert( defined $fn );
    assert( $fn );

    my $fetched_data_ = undef;

    open my $f, '< :raw', $fn or croak "$OS_ERROR";
    binmode $f;

    try {
        $fetched_data_ = do { local $/; <$f> };
    }
    catch {
        croak $_;
    }
    finally {
        close $f  or croak "$OS_ERROR";
    };

    my $enc
      = guess_encoding( $fetched_data_, ('ascii','utf8','latin1') );

    my $fetched_data;
    if ( ref($enc) ) {
        $fetched_data = decode( $enc, $fetched_data_ );
    }
    else {
        $fetched_data = decode( "UTF-8", $fetched_data_ );
    };

    return scalar $fetched_data;

};


# ............................................................................


1;
