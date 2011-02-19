use strict;
use warnings;

use Bio::Root::Test;

test_begin(-tests => 29,
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

# check that we've got the exon positions in the place:
