#! /usr/bin/perl -w

# https://github.com/JochenHayek/Perl/blob/master/XML/t/XML-Template/ex0.pl

# this file is in the public domain.

use lib '/Users/johayek/Computers/Programming/Languages/Perl';

use XML::Template;

my $template = XML::Template->new(filename => 'ex1.tmpl');

$template->param(
    EMPLOYEE_INFO => [{name => 'Sam', job => 'programmer'},
		      {name => 'Steve', job => 'soda jerk'},
                     ]
  );
print $template->output();
