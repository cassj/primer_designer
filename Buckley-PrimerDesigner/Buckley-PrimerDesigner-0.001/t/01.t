use strict;
use warnings;

use Bio::Root::Test;
use Bio::Seq;

test_begin(-tests => 24);
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

ok(my @res = $pd->design($seq1, $seq2));
isa_ok($res[0], 'Bio::Tools::Primer3Redux::Result');


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
isa_ok($res[0], 'Bio::Tools::Primer3Redux::Result');



# ok, so we can successfully design primers to a sequence. 
# can we defined a pre-processing thing to that sequence that
# will alter the design?

use Buckley::Annotation::Parameter::Primer3;

# A sub that adds a SEQUENCE_TARGET that primer pairs must flank.
my $pp = sub {
  my $seq = shift;
  my $param = Buckley::Annotation::Parameter::Primer3->new(-value => '100,10');  # format is <start>,<len> <start><len>
  $seq->annotation->add_Annotation('SEQUENCE_TARGET', $param);
  return $seq;
};

$pd->register_pre_process(name      => "pp",
			  subref    => $pp,
			  is_filter => 0 );

ok(@res = $pd->design($seq1));
isa_ok($res[0], 'Bio::Tools::Primer3Redux::Result');


# we should try a filter here too.


# Do post-processes work...?

use Bio::Tools::Run::Unafold::melt;

# A sub that runs melt.pl on all each of the primers and discards any
# with a higher value than x
my $x = 40;
my $folder = Bio::Tools::Run::Unafold::melt->new();

$folder->NA('DNA');
$folder->temperature('37');

my $postp = sub {
  my $p3_res = shift;

  # The rewind function doesn't appear to work, so
  # if we use teh iterator once, all our data's gone.
  # So kludge for now. Need to find out how this is supposed to work.
  my $n_primers = $p3_res->num_primer_pairs;
  foreach (keys %{$p3_res->{feature_data}}){
    my $this =  $p3_res->{feature_data}->{$_};
    my $lp = $this->{LEFT};
    my $rp = $this->{RIGHT};
    my $seq =  Bio::PrimarySeq->new ( -seq => $lp->{sequence} );
    my $lp_fold = $folder->run($seq );
    $lp->{melt_Tm} = $lp_fold->{Tm};
    $seq =  Bio::PrimarySeq->new ( -seq => $rp->{sequence} );
    my $rp_fold = $folder->run($seq);
    $rp->{melt_Tm} = $rp_fold->{Tm};
  }

  return $p3_res;
};

$pd = Buckley::PrimerDesigner->new(-verbose => $debug);
$pd->primer3->set_parameters( %dc_params );

$pd->register_post_process(name      => "postp",
			   subref    => $postp,
			   is_filter => 0 );

ok(@res = $pd->design($seq1));
isa_ok($res[0], 'Bio::Tools::Primer3Redux::Result');

my $pair = $res[0]->next_primer_pair;
isa_ok($pair, 'Bio::Tools::Primer3Redux::PrimerPair');

my $fwd = $pair->forward_primer();
isa_ok($fwd, 'Bio::Tools::Primer3Redux::Primer');

ok($fwd->get_tag_values('melt_Tm'));



# Can we call the same things from a class?

# What about seq fetchers?
my $sf = sub {
  my @seqs = @_;
  #just submit the same sequence twice for now.
  @seqs = (@seqs, @seqs);
  return @seqs;  
};

$pd = Buckley::PrimerDesigner->new(-verbose => $debug);
$pd->primer3->set_parameters( %dc_params );
$pd->seq_fetcher($sf);


ok(@res = $pd->design($seq1));
isa_ok($res[0], 'Bio::Tools::Primer3Redux::Result');
isa_ok($res[1], 'Bio::Tools::Primer3Redux::Result');

