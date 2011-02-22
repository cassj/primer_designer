use strict;
use warnings;

package Buckley::PrimerDesigner::PreProcess;
use base 'Buckley::PrimerDesigner::Process';

=head1 NAME

Buckley::PrimerDesigner::PreProcess - Base class for PreProcesses in PrimerDesigner

=head1 DESCRIPTION

PrimerDesigner can just take a subref as a pre-process, but if you make it a
subclass of PreProcess instead then the web-interface will automatically
be able to find it.

=head1 SYNOPSIS

  package Buckley::PrimerDesigner::PreProcess::DoSomething;

  {
    my $callback = sub{my $bioseq = shift; ... do some stuff ... return $bioseq || undef;}
    sub callback{ return $callback; }
    sub is_filter(return 0);
  }

  1;


And elsewhere:

  my $pd = Buckley::PrimerDesigner->new();
  my $pre_proc = Buckley::PrimerDesigner::PreProcess:DoSomething->new();  #blessed subref.
  $pd->register_pre_process(name=>'do_stuff', subref=>$pre_proc->callback, description=>"a thing which does stuff");
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
