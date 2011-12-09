use strict;
use warnings;

use DBAuthTest;

my $app = DBAuthTest->apply_default_middlewares(DBAuthTest->psgi_app);
$app;

