package Mojolicious::Plugin::Korpokkur::Command::publish;
use Mojo::Base 'Mojolicious::Command';
use strict;
use warnings;
use utf8;
use Mojo::IOLoop;
use Mojo::Server;
use Mojo::UserAgent;
use Path::Tiny;
use File::Copy::Recursive qw(rcopy);

has ua => sub { Mojo::UserAgent->new->ioloop( Mojo::IOLoop->singleton ) };
has description => 'publish static html.';

has usage => <<EOF;
usage: $0 publish  
These options are available:
  -m, --mode <mode>           Operating mode for your application, defaults to the
                              value of MOJO_MODE/PLACK_ENV or "development".
EOF

sub run {
    my $self = shift;
    $self->ua->server->app( $self->app );
    my $mode = $ENV{MOJO_MODE};
    $self->app->log->level('info')
        if ( !defined $mode || $mode ne 'development' );
    my $defaults = $self->app->defaults;

    my $sitemap = $defaults->{korpokkur}->{sitemap};
    my $dir     = $self->create_dir;
    for my $ref ( keys %{$sitemap} ) {
        my $meta = $sitemap->{$ref};
        my $url = $meta->{path} // '';
        next if ( $url =~ /^http/ || $meta->{no_publish} );
        my $tx
            = ( $url =~ /^\// )
            ? $self->ua->get($url)
            : $self->ua->get( '/' . $url );
        my ( $err, $code ) = $tx->error;
        if ( !$err ) {
            my $path = $dir->child($url);
            $path->touchpath->spew_utf8( $tx->res->text );
            say '  [write] '.$path;
        }
        else {
            say "  [fail] $err $url";
        }
    }
}

sub create_dir {
    my $self = shift;

    my $config = $self->app->korpokkur;

    my $dir = $config->{publish_dir} // './www';

    my $ab_dir = path( $self->app->home->rel_dir($dir) );
    $ab_dir->remove_tree;
    $ab_dir->mkpath;

    my $public_dir = $config->{public_dir} // './public';

    rcopy( $self->app->home->rel_dir($public_dir), $ab_dir );
    return $ab_dir;
}
1;

=encoding utf8

=head1 NAME

Mojolicious::Plugin::Korpokkur::Command::publish

=head1 SYNOPSIS


  use Mojolicious::Plugin::Korpokkur::Command::publish;

  my $publish = Mojolicious::Plugin::Korpokkur::Command::publish->new;
  $publish->run(@ARGV);

=head1 DESCRIPTION

L<Mojolicious::Plugin::Korpokkur::Command::publish> is a L<Mojolicious> Command.

generate static html for sitemap.yaml

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>.

=cut

