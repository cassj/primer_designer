## test the pre and post processing widgets.

use strict;
use warnings;

# force carp instead of die
use Carp;
$SIG{ __DIE__ } = sub { Carp::confess( @_ ) };


use Bio::Root::Test;
use Bio::Seq;
use Buckley::PrimerDesigner;

test_begin(-tests => 19);
my $debug = test_debug();

use_ok('Buckley::PrimerDesigner::PreProcess');
require_ok('Buckley::PrimerDesigner::PreProcess');

use_ok('Buckley::PrimerDesigner::PostProcess');
require_ok('Buckley::PrimerDesigner::PostProcess');

ok(my $pre = Buckley::PrimerDesigner::PreProcess->new, 'pre process instantiation');
ok(my $post = Buckley::PrimerDesigner::PostProcess->new, 'post process instantiation');

## base classes just cry if you try and use them for anything
throws_ok {$pre->process} 'Bio::Root::Exception', 'should be defined by a subclass';
throws_ok {$post->process} 'Bio::Root::Exception', 'should be defined by a subclass';


# test the OverlapExonBoundaries PreProcess, need to use a SeqFetcher that annotates exons:
use Bio::SeqFetcher::Ensembl::TranscriptIDtocDNASeq::WithExons;
my $sf = Bio::SeqFetcher::Ensembl::TranscriptIDtocDNASeq::WithExons->new( -species => "mouse");
my ($seq) = $sf->fetch('ENSMUST00000072119');


# and let's just check the parameter is actually being used.
my $pd = Buckley::PrimerDesigner->new(-verbose => $debug);

#use lenient params so we get something back.
my %params = (
	      PRIMER_TASK                       => 'pick_detection_primers',
	      PRIMER_PICK_LEFT_PRIMER           => 1,
	      PRIMER_PICK_RIGHT_PRIMER          => 1,
	      PRIMER_NUM_RETURN                 => 20,
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



############
# OverlapExonBoundaries PreProcess

use_ok('Buckley::PrimerDesigner::PreProcess::OverlapExonBoundaries');
$pre = Buckley::PrimerDesigner::PreProcess::OverlapExonBoundaries->new();
$pd->register_pre_process($pre);
ok(my @res = $pd->design($seq));
isa_ok($res[0], 'Bio::Seq');


# Should still have Bio::SeqFeature::ExonBoundary features
my @sfs = $res[0]->get_SeqFeatures;
my @e_sfs = grep {$_->isa('Bio::SeqFeature::ExonBoundary')} @sfs;
ok(scalar @e_sfs, "Exon boundary features retained");

# Should have primer3 parameters added
my $ac = $res[0]->annotation;
my @ks = $ac->get_all_annotation_keys;
my @annots = map {$ac->get_Annotations($_)} @ks;
@annots = grep {$_->isa('Buckley::Annotation::Parameter::Primer3')} @annots;
is(scalar @annots, 1, "Primer3 Annotations added");

is($annots[0]->value, '189,1 360,1 522,1 705,1 864,1 1101,1 1242,1 1353,1', 'Exon Boundary Primer 3 param set correctly');

# Should have some primers.
my @pp_sfs = grep {$_->isa('Bio::Tools::Primer3Redux::PrimerPair')} @sfs;
ok(scalar @pp_sfs, "Got some primers");



###########
# Unafold PostProcess

$pd = Buckley::PrimerDesigner->new(-verbose => $debug);
$pd->primer3->set_parameters( %params );

use_ok('Buckley::PrimerDesigner::PostProcess::UnafoldMelt');
#set max_tm to be stupidly high to check we do actually get some results.
$post = Buckley::PrimerDesigner::PostProcess::UnafoldMelt->new(-max_tm => 100);

$pd->register_post_process($post);

ok(@res = $pd->design($seq), "design with post process");
isa_ok($res[0], 'Bio::Seq');

@sfs = $res[0]->get_SeqFeatures;
@pp_sfs = grep {$_->isa("Bio::Tools::Primer3Redux::PrimerPair")} @sfs;
ok(scalar @pp_sfs, "got some primer pairs");

#just check we do actually have the relevant annotations?
my $p = $pp_sfs[0];
ok($p->annotation->get_Annotations('Tm'), "Tm is set by unafold");


