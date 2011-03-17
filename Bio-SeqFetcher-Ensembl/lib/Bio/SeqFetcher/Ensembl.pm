# ABSTRACT: Base class for Ensembl Sequence Fetchers
package Bio::SeqFetcher::Ensembl;

use base 'Bio::SeqFetcher';
use Bio::EnsEMBL::Registry;
use Bio::Seq;
use Scalar::Util qw(blessed);

=head1 NAME

Bio::SeqFetcher::Ensembl - base clas for Ensembl sequence fetchers

=head1 SYNOPSIS

This class is not intended to be used directly, it is meant to
be subclassed...

 package Bio::SeqFetcher::Ensembl::Foo;
 use base 'Bio::SeqFetcher::Ensembl';

 # define a fetcher. 
 # Will have access to a connection to Ensembl
 sub fetch {
   my $self = shift;
   my @ids = @_;

   ... on the basic of @ids, any other parameters you choose to define and the 
       ensembl connection in $self->ensembldb get @seq

   return @seq;
 }

 ### and elsewhere..
 use Bio::SeqFetcher::Ensembl::Foo;

 my $fetcher = Bio::SeqFetcher::Foo->new(-some_param => $some_value);
 my @bioseqs = $fetcher->(@some_seq_ids);


=head1 DESCRIPTION

This is an abstract base class for SeqFetcher classes and isn't intended to be
instantiated directly.

Create subclasses that define a function to actually retrieve sequences.

=cut


=head2 new

Title    : new
Usage    : Constructor
Function : Create a new object of the Bio::SeqFeature::Ensembl subclass.
           Don't use it to create objects of the base class.
Returns  : A new instance of the class. 
Args     : Database connections args are passed straight through to
           Bio::EnsEMBL::Registry->load_registry_from_db
           -host 'ensembldb.ensembl.org' 
           -user 'anonymous'
           -port
           -password

           You also need to define which species you're using
           -species => $species
           

=cut

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  bless $self, $class;

  my ($host,$port, $user, $password, $species) = 
    $self->_rearrange([qw(HOST PORT USER PASSWORD SPECIES)], @_);

  $self->throw("Please provide species") unless $species;
  $host = 'ensembldb.ensembl.org' unless $host;
  $user = 'anonymous' unless $user;

  # DB connection is a singleton:
  $self->{_registry} = 'Bio::EnsEMBL::Registry';
  $self->{_registry}->load_registry_from_db(
					 -host     => $host,
					 -user     => $user,
					 -port     => $port,
                                         -password => $password
					);


  # Get a slice adaptor
  $self->{_slice_adap} = $self->_registry->get_adaptor(
						       $species,
						       'core',
						       'Slice',
						      );
  $self->throw("Can't get Slice Adaptor. Check your database settings?")
    unless
      (
       blessed ($self->{_slice_adap})
       && $self->{_slice_adap}->isa("Bio::EnsEMBL::DBSQL::SliceAdaptor")
      );

  # and a gene adaptor
  $self->{_gene_adap} = $self->_registry->get_adaptor(
                                                       $species,
                                                       'core',
                                                       'Gene',
                                                     );
  
   $self->throw("Can't get Gene Adaptor. Check your database settings?")
    unless
      (
       blessed ($self->{_gene_adap})
       && $self->{_gene_adap}->isa("Bio::EnsEMBL::DBSQL::GeneAdaptor")
      );

   #and a transcript adaptor
   $self->{_transcript_adap} = $self->_registry->get_adaptor(
                                                             $species,
                                                             'core',
                                                             'Transcript'
                                                             );
   $self->throw("Can't get Transcript Adaptor. Check your database settings?")
    unless
      (
       blessed ($self->{_transcript_adap})
       && $self->{_transcript_adap}->isa("Bio::EnsEMBL::DBSQL::TranscriptAdaptor")
      );

  return $self;
}

=head2 description

Returns a string describing the function of this fetcher

=cut

sub description{
  return "Base class for Ensembl SeqFetchers, do not instantiate directly";
}

=head2 _registry

  Internal use only

=cut

sub _registry{
  my $self = shift;
  return $self->{_registry}
}


=head2 _slice_adap

  Internal use only

=cut

sub _slice_adap{
  my $self = shift;
  return $self->{_slice_adap};
}


=head2 _gene_adap

  Internal use only

=cut

sub _gene_adap{
  my $self = shift;
  return $self->{_gene_adap};
}

=head2 _transcript_adap
  
  Internal use only

=cut

sub _transcript_adap{
  my $self = shift;
  return $self->{_transcript_adap};
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
