package Mojolicious::Plugin::Korpokkur::Command::generate::site;
use strict;
use warnings;
use Mojo::Base 'Mojolicious::Command';
use File::Spec::Functions qw(abs2rel catdir catfile splitdir);
use File::HomeDir;
use File::ShareDir ':ALL';
use File::Copy::Recursive qw(rcopy);
use YAML::Syck;

has description => "Generate Korpokkur skeleton\n";
has usage       => "usage: $0 generate pokkur [NAME]\n";

sub run {
    my ( $self, $name, $theme ) = @_;
    $name ||= 'mysite';

    my $myhome = File::HomeDir->my_home;
    my $mysite = catdir( $self->app->home, $name );
    $self->{my_site} = $mysite;
    my $theme_directory
        = $theme ? catdir( $myhome, '.korpokkur', $theme ) : undef;
    $self->{config} = {
        site_name => $name,
        script    => ['/common/js/jquery.js'],
        css       => ['/common/css/style.css'],
        plugins   => {}
    };

    $self->{xslate} = {
        template_options => {
            module => [
                'Text::Xslate::Bridge::Star',
                'Text::Xslate::Bridge::Korpokkur'
            ]
        }
    };

    $self->{default_path}
        = catdir( dist_dir('Mojolicious-Plugin-Korpokkur'), '/default' );

    if ( !$theme ) {
        my $default_path = $self->{default_path};
        $self->{config}->{plugins}->{xslate_renderer} = $self->{xslate};
        my $korpokkur = YAML::Syck::Dump( $self->{config} );
        $self->write_file(
            catfile( $self->app->home, $name, 'korpokkur.yaml' ),
            $korpokkur );
        File::Copy::copy( catfile( $default_path, 'sitemap.yaml' ),
            "$name/sitemap.yaml" );
        say '  [create] sitemap.yaml';
        File::Copy::copy( catfile( $default_path, 'readme.txt' ),
            "$name/readme.txt" );
        say '  [create] readme.txt';
        $self->set_base;

    }
    elsif ( -d $theme_directory ) {
        $self->set_theme( $theme_directory, $theme );
        say "  [setup] theme: $theme";
    }
    else {
        say "  [error] theme not found";
    }
}

sub set_base {
    my $self = shift;

    rcopy(
        catdir( dist_dir('Mojolicious-Plugin-Korpokkur'), '/default', 'lib' ),
        catdir( $self->{my_site},                         'lib' )
    );
    say '  [create] lib';
    rcopy(
        catdir(
            dist_dir('Mojolicious-Plugin-Korpokkur'), '/default',
            'templates'
        ),
        catdir( $self->{my_site}, 'templates' )
    );
    say '  [create] templates';

    rcopy(
        catdir(
            dist_dir('Mojolicious-Plugin-Korpokkur'),
            '/default', 'stash'
        ),
        catdir( $self->{my_site}, 'stash' )
    );
    say '  [create] stash';

    rcopy(
        catdir(
            dist_dir('Mojolicious-Plugin-Korpokkur'), '/default',
            'publis'
        ),
        catdir( $self->{my_site}, 'public' )
    );

    say '  [create] public';

}

sub set_theme {
    my ( $self, $theme_directory, $theme ) = @_;
    my $public_dir = catdir( $theme_directory, 'public' );
    rcopy( $public_dir, catdir( $self->{my_site}, 'public' ) )
        if ( -d $public_dir );

    my $lib_dir = catdir( $theme_directory, 'lib' );
    if ( -d $lib_dir ) {
        rcopy( $lib_dir, catdir( $self->{my_site}, 'lib' ) );
    }
    else {
        rcopy(
            catdir( $self->{default_path}, 'lib' ),
            catdir( $self->{my_site},      'lib' )
        );
    }
    $self->{xslate}->{template_options}->{path} = [
        catdir( $self->{my_site}, 'templates' ),
        catdir( $theme_directory, 'templates' )
    ];

    $self->{config}->{plugins}->{xslate_renderer} = $self->{xslate};
    my $korpokkur = YAML::Syck::Dump( $self->{config} );
    $self->write_file( catfile( $self->{my_site}, 'korpokkur.yaml' ),
        $korpokkur );
    say "  [setup] theme: $theme";
}
1;
__DATA__
@@ sitemap



