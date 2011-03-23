use strict;
use warnings;

package Buckley::PrimerDesigner::PostProcess;
use base 'Buckley::PrimerDesigner::Process';


=head1 NAME

Buckley::PrimerDesigner::PostProcess -  Base class for PostProcesses in PrimerDesigner

=head1 DESCRIPTION

A PostProcess for Buckley::PrimerDesigner.

=head1 SYNOPSIS

  package Buckley::PrimerDesigner::PostProcess::DoSomething;

  sub description {return "proc description"}
  sub process {my ($self, $seq) = @_; ...do some stuff to $seq...; return $seq;}

  1;


And elsewhere:

  my $pd = Buckley::PrimerDesigner->new();
  my $pre_proc = Buckley::PrimerDesigner::PostProcess:DoSomething->new();
  $pd->register_pre_process($pre_proc);
  my $PDres = $pd->design(@seqs);



=head1 METHODS - from L<Buckley::PrimerDesigner::Process>

=head2 new

Constructor

=head2 process

Should be overridden by subclasses to return a subref to use as a process

=head2 name

=head2 description

=head1 AUTHOR

Cass Johnston <cassjohnston@gmail.com>

=cut



1;
