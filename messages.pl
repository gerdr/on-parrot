use strict;
use warnings;

my %templates = (

	create =>	<<'EOT',
post comments on '%s' here
URL: http://gerdr.github.com/on-parrot/%s
EOT

	update => <<'EOT'
post comments on update for '%s' here
URL: http://gerdr.github.com/on-parrot/%s
EOT
);

my ($type, $md_file) = @ARGV;

my $title = $md_file;
$title =~ s/\.md$//;
$title =~ s/^(\w)/\U$1/;
$title =~ s/(?:-)(\w)/ \U$1/g;

my $html_file = $md_file;
$html_file =~ s/\.md$/.html/;

printf $templates{$type}, $title, $html_file;
