# ABSTRACT: Primer design with bells on.

package Buckley::PrimerDesigner::Result;
use base 'Bio::Root::Root';

=head1 NAME

Bio::PrimerDesigner::Result - A class to store results from Buckley::PrimerDesigner

=head1 DESCRIPTION

A class to store the results of a L<Buckley::PrimerDesigner> run.
Includes methods to output the results textually and graphically.

=head1 SYNOPSIS


=cut

sub new {
  my $class = shift;
  my $self = {};
  bless {}, $class;
  return $self;
}


=head1 AUTHOR 

Cass Johnston <cassjohnston@gmail.com>

=cut

1;
