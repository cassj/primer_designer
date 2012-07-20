use strict;
use warnings;

package Buckley::PrimerDesigner::PostProcess::UnafoldMelt;
use base 'Buckley::PrimerDesigner::PostProcess';

use Bio::Tools::Run::Unafold::melt;
use Bio::Annotation::Collection;
use Buckley::Annotation::Result::Unafold;


=head1 NAME

Buckley::PrimerDesigner::PostProcess::UnafoldMelt - PrimerDesigner post-process

=head1 DESCRIPTION


=head2 new

Constructor can take parameters to be passed to the 
Bio::Tools::Run::Unafold::melt object and a max_tm 
above which primer pairs will be removed.
max_tm defaults to 65.

=cut

sub new{
  my $class = shift;
  my $self = $class->SUPER::new();
  
  #set the cut-off.
  my ($max_tm) = $self->_rearrange([qw(MAX_TM)], @_);
  $self->{max_tm} = $max_tm || 65;

  #create a Bio::Tools::Run::Unafold::melt object
  $self->{_folder} = Bio::Tools::Run::Unafold::melt->new(@_);

  return $self;
}


# internal accessor for the Unafold::melt object
sub _folder {
  my $self = shift;
  return $self->{_folder};
}

=head2 max_tm

  Returns the maximum tm value (set at object construction)

=cut

sub max_tm{
  my $self = shift;
  return $self->{max_tm};
}

#internal function to fold sequences
sub _fold{
  my ($self,$seq_feat) = @_;
  my $folder = $self->_folder;
  my $seq = $seq_feat->seq;
  my $fold = $folder->run( $seq );
  my $ac = $seq_feat->annotation() || Bio::Annotation::Collection->new();
  my $param = Buckley::Annotation::Result::Unafold->new(-value =>  $fold->{Tm});
  $ac->add_Annotation('Tm', $param);
  $seq_feat->annotation($ac);

}

=head2 process

Returns a subref that runs single stranded melt.pl from the 
Unafold tools on the primers and the amplicon for each of the 
primer pairs attached to the sequence. 

Deletes primer pairs for which any of the resulting Tm values 
are below $max_tm (defaults to 65)


=cut

sub process {
  my $self = shift;
  my $p3_res = shift;

  my $folder = $self->_folder;
  
  my @sfs = $p3_res->get_SeqFeatures;

  # this will retrieve PrimerPairs for you to process
  my @primer_pairs = grep {$_->isa('Bio::Tools::Primer3Redux::PrimerPair')} @sfs;
 
  # and this will retrieve single oligos 
  my @oligos = grep {$_->isa('Bio::Tools::Primer3Redux::Primer')  && $_->oligo_type eq 'ss_oligo'} @sfs;
  
  my @new_sfs;
  if (scalar(@primer_pairs)){ 
   #process primer pairs if we have any
    foreach my $pair (@primer_pairs){
      my ($fp, $rp) = ($pair->forward_primer, $pair->reverse_primer);
      $self->_fold($pair);
      $self->_fold($fp);
      $self->_fold($rp);
    }
    @new_sfs = grep {$self->_check_tm($_)} @primer_pairs;
  }else{
    #process single oligos 
    foreach my $probe (@oligos){
      $self->_fold($probe);
    }
    @new_sfs = grep {$self->_check_tm($_)} @oligos;
  }

  #Now remove all seq features, delete the ones that failed and add everything else back.
  my @other = grep {!$_->isa('Bio::Tools::Primer3Redux::PrimerPair')} @sfs;
  $p3_res->remove_SeqFeatures();
  $p3_res->add_SeqFeature(@other);
  $p3_res->add_SeqFeature(@sfs);
  
  return $p3_res;
}


# internal function to check that the unafold results pass.
sub _check_tm {
  my ($self, $feat) = @_;
  my $max_tm = $self->max_tm;
  my ($tm) = $feat->annotation->get_Annotations("Tm");
  return 0 if $tm->value > $max_tm;
  if ($feat->isa('Bio::Tools::Primer3Redux::PrimerPair')){
    my ($fp, $rp) = ($feat->forward_primer, $feat->reverse_primer);
    ($tm) = $rp->annotation->get_Annotations("Tm");
    return 0 if $tm->value > $max_tm;
    ($tm) = $rp->annotation->get_Annotations("Tm");
    return 0 if $tm->value > $max_tm;
  }
  return 1;
}




=head2 description

=cut
sub description {
  return "Runs UNAfold on all of the primers and amplicons and removes primer pairs whose self-binding Tm is too high";
}

=head1 AUTHOR

Cass Johnston <cassjohnston@gmail.com>

=cut

1;
