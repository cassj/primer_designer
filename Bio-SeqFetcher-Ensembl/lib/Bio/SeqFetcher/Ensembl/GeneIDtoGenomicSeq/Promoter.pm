# ABSTRACT: Fetch promoter sequences by Ensembl ID
package Bio::SeqFetcher::Ensembl::GeneIDtoGenomicSeq::Promoter;
use base 'Bio::SeqFetcher::Ensembl::GeneIDtoGenomicSeq';

use Bio::SeqFeature::Generic;

=head1 NAME

Bio::SeqFetcher::Ensembl::GeneIDtoGenomicSeq::Promoter - sequence fetcher for ensembl gene id to promoter sequence

=head1 SYNOPSIS

 use Bio::SeqFetcher::Ensembl::GeneIDtoGenomicSeq::Promoter
  
 my $fetcher = Bio::SeqFetcher::Ensembl::GeneIDtoGenomicSeq::Promoter->new(-species     => $species,
                                                                           -upstream    => 1000,
                                                                           -downstream  => 500);
 my @bioseqs = $fetcher->(@some_seq_ids);
  

=head1 DESCRIPTION

A SeqFetcher class for retrieving promoter region sequence from the Ensembl database
by Ensembl Gene ID

=cut



=head2 new

Title    : new
Usage    : Constructor
Function : Create a new Bio::SeqFetcher::Ensembl::GeneIDtoGenomicSeq::Promoter
           object.
Returns  : A new instance of the class. 
Args     : -species  - the name of the species
           -upstream - Number of bases upstream of the promoter
           -downstream - Number of bases downstream of the promoter
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

  my ($upstream, $downstream) =
    $self->_rearrange([qw(UPSTREAM DOWNSTREAM)], @_);

  $self->{_upstream} = $upstream;
  $self->{_downstream} = $downstream;

  return $self;
}

sub _upstream{
  my $self = shift;
  return $self->{_upstream};
}

sub _downstream{
  my $self = shift;
  return $self->{_downstream};
}


=head2 _make_seqs

  Internal use

  Takes an array of Bio::Ensembl::Gene objects and creates Bio::Seq 
  objects representing the sequence of their promoters.

=cut

sub _make_seqs{
  my ($self,@genes) = @_;
  my @seqs;
  foreach (@genes){ 
     my $strand = $_->strand;
     my $chr = $_->slice->seq_region_name;
     my $id = $_->stable_id;

     #start and end are always given on the top strand, so:
     
     my ($start, $end);
     if ($strand == 1 ) {
       $start = $_->start;
       $end = $_->start;
       $start = $start - $self->_upstream;
       $end = $end + $self->_downstream;
     }else{
       $start = $_->end;
       $end   = $_->end;
       $start = $start -$self->_downstream;
       $end   = $end + $self->_upstream;
       
     }
      

     my $slice = $self->_slice_adap->fetch_by_region('chromosome', $chr, $start, $end, $strand);
     my $seq = Bio::Seq->new(-seq  => $slice->seq,
                             -id   => $id);
     
     # add a seqfeature for the tss posisition.
     @Bio::SeqFeature::TSS::ISA = 'Bio::SeqFeature::Generic';
     my $feat = Bio::SeqFeature::TSS->new(
					  '-start'  => $self->_upstream,
					  '-end'    => $self->_upstream,
					  '-strand' => 1, # everything should be in transcript direction now.
					  '-display_name' => 'TSS'
					 );
     $seq->add_SeqFeature($feat);
     push @seqs, $seq;
  }
  return @seqs;
}

1;

