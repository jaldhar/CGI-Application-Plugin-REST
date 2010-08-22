
=head1 NAME

CGI::Application::Plugin::REST - Helps implement RESTful architecture in CGI applications

=head1 SYNOPSIS

    use CGI::Application::Plugin::REST;
    my $app = CGI::Application::Plugin::REST->new();
    $app->run();

=head1 ABSTRACT

If you use the L<CGI::Application> framework, this plugin will help you create
a RESTful (that's the common term for "using REST") architecture by
abstracting out a lot of the busy work needed to make it happen.

=cut

package CGI::Application::Plugin::REST;

use warnings;
use strict;
use Carp qw( croak );
use English qw/ -no_match_vars /;
use List::Util qw/ first /;

=head1 VERSION

This document describes CGI::Application::Plugin::REST Version 0.1

=cut

our $VERSION = '0.1';

our @EXPORT_OK = qw/ rest_route /;

our %EXPORT_TAGS = ( 'all' => [@EXPORT_OK] );

=head1 DESCRIPTION

REST stands for REpresentational State Transfer. It is an architecture for web
applications that tries to leverage the existing infrastructure of the World
Wide Web such as URIs. MIME media types and HTTP instead of building up
protocols and functions on top of them.

This plugin contains a number of functions to support the various REST
concepts. They try to use existing L<CGI::Application> functionality
wherever possible.

C<use>'ing this plugin will override L<CGI::Application>s' standard dispatch
mechanism.  Instead of being selected based on a query parameter like C<rm>,
the run mode will be determined by the C<PATH_INFO> information in a URL.

=head1 FUNCTIONS

The following functions are available.

=cut

# Plug in to CGI::Application and setup our callbacks
#
sub import {
    my $caller = scalar caller;

    $caller->add_callback(
        'init',
        sub {
            my ($self) = @_;
            $self->mode_param( \&_rest_dispatch );

            return;
        }
    );
    goto &Exporter::import;
}

sub _rest_dispatch {
    my ( $self, $run_mode ) = @_;

    return;
}

=head3 rest_route()

This function configures the mapping of URIs to methods within your
L<CGI::Application>.  The mapping can be specified in several different
styles.  Assume for the purpose of the following examples that your
instance script has a base URI of C<http://localhost/app>

HINT: Your web server might not execute CGI scripts unless they have an
extension of .cgi so your actual script might be C<http://localhost/app.cgi>.
However it is considered unRESTful to include infrastructural details in your
URLs.  Use your web servers URL rewriting features (i.e. mod_rewrite in
Apache) to hide the extension.

Example 1: arrayref

    $self->rest_route( [ qw/ foo bar baz / ] );

The most basic style is to specify an arrayref where each of the elements will 
represent the first part of C<PATH_INFO> (i.e. upto the first '/' not counting
the leading '/') This will be combined with the base URI.  Requests to the
resulting URI will be dispatched to a method in your module named
E<lt>elementE<gt>

For example a request to C<http://localhost/app/foo> will be dispatched to
C<foo()>.  (It is upto you to make sure such a method exists.)  A request to
C<http://localhost/app/baz> will dispatch to C<baz> and so on.

If you pass a hash as the parameter to C<rest_route> more complex mappings are
possible, depending on the form of the keys and values of the hash.

Example 2: hash

    $self->rest_route(
        foo             => 'wibble',
        bar             => \&wobble,
        '/app/baz'      => 'woop',
        '/app/quux'     => {
            GET    => 'ptang',
            DELETE => 'krrang',
        },
        '/app/edna'     => {
            POST   => 'blip',
            '*'    => 'blop',
        },
        '/app/grudnuk'  => {
	        GET    => {
                'application/xml' => 'zip',
                '*/*'             => 'zap',
            },
            PUT    => {
                'application/xml' => 'zoom',
	        },
        },
    );

If the key is a single word, it will represent the first path segment of
C<PATH_INFO> as in Example 1.  The value can be a scalar which is the name of
a method or a coderef.

In example 2, a request to C<http://localhost/app/foo> will be dispatched to
the method C<wibble()>.  A request to C<http://localhost/app/bar> will
dispatch to C<wobble()> and so on.

If the key is a path (which for the purposes of this module is defined as a
scalar that begins with a '/') it will be matched against C<PATH_INFO>.  The
match must be exact.  if the value is a scalar or a coderef the corresponding
method will be dispatched to.

In example 2, a request to C<http://localhost/app/baz> will be dispatched to
C<woop()>.

If the value is a hash, the keys of the second-level hash are HTTP methods and
the values if scalars or coderefs, are functions to be dispatched to.  The key
can also be * which matches all methods not explicitly specified.  If a valid
method cannot be matched, an error is raised and the HTTP status of the
response is set to 405.  (See L<"DIAGNOSTICS">)

In example 2, a C<GET> request to C<http://localhost/app/quux> will be
dispatched to C<ptang()>.  A C<DELETE> to C<http://localhost/app/quux> will
dispatch to C<krrang()>.  A C<POST>, C<PUT> or C<HEAD> will cause an error.

A C<POST> request to C<http://localhost/app/edna> will dispatch to C<zip()>
while any other type of request to that URL will dispatch to C<blop()>

The values of the second-level hash can also be hashes.  In this case the keys
of the third-level hash represent MIME media types.  The values can be scalars
representing names of methods or coderefs.  The best possible match is made
according to the HTTP Accept header sent in the request.  The string ' * /*'
matches any MIME media type.  If a valid MIME media type cannot be matched an
error is raised and the HTTP status of the response is set to 415.  (See
L<"DIAGNOSTICS">)

In example 2, a C<GET> request to C<http://localhost/ app/grudnuk> with MIME
media type application / xml will dispatch to C<zip()>. If the same request is
made with any other MIME media type, the method C <zap()> will be called
instead. A C <PUT> request made to the same URL with MIME media type
application/xml will dispatch to C <zoom()>. Any other MIME media type will
cause an error to be raised.

Instead of a hash, you can use a hashref as in example 3.

Example 3 :

    my $routes = {
        foo             => 'wibble',
        bar             => \&wobble,
        '/app/baz'      => 'woop',
        '/app/quux'     => {
            GET    => 'ptang',
            DELETE => 'krrang',
        },
        '/app/edna'     => {
            POST   => 'blip',
            '*'    => 'blop',
        },
        '/app/grudnuk'  => {
	        GET    => {
                'application/xml' => 'zip',
                '*/*'             => 'zap',
            },
            PUT    => {
                'application/xml' => 'zoom',
	        },
        },
    );

    $self->rest_route( $routes );


If no URI can be matched, an error is raised and the HTTP status of the 
response is set to 400 (See L<"DIAGNOSTICS">.)

=cut

sub rest_route {
    my ( $self, @params ) = @_;

    # First use?  Create new __rest_dispatch_table.
    if ( !exists $self->{__rest_dispatch_table} ) {
        $self->{__rest_dispatch_table} = {};
    }

    return $self->{_rest_dispatch_table};
}

=head1 DIAGNOSTICS

During the dispatch process, errors can occur in certain circumstances. Here
is a list along with status codes and messages.

=over 4

=item * 400 Bad Request '$param'

The path info passed to the script is in the wrong format from that specified
in L<"rest_route()">.  C<$param> will contain the segment of path info that 
failed to match.

=item * 405 Method '$method' not Allowed

The route you specified with L<"rest_route()"> does not allow this HTTP request
method.  An HTTP C<Allow> header is added to the response specifying which
methods can be used.

=item * 500 Application Error

The function that has been called for this run_mode C<die>'d somewhere.

=item * 501 Function Doesn't Exist

The function that you wanted to call from L<"rest_route()"> for this run_mode
doesn't exist in your application.

=back

=head1 BUGS AND LIMITATIONS

There are no known problems with this module.

Please report any bugs or feature requests to
C<bug-cgi-application-plugin-rest at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=CGI-Application-Plugin-REST>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SEE ALSO

=over 4

=item * L<CGI::Application>:

The application framework this module plugs into.

=item * L<REST::Application>:

This module by Matthew O'Connor gave me some good ideas.

=item * L<CGI::Application::Dispatch>:

A L<CGI::Application> helper that also does URI based function dispatch and a
lot more. If you find you are running into limitations with this module, you
should look at L<CGI::Application::Dispatch>.

=item * L<http://www.ics.uci.edu/~fielding/pubs/dissertation/top.htm>:

Roy Fieldings' doctoral thesis in which the term REST was first defined.

=item * L<http://www.xml.com/pub/at/34>

"The Restful Web" columns by Joe Gregorio have been very useful to me in
understanding the ins and outs of REST.

=back

=head1 AUTHOR

Jaldhar H. Vyas, C<< <jaldhar at braincells.com> >>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2010 Consolidated Braincells Inc., all rights reserved.

This distribution is free software; you can redistribute it and/or modify it
under the terms of either:

a) the GNU General Public License as published by the Free Software
Foundation; either version 2, or (at your option) any later version, or

b) the Artistic License version 2.0.

The full text of the license can be found in the LICENSE file included
with this distribution.

=cut

1;    # End of CGI::Application::Plugin::REST::Routes

__END__
