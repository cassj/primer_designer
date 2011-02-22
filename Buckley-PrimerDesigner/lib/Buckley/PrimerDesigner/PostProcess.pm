use strict;
use warnings;

package Buckley::PrimerDesigner::PostProcess;
use base 'Buckley::PrimerDesigner::Process';

=head1 NAME

Buckley::PrimerDesigner::PostProcess - Base class for PostProcesses in PrimerDesigner

=head1 DESCRIPTION

PrimerDesigner can just take a subref as a post-process, but if you make it a
subclass of PostProcess instead it will work with the web interface.

=head1 SYNOPSIS

  package Buckley::PrimerDesigner::PostProcess::DoSomething;

  {
    my $callback = sub{my $bioseq = shift; ... do some stuff ... return $bioseq || undef;}
    sub callback{ return $callback; }
  }

  1;


And elsewhere:

  my $pd = Buckley::PrimerDesigner->new();
  my $post_proc = Buckley::PrimerDesigner::PostProcess:DoSomething->new();  #blessed subref.
  $pd->register_post_process(name=>'do_stuff', subref=>$post_proc->callback, description=>"a thing which does stuff");
  my $PDres = $pd->design(@seqs);


=head1 METHODS - from L<Buckley::PrimerDesigner::Process>

=head2 new

Constructor

=head2 callback

Should be overridden by subclasses to return a subref to use as a callback

=head2 is_filter

Should be overridden by subclasses to return a boolean value indicating
whether or not this callback is a filter. If false, then PrimerDesign 
will expect the resulting array of Bio::Seq objects to be the same length
as the input array.

=head1 AUTHOR

Cass Johnston <cassjohnston@gmail.com>

=cut

1;
