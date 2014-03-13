requires 'perl', '5.010001';

requires 'Mojolicious';
requires 'YAML::Syck';
requires 'Path::Tiny';
requires 'File::Copy::Recursive';
requires 'MojoX::Renderer::Xslate';
requires 'Text::Markdown';
requires 'Image::Size';
requires 'File::HomeDir';
requires 'File::ShareDir';

on 'test' => sub {
    requires 'Test::More', '0.98';
};
