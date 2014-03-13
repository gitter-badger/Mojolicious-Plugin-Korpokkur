package Mojolicious::Plugin::Korpokkur;
use Mojo::Base 'Mojolicious::Plugin';
use YAML::Syck;
use Try::Tiny;
use File::Basename qw(fileparse dirname);
use File::Spec::Functions qw(abs2rel catdir catfile splitdir);
use File::ShareDir ':ALL';
use File::HomeDir;
use Path::Tiny;
use utf8;
use Image::Size ();
our $VERSION = '0.02';
local $YAML::Syck::ImplicitUnicode = 1;

sub register {
    my ( $self, $app, $options ) = @_;

    unshift @{ $app->commands->namespaces },
        'Mojolicious::Plugin::Korpokkur::Command';
    my $config
        = $self->load_yaml( $options->{conf} // './korpokkur.yaml', $app );
    return unless $config;

    #plugin
    my $plugins = delete $config->{plugins};
    $self->load_plugin( $app, $plugins ) if ($plugins);

    #sitemap
    my $sitemap
        = $self->load_yaml( $options->{sitemap_file} // 'sitemap.yaml',
        $app );

    #theme
    $self->set_theme( $config->{theme}, $app ) if $config->{theme};

    #manual
    $config->{no_manual} //= 0;
    unless ( $config->{no_manual} ) {
        my $public_path
            = catdir( dist_dir('Mojolicious-Plugin-Korpokkur'), '/public' );
        push @{ $app->static->paths }, $public_path;
    }

    #helper rel url
    $app->helper(
        url_rel => sub {
            my $c    = shift;
            my $rel  = $c->url_for(@_)->to_abs->clone;
            my $base = $c->req->url->clone->to_abs;
            $rel->base($base)->scheme(undef);
            $rel->userinfo(undef)->host(undef)->port(undef)
                if $base->authority;
            my @parts      = @{ $rel->path->parts };
            my $base_path  = $base->path;
            my @base_parts = @{ $base_path->parts };
            pop @base_parts unless $base_path->trailing_slash;

            while ( @parts && @base_parts && $parts[0] eq $base_parts[0] ) {
                shift @$_ for \@parts, \@base_parts;
            }
            my $path = $rel->path( Mojo::Path->new )->path;
            $path->leading_slash(1) if $rel->authority;
            $path->parts( [ ('..') x @base_parts, @parts ] );
            $path->trailing_slash(1) if $rel->path->trailing_slash;
            return $rel;
        }
    );

    $app->helper(
        'image_size' => sub {
            my $c    = shift;
            my $path = shift;
            my $dir  = $app->home->rel_dir('public');
            my @size = Image::Size::imgsize( catfile( $dir, $path ) );
            return [@size];
        }
    );

    my $korpokkur = { %{$config}, sitemap => $sitemap, };
    $app->attr(
        'korpokkur',
        sub {
            return $korpokkur;
        }
    );

    $app->defaults(
        korpokkur => $korpokkur,
        handler   => 'ep'
    );

    #routing
    for my $ref ( keys %{$sitemap} ) {
        my $meta       = $sitemap->{$ref};
        my $url        = $meta->{path};
        my $stash_dir  = $app->home->rel_dir('./stash/');
        my $stash_path = path($stash_dir)->child( $ref . '.yaml' );

        my $yaml
            = $stash_path->is_file
            ? $self->load_yaml($stash_path) // {}
            : {};
        my $template = $meta->{template};
        my $default  = {
            %{$meta},
            %{$yaml},
            template => $template,
            handler  => $config->{handler} // 'tx'
        };

        if ( !$template && $config->{default_template} ) {
            $default->{template_name} //= $config->{default_template};
        }

        $app->routes->get( $url, $default, $ref );
    }
}

sub load_plugin {
    my ( $self, $app, $plugins ) = @_;
    return unless $plugins;
    if ( ref $plugins eq 'HASH' ) {
        for my $plugin ( keys %{$plugins} ) {
            $app->plugin( $plugin, $plugins->{$plugin} );
        }
    }
    elsif ( !ref $plugins ) {
        $app->plugin($plugins);
    }
}

sub load_yaml {
    my ( $self, $file, $app ) = @_;
    my $yaml;
    try {
        local $YAML::Syck::ImplicitUnicode = 1;
        $yaml = YAML::Syck::LoadFile(
            ref $file eq 'Path::Tiny'
            ? $file->absolute
            : $app->home->rel_file($file)
        );
    }
    catch {
        $app->log->debug( $app->home->rel_file($file) );
        $app->log->debug("Korpokkur:not loaded $file");
    };
    return $yaml;
}

sub set_theme {
    my ( $self, $theme, $app ) = @_;
    my $theme_directory
        = catdir( File::HomeDir->my_home, '.korpokkur', $theme );

}
1;
__END__

=encoding utf8

=head1 NAME

Mojolicious::Plugin::Korpokkur - Mojolicious Plugin

=head1 SYNOPSIS

  # Mojolicious
  $self->plugin('Korpokkur');

  # Mojolicious::Lite
  plugin 'Korpokkur';

Mojoliciousを利用した静的ファイル生成アプリケーションです。
Mojoliciousのプラグインとしてかかれていますので既存のMojoliciousを拡張することも可能ですし、
このプラグイン（あるいは付属のコマンド）を使って静的サイトを作っていれば一部もしくは全てをMojolicious アプリケーションとしてリニューアルすることが可能です。

=head1 Commands

このプラグインではpokkurとkpokkurという2つのコマンドがインストールされます。

pokkurもkpokkurもカレントディレクトリにあるファイルを読みに行くようにしてあるので複数のサイトを取り扱うことができます。

=head2 pokkur
 
  #generate sites skeleton
  pokkur generate sites <site_name>

  #publish
  pokkur publish

pokkurはKorpokkur PluginをロードしたMojolicious lite appです。
mojoコマンドとKorpokkurで追加したコマンドが使えます。

=head2 pokkur generate sites
 
  #generate site skeleton
  pokkur generate site <site_name>

サイト設定に必要な設定ファイルなどの初期ファイルを生成します。
pokkur generate sitesでsitemap.yamlやkorpokkur.yamlなど必要ファイルを生成します。
デフォルトのテンプレートはText::Xslateを使うよう設定しています。

=head2 pokkur publish

  #publish
  pokkur publish

静的ファイル書き出し機能です。wwwフォルダを作成（元からある場合はいったん削除）しwwwフォルダ内に、publicディレクトリ内の静的ファイルをコピーしsitemap.yamlにあるメタデータから静的ファイルを生成します。

=head2 kpokkur

  #morbo server
  kpokkur

pokkurをロードしたmorboサーバーの起動スクリプトです。libとtemplates以外にもkorpokkur.yaml
sitemap.yamlとstashディレクトリを監視しします。morboの初期設定を変更した起動スクリプトですのでMojoliciousのmorboサーバーがそのまま動きます。
変更が即座に反映されるのでサーバーを立ち上げて確認しながら作業が行えます。

=head1 DESCRIPTION

L<Mojolicious::Plugin::Korpokkur> is a L<Mojolicious> plugin.


=head1 METHODS

L<Mojolicious::Plugin::Korpokkur> inherits all methods from
L<Mojolicious::Plugin> and implements the following new ones.

=head2 register

  $plugin->register(Mojolicious->new);

Register plugin in L<Mojolicious> application.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>.


=head1 Author

mozquito<mozqutio@me.com> 

=cut

