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


=head2 callback

Should be overridden by subclasses to return a subref to use as a callback

=cut

sub callback {
  my $self = shift;
  $self->throw("->callback should be defined by a subclass");
}


=head2 is_filter

Should be overridden by subclasses to return a boolean value indicating
whether or not this callback is a filter. If false, then PrimerDesign 
will expect the resulting array of Bio::Seq objects to be the same length
as the input array.

=cut

sub is_filter{
  my $self = shift;
  $self->throw("->is_filter should be defined by a subclass");
}


=head1 AUTHOR

Cass Johnston <cassjohnston@gmail.com>

=cut

1;
