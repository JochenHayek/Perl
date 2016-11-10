# https://github.com/JochenHayek/Perl/blob/master/XML/Template.pm

# this file is in the public domain.

package XML::Template;

$XML::Template::VERSION = '0.00';

our($debug) = 0;

=head1 NAME
 
XML::Template - Perl module to use XML-like templating language
 
=head1 SYNOPSIS

This POD got adapted from HTML::Template.

First you create a template - this is just a normal XML or XHTML file with a few extra tags, the simplest being C<< <TMPL_VAR> >>
 
For example, test.tmpl:
 
    <html>
    <head><title>Test Template</title></head>
    <body>
    My Home Directory is <TMPL_VAR NAME=HOME/>
    <p>
    My Path is set to <TMPL_VAR NAME=PATH/>
    </body>
    </html>
 
Now you can use it in a small CGI program:
 
    #!/usr/bin/perl -w
    use XML::Template;
 
    # open the XML template
    my $template = XML::Template->new(filename => 'test.tmpl');
 
    # fill in some parameters
    $template->param(HOME => $ENV{HOME});
    $template->param(PATH => $ENV{PATH});
 
    # send the obligatory Content-Type and print the template output
    print "Content-Type: text/html\n\n", $template->output;
 
If all is well in the universe, this should show something like this in
your browser when visiting the CGI:
 
    My Home Directory is /home/some/directory
    My Path is set to /bin;/usr/bin
 
=head1 DESCRIPTION
 
This module attempts to make using XML templates simple and natural.
It extends standard XML with a few new XML-esque tags - C<< <TMPL_VAR> >> and
C<< <TMPL_LOOP> >>.  The file written in XML and these new tags
are called a template. It is usually saved separate from your script -
possibly even created by someone else! Using this module you fill in the
values for the variables, loops and branches declared in the template.
This allows you to separate design - the XML or XHTML - from the data, which
you generate in the Perl script.
 
This code is in the public domain. 
You better use HTML::Template,
but if you want to make use of XML::Template,
do with it whatever you want,
but give proper credit to its authors
and also the authors of HTML::Template.
 
=head1 TUTORIAL
 
If you're new to XML::Template resp. HTML::Template, 
we suggest you start with the introductory article available on Perl Monks:
 
    http://www.perlmonks.org/?node_id=65642
 
=head1 FAQ
 
Please see L<HTML::Template::FAQ>
 
=head1 MOTIVATION
 
It is true that there are a number of packages out there to do HTML
templates.  On the one hand you have things like L<HTML::Embperl> which
allows you freely mix Perl with HTML.  On the other hand lie home-grown
variable substitution solutions.  Hopefully the module can find a place
between the two.

One advantage of this module over a full L<HTML::Embperl>-esque solution
is that it enforces an important divide - design and programming.
By limiting the programmer to just using simple variables and loops
in the HTML, the template remains accessible to designers and other
non-perl people.  The use of HTML-esque syntax goes further to make the
format understandable to others.  In the future this similarity could be
used to extend existing HTML editors/analyzers to support HTML::Template.
 
An advantage of this module over home-grown tag-replacement schemes is
the support for loops.  In my work I am often called on to produce
tables of data in HTML.  Producing them using simplistic HTML
templates results in programs containing lots of HTML since the HTML
itself cannot represent loops.  The introduction of loop statements in
the HTML simplifies this situation considerably.  The designer can
layout a single row and the programmer can fill it in as many times as
necessary - all they must agree on is the parameter names.
 
For all that, I think the best thing about this module is that it does
just one thing and it does it quickly and carefully.  It doesn't try
to replace Perl and HTML, it just augments them to interact a little
better.  And it's pretty fast.
 
=head1 THE TAGS
 
=head2 TMPL_VAR
 
    <TMPL_VAR NAME="PARAMETER_NAME"/>
 
The C<< <TMPL_VAR> >> tag is very simple.  For each C<< <TMPL_VAR> >>
tag in the template you call:
 
    $template->param(PARAMETER_NAME => "VALUE") 
 
When the template is output the C<< <TMPL_VAR>  >> is replaced with the
VALUE text you specified.  If you don't set a parameter it just gets
skipped in the output.
 
(Not yet implemented for XML::Template:)
You can also specify the value of the parameter as a code reference in order
to have "lazy" variables. These sub routines will only be referenced if the
variables are used. See L<LAZY VALUES> for more information.
 
