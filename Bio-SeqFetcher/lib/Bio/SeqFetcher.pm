# ABSTRACT: Abstract base class for sequence fetchers 

=head1 NAME

Bio::SeqFetcher - abstract base class for sequence fetchers

=head1 SYNOPSIS

package Bio::SeqFetcher::Foo;
use base 'Bio::SeqFetcher';

#override new if you need to do some initialisation
sub new{
  my $class = shift;
  my $self = $class::new(@_);
  ... do some stuff. setup a database connection, save params somewhere
      whatever else you need to do to be able to get sequences ...
  bless $self, $class;
  return $self;
}

# define a fetcher. Should take an array of ids objects of some sort 
# and return an array of Bio::Seq objects
sub fetch {
  my $self = shift;
  my $some_other_param; #(say a connection to Ensembl. Or similar.
  my @seq_identifiers = @_;
  ... get sequences on the basis of $seq_identifiers and $some_other_param ...
  return @seq;
}

### and elsewhere..
use Bio::SeqFetcher::Foo;

my $fetcher = Bio::SeqFetcher::Foo->new(-some_param => $some_value);
my @bioseqs = $fetcher->(@some_seq_ids);


=head1 DESCRIPTION

This is an abstract base class for SeqFetcher classes and isn't intended to be
instantiated directly.

Create subclasses that define a function to actually retrieve sequences.

=cut

use strict;
use warnings;
package Bio::SeqFetcher;
use base 'Bio::Root::Root';

=head2 new

Title    : new
Usage    : Constructor
Function : Create a new object of the Bio::SeqFeature subclass. 
           Don't use it to create objects of the base class as they
           won't have any functionality.
Returns  : A new instance of the calss
Args     : None in the base class, but subclasses may override it to
           get parameters they need for sequence retrieval (database 
           access settings, species etc)

=cut

sub new{
  return bless {}, shift;
}


=head2 fetch

Title    : fetch
Usage    : Implemented by subclasses to do something like:
             my @bioseqs = $sf->fetch(@ids);
Function : fetches sequence data from somewhere and constructes Bio::Seq objects from it.
Returns  : An array of Bio::Seq objects (or undef)
Args     : An array of identifiers.
           Global settings, like species, or DB login details should be set in the
           constuctor. If you're trying to pass arguments like "sequence-type" or
           "id-type" to fetch, then you should probably create multiple classes.

=cut

sub fetch{
  my $self = shift;
  $self->throw('fetch should be implemented in Bio::SeqFeature subclasses.');
  return;
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
