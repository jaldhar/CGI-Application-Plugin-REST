use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    dist_name           => 'CGI-Application-Plugin-REST',
    module_name         => 'CGI::Application::Plugin::REST',
    dist_abstract       => 'Helps implement RESTful architecture in CGI applications',
    dist_author         => 'Jaldhar H. Vyas <jaldhar@braincells.com>',
    license             => 'perl',
    dist_version_from   => 'lib/CGI/Application/Plugin/REST.pm',
    build_requires => {
        'Test::WWW::Mechanize::CGIApp'  => 0,
        'Test::LongString'              => 0,
    },
    requires => {
        'perl'                          => 5.008,
        'CGI::Application'              => 4.04,
    },
    add_to_cleanup      => [ 'CGI-Application-Plugin-REST-*' ],
    create_makefile_pl  => 'traditional',
    sign                => 1,
);

$builder->create_build_script();
