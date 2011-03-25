use strict;
use warnings;

package Buckley::PrimerDesigner::PostProcess::UnafoldMelt;
use base 'Buckley::PrimerDesigner::PreProcess';

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
  my @primer_pairs = grep {$_->isa('Bio::Tools::Primer3Redux::PrimerPair')} $p3_res->get_SeqFeatures;

  foreach my $pair (@primer_pairs){
    my ($fp, $rp) = ($pair->forward_primer, $pair->reverse_primer);

    my $seq = $pair->seq;
    my $amp_fold = $folder->run( $seq );
    my $ac = $pair->annotation() || Bio::Annotation::Collection->new();
    my $param = Buckley::Annotation::Result::Unafold->new(-value =>  $amp_fold->{Tm});
    $ac->add_Annotation('Tm', $param);
    $pair->annotation($ac);

    $seq =  $fp->seq;
    my $fp_fold = $folder->run( $seq );
    $ac = $fp->annotation() || Bio::Annotation::Collection->new();
    $param = Buckley::Annotation::Result::Unafold->new(-value =>  $fp_fold->{Tm});
    $ac->add_Annotation('Tm', $param);
    $fp->annotation($ac);

    $seq =  $rp->seq;
    my $rp_fold = $folder->run($seq);
    $ac = $rp->annotation() || Bio::Annotation::Collection->new();
    $param = Buckley::Annotation::Result::Unafold->new(-value =>  $rp_fold->{Tm});
    $ac->add_Annotation('Tm', $param);
    $rp->annotation($ac);
  }

  #Now remove all seq features, delete the ones that failed and add everything else back.

  my @sfs = $p3_res->get_SeqFeatures;
  my @other = grep {!$_->isa('Bio::Tools::Primer3Redux::PrimerPair')} @sfs;
  my @primerpairs = grep {$_->isa('Bio::Tools::Primer3Redux::PrimerPair')} @sfs;
  @primerpairs = grep {$self->_check_tm($_)} @primerpairs;

  $p3_res->remove_SeqFeatures();
  $p3_res->add_SeqFeature(@other);
  $p3_res->add_SeqFeature(@primerpairs);
  return $p3_res;
}


# internal function to check that the unafold results pass.
sub _check_tm {
  my ($self, $feat) = @_;
  my $max_tm = $self->max_tm;
  my ($tm) = $feat->annotation->get_Annotations("Tm");
  return 0 if $tm->value > $max_tm;
  my ($fp, $rp) = ($feat->forward_primer, $feat->reverse_primer);
  ($tm) = $rp->annotation->get_Annotations("Tm");
  return 0 if $tm->value > $max_tm;
  ($tm) = $rp->annotation->get_Annotations("Tm");
  return 0 if $tm->value > $max_tm;
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
