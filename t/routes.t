#!/usr/bin/perl

# Test REST routing
use strict;
use warnings;
use English qw( -no_match_vars );
use Test::More tests => 8;
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

$mech->get('http://localhost/foo');
$mech->title_is('No parameters', 'route with no parameters');

$mech->get('http://localhost/bar/mark/76/mark@stosberg.com');
$mech->title_is('mark@stosberg.com mark 76', 'route with parameters');

$mech->get('http://localhost/bar/mark/mark@stosberg.com');
$mech->title_is('mark@stosberg.com mark', 'route with a missing parameter');

eval {
    $mech->get('http://localhost/bar/mark/76/mark@stosberg.com?nodispatch=1');
};
ok(defined $EVAL_ERROR, 'no dispatch table');

$mech->get('http://localhost/bogus/mark/76/mark@stosberg.com');
$mech->title_is('default', 'non-existent route');

$mech->get('http://localhost/baz/string/good/');
$mech->title_is('good', 'route with a wildcard parameter');

$mech->get('http://localhost/baz/string/evil/');
$mech->title_is('evil', 'route with a a different wildcard parameter');

$mech->get('http://localhost/quux');
$mech->title_is('xARRAYx', 'rest_route return value');
