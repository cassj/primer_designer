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
  $self->throw("->process should be defined by a subclass");
}


sub name {
  my $self = shift;
  return __PACKAGE__.'';
}


sub description{
  my $self = shift;
  return $self->{description};
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

Should be overridden by subclasses

=head2 name

 Returns the process name

=head2 description

 Returns the process description

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

