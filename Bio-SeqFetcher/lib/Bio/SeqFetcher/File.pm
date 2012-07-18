# ABSTRACT: Fetch sequences from files
package Bio::SeqFetcher::File;

use base 'Bio::SeqFetcher';
use Bio::Seq;
use Bio::SeqIO;
use Scalar::Util qw(blessed);

=head1 NAME

Bio::SeqFetcher::File - fetch sequences from files

=head1 SYNOPSIS

 use Bio::SeqFetcher::File;

 my $fetcher = Bio::SeqFetcher::File->new(-some_param => $some_value);
 my @bioseqs = $fetcher->(@some_seq_ids);


=head1 DESCRIPTION

Retrieves sequences from files (in formats that BioPerl understands)

=cut


=head2 new

Title    : new
Usage    : Constructor
Function : Create a new object of class Bio::SeqFetcher::File
Returns  : A new instance of the class. 
Args     : -type - the type of file to be read.           

=cut

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  bless $self, $class;

  my ($file, $type, $species, $build) = 
    $self->_rearrange([qw(FILE TYPE SPECIES BUILD)], @_);

  $self->throw("Please provide a file") unless $file;
  $self->throw("Please provide species") unless $species;
  $self->throw("Please provide build") unless $build;
  
  $self->throw("Can't open file $file for reading") unless -r $file;
  $self->{_file} = $file; 
  $self->{_species} = $species;  
  $self->{_build} = $build;

  return $self;
}

sub file{
  my $self = shift;
  return $self->{_file};
}

sub species{
  my $self = shift;
  return $self->{_species};
}

sub build{
  my $self = shift;
  return $self->{_build};
}

=head2 description

Returns a string describing the function of this fetcher

=cut

sub description{
  return "Returns sequences from files (that Bioperl knows how to parse)";
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
  my @seqs = $self->_get_seqs(@ids);
  return @seqs;
}

# internal method to pull requested seqs
# from file.
# @ids act as filters, if none are given,all
# sequences will be returned. 
sub _get_seqs{
  my $self = shift;
  my @ids = @_;
  my %lookup = map {$_ => 1} @ids;
    
  my @seqs;
  my $file = $self->file;
  my $seqio = Bio::SeqIO->new(-file => $file);
  while (my $seq = $seqio->next_seq){
    if (scalar(@ids)) {
       my $id = $seq->primary_id;
       next unless ($lookup{$id});
    }
    push @seqs,$seq;
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
