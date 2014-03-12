use strict;
use Test::More;

use_ok $_ for qw(
    Mojolicious::Plugin::Korpokkur
    Mojolicious::Plugin::Korpokkur::Command::publish
    Mojolicious::Plugin::Korpokkur::Command::generate
    Mojolicious::Plugin::Korpokkur::Command::generate::site
);

done_testing;

