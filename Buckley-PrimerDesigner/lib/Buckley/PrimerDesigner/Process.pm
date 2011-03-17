use strict;
use warnings;

package Buckley::PrimerDesigner::Process;
use base 'Bio::Root::Root';

=head1 NAME

Buckley::PrimerDesigner::Process - Base class for Pre- and Post- Processes in PrimerDesigner

=head1 DESCRIPTION

Don't use this directly. Use PreProcess or PostProcess as your base class.

=head2 new

Constructor

=cut

sub new {
  my $class = shift;
  my $self = bless {}, $class;
  return $self;
}


=head2 process

Should be overridden by subclasses to return a subref to use as a process

=cut

sub process {
  my $self = shift;
  $self->throw("->callback should be defined by a subclass");
}

=head2 description

=cut

sub description{
  return "Base class for PrimerDesigner Processes. Do not use directly";
}

=head1 AUTHOR

Cass Johnston <cassjohnston@gmail.com>

=cut

1;
