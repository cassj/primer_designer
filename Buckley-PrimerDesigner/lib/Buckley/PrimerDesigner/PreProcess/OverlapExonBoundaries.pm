use strict;
use warnings;

package Buckley::PrimerDesigner::PreProcess::OverlapExonBoundaries;
use base 'Buckley::PrimerDesigner::PreProcess';

use Buckley::Annotation::Parameter::Primer3;
use Scalar::Util qw(blessed);

=head1 NAME

Buckley::PrimerDesigner::PreProcess::OverlapExonBoundaries - PrimerDesigner pre-process

=head1 DESCRIPTION


=head2 process

Returns a subref that checks a Bio::Seq object for 
Bio::SeqFeature::ExonBoundary features.
If found, adds a sequence-specific primer3 SEQUENCE_TARGET
which means valid primers must overlap an exon boundary.

If a sequence has no exon boundaries, it will be returned
as is, so you may want to use a filter to remove
single exon sequences first.

=cut

sub process{
  my ($self, $seq) = @_;
  my $seq_target = '';
  for my $feat ($seq->get_SeqFeatures) {
    if(blessed $feat && $feat->isa('Bio::SeqFeature::ExonBoundary')){
      my $pos = $feat->start;
      $seq_target ="$seq_target $pos,1"; # format is '<start>,<len> <start><len>'
    }
    }
  $seq_target = substr($seq_target, 1, length($seq_target)); #remove leading space
  $seq_target = Buckley::Annotation::Parameter::Primer3->new(-value => $seq_target);
  $seq->annotation->add_Annotation('SEQUENCE_TARGET', $seq_target);
  
  return $seq;
}



=head2 description

=cut
sub description {
  return "Adds a primer3 SEQUENCE_TARGET parameter for any Bio::SeqFeature::ExonBoundary features on the sequence";
}

=head1 AUTHOR

Cass Johnston <cassjohnston@gmail.com>

=cut

1;
