use strict;
use warnings;

use Bio::Root::Test;

test_begin(-tests => 6,
           -requires_modules => [qw()],
           -requires_networking => 0);

is(1,1,"an example test");


# test the base class.
use_ok('Bio::SeqFetcher');
ok(my $sf = Bio::SeqFetcher->new());
isa_ok($sf, 'Bio::SeqFetcher');
can_ok($sf, 'fetch');
throws_ok {$sf->fetch} qr/should be implemented in Bio::SeqFeature subclasses/, 'error ok if using abstract base';

