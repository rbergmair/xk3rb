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


package Xk3RbSpamex::FilterFun::FilterForSpamex;


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


use Xk3RbSpamex::FilterFun::Preprocessor;


# ............................................................................


has '_positive_count_by_feature'
  =>  ( is => 'rw',
        default => sub { {} },
        init_arg => undef );

has '_positive_total'
  =>  ( is => 'rw',
        default => 0,
        init_arg => undef );  

has '_negative_count_by_feature'
  =>  ( is => 'rw',
        default => sub { {} },
        init_arg => undef );

has '_negative_total'
  =>  ( is => 'rw',
        default => 0,
        init_arg => undef );  

has '_bayesian_weight_by_feature'
  =>  ( is => 'rw',
        default => sub { {} },
        init_arg => undef );

has '_bayesian_bias_term'
  =>  ( is => 'rw',
        default => undef,
        init_arg => undef );


# ............................................................................


sub init {

    assert( not wantarray );
    assert( @_ == 1 );
    my ( $self ) = @_;
    assert( defined $self );
    
    return scalar undef;
    
};


sub ingest_for_training {

    assert( not wantarray );
    assert( @_ == 4 );
    my ( $self, $domain, $fetched_data, $is_spam ) = @_;
    assert( defined $self );
    assert( defined $domain );
    assert( $domain );
    assert( defined $fetched_data );
    assert( $fetched_data );
    assert( defined $is_spam );

    # say "received $domain for training.";
    # say '  length(fetched_data): ', length($fetched_data);
    # say '  is_spam: ', $is_spam;
    # say q();

    my $pp = Xk3RbSpamex::FilterFun::Preprocessor->new();
    $pp->init( $domain, $fetched_data );

    my @outgoing_links = $pp->get_outgoing_links();
    my @words = $pp->get_words();

    for my $feature ( @outgoing_links, @words ) {

        if ( $is_spam ) {

            my $cnt
              = ( $self->_positive_count_by_feature->{ $feature } or 0 );
            $self->_positive_count_by_feature->{ $feature } = $cnt + 1;

            if ( not ( defined $self->_negative_count_by_feature->{ $feature } ) ) {
                $self->_negative_count_by_feature->{ $feature } = 0;
            };

        }
        else {

            my $cnt
              = ( $self->_negative_count_by_feature->{ $feature } or 0 );
            $self->_negative_count_by_feature->{ $feature } = $cnt + 1;

            if ( not ( defined $self->_positive_count_by_feature->{ $feature } ) ) {
                $self->_positive_count_by_feature->{ $feature } = 0;
            };

        };

    };

    if ( $is_spam ) {
        my $total
          = ( $self->_positive_total or 0 );
        $self->_positive_total( $total + 1 );
    }
    else {
        my $total
          = ( $self->_negative_total or 0 );
        $self->_negative_total( $total + 1 );
    };

    return scalar undef;

};


sub dump_to_file {

    assert( not wantarray );
    assert( @_ == 2 );
    my ( $self, $model_fn ) = @_;
    assert( defined $self );
    assert( defined $model_fn );
    assert( $model_fn );

    my $total_pos = $self->_positive_total;
    my $total_neg = $self->_negative_total;

    assert ( $total_pos > 0 );
    assert ( $total_neg > 0 );

    open my $model_f, '> :encoding(UTF-8)', $model_fn  or croak "$OS_ERROR";

    try {

        for my $feature ( keys %{ $self->_positive_count_by_feature } ) {

            my $pos_cnt = ( $self->_positive_count_by_feature->{ $feature } );
            my $neg_cnt = ( $self->_negative_count_by_feature->{ $feature } );

            if ( ( $pos_cnt + $neg_cnt ) <= 2 ) {
                next;
            };

            assert( index( $feature, "\t" ) == -1 );
            assert( index( $feature, "\n" ) == -1 );
            print {$model_f} "$feature\t$pos_cnt\t$neg_cnt\n";

        };

        print {$model_f} "T O T A L\t$total_pos\t$total_neg\n";

    }
    catch {

        croak $_;

    }
    finally {

        close $model_f  or croak "$OS_ERROR";

    };

    return scalar undef;

};


