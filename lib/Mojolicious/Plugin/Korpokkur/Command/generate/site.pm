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
        rcopy( $default_path, $self->{my_site} );
        
        say "  [setup] successfully created skeleton";
    }
    elsif ( -d $theme_directory ) {
        $self->set_theme( $theme_directory, $theme );
    }
    else {
        say "  [error] theme not found";
    }
}

sub dir_copy {
    my ( $self, $dir ) = @_;
    my $dist_dir = $self->{default_path};
    rcopy( catdir( $dist_dir, $dir ), catdir( $self->{my_site}, $dir ) );
    say '  [create] ' . $dir;
}

sub set_theme {
    my ( $self, $theme_directory, $theme ) = @_;
    
    my @install = qw(public lib stash readme.txt sitemap.yaml  );
    for my $install (@install) {
        my $dir = catdir( $theme_directory, $install );
        if ( -d $dir ) {
            rcopy( $dir, catdir( $self->{my_site}, $install ) );
        }
        else {
            $self->dir_copy($install);
        }
    }
    my $korpokkur = catdir($theme_directory,'korpokkur.yaml');
    if(-d $korpokkur){
      rcopy($korpokkur,catdir($self->{my_site},'korpokkur.yaml'));
    }else{
      $self->{xslate}->{template_options}->{path} = [
        catdir( $self->{my_site}, 'templates' ),
        catdir( $theme_directory, 'templates' )
      ];

      $self->{config}->{plugins}->{xslate_renderer} = $self->{xslate};
      my $korpokkur = YAML::Syck::Dump( $self->{config} );
      $self->write_file( catfile( $self->{my_site}, 'korpokkur.yaml' ),
        $korpokkur );

    
    }
    say "  [setup] successfully created skeleton: $theme";
}
1;

