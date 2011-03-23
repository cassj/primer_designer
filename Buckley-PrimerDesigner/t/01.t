use strict;
use warnings;

use Bio::Root::Test;
use Bio::Seq;

test_begin(-tests => 23);
my $debug = test_debug();

use_ok('Buckley::PrimerDesigner');
require_ok('Buckley::PrimerDesigner');

can_ok('Buckley::PrimerDesigner', "new");
ok(my $pd = Buckley::PrimerDesigner->new(-verbose => $debug));

isa_ok($pd, 'Buckley::PrimerDesigner');

can_ok($pd, 'register_pre_process');
can_ok($pd, 'registered_pre_processes');
can_ok($pd, 'register_post_process');
can_ok($pd, 'registered_post_processes');
can_ok($pd, 'design');



# ok, start with just running Primer3Redux with default settings and no hooks
my $seq1 = 'GTGCATAGATTACAGGTCTGTGTCACCACACCAGTCCTTGTTTTGTGAGACAAGGGTTTGTTTCAGTAGTAGCCTGGCCCTGCTGAATTCTTGCTTCTTGAGGCTATTATTAACAAGTCTAGGAAGATAGGTGTGAGCCACAAAACCCTGGCCAGCCTAGCACTCCCTCTCCTGCCTCAGCCTTCTGATGTCTAAGACAAGCAGATGCAGATACTGAGATGGGTGTACTTAGCTTTATTGAACTTTTAGTGTTTGGTTGAATGTTTGATAGTACTGGGCATAGAGTAACTTCAACATTTATCGGAGTTGATTCATTCTGTCAGATACAATCAGAATGGATTGTAACTGTCAACCCTAGAATGGCACTTTGCATATGTATATATGTACAAAAGGGTGGAAGAGTGCTTAGGGCAATTTCAGAAATGGTTGGAAATTCTGCTCTGGTCTCAAAGTGAAACTTTGTTAAATGCTTTGTTTTGTTTTTTAAACTCAAGTTTGTGGCTGTGCATGGTGATGCATAGCTTGAATCCCAGTGACTTCCAGGACAGCCAGGGCTGGACAAATAGAACCCTCTCTGGGGTAGGGTGGACTGGAGGATAGGGTTGGGGGTGACAGGCACAAAACAAGAAAAATTCAGGTCTGCTGTTCTAAAGGGCAAACATTCTAATCCGGTCTGCACACAGTAGGGAAGGATAGAAGGCTTTAGATTCTGAAGTGGGGACCGTTATGTTTCCATAAGACCAGAAACTTCATGTGTGCAGTGAAAATTGCAGTTGCTAACAGCAGTGGTCTGCAGTGTGAGCCAGGGCTCCTAGCTGCTGCATGCACAGACCCCAGTGTTCTGTGCATGGAGAACCAGGGCTACAGGTAGGGCTGCCAGAAACAGCTCAGATTTTATTTTATTATTATGATGTAGTCAGGCTGTCCTGGATTCACAGAAATCCACCTGTCTCCATCTCCCAGTGCTGGGATCAAAGGCTTGTGCCACTACACCTGGCTTAGATTTTGAATTAATTTTA';
my $seq2 = 'AGCGTCCTGTGCTGGAATGTGCGGCTCCCGCGAGCTCGCGGCGCAGCAGCAGAAGACCGAGGAGCGCCGCCGAGGCCGCGGGCCCCAGACCCGGGCGGCCGGGACCGCAGCGACGGCAGAACCAGGGCCGGCGGTCTGATCCCGCTCCGCGATCGCACCCCGGGATCTCGAGGGCCTCGAGGGGCGGGATCGAGTTACGGAGCGAGTCACGGGCTGGGCCGGGGGCTGGTGCGGAGCGGCGTGGGCATCGGCCCCCAGCGGAGCACGGGGAGGCCCTTCCGCACGGCGCTGAGATCCGGG';


$seq1 = Bio::Seq->new( -seq => $seq1,
		       -id  => 'seq_1'
		     );


$seq2 = Bio::Seq->new( -seq => $seq2,
		       -id  => 'seq_2'
		     );

ok(my @res = $pd->design($seq1));
ok(@res = $pd->design($seq1, $seq2));

# Design returns the sequences, annotated with primers.
isa_ok($res[0], 'Bio::Seq');


# Now try with some reasonable parameter settings. 
# We'll need to have some kind of 'save these global parameters as' option, I guess

