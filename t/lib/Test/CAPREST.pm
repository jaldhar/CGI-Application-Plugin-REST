package Test::CAPREST;
use strict;
use warnings;
use base 'CGI::Application';
use CGI::Application::Plugin::REST qw( :all );

sub setup {
    my ($self) = @_;
    
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

    $self->rest_route(['/view/:name/:id/:email'  => 'view',]);
    return;
}

sub view {
    my ($self) = @_;

    my $q = $self->query;

    my $title = join q{ }, ($q->param('email'), $q->param('name'),
        $q->param('id'));
    return $q->start_html($title) .
           $q->end_html;
}

1;
