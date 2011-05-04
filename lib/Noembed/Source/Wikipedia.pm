package Noembed::Source::Wikipedia;

use Web::Scraper;
use JSON;

use parent 'Noembed::Source';

my $re = qr{http://[^\.]+\.wikipedia\.org/wiki/.*}i;

sub prepare_source {
  my $self = shift;

  $self->{scraper} = scraper {
    process "#firstHeading", title => 'TEXT';
    process "#bodyContent", html => sub {
      my $el = shift;
      my $output;
      my @children = $el->content_list;
      for my $child (@children) {
        last if $child->attr("id") eq "toc";
        if ($child->tag eq "p") {
          $output .= $child->as_HTML;
        }
      }
      return $output;
    };
  };
}

sub provider_name { "Wikipedia" }

sub filter {
  my ($self, $body) = @_;

  my $res = $self->{scraper}->scrape($body);
  return $res;
}

sub matches {
  my ($self, $url) = @_;
  return $url =~ $re;
}

1;