my %dc_params = (
		 PRIMER_TASK                       => 'pick_detection_primers',
		 PRIMER_PICK_LEFT_PRIMER           => 1,
		 PRIMER_PICK_RIGHT_PRIMER          => 1,
		 PRIMER_NUM_RETURN                 => 5,
		 PRIMER_PRODUCT_SIZE_RANGE         => "100-150",
		 PRIMER_MIN_SIZE                   => 18,
		 PRIMER_OPT_SIZE                   => 20,
		 PRIMER_MAX_SIZE                   => 27,
		 PRIMER_MIN_GC                     => 40,
		 PRIMER_MAX_GC                     => 80,
		 PRIMER_OPT_GC_PERCENT             => 60,
		 PRIMER_GC_CLAMP                   => 2,
		 PRIMER_MIN_TM                     => 57,
		 PRIMER_OPT_TM                     => 60,
		 PRIMER_MAX_TM                     => 63,
		 PRIMER_PAIR_MAX_DIFF_TM           => 1,
		 PRIMER_TM_FORMULA                 => 1,
		 PRIMER_SALT_CORRECTIONS           => 1,
		 PRIMER_SALT_MONOVALENT            => 50,
		 PRIMER_SALT_DIVALENT              => 0,
		 PRIMER_MAX_TEMPLATE_MISPRIMING    => 10,
		 PRIMER_MAX_NS_ACCEPTED            => 0,
		 PRIMER_MAX_POLY_X                 => 5
);

$pd->primer3->set_parameters( %dc_params );
ok(@res = $pd->design($seq1));
isa_ok($res[0], 'Bio::Seq');



# ok, so we can successfully design primers to a sequence. 
# can we defined a pre-processing thing to that sequence that
# will alter the design?

use Buckley::Annotation::Parameter::Primer3;

# Mock up a Pre-Process:
use Buckley::PrimerDesigner::PreProcess;
{
  no warnings;
  @Buckley::PrimerDesigner::PreProcess::Test::ISA = 'Buckley::PrimerDesigner::PreProcess';
  *Buckley::PrimerDesigner::PreProcess::Test::new = sub{bless {}, shift};
  # A sub that adds a SEQUENCE_TARGET that primer pairs must flank.
  *Buckley::PrimerDesigner::PreProcess::Test::process =
    sub {
      my $self = shift;
      my $seq = shift;
      my $param = Buckley::Annotation::Parameter::Primer3->new(-value => '100,10');  # format is <start>,<len> <start><len>
      $seq->annotation->add_Annotation('SEQUENCE_TARGET', $param);
      return $seq;
    };
}
my $pp = Buckley::PrimerDesigner::PreProcess::Test->new();

$pd->register_pre_process($pp);
ok(@res = $pd->design($seq1));
isa_ok($res[0], 'Bio::Seq');


# does the seq we get back retain its annotations?
my $ac = $res[0]->annotation;
my @annots = $ac->get_Annotations('SEQUENCE_TARGET');
isa_ok($annots[0], 'Buckley::Annotation::Parameter::Primer3');




# Do post-processes work...?


# Mock up a Pre-Process:
use Buckley::PrimerDesigner::PostProcess;
use Bio::Tools::Run::Unafold::melt;
use Bio::Annotation::Collection;
use Buckley::Annotation::Result::Unafold;

{
  no warnings;
  @Buckley::PrimerDesigner::PostProcess::Test::ISA = 'Buckley::PrimerDesigner::PostProcess';
  *Buckley::PrimerDesigner::PostProcess::Test::new = sub{bless {}, shift};
  # A sub that runs melt.pl on all each of the primers and amplicons
  *Buckley::PrimerDesigner::PostProcess::Test::process = sub {
    my ($self, $p3_res) = @_;

    my $x = 40;
    my $folder = Bio::Tools::Run::Unafold::melt->new();
    $folder->NA('DNA');
    $folder->temperature('37');

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
    return $p3_res;
  };

}
$pp = Buckley::PrimerDesigner::PostProcess::Test->new();

$pd = Buckley::PrimerDesigner->new(-verbose => $debug);
$pd->primer3->set_parameters( %dc_params );

$pd->register_post_process($pp);
ok(@res = $pd->design($seq1));
isa_ok($res[0], 'Bio::Seq');


# Fake a SeqFetcher
{ no warnings;
 @Bio::SeqFetcher::Test::ISA = 'Bio::SeqFetcher';
 *Bio::SeqFetcher::Test::new = sub{return bless {}, shift};
 *Bio::SeqFetcher::Test::fetch = sub {
  my $self = shift;
  my @seqs = @_;
  #just submit the same sequence twice for now.
  @seqs = (@seqs, @seqs);
  return @seqs;
};
}

my $sf = Bio::SeqFetcher::Test->new();
$pd = Buckley::PrimerDesigner->new(-verbose => $debug);
$pd->primer3->set_parameters( %dc_params );
$pd->seq_fetcher($sf); 


ok(@res = $pd->design($seq1));
isa_ok($res[0], 'Bio::Seq');
isa_ok($res[1], 'Bio::Seq');

