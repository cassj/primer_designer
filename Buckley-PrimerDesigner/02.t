## test the pre and post processing widgets.

use strict;
use warnings;

use Bio::Root::Test;
use Bio::Seq;
use Buckley::PrimerDesigner;

test_begin(-tests => 14);
my $debug = test_debug();

use_ok('Buckley::PrimerDesigner::PreProcess');
require_ok('Buckley::PrimerDesigner::PreProcess');

use_ok('Buckley::PrimerDesigner::PostProcess');
require_ok('Buckley::PrimerDesigner::PostProcess');

ok(my $pre = Buckley::PrimerDesigner::PreProcess->new);
ok(my $post = Buckley::PrimerDesigner::PostProcess->new);


# base classes just cry if you try and use them for anything
throws_ok {$pre->callback} 'Bio::Root::Exception', 'should be defined by a subclass';
throws_ok {$pre->is_filter} 'Bio::Root::Exception', 'should be defined by a subclass';

throws_ok {$post->callback} 'Bio::Root::Exception', 'should be defined by a subclass';
throws_ok {$post->is_filter} 'Bio::Root::Exception', 'should be defined by a subclass';


## test the OverlapExonBoundaries PreProcess, need to use a SeqFetcher that annotates exons:
use Bio::SeqFetcher::Ensembl::TranscriptIDtocDNASeq::WithExons;
my $sf = Bio::SeqFetcher::Ensembl::TranscriptIDtocDNASeq::WithExons->new( -species => "mouse");
my ($seq) = $sf->fetch('ENSMUST00000072119');

use_ok('Buckley::PrimerDesigner::PreProcess::OverlapExonBoundaries');
$pre = Buckley::PrimerDesigner::PreProcess::OverlapExonBoundaries->new();
my $new_seq  = $pre->callback->($seq);

my $anno_col = $new_seq->annotation;
my ($test) =  $anno_col->get_Annotations('SEQUENCE_TARGET');

is($test->value, '189,1 360,1 522,1 705,1 864,1 1101,1 1242,1 1353,1');


# and let's just check the parameter is actually being used.
my $pd = Buckley::PrimerDesigner->new(-verbose => $debug);

#use lenient params so we get something back.
my %params = (
	      PRIMER_TASK                       => 'pick_detection_primers',
	      PRIMER_PICK_LEFT_PRIMER           => 1,
	      PRIMER_PICK_RIGHT_PRIMER          => 1,
	      PRIMER_NUM_RETURN                 => 5,
	      PRIMER_PRODUCT_SIZE_RANGE         => "100-1000",
	      PRIMER_MIN_SIZE                   => 18,
	      PRIMER_OPT_SIZE                   => 20,
	      PRIMER_MAX_SIZE                   => 27,
	      PRIMER_MIN_GC                     => 40,
	      PRIMER_MAX_GC                     => 100,
	      PRIMER_OPT_GC_PERCENT             => 60,
	      PRIMER_MIN_TM                     => 57,
	      PRIMER_OPT_TM                     => 60,
	      PRIMER_MAX_TM                     => 70,
	      PRIMER_PAIR_MAX_DIFF_TM           => 1,
	      PRIMER_TM_FORMULA                 => 1,
	      PRIMER_SALT_CORRECTIONS           => 1,
	      PRIMER_SALT_MONOVALENT            => 50,
	      PRIMER_SALT_DIVALENT              => 0,
	      PRIMER_MAX_TEMPLATE_MISPRIMING    => 10,
	      PRIMER_MAX_NS_ACCEPTED            => 0,
	      PRIMER_MAX_POLY_X                 => 5
	     );
$pd->primer3->set_parameters( %params );

$pd->register_pre_process( name      => "overlap_exons",
			   subref    => $pre->callback,
			   is_filter => 0 );


my @res = $pd->design($seq); 


isa_ok($res[0], 'Bio::Tools::Primer3Redux::Result');

my $pair = $res[0]->next_primer_pair;
isa_ok($pair, 'Bio::Tools::Primer3Redux::PrimerPair');

my ($fp, $rp) = ($pair->forward_primer, $pair->reverse_primer);

#should still test that this is actually flanking an exon, I guess.
#use Data::Dumper;
#warn Dumper $res[0];
















# test the TiledPrimers PostProcess
#use Bio::SeqFetcher::Ensembl::TranscriptIDtocDNASeq::WithExons;
#my $sf = Bio::SeqFetcher::Ensembl::TranscriptIDtocDNASeq::WithExons->new( -species => "mouse");
#my ($seq) = $sf->fetch('ENSMUST00000072119');
#
#use_ok('Buckley::PrimerDesigner::PreProcess::OverlapExonBoundaries');
#$pre = Buckley::PrimerDesigner::PreProcess::OverlapExonBoundaries->new();
#my $new_seq  = $pre->callback->($seq);
#
#my $anno_col = $new_seq->annotation;
#my ($test) =  $anno_col->get_Annotations('SEQUENCE_TARGET');
#
#is($test->value, '189,1 360,1 522,1 705,1 864,1 1101,1 1242,1 1353,1');
#
#
## and let's just check the parameter is actually being used.
#my $pd = Buckley::PrimerDesigner->new(-verbose => $debug);
#
#
#$pd->primer3->set_parameters( %params );
#
#$pd->register_pre_process( name      => "overlap_exons",
#			   subref    => $pre->callback,
##			   is_filter => 0 );
#
#my @res = $pd->design($seq);
#isa_ok($res[0], 'Bio::Tools::Primer3Redux::Result');
#
#my $pair = $res[0]->next_primer_pair;
#isa_ok($pair, 'Bio::Tools::Primer3Redux::PrimerPair');
#
##my ($fp, $rp) = ($pair->forward_primer, $pair->reverse_primer);
#
##should still test that this is actually flanking an exon, I guess.
##use Data::Dumper;
##warn Dumper $res[0];
#





