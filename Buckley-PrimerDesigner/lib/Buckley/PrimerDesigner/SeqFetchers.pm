# ABSTRACT: Widgets for getting sequences for PrimerDesigner.pm from various sources 

use strict;
use warnings;

package Buckley::PrimerDesigner;

use base 'Bio::Root::Root';

use Bio::Seq;
use Bio::SeqIO;

use Buckley::Annotation::Parameter::Primer3;

use Scalar::Util qw(blessed);

=head1 NAME

Bio::PrimerDesigner - Primer3 with bells on.

=head1 DESCRIPTION

Basically a wrapper around Chris Fields's Primer3Redux wrapper
to design primers for multiple sequences, with hooks for
pre-processing of sequences and post- processing of primers

=head1 SYNOPSIS
=cut

sub new {
  my($class,@args) = @_;
  my $self = $class->SUPER::new(@args);
  $self->{_primer3} = Bio::Tools::Run::Primer3Redux->new();
  $self->throw("primer3 not found. Is it installed?") unless -x $self->primer3->executable;
  return $self;
}


my $sf = sub {
  my @seqs = @_;
  # ... do something ...
  return @seqs;
};


=head1 AUTHOR 

Cass Johnston <cassjohnston@gmail.com>

=cut

1;

