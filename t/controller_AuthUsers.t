use strict;
use warnings;
use Test::More;


use Catalyst::Test 'DBAuthTest';
use DBAuthTest::Controller::AuthUsers;

ok( request('/authusers')->is_success, 'Request should succeed' );
done_testing();
