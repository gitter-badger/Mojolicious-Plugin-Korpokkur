use Mojo::Base -strict;
use Test::More;
use Mojolicious::Lite;
use Test::Mojo;
use Path::Tiny;
use Mojolicious::Plugin::Korpokkur::Command::publish;

plugin 'Korpokkur';

my $default = app->defaults;

is(ref app->korpokkur,'HASH');

my $t = Test::Mojo->new;

$t->get_ok('/index.html')->status_is(200)->content_like(qr{title_index});

#url_rel
$t->get_ok('/url_rel/index.html')->status_is(200)->content_like(qr{url_rel},'title')
    ->content_like(qr{\.\./use/yaml\.html},'url_rel');
$t->get_ok('/sitemap')->status_is(404);

#add korpokkur document
$t->get_ok('/__korpokkur/index.html')->status_is(200);


#長い？
my $publish
    = Mojolicious::Plugin::Korpokkur::Command::publish->new( app => app );

subtest 'create_dir' => sub {
    ok !-d './t/www';
    $publish->create_dir;
    ok -d './t/www';
    cleanup();
    done_testing;
};

subtest 'publish' => sub {
    $publish->run();
    my $a = path('./t/www/index.html');
    my $b = path('./t/www/url_rel/index.html');
    my $c = path('./t/www/use/yaml.html');
    
    ok( $a->is_file, 'create /www/index.html' );
    ok( $b->is_file, 'create /www/url_rel/index.html' );

    like( $a->slurp_utf8, qr/title_index/ );
    like( $b->slurp_utf8, qr/url_rel/ );
    like( $b->slurp_utf8, qr/\.\.\/use\/yaml\.html/);

    cleanup();  
};

sub cleanup {
    path('./t/www/')->remove_tree;
}

done_testing();
__DATA__

@@ p1.html.ep
<%= title %>
 
@@ p2.html.ep
<%= title %>
<a href="<%= url_rel('p3') %>">test</a>

@@ p3.html.ep
<% my $block = <<'EOF';
- aaaaa
- aaaaaa
- aaaa
EOF
%>
<!DOCTYPE HTML>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title></title>
</head>
<body>
  
<% my $li = begin %>
  <% my $list = shift; =%>
% for my $row (@{$list}){
    <li><%= $row %></li>
% }

<% end %>

%= $block;
<ul>
%= $li->(yaml $block);
</ul>
</body>
</html>

