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


package Xk3RbSpamex::FilterFun::Preprocessor;


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


use HTML::TreeBuilder 5 -weak;
use URI;


# ............................................................................


# project-internal imports go here


# ............................................................................


has '_tree'
  =>  ( is => 'rw',
        default => undef,
        init_arg => undef );

has '_domain'
  =>  ( is => 'rw',
        default => undef,
        init_arg => undef );


# ............................................................................


sub init {

    assert( not wantarray );
    assert( @_ == 3 );
    my ( $self, $domain, $input_html ) = @_;
    assert( defined $self );
    assert( defined $domain );
    assert( defined $input_html );
    assert( $domain );
    assert( $input_html );

    $self->_domain( $domain );

    my $tree = HTML::TreeBuilder->new_from_content( $input_html );

    for my $node ( $tree->look_down( "_tag", "script" ) ) {
        $node->delete();
    };

    for my $node ( $tree->look_down( "_tag", "noscript" ) ) {
        $node->delete();
    };

    for my $node ( $tree->look_down( "_tag", "style" ) ) {
        $node->delete();
    };

    $tree->objectify_text();

    $self->_tree( $tree );

    return scalar undef;

};


sub get_outgoing_links {

    assert( wantarray );
    assert( @_ == 1 );
    my ( $self ) = @_;
    assert( defined $self );

    my @nodes
        = $self->_tree->look_down(
              sub {
                  my ( $node ) = @_;
                  if ( $node->attr( "href" ) ) {
                      return 1;
                  };
                  if ( $node->attr( "src" ) ) {
                      return 1;
                  };
                  return 0;
              }
            );

    my @links_ = ();

    for my $node ( @nodes ) {

        my $href = $node->attr( "href" );
        my $src = $node->attr( "src" );

        if ( $href ) {
            push @links_, $href;
        };

        if ( $src ) {
            push @links_, $src;
        };

    };

    my $domain = $self->_domain;
    my $baseuri = URI->new( "http://$domain/" );

    my %links = ();

    for my $link ( @links_ ) {

        my $absuri_host = undef;

        try {
            my $reluri = URI->new( $link );
            my $absuri = $reluri->abs( $baseuri );
            $absuri_host = $absuri->host;
        }
        catch {
            $absuri_host = undef;
        };

        if ( not $absuri_host ) {
            next;
        };

        $absuri_host = lc $absuri_host;

        if ( $absuri_host =~ /^www\..*/ ) {
            $absuri_host = substr $absuri_host, length('www.');
        };

        $links{ $absuri_host } = 1;

    };

    return keys %links;

};


sub get_words {

    assert( wantarray );
    assert( @_ == 1 );
    my ( $self ) = @_;
    assert( defined $self );

    my %words = ();

    for my $node ( $self->_tree->look_down( "_tag", "~text" ) ) {
        for my $word ( split ' ', $node->attr( "text" ) ) {

            $word = uc $word;

            while ( length($word) > 0 ) {
                my $firstch = substr $word, 0, 1;
                if ( $firstch =~ /[A-Z]/ ) {
                    last;
                };
                if ( $firstch =~ /[0-9]/ ) {
                    last;
                };
                $word = substr $word, 1;
            };

            while ( length($word) > 0 ) {
                my $lastch = substr $word, -1;
                if ( $lastch =~ /[A-Z]/ ) {
                    last;
                };
                if ( $lastch =~ /[0-9]/ ) {
                    last;
                };
                $word = ( substr $word, 0, (length($word)-1) );                
            };

            if ( length($word) == 0 ) {
                next;
            };

            if ( length($word) > 20 ) {
                next;
            };

            $words{ $word } = 1;

        };
    };

    return keys %words;

};


# ............................................................................


sub to_str { assert(0); };
sub to_int { assert(0); };
sub to_bool { assert(0); };
sub to_regex { assert(0); };

__PACKAGE__->meta->make_immutable;

1;
