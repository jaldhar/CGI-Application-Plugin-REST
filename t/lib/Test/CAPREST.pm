package Test::CAPREST;
use strict;
use warnings;
use base 'CGI::Application';
use CGI::Application::Plugin::REST qw( :all );

sub setup {
    my ($self) = @_;

    $self->run_modes([ 'default' ]);
    $self->start_mode('default');

#    $self->rest_route(
#        foo             => 'wibble',
#        bar             => \&wobble,
#        '/app/baz'      => 'woop',
#        '/app/quux'     => {
#            GET    => 'ptang',
#            DELETE => 'krrang',
#        },
#        '/app/edna'     => {
#            POST   => 'blip',
#            '*'    => 'blop',
#        },
#        '/app/grudnuk'  => {
#            GET   => {
#                'application/xml' => 'zip',
#                '*/*'             => 'zap',
#            },
#            PUT   => {
#                'application/xml' => 'zoom',
#            },
#        },
#    );

    if (defined $self->query->param('bogusdispatch')) {
        $self->rest_route( '/baz/string/*/' );
    }
    elsif (!defined $self->query->param('nodispatch')) {
        # Remember to change rest_route_return_value test in t/routes.t
        # when you change number of routes here. (add 1 for default '/'.)
        my $routes = {
            '/foo'                    => 'foo',
            '/bar/:name/:id?/:email'  => 'bar',
        };
        $self->rest_route($routes);
        $self->rest_route(
            '/baz/string/*/'          => 'baz',
            '/quux'                   => 'quux',
        );
    }

    return;
}

sub default {
    my ($self) = @_;

    my $q = $self->query;

    return $q->start_html('default') .
           $q->end_html;
}

sub foo {
    my ($self) = @_;

    my $q = $self->query;

    return $q->start_html('No parameters') .
           $q->end_html;
}

sub bar {
    my ($self) = @_;

    my $q = $self->query;

    my $title = join q{ }, ($q->param('email'), $q->param('name'),
        $q->param('id'));
    return $q->start_html($title) .
           $q->end_html;
}

sub baz {
    my ($self) = @_;

    my $q = $self->query;

    my $title = $q->param('dispatch_url_remainder');
    return $q->start_html($title) .
           $q->end_html;
}

sub quux {
    my ($self) = @_;

    my $q = $self->query;

    my $title = scalar keys %{ $self->rest_route };
    return $q->start_html($title) .
           $q->end_html;
}

1;
