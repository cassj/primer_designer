use strict;
use warnings;

use Bio::Root::Test;

test_begin(-tests => 1,
           -requires_modules => [qw()],
           -requires_networking => 0);

use_ok('Bio::SeqFetcher::Ensembl');
ok(my $sf = Bio::SeqFetcher::Ensembl->new(-species => "human"));
isa_ok($sf, 'Bio::SeqFetcher::Ensembl');
is($sf->_registry, 'Bio::EnsEMBL::Registry');


# TranscriptIDtoRNAseq
# Gets the sequence of the transcript as RNA. No features

use_ok('Bio::SeqFetcher::Ensembl::TranscriptIDtoRNASeq');
ok($sf = Bio::SeqFetcher::Ensembl::TranscriptIDtoRNASeq->new( -species => "mouse"));

my @t_ids = ('ENSMUST00000080359', 'ENSMUST00000073279');
ok( my @seqs = $sf->fetch(@t_ids) );
isa_ok($seqs[0], 'Bio::Seq');

ok($seqs[0]->seq =~ /^AGCGTCCTGTGCTGGAATGTGCGGCTCCCGCGAGCTCGCGGCGCAGCAGCAGAAGACCGA/ );
ok($seqs[1]->seq =~ /^GGGGCGGTGATGGCGGCTCCATATTAACACCTCCTCCTCCTCCTCCGCGCTCCCGCCCGC/ );
