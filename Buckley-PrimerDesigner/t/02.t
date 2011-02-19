## test the pre and post processing widgets.


use strict;
use warnings;

use Bio::Root::Test;
use Bio::Seq;

test_begin(-tests => 3);
my $debug = test_debug();

use_ok('Buckley::PrimerDesigner');
require_ok('Buckley::PrimerDesigner');

my $seq1 = 'GTGCATAGATTACAGGTCTGTGTCACCACACCAGTCCTTGTTTTGTGAGACAAGGGTTTGTTTCAGTAGTAGCCTGGCCCTGCTGAATTCTTGCTTCTTGAGGCTATTATTAACAAGTCTAGGAAGATAGGTGTGAGCCACAAAACCCTGGCCAGCCTAGCACTCCCTCTCCTGCCTCAGCCTTCTGATGTCTAAGACAAGCAGATGCAGATACTGAGATGGGTGTACTTAGCTTTATTGAACTTTTAGTGTTTGGTTGAATGTTTGATAGTACTGGGCATAGAGTAACTTCAACATTTATCGGAGTTGATTCATTCTGTCAGATACAATCAGAATGGATTGTAACTGTCAACCCTAGAATGGCACTTTGCATATGTATATATGTACAAAAGGGTGGAAGAGTGCTTAGGGCAATTTCAGAAATGGTTGGAAATTCTGCTCTGGTCTCAAAGTGAAACTTTGTTAAATGCTTTGTTTTGTTTTTTAAACTCAAGTTTGTGGCTGTGCATGGTGATGCATAGCTTGAATCCCAGTGACTTCCAGGACAGCCAGGGCTGGACAAATAGAACCCTCTCTGGGGTAGGGTGGACTGGAGGATAGGGTTGGGGGTGACAGGCACAAAACAAGAAAAATTCAGGTCTGCTGTTCTAAAGGGCAAACATTCTAATCCGGTCTGCACACAGTAGGGAAGGATAGAAGGCTTTAGATTCTGAAGTGGGGACCGTTATGTTTCCATAAGACCAGAAACTTCATGTGTGCAGTGAAAATTGCAGTTGCTAACAGCAGTGGTCTGCAGTGTGAGCCAGGGCTCCTAGCTGCTGCATGCACAGACCCCAGTGTTCTGTGCATGGAGAACCAGGGCTACAGGTAGGGCTGCCAGAAACAGCTCAGATTTTATTTTATTATTATGATGTAGTCAGGCTGTCCTGGATTCACAGAAATCCACCTGTCTCCATCTCCCAGTGCTGGGATCAAAGGCTTGTGCCACTACACCTGGCTTAGATTTTGAATTAATTTTA';
$seq1 = Bio::Seq->new( -seq => $seq1,
                       -id  => 'seq_1'
                     );


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

ok(my $pd = Buckley::PrimerDesigner->new(-verbose => $debug));
$pd->primer3->set_parameters( %dc_params );
my @res = $pd->design($seq1);
                  
#this does fuck all. why?  what the hell was it supposed to do?
