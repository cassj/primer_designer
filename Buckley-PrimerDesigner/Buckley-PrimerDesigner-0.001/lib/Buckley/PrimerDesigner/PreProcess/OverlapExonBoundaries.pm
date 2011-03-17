use strict;
use warnings;

package Buckley::PrimerDesigner::PreProcess::OverlapExonBoundaries;
BEGIN {
  $Buckley::PrimerDesigner::PreProcess::OverlapExonBoundaries::VERSION = '0.001';
}
use base 'Buckley::PrimerDesigner::PreProcess';

use Buckley::Annotation::Parameter::Primer3;
use Scalar::Util qw(blessed);


{
  my $process = sub {
    my $seq = shift;

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
  };

  sub process {
    my $self = shift;
    return $process;
  }

}


sub description {
  return "Adds a primer3 SEQUENCE_TARGET parameter for any Bio::SeqFeature::ExonBoundary features on the sequence";
}


1;

__END__
=pod

=head1 NAME

Buckley::PrimerDesigner::PreProcess::OverlapExonBoundaries

=head1 VERSION

version 0.001

=head1 DESCRIPTION

=head2 process

Returns a subref that checks a Bio::Seq object for 
Bio::SeqFeature::ExonBoundary features.
If found, adds a sequence-specific primer3 SEQUENCE_TARGET
which means valid primers must overlap an exon boundary.

If a sequence has no exon boundaries, it will be returned
as is, so you may want to use a filter to remove
single exon sequences first.

=head2 description

=head1 NAME

Buckley::PrimerDesigner::PreProcess::OverlapExonBoundaries - PrimerDesigner pre-process

=head1 AUTHOR

Cass Johnston <cassjohnston@gmail.com>

=head1 AUTHOR

Cass Johnston <cassjohnston@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Cass Johnston.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

