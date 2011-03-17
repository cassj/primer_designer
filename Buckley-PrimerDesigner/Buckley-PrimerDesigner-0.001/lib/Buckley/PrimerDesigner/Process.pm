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



sub process {
  my $self = shift;
  $self->throw("->callback should be defined by a subclass");
}


sub description{
  return "Base class for PrimerDesigner Processes. Do not use directly";
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

=head2 process

Should be overridden by subclasses to return a subref to use as a process

=head2 description

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

