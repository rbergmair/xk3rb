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


package Xk3RbSpamex::FilterFun::Evaluator;


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


has 'true_positives'
  =>  ( is => 'rw',
        default => 0,
        init_arg => undef );

has 'true_negatives'
  =>  ( is => 'rw',
        default => 0,
        init_arg => undef );  

has 'false_positives'
  =>  ( is => 'rw',
        default => 0,
        init_arg => undef );

has 'false_negatives'
  =>  ( is => 'rw',
        default => 0,
        init_arg => undef );


# ............................................................................


sub init {

    assert( not wantarray );
    assert( @_ == 1 );
    my ( $self ) = @_;
    assert( defined $self );

    return scalar undef;
    
};


sub ingest_for_evaluation {

    assert( not wantarray );
    assert( @_ == 3 );
    my ( $self, $correct_label, $model_label ) = @_;
    assert( defined $self );
    assert( defined $correct_label );
    assert( ( $correct_label == 0 ) or ( $correct_label == 1 ) );
    assert( defined $model_label );
    assert( ( $model_label == 0 ) or ( $model_label == 1 ) );

    if ( $model_label == 1 ) {
        if ( $correct_label == 1 ) {
            $self->true_positives( $self->true_positives + 1 );
        }
        else {
            $self->false_positives( $self->false_positives + 1 );
        };
    }
    else {
        if ( $correct_label == 1 ) {
            $self->false_negatives( $self->false_negatives + 1 );
        }
        else {
            $self->true_negatives( $self->true_negatives + 1 );
        };
    }

    return scalar undef;

};


sub total {

    assert( not wantarray );
    assert( @_ == 1 );
    my ( $self ) = @_;
    assert( defined $self );

    return scalar (
          $self->true_positives
        + $self->true_negatives
        + $self->false_positives
        + $self->false_negatives
      );

};


sub dataset_bias {

    assert( not wantarray );
    assert( @_ == 1 );
    my ( $self ) = @_;
    assert( defined $self );

    return scalar (
          ( $self->true_positives + $self->false_negatives )
        /   $self->total
      );

};


sub model_bias {

    assert( not wantarray );
    assert( @_ == 1 );
    my ( $self ) = @_;
    assert( defined $self );

    return scalar (
          ( $self->true_positives + $self->false_positives )
        /   $self->total
      );

};


sub accuracy {

    assert( not wantarray );
    assert( @_ == 1 );
    my ( $self ) = @_;
    assert( defined $self );

    return scalar (
          ( $self->true_positives + $self->true_negatives ) 
        /   $self->total
      );

};


sub precision {

    assert( not wantarray );
    assert( @_ == 1 );
    my ( $self ) = @_;
    assert( defined $self );

    return scalar (
            $self->true_positives
        / ( $self->true_positives + $self->false_positives )
      );

};


sub recall {

    assert( not wantarray );
    assert( @_ == 1 );
    my ( $self ) = @_;
    assert( defined $self );

    return scalar (
            $self->true_positives
        / ( $self->true_positives + $self->false_negatives )
      );

};


sub fmeasure {

    assert( not wantarray );
    assert( @_ == 1 );
    my ( $self ) = @_;
    assert( defined $self );

    return scalar (
        2.0
          * (   ( $self->precision * $self->recall )
              / ( $self->precision + $self->recall ) )
      );

};


sub say_report {

    assert( not wantarray );
    assert( @_ == 1 );
    my ( $self ) = @_;
    assert( defined $self );

    say "--";
    say "total:           ", sprintf(    "%d", scalar $self->total );
    say "true_positives:  ", sprintf(    "%d", scalar $self->true_positives );
    say "false_positives: ", sprintf(    "%d", scalar $self->false_positives );
    say "true_negatives:  ", sprintf(    "%d", scalar $self->true_negatives );
    say "false_negatives: ", sprintf(    "%d", scalar $self->false_negatives );
    say "dataset_bias:    ", sprintf( "%1.4f", scalar $self->dataset_bias );
    say "model_bias:      ", sprintf( "%1.4f", scalar $self->model_bias );
    say "accuracy:        ", sprintf( "%1.4f", scalar $self->accuracy );
    say "precision:       ", sprintf( "%1.4f", scalar $self->precision );
    say "recall:          ", sprintf( "%1.4f", scalar $self->recall );
    say "fmeasure:        ", sprintf( "%1.4f", scalar $self->fmeasure );
    say q();

    return scalar undef;

};


# ............................................................................


sub to_str { assert(0); };
sub to_int { assert(0); };
sub to_bool { assert(0); };
sub to_regex { assert(0); };

__PACKAGE__->meta->make_immutable;

1;
