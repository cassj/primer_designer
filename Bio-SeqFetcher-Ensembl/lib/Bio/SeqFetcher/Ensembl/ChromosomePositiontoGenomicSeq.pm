package Bio::SeqFetcher::Ensembl::ChromosomePositiontoGenomicSeq;

use base 'Bio::SeqFetcher::Ensembl';

=head1 NAME

Bio::SeqFetcher::Ensembl::ChromosomePostiontoGenomicSeq - sequence fetcher for chr position from ensembl to genomic sequence

=head1 SYNOPSIS

 use Bio::SeqFetcher::Ensembl::ChromosomePositiontoGenomicSeq

 my $fetcher = Bio::SeqFetcher::Ensembl::ChromosomePositiontoGenomicSeq->new(-species => $species);
 my @bioseqs = $fetcher->(chr1:12345678-12346758:1, chr3:7849372-7329832:-1);


=head1 DESCRIPTION

A SeqFetcher class for retrieving genomic sequence from the Ensembl database
by Chromosome Position

=cut


=head2 new

Title    : new
Usage    : Constructor
Function : Create a new Bio::SeqFetcher::Ensembl::GeneIDtoGenomicSeq 
           object.
Returns  : A new instance of the class. 
Args     : -species  - the name of the species
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

  my ($species) = $self->_rearrange(qw(SPECIES));

  return $self;
}

=head2 description

returns a string containing a description of this SeqFetcher

=cut
sub description {
  return "Fetches genomic sequence from chromosome position";
}

=head2 fetch
  
  Title    : fetch
  Usage    : my @seqs = $sf->fetch(@pos);
  Function : fetches the sequences
  Args     : An array of ids
  Returns  : An array of Bio::Seq objects.

=cut
sub fetch {
  my $self = shift;
  my @ids = @_;
  my @seqs = $self->_get_seqs(@_);
  return @seqs;
}



=head2 _get_seqs

  Internal use.
  Fetches sequence objects from Ensembl

=cut
sub _get_seqs{
  my ($self, @regions) = @_;
  my @seqs;
  foreach my $region (@regions){
    my ($chr, $se, $strand) = split ':', $region;
    my ($start, $end) = split '-', $se;
    #apparently fetch_by_region doesn't expect the "chr" prefix
    $chr =~ s/chr//;

    my $slice = $self->_slice_adap->fetch_by_region('chromosome', $chr, $start, $end, $strand);
    my $seq = Bio::Seq->new(-seq => $slice->seq,
			    -id  => $region);
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
