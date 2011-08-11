use strict;
use warnings;

my $title = $ARGV[0];
$title =~ s/\.md$//;
$title =~ s/(?:^|-)(\w)/ \U$1/g;

print <<"EOT";
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
 "http://www.w3.org/TR/html4/strict.dtd">
<html>
 <head>
  <meta http-equiv="content-type" content="text/html; charset=UTF-8">
  <title>$title // gerdr on parrot</title>
  <link href="styles.css" rel="stylesheet" type="text/css">
 </head>
 <body>
 <h1><a href="http://github.com/gerdr" title="github.com/gerdr"><img 
  src="http://assets.github.com/images/gravatars/gravatar-140.png" width="48" 
  height="48">gerdr</a> on parrot</h1>
 <div id="navi"><a href="index.html">index</a> | <a href="https://github.com/gerdr/on-parrot/commits/comments">comments</a></div>
EOT