=head3 Attributes
 
(Attributes not yet implemented at all for XML::Template:)
The following "attributes" can also be specified in template var tags: ...

=head2 TMPL_LOOP
 
    <TMPL_LOOP NAME="LOOP_NAME"> ... </TMPL_LOOP>
 
The C<< <TMPL_LOOP> >> tag is a bit more complicated than C<< <TMPL_VAR> >>.  
The C<< <TMPL_LOOP> >> tag allows you to delimit a section of text and
give it a name.  Inside this named loop you place C<< <TMPL_VAR> >>s.
Now you pass to C<param()> a list (an array ref) of parameter assignments
(hash refs) for this loop.  The loop iterates over the list and produces
output from the text block for each pass.  Unset parameters are skipped.
Here's an example:
 
In the template:
 
   <TMPL_LOOP NAME=EMPLOYEE_INFO>
      Name: <TMPL_VAR NAME=NAME/> <br>
      Job:  <TMPL_VAR NAME=JOB>/  <p>
   </TMPL_LOOP>
 
In your Perl code:
 
    $template->param(
        EMPLOYEE_INFO => [{name => 'Sam', job => 'programmer'}, {name => 'Steve', job => 'soda jerk'}]
    );
    print $template->output();
   
The output is:
 
    Name: Sam
    Job: programmer
 
    Name: Steve
    Job: soda jerk
 
As you can see above the C<< <TMPL_LOOP> >> takes a list of variable
assignments and then iterates over the loop body producing output.
 
Often you'll want to generate a C<< <TMPL_LOOP> >>'s contents
programmatically.  Here's an example of how this can be done (many other
ways are possible!):
 
    # a couple of arrays of data to put in a loop:
    my @words     = qw(I Am Cool);
    my @numbers   = qw(1 2 3);
    my @loop_data = ();              # initialize an array to hold your loop
 
    while (@words and @numbers) {
        my %row_data;      # get a fresh hash for the row data
 
        # fill in this row
        $row_data{WORD}   = shift @words;
        $row_data{NUMBER} = shift @numbers;
 
        # the crucial step - push a reference to this row into the loop!
        push(@loop_data, \%row_data);
    }
 
    # finally, assign the loop data to the loop param, again with a reference:
    $template->param(THIS_LOOP => \@loop_data);
 
The above example would work with a template like:
 
    <TMPL_LOOP NAME="THIS_LOOP">
      Word: <TMPL_VAR NAME="WORD"/>     
      Number: <TMPL_VAR NAME="NUMBER"/>
  
    </TMPL_LOOP>
 
It would produce output like:
 
    Word: I
    Number: 1
 
    Word: Am
    Number: 2
 
    Word: Cool
    Number: 3
 
C<< <TMPL_LOOP> >>s within C<< <TMPL_LOOP> >>s are fine and work as you
would expect.  If the syntax for the C<param()> call has you stumped,
here's an example of a param call with one nested loop:
 
    $template->param(
        LOOP => [
            {
                name      => 'Bobby',
                nicknames => [{name => 'the big bad wolf'}, {name => 'He-Man'}],
            },
        ],
    );
 
Basically, each C<< <TMPL_LOOP> >> gets an array reference.  Inside the
array are any number of hash references.  These hashes contain the
name=>value pairs for a single pass over the loop template.
 
Inside a C<< <TMPL_LOOP> >>, the only variables that are usable are the
ones from the C<< <TMPL_LOOP> >>.  The variables in the outer blocks
are not visible within a template loop.  For the computer-science geeks
among you, a C<< <TMPL_LOOP> >> introduces a new scope much like a perl
subroutine call.  If you want your variables to be global you can use
C<global_vars> option to C<new()> described below.
 
=head2 TMPL_INCLUDE

(Not yet implemented at all for XML::Template.)
 
=head2 TMPL_IF

(Not yet implemented at all for XML::Template.)
 
=head2 TMPL_ELSE

(Not yet implemented at all for XML::Template.)

=head2 NOTES

(Not yet implemented at all for XML::Template.)
 
=head1 METHODS
 
=head2 new
 
Call C<new()> to create a new Template object:
 
    my $template = HTML::Template->new(
        filename => 'file.tmpl',
        option   => 'value',
    );
 
