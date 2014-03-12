# NAME

Mojolicious::Plugin::Korpokkur - Mojolicious Plugin

# SYNOPSIS

    # Mojolicious
    $self->plugin('Korpokkur');

    # Mojolicious::Lite
    plugin 'Korpokkur';

Mojoliciousを利用した静的ファイル生成アプリケーションです。
Mojoliciousのプラグインとしてかかれていますので既存のMojoliciousを拡張することも可能ですし、
このプラグイン（あるいは付属のコマンド）を使って静的サイトを作っていれば一部もしくは全てをMojolicious アプリケーションとしてリニューアルすることが可能です。

# Commands

このプラグインではpokkurとkpokkurという2つのコマンドがインストールされます。

pokkurもkpokkurもカレントディレクトリにあるファイルを読みに行くようにしてあるので複数のサイトを取り扱うことができます。

## pokkur

    #generate sites skeleton
    pokkur generate sites <site_name>

    #publish
    pokkur publish

pokkurはKorpokkur PluginをロードしたMojolicious lite appです。
mojoコマンドとKorpokkurで追加したコマンドが使えます。

## pokkur generate sites

    #generate site skeleton
    pokkur generate site <site_name>

サイト設定に必要な設定ファイルなどの初期ファイルを生成します。
pokkur generate sitesでsitemap.yamlやkorpokkur.yamlなど必要ファイルを生成します。
デフォルトのテンプレートはText::Xslateを使うよう設定しています。

## pokkur publish

    #publish
    pokkur publish

静的ファイル書き出し機能です。wwwフォルダを作成（元からある場合はいったん削除）しwwwフォルダ内に、publicディレクトリ内の静的ファイルをコピーしsitemap.yamlにあるメタデータから静的ファイルを生成します。

## kpokkur

    #morbo server
    kpokkur

pokkurをロードしたmorboサーバーの起動スクリプトです。libとtemplates以外にもkorpokkur.yaml
sitemap.yamlとstashディレクトリを監視しします。morboの初期設定を変更した起動スクリプトですのでMojoliciousのmorboサーバーがそのまま動きます。
変更が即座に反映されるのでサーバーを立ち上げて確認しながら作業が行えます。

# DESCRIPTION

[Mojolicious::Plugin::Korpokkur](https://metacpan.org/pod/Mojolicious::Plugin::Korpokkur) is a [Mojolicious](https://metacpan.org/pod/Mojolicious) plugin.

# METHODS

[Mojolicious::Plugin::Korpokkur](https://metacpan.org/pod/Mojolicious::Plugin::Korpokkur) inherits all methods from
[Mojolicious::Plugin](https://metacpan.org/pod/Mojolicious::Plugin) and implements the following new ones.

## register

    $plugin->register(Mojolicious->new);

Register plugin in [Mojolicious](https://metacpan.org/pod/Mojolicious) application.

# SEE ALSO

[Mojolicious](https://metacpan.org/pod/Mojolicious), [Mojolicious::Guides](https://metacpan.org/pod/Mojolicious::Guides), [http://mojolicio.us](http://mojolicio.us).

# Author

mozquito<mozqutio@me.com> 
