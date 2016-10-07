# https://github.com/JochenHayek/Perl/blob/master/XML/Template.pm

# this file is in the public domain.

package XML::Template;

$XML::Template::VERSION = '0.00';

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
	'…'
	if 0;

      $self->{options}{$key} = $val;
    }

  return $self;
}

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
	'…'
	if 0;
    }
  return $return_value;
}

sub output
{
  my($package,$filename,$line,$proc_name) = caller(0);
  my $self      = shift;
  my(%param) = @_;
  my($return_value) = '';

  printf STDERR "=%s,%d,%s: %s=>{%s} // %s\n",__FILE__,__LINE__,$proc_name,
    '$self->{options}{filename}' => $self->{options}{filename},
    '…'
    if 0;

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
	'…'
	if 0;

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
		if 0;

	      # let's loop over the loop variable:
	      printf STDERR "=%s,%d,%s: %s=>{%s} // %s\n",__FILE__,__LINE__,$proc_name,
		"\$self->{loop_param}{NAME}" => $self->{loop_param}{NAME},
		'…'
		if 0;

	      my($loop_param_name) = $self->{loop_param}{NAME};

	      foreach my $vset ( @{ $self->{param}{ $loop_param_name } } )
		{
		  my($h) = $loop_text;

		  printf STDERR "=%s,%d,%s: // %s\n",__FILE__,__LINE__,$proc_name,
		    '=========='
		    if 0;

		  while(my($key,$val) = each %{ $vset })
		    {
		      printf STDERR "=%s,%d,%s: %s=>{%s} // %s\n",__FILE__,__LINE__,$proc_name,
			$key => $val,
			'…'
			if 0;

		      $h =~ s/ < TMPL_VAR \s+ NAME = ${key} \/>  /${val}/gx;

		      printf STDERR "=%s,%d,%s: %s=>{%s},%s=>{%s} // %s\n",__FILE__,__LINE__,$proc_name,
			$key => $val,
			'$h' => $h,
			'…'
			if 0;
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
		if 0;

	      $self->{loop_param}{ $+{key} } = $+{val};

	      printf STDERR "=%s,%d,%s: %s=>{%s} // %s\n",__FILE__,__LINE__,$proc_name,
		"\$self->{loop_param}{$+{key}}" => $+{val},
		'…'
		if 0;
	    }
	  elsif( m/ < TMPL_VAR \s+ (?<key>[^=]+) = (?<val>[^>]*) \/> /x)
	    {
	      die "!defined(\$self->{param}{$+{val}})"
		  unless $self->{param}{$+{val}};

	      s/    < TMPL_VAR \s+ (?<key>[^=]+) = (?<val>[^>]*) \/>  /$self->{param}{$+{val}}/gx;
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
