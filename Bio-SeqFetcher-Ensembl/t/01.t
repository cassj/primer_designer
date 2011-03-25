use strict;
use warnings;

use Bio::Root::Test;

test_begin(-tests => 34,
           -requires_modules => [qw()],
           -requires_networking => 0);

is(1,1,"an example test");

use_ok('Bio::SeqFetcher::Ensembl');

ok(my $sf = Bio::SeqFetcher::Ensembl->new(-species => "human"));

isa_ok($sf, 'Bio::SeqFetcher::Ensembl');

is($sf->_registry, 'Bio::EnsEMBL::Registry');


# GeneIDtoGenomicSeq
# Just gets the sequence of the gene. No annotation.
use_ok('Bio::SeqFetcher::Ensembl::GeneIDtoGenomicSeq');
ok($sf = Bio::SeqFetcher::Ensembl::GeneIDtoGenomicSeq->new( -species     => "mouse"));
my @ids = ('ENSMUSG00000029249', 'ENSMUSG00000037395'); # +ve strand and -ve strand respectively.
ok( my @seqs = $sf->fetch(@ids) );
isa_ok($seqs[0], 'Bio::Seq'); 
ok($seqs[0]->seq =~ /^AGCGTCCTGTGCTGGAATGTGCGGCTCCCGCGAGCTCGCGGCGCAGCAGCAGAAGACCGA/); 
ok($seqs[1]->seq =~ /^GGGGCGGTGATGGCGGCTCCATATTAACACCTCCTCCTCCTCCTCCGCGCTCCCGCCCGC/); 
is($seqs[0]->display_id, $ids[0], "display ID set ok");




# GeneIDtoGenomicSeqPromoter
# Just gets the sequence of the gene around the promoter, with the specified distances
use_ok('Bio::SeqFetcher::Ensembl::GeneIDtoGenomicSeq::Promoter');
ok($sf = Bio::SeqFetcher::Ensembl::GeneIDtoGenomicSeq::Promoter->new( -species => "mouse", 
                                                                      -upstream => 100, 
                                                                      -downstream => 300) );
ok( @seqs = $sf->fetch(@ids) );
isa_ok($seqs[0], 'Bio::Seq');
ok($seqs[0]->seq =~ /^CGGGCGGGGAAGGGGGCGTGTCGGCGGGCGCGCGCGGACGGCGAGGGGGCGTGTCCGGCG/ );
ok($seqs[1]->seq =~ /^GCTCGGCCGGGTGGCACGGCGCGGGGCGGCGGCGGCGGGGGAGGGGAGGGAGGCGGGGCC/ );


# TranscriptIDtocDNAseq
# Gets the sequence of the transcript. No features

use_ok('Bio::SeqFetcher::Ensembl::TranscriptIDtocDNASeq');
ok($sf = Bio::SeqFetcher::Ensembl::TranscriptIDtocDNASeq->new( -species => "mouse"));

my @t_ids = ('ENSMUST00000080359', 'ENSMUST00000073279');
ok( @seqs = $sf->fetch(@t_ids) );
isa_ok($seqs[0], 'Bio::Seq');

ok($seqs[0]->seq =~ /^AGCGTCCTGTGCTGGAATGTGCGGCTCCCGCGAGCTCGCGGCGCAGCAGCAGAAGACCGA/ );
ok($seqs[1]->seq =~ /^GGGGCGGTGATGGCGGCTCCATATTAACACCTCCTCCTCCTCCTCCGCGCTCCCGCCCGC/ );

#TranscriptIDtocDNASeq::WithExons
#gets the cDNA sequence of the transcript with exons as features.

use_ok('Bio::SeqFetcher::Ensembl::TranscriptIDtocDNASeq::WithExons');
ok($sf = Bio::SeqFetcher::Ensembl::TranscriptIDtocDNASeq::WithExons->new( -species => "mouse"));

@t_ids = ('ENSMUST00000080359', 'ENSMUST00000073279');
ok( @seqs = $sf->fetch(@t_ids) );
isa_ok($seqs[0], 'Bio::Seq');

ok($seqs[0]->seq =~ /^AGCGTCCTGTGCTGGAATGTGCGGCTCCCGCGAGCTCGCGGCGCAGCAGCAGAAGACCGA/ );
ok($seqs[1]->seq =~ /^GGGGCGGTGATGGCGGCTCCATATTAACACCTCCTCCTCCTCCTCCGCGCTCCCGCCCGC/ );

# check that we've got the exon positions in the right place?

my $pos_seq = $seqs[0];
my $neg_seq = $seqs[1];

# ENSMUST00000080359
# 1: ENSMUSE00000695626	77,694,516	77,694,813  (len = 298)
# 2: ENSMUSE00000483844	77,696,957	77,697,848  (len = 892)

# ENSMUST00000073279
# 1: ENSMUSE00000533409	193,961,621	193,961,892 (len = 272)
# 2: ENSMUSE00000499716	193,961,315	193,961,371 (len = 57)

# positive strand exon-boundary placement?
my @feats = $pos_seq->get_SeqFeatures;
is($feats[0]->start, 298);
is($feats[1]->start, 1190);

# negative strand exon-boundary placement?
@feats = $neg_seq->get_SeqFeatures;
is($feats[0]->start, 272);
is($feats[1]->start, 329);

