package Mojolicious::Plugin::Korpokkur::Command::generate;
use Mojo::Base 'Mojolicious::Command::generate';
our $VERSION = '0.02'; # VERSION
has namespaces => sub { ['Mojolicious::Plugin::Korpokkur::Command::generate'] };


1;

=encoding utf8

=head1 NAME

Mojolicious::Plugin::Korpokkur::Command::generate - Korpokkur generator commands

=head1 SYNOPSIS

  use Mojolicious::Plugin::Korpokkur::Command::generate;

  my $generator = Mojolicious::Plugin::Korpokkur::Command::generate->new;
  $generator->run(@ARGV);

=head1 DESCRIPTION

Mojolicious::Plugin::Korpokkur code generation commands.

=head1 Super Class 

L<Mojolicious::Command::generate>

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>.

=cut
