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


=head2 process

Returns a subref that runs single stranded melt.pl from the 
Unafold tools on the primers and the amplicon for each of the 
primer pairs attached to the sequence. 

Deletes primer pairs for which any of the resulting Tm values 
are below $max_tm (defaults to 65)


=cut

sub process {
    my $self = shift;
    my ($max_tm) = $self->_rearrange([qw(MAXTM)], @args);
    $max_tm ||= 65;

    my $folder = Bio::Tools::Run::Unafold::melt->new(@args);

    my $process = sub {
      my $p3_res = shift;

      my @primer_pairs =  grep {$_->isa('Bio::Tools::Primer3Redux::PrimerPair')} $p3_res->get_SeqFeatures;
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
      my @sfs = grep {} $p3_res->get_SeqFeatures;
      $p3_res->remove_SeqFeatures();

      return $p3_res;
    };

    return $process;
  }

}




=head1 AUTHOR

Cass Johnston <cassjohnston@gmail.com>

=cut

1;
