# ABSTRACT: Fetch cDNA sequence as Bio::Seq from TranscriptID
package Bio::SeqFetcher::Ensembl::TranscriptIDtocDNASeq;

use base 'Bio::SeqFetcher::Ensembl';

=head1 NAME

Bio::SeqFetcher::Ensembl::TranscriptIDtocDNASeq - sequence fetcher for ensembl transcript id to cDNA sequence

=head1 SYNOPSIS

 use Bio::SeqFetcher::Ensembl::TranscriptIDtocDNASeq

 my $fetcher = Bio::SeqFetcher::Ensembl::TranscriptIDtocDNASeq->new(-species => $species);
 my @bioseqs = $fetcher->(@some_seq_ids);


=head1 DESCRIPTION

A SeqFetcher class for retrieving cDNA sequence from the Ensembl database
by Ensembl Transcript ID

=cut


=head2 new

Title    : new
Usage    : Constructor
Function : Create a new Bio::SeqFetcher::Ensembl::GeneIDtoGenomicSeq 
           object.
Returns  : A new instance of the class. 
Args     : -species  - the name of the species
           -flanking - the number of flanking bases to retrieve on either
                       end of the gene sequence.
           Database connection info
           -host 'ensembldb.ensembl.org'
           -user 'anonymous'
           -password
           -port

=cut

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  bless $self, $class;

  my ($species, $flanking) = $self->_rearrange(qw(SPECIES FLANKING));
  
  return $self;
}

=head2 description

Returns a string description of the seqfetcher.

=cut
sub description{
return "Returns Ensembl cDNA sequence given an Ensembl Transcript ID";
}

=head2 fetch
  
  Title    : fetch
  Usage    : my @seqs = $sf->fetch(@ids);
  Function : fetches the sequences
  Args     : An array of ids
  Returns  : An array of Bio::Seq objects.

=cut
sub fetch {
  my $self = shift;
  my @ids = @_;
  my @transcripts = $self->_get_transcripts(@_);
  my @seqs = $self->_make_seqs(@transcripts);
  return @seqs;
}



=head2 _get_transcripts

  Internal use.
  Fetches Ensembl Transcript objects by Ensemble Transcript ID.

=cut

sub _get_transcripts {
  my ($self, @ids) = @_; 
  return map {$self->_transcript_adap->fetch_by_stable_id($_)} @ids;
}


=head2 _make_seqs

  Internal use.
  Generates sequence objects from Bio::Ensembl::Genes. 

=cut
sub _make_seqs{
  my ($self,@transcripts) = @_;
  my @seqs;
  foreach (@transcripts){ 
     # according to the docs, Bio::EnsEMBL::Gene doesn't have ->strand, but
     # this works and if you just get the slice it's not right.
     my $strand = $_->strand;
     my $chr = $_->slice->seq_region_name; 
     my $start = $_->start;
     my $end = $_->end;
     my $id = $_->stable_id;
     my $slice = $self->_slice_adap->fetch_by_region('chromosome', $chr, $start, $end, $strand);
     my $seq = Bio::Seq->new(-seq => $slice->seq,
  	                     -id  => $id);
   
     push @seqs, $seq;
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
