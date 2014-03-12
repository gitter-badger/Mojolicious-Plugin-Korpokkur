package Text::Xslate::Bridge::Korpokkur;
use strict;
use warnings;
use utf8;
use parent qw(Text::Xslate::Bridge);
use Text::Xslate ();
use Text::Markdown;
use Encode;
use Time::Piece;

sub sp {
    my ( $time, $format ) = @_;
    return Time::Piece->strptime( $time, $format );
}

sub tag {
    my ( $name, $attrs ) = @_;
    $attrs //= {};
    return Text::Xslate::html_builder {

        my $html = shift;
        my $tag  = "<$name";
        for my $key ( sort keys %{$attrs} ) {
            $tag .= qq{ $key="}
                . Text::Xslate::html_escape( $attrs->{$key} // '' ) . '"';
        }
        if ($html) {
            $html = ref $html ? $html : Text::Xslate::html_escape($html);
            $tag .= '>' . $html . "</$name>";
        }
        else { $tag .= ' />' }
        return $tag;

    }
}

sub markdown {
    my $flag = shift;
    my $md   = Text::Markdown->new();
    return Text::Xslate::html_builder {
        my $text = shift;
        if ( !$flag ) {
            $text = Text::Xslate::html_escape("$text");
        }
        return $md->markdown($text);
    };
}

__PACKAGE__->bridge(
    function => {
        tag      => \&tag,
        markdown => \&markdown,
        strptime => \&sp
    }
);
1;
