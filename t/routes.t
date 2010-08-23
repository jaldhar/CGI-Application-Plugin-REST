#!/usr/bin/perl

# Test application functionality
use strict;
use warnings;
use Test::More tests => 1;
use Test::WWW::Mechanize::CGIApp;
use lib 't/lib';
use Test::CAPREST;

my $mech = Test::WWW::Mechanize::CGIApp->new;

$mech->app(
    sub {
        my $app = Test::CAPREST->new(PARAMS => {

        });
        $app->run();
    }
);

$mech->get('http://localhost/view/mark/76/mark@stosberg.com');
$mech->title_is('mark@stosberg.com mark 76', 'route with parameters');