You must call C<new()> with at least one C<name => value> pair specifying how
to access the template text.  You can use C<< filename => 'file.tmpl' >> 
to specify a filename to be opened as the template.
(Not yet implemented at all for XML::Template:) ...

=head3 Error Detection Options

(Not yet implemented at all for XML::Template.)
 
=head3 Caching Options

(Not yet implemented at all for XML::Template.)
 
=head3 Filesystem Options

(Not yet implemented at all for XML::Template.)
 
=head3 Debugging Options

(Not yet implemented at all for XML::Template.)
 
=head3 Miscellaneous Options

(Not yet implemented at all for XML::Template.)
 
=cut

sub new {
  my($package,$filename,$line,$proc_name) = caller(0);
  my $pkg = shift;
  my(%param) = @_;

  my $self;
  { my %hash; $self = bless(\%hash, $pkg); }
  $self->{options} = {};

  while(($key,$val) = each %param)
    {
      printf STDERR "=%s,%d,%s: %s=>{%s} // %s\n",__FILE__,__LINE__,$proc_name,
	"\$param{$key}" => $val,
	'...'
	if $debug;

      $self->{options}{$key} = $val;
    }

  return $self;
}

=head2 param

C<param()> can be called in a number of ways

=over

=item 1 - To return a list of parameters in the template : 

    NYI:

    my @parameter_names = $self->param();

=item 2 - To return the value set to a param : 

    NYI:

    my $value = $self->param('PARAM');

=item 3 - To set the value of a parameter :

    # For simple TMPL_VARs:
    $self->param(PARAM => 'value');

    NYI:

    # with a subroutine reference that gets called to get the value
    # of the scalar.  The sub will receive the template object as a
    # parameter.
    $self->param(PARAM => sub { return 'value' });

    # And TMPL_LOOPs:
    $self->param(LOOP_PARAM => [{PARAM => VALUE_FOR_FIRST_PASS}, {PARAM => VALUE_FOR_SECOND_PASS}]);

=item 4 - To set the value of a number of parameters :

    # For simple TMPL_VARs:
    $self->param(
        PARAM  => 'value',
        PARAM2 => 'value'
    );

    # And with some TMPL_LOOPs:
    $self->param(
        PARAM              => 'value',
        PARAM2             => 'value',
        LOOP_PARAM         => [{PARAM => VALUE_FOR_FIRST_PASS}, {PARAM => VALUE_FOR_SECOND_PASS}],
        ANOTHER_LOOP_PARAM => [{PARAM => VALUE_FOR_FIRST_PASS}, {PARAM => VALUE_FOR_SECOND_PASS}],
    );

=item 5 - To set the value of a number of parameters using a hash-ref :

    NYI:

    $self->param(
        {
            PARAM              => 'value',
            PARAM2             => 'value',
            LOOP_PARAM         => [{PARAM => VALUE_FOR_FIRST_PASS}, {PARAM => VALUE_FOR_SECOND_PASS}],
            ANOTHER_LOOP_PARAM => [{PARAM => VALUE_FOR_FIRST_PASS}, {PARAM => VALUE_FOR_SECOND_PASS}],
        }
    );

An error occurs if you try to set a value that is tainted if the C<force_untaint>
option is set.

=back

=cut

sub param
{
  my($package,$filename,$line,$proc_name) = caller(0);
  my $self      = shift;
  my(%param) = @_;
  my($return_value) = 0;
  while(my($key,$val) = each %param)
    {
      $self->{param}{$key} = $val;

      printf STDERR "=%s,%d,%s: %s=>{%s} // %s\n",__FILE__,__LINE__,$proc_name,
	"\$param{$key}" => $val,
	'...'
	if $debug;
    }
  return $return_value;
}

=head2 output

C<output()> returns the final result of the template.  In most situations
you'll want to print this, like:

    print $template->output();

When output is called each occurrence of C<< <TMPL_VAR NAME=name> >> is
replaced with the value assigned to "name" via C<param()>.  If a named
parameter is unset it is simply replaced with ''.  C<< <TMPL_LOOP> >>s
are evaluated once per parameter set, accumulating output on each pass.

Calling C<output()> is guaranteed not to change the state of the
XML::Template object, in case you were wondering.  This property is
mostly important for the internal implementation of loops.

