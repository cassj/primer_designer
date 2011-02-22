use strict;
use warnings;

package Buckley::PrimerDesigner::Process;
BEGIN {
  $Buckley::PrimerDesigner::Process::VERSION = '0.001';
}
use base 'Bio::Root::Root';


sub new {
  my $class = shift;
  my $self = bless {}, $class;
  return $self;
}



sub callback {
  my $self = shift;
  $self->throw("->callback should be defined by a subclass");
}



sub is_filter{
  my $self = shift;
  $self->throw("->is_filter should be defined by a subclass");
}



1;

__END__
=pod

=head1 NAME

Buckley::PrimerDesigner::Process

=head1 VERSION

version 0.001

=head1 DESCRIPTION

Don't use this directly. Use PreProcess or PostProcess as your base class.

=head2 new

Constructor

=head2 callback

Should be overridden by subclasses to return a subref to use as a callback

=head2 is_filter

Should be overridden by subclasses to return a boolean value indicating
whether or not this callback is a filter. If false, then PrimerDesign 
will expect the resulting array of Bio::Seq objects to be the same length
as the input array.

=head1 NAME

Buckley::PrimerDesigner::Process - Base class for Pre- and Post- Processes in PrimerDesigner

=head1 AUTHOR

Cass Johnston <cassjohnston@gmail.com>

=head1 AUTHOR

Cass Johnston <cassjohnston@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Cass Johnston.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