sub load_from_file {

    assert( not wantarray );
    assert( @_ == 2 );
    my ( $self, $model_fn ) = @_;
    assert( defined $self );
    assert( defined $model_fn );
    assert( $model_fn );

    open my $model_f, '< :encoding(UTF-8)', $model_fn  or croak "$OS_ERROR";

    try {

        while ( my $model_ln = <$model_f> ) {

            chomp $model_ln;

            my ( $feature, $pos_cnt_, $neg_cnt_, $rest_ )
                = split "\t", $model_ln, 4;

            assert( not $rest_ );

            my $pos_cnt = int( $pos_cnt_ + 0 );
            assert( "$pos_cnt" eq $pos_cnt_ );

            my $neg_cnt = int( $neg_cnt_ + 0 );
            assert( "$neg_cnt" eq $neg_cnt_ );

            if ( $feature ne "T O T A L" ) {
                $self->_positive_count_by_feature->{ $feature } = $pos_cnt;
                $self->_negative_count_by_feature->{ $feature } = $neg_cnt;
            }
            else {
                assert ( $pos_cnt > 0 );
                assert ( $neg_cnt > 0 );
                $self->_positive_total( $pos_cnt );
                $self->_negative_total( $neg_cnt );
            };

        };

    }
    catch {

        croak $_;

    }
    finally {

        close $model_f  or croak "$OS_ERROR";

    };

    return scalar undef;

};


sub _determine_bayesian_weights_by_feature {

    assert( not wantarray );
    assert( @_ == 1 );
    my ( $self ) = @_;
    assert( defined $self );

    my $smoothing_alpha = 0.02;
    my $smoothing_d = 50.0;
    my $bias_fudgefactor = -100.0;

    my $pos_total = $self->_positive_total;
    my $neg_total = $self->_negative_total;

    my %bayesian_weight_by_feature = ();
    my $bayesian_bias_term = $bias_fudgefactor;

    for my $feature ( keys %{ $self->_positive_count_by_feature } ) {

        my $pos_cnt = ( $self->_positive_count_by_feature->{ $feature } );
        my $neg_cnt = ( $self->_negative_count_by_feature->{ $feature } );

        assert ( ( $pos_cnt + $neg_cnt ) > 2 );

        my $p
          =    ( $pos_cnt + $smoothing_alpha )
             / ( $pos_total + $smoothing_d * $smoothing_alpha );

        my $q
          =    ( $neg_cnt + $smoothing_alpha )
             / ( $neg_total + $smoothing_d * $smoothing_alpha );

        my $w 
          = log(
                  ( $p * ( 1.0 - $q ) )
                / ( $q * ( 1.0 - $p ) )
              );

        $bayesian_weight_by_feature{ $feature } = $w;

        $bayesian_bias_term += log( ( 1.0 - $p ) / ( 1.0 - $q ) );      

    };

    $self->_bayesian_weight_by_feature( \%bayesian_weight_by_feature );
    $self->_bayesian_bias_term( $bayesian_bias_term );

    return scalar undef;

};


sub apply_filter {

    assert( not wantarray );
    assert( @_ == 3 );
    my ( $self, $domain, $fetched_data ) = @_;
    assert( defined $self );

    if ( not %{ $self->_bayesian_weight_by_feature() } ) {
        $self->_determine_bayesian_weights_by_feature();
    };
    assert ( %{ $self->_bayesian_weight_by_feature() } );

    # say "received $domain for evaluation.";
    # say '  length(fetched_data): ', length($fetched_data);

    my $pp = Xk3RbSpamex::FilterFun::Preprocessor->new();
    $pp->init( $domain, $fetched_data );

    my @outgoing_links = $pp->get_outgoing_links();
    my @words = $pp->get_words();

    my $weight = $self->_bayesian_bias_term;

    for my $feature ( @outgoing_links, @words ) {

        $weight
          += ( $self->_bayesian_weight_by_feature->{ $feature } or 0.0 );

    };

    my $result = ( $weight > 0.0 );

    if ( $result ) {
        # say '  is_spam: 1';
        # say q();
        return scalar 1;
    }
    
    # say '  is_spam: 0';
    # say q();
    return scalar 0;

};


# ............................................................................


sub to_str { assert(0); };
sub to_int { assert(0); };
sub to_bool { assert(0); };
sub to_regex { assert(0); };

__PACKAGE__->meta->make_immutable;

1;