NYI:
You may optionally supply a filehandle to print to automatically as the
template is generated.  This may improve performance and lower memory
consumption.  Example:

    $template->output(print_to => *STDOUT);

The return value is undefined when using the C<print_to> option.

=cut

sub output
{
  my($package,$filename,$line,$proc_name) = caller(0);
  my $self      = shift;
  my(%param) = @_;
  my($return_value) = '';

  printf STDERR "=%s,%d,%s: %s=>{%s} // %s\n",__FILE__,__LINE__,$proc_name,
    '$self->{options}{filename}' => $self->{options}{filename},
    '...'
    if $debug;

  my($FH_IN) = IO::File->new();
  open($FH_IN,'<',$self->{options}{filename});

  my($within_loop_p) = 0;
  my($loop_text) = '';
  while(<$FH_IN>)
    {
      printf STDERR "=%s,%d,%s: %s=>{%s},%s=>{%s},%s=>{%s} // %s\n",__FILE__,__LINE__,$proc_name,
	'$return_value' => $return_value,
	'$loop_text' => $loop_text,
	'$within_loop_p' => $within_loop_p,
	'...'
        if $debug;

      if($within_loop_p)
	{
	  if( m/ <\/ TMPL_LOOP > /x)
	    {
	      $within_loop_p = 0;

	      printf STDERR "=%s,%d,%s: %s=>{%s},%s=>{%s},%s=>{%s} // %s\n",__FILE__,__LINE__,$proc_name,
		'$return_value' => $return_value,
		'$loop_text' => $loop_text,
		'$within_loop_p' => $within_loop_p,
		'</TMPL_LOOP>'
                if $debug;

	      # let's loop over the loop variable:
	      printf STDERR "=%s,%d,%s: %s=>{%s} // %s\n",__FILE__,__LINE__,$proc_name,
		"\$self->{loop_param}{NAME}" => $self->{loop_param}{NAME},
		'...'
                if $debug;

	      my($loop_param_name) = $self->{loop_param}{NAME};

	      foreach my $vset ( @{ $self->{param}{ $loop_param_name } } )
		{
		  my($h) = $loop_text;

		  printf STDERR "=%s,%d,%s: // %s\n",__FILE__,__LINE__,$proc_name,
		    '=========='
                    if $debug;

		  while(my($key,$val) = each %{ $vset })
		    {
		      printf STDERR "=%s,%d,%s: %s=>{%s} // %s\n",__FILE__,__LINE__,$proc_name,
			$key => $val,
			'...'
                        if $debug;

		      $h =~ s/ < TMPL_VAR \s+ NAME = ${key} \/>  /${val}/gx;

		      printf STDERR "=%s,%d,%s: %s=>{%s},%s=>{%s} // %s\n",__FILE__,__LINE__,$proc_name,
			$key => $val,
			'$h' => $h,
			'...'
			if $debug;
		    }

		  $return_value .= $h;
		}
	    }
	  else
	    {
	      $loop_text .= $_;
	    }
	}
      else
	{
	  if   ( m/ < TMPL_LOOP \s+ (?<key>[^=]+) = (?<val>[^>]*) > /x)
	    {
	      $within_loop_p = 1;
	      $loop_text = '';

	      printf STDERR "=%s,%d,%s: %s=>{%s},%s=>{%s},%s=>{%s} // %s\n",__FILE__,__LINE__,$proc_name,
		'$return_value' => $return_value,
		'$loop_text' => $loop_text,
		'$within_loop_p' => $within_loop_p,
		'<TMPL_LOOP …>'
		if $debug;

	      $self->{loop_param}{ $+{key} } = $+{val};

	      printf STDERR "=%s,%d,%s: %s=>{%s} // %s\n",__FILE__,__LINE__,$proc_name,
		"\$self->{loop_param}{$+{key}}" => $+{val},
		'...'
		if $debug;
	    }
	  elsif( m/ < TMPL_VAR \s+ (?<key>[^=]+) = (?<val>[^>]*) \/> /x)
	    {
	      if(defined($self->{param}{$+{val}})){
		s/    < TMPL_VAR \s+ (?<key>[^=]+) = (?<val>[^>]*) \/>  /$self->{param}{$+{val}}/gx;
	      }

	      $return_value .= $_;
	    }
	  else
	    {
	      $return_value .= $_;
	    }
	}
    }

  return $return_value;
}
