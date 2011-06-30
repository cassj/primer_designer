use strict;
use warnings;
use Error qw(:try);

package Buckley::PrimerDesigner::PreProcess::RepeatMask;
BEGIN {
  $Buckley::PrimerDesigner::PreProcess::RepeatMask::VERSION = '0.001';
}
use base 'Buckley::PrimerDesigner::PreProcess';

use Bio::Tools::Run::RepeatMasker;
use Buckley::Annotation::Parameter::Primer3;
use Scalar::Util qw(blessed);

# override new to grab parameters
sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  bless $self, $class;

  $self->{_params} = \@_;

  return $self;
}



sub process{
  my ($self, $seq) = @_;
 
  my $rpt_masker = Bio::Tools::Run::RepeatMasker->new(@{$self->{_params}});
  my @masked_feats;
  my $masked_seq;

  my $rm_run = eval {
    # this throws an exception if no rpts are found cos it can't find the result file
    # for reasons I can't quite figure out, try catch doesn't work.
    @masked_feats = $rpt_masker->run($seq);
    1;
  }or do {



    my $e;
    {
      local $@; # protect existing $@
      eval { @masked_feats = $rpt_masker->run($seq);
      };
      $@ =~ /nefarious/ and $e = $@;
    }
    die $e if defined $e
      #    my $e = $@;
    #    throw $e unless $e =~ /No such file or directory/;
    #    warn "No repeat regions found";
    #    die "meh";
  }
  
    

    #    use Data::Dumper;
    #    warn Dumper \@masked_feats;
    #    $masked_seq = $rpt_masker->masked_seq;
    #    
    #    foreach (@masked_feats){
    #      
    #      print REPORT "Masked region: ".$_->start." to ".$_->end. ' length '.($_->end - $_->start)."\n";
    #      print REPORT $_->primary_tag."\n";
    #      print REPORT $target_seq->subseq($_->start,$_->end)."\n\n";
    #    }



#  my $seq_target = '';
#  for my $feat ($seq->get_SeqFeatures) {
#    if(blessed $feat && $feat->isa('Bio::SeqFeature::ExonBoundary')){
#      my $pos = $feat->start;
#      $seq_target ="$seq_target $pos,1"; # format is '<start>,<len> <start><len>'
#    }
#  }
#  $seq_target = substr($seq_target, 1, length($seq_target)); #remove leading space
#  $seq_target = Buckley::Annotation::Parameter::Primer3->new(-value => $seq_target);
#  $seq->annotation->add_Annotation('SEQUENCE_TARGET', $seq_target);
  
#  return $seq;
}



sub description {
  return "Adds a primer3 SEQUENCE_EXCLUDED_REGION parameter for any repeats in the sequence as determined by RepeatMasker";
}


1;

__END__
=pod

=head1 NAME

Buckley::PrimerDesigner::PreProcess::RepeatMask

=head1 VERSION

version 0.001

=head1 DESCRIPTION

=head2 process

Uses RepeatMasker to checks a Bio::Seq object for repeat 
regions.

If found, adds a sequence-specific primer3 SEQUENCE_EXCLUDED_REGION
parameter which means primers must not overlap the specified region


=head2 description

=head1 NAME

Buckley::PrimerDesigner::PreProcess::RepeatMask - PrimerDesigner pre-process

=head1 AUTHOR

Cass Johnston <cassjohnston@gmail.com>

=head1 AUTHOR

Cass Johnston <cassjohnston@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Cass Johnston.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

