# ABSTRACT: Fetch cDNA sequence as Bio::Seq from TranscriptID
package Bio::SeqFetcher::Ensembl::TranscriptIDtocDNASeq::WithExons;
use base 'Bio::SeqFetcher::Ensembl::TranscriptIDtocDNASeq';

use Bio::SeqFeature::Generic;

=head1 NAME

Bio::SeqFetcher::Ensembl::TranscriptIDtocDNASeq::WithExons - sequence fetcher for ensembl transcript id to cDNA sequence with exon annotations

=head1 SYNOPSIS

 use Bio::SeqFetcher::Ensembl::TranscriptIDtocDNASeq:WithExons

 my $fetcher = Bio::SeqFetcher::Ensembl::TranscriptIDtocDNASeq::WithExons->new(-species => $species);
 my @bioseqs = $fetcher->(@some_seq_ids);



=head2 description

=cut
sub description{
  return "Returns cDNA sequence, with exon boundaries marked as Bio::SeqFeature::ExonBoundary SeqFeatures, given an Ensembl Transcript ID";
}


=head2 _make_seqs

  Internal use.
  Generates sequence objects from Bio::Ensembl::Genes. 

=cut

sub _make_seqs{
  my ($self,@transcripts) = @_;
  my @seqs;
  foreach my $trsc (@transcripts){

    # A transcript is just a collection of exons and possibly a translation
    # defining the coding and non coding regions.

    # Get exons (in order they appear in transcript, although start and end are top strand)
    my $trsc_exons = $trsc->get_all_Exons;
    my $seq;

    my $id = $trsc->stable_id;
    foreach my $exon (@$trsc_exons){
      my $strand = $exon->strand;
      my $chr = $exon->slice->seq_region_name;
      my $start = $exon->start;
      my $end = $exon->end;
      my $exon_id = $exon->stable_id;

      #fetch the transcript sequence
      my $slice = $self->_slice_adap->fetch_by_region('chromosome', $chr, $start, $end, $strand);
      $seq = $seq.$slice->seq;
    }

    #concatenation of exon sequences to Bio::Seq:
    $seq = Bio::Seq->new(-seq => $seq,
			 -id  => $id);

    #Now we need to add the exon boundaries as features:
    my @exon_lengths = map {$_->length} @$trsc_exons;
    pop @exon_lengths;  # except the last one

    my $pos = 0;
    foreach (@exon_lengths){
      $pos = $pos+$_;
      @Bio::SeqFeature::ExonBoundary::ISA = 'Bio::SeqFeature::Generic';
      my $feat = Bio::SeqFeature::ExonBoundary->new(
						    '-start'  => $pos,
						    '-end'    => $pos,
						    '-strand' => 1, # everything should be in transcript direction now.
						    '-display_name' => 'exon boundary'
					      );
      $seq->add_SeqFeature($feat);
    }
    push @seqs, $seq;
  }
  return @seqs;
}

1;


