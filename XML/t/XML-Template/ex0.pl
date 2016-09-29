#! /usr/bin/perl -w

# https://github.com/JochenHayek/Perl/blob/master/XML/t/XML-Template/ex0.pl

# this file is in the public domain.

use lib '/Users/johayek/Computers/Programming/Languages/Perl';

use XML::Template;

my $template = XML::Template->new(filename => 'ex0.tmpl');

# fill in some parameters
$template->param(HOME => $ENV{HOME});
$template->param(PATH => $ENV{PATH});

# send the obligatory Content-Type and print the template output
print "Content-Type: text/html\n\n", $template->output;
