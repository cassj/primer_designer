# ABSTRACT: Fetch RNA sequence as Bio::Seq from TranscriptID
package Bio::SeqFetcher::Ensembl::TranscriptIDtoRNASeq;

use base 'Bio::SeqFetcher::Ensembl::TranscriptIDtocDNASeq';

use Data::Dumper;

=head1 NAME

Bio::SeqFetcher::Ensembl::TranscriptIDtoRNASeq - sequence fetcher for ensembl transcript id to cDNA sequence

=head1 SYNOPSIS

 use Bio::SeqFetcher::Ensembl::TranscriptIDtomDNASeq

 my $fetcher = Bio::SeqFetcher::Ensembl::TranscriptIDtoRNASeq->new(-species => $species);
 my @bioseqs = $fetcher->(@some_seq_ids);


=head1 DESCRIPTION

A SeqFetcher class for retrieving RNA sequence from the Ensembl database
by Ensembl Transcript ID

=cut


=head2 description

Returns a string description of the seqfetcher.

=cut
sub description{
  return "Returns RNA sequence given an Ensembl Transcript ID";
}


=head2 _make_seqs

  Internal use.
  Generates sequence objects from Bio::Ensembl::Genes. 

=cut
sub _make_seqs{
  my ($self,@transcripts) = @_;
  my @seqs;
  # Just use the parent method to get the cDNA sequences and then convert them to RNA
  my @seqs = $self->SUPER::_make_seqs(@transcripts);
  foreach my $seq (@seqs) {
    $seq = $seq->revcom;
    $_ = $seq->seq;
    tr/T/U/;
    $seq->seq($_);
    $seq->alphabet('rna');
  }
  return @seqs;
}


=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to the
Bioperl mailing list. Your participation is much appreciated. 

  bioperl-l@bioperl.org                  - General discussion
  http://bioperl.org/wiki/Mailing_lists  - About the mailing lists

=head2 Reporting Bugs 

Report bugs to the Bioperl bug tracking system to help us keep track
of the bugs and their resolution. Bug reports can be submitted via the
web:

  http://bugzilla.open-bio.org/  

=head1 AUTHOR - Cass Johnston <cassjohnston@gmail.com>

The author(s) and contact details should be included here (this insures you get credit for creating the module.  
Lesser contributions can be documented in a separate CONTRIBUTORS section if you prefer. 

=cut

1;
