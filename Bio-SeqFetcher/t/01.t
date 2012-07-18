use strict;
use warnings;

use Bio::Root::Test;

test_begin(-tests => 17,
           -requires_modules => [qw()],
           -requires_networking => 0);

is(1,1,"an example test");


# test the base class.
use_ok('Bio::SeqFetcher');
ok(my $sf = Bio::SeqFetcher->new());
isa_ok($sf, 'Bio::SeqFetcher');
can_ok($sf, 'fetch');
throws_ok {$sf->fetch} qr/should be implemented in Bio::SeqFeature subclasses/, 'error ok if using abstract base';

# test the sequence class using a test fasta file
use_ok('Bio::SeqFetcher::File');
ok($sf = Bio::SeqFetcher::File->new('-file' => 't/seq.fa',
                                    '-species' => 'mouse',
                                    '-build' => 'mm9' ), "B:SF:F constructor ok");
isa_ok($sf, 'Bio::SeqFetcher::File');

is($sf->species, 'mouse', 'species set from file');
is($sf->file, 't/seq.fa', 'file set from file');
is($sf->build, 'mm9', 'build set from file');

ok(my @test = $sf->fetch('test'), 'fetch sequence by id');
is(scalar(@test),1, 'id filter ok');
ok(@test = $sf->fetch(),'fetch all seqs ok');
is(scalar(@test),2,'no filter ok');
isa_ok($test[0], 'Bio::Seq', 'returns Bio::Seq objects');

