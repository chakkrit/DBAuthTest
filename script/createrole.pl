use strict;
use warnings;

use FindBin qw($Bin);
use lib '$Bin/../lib';
use Auth::Schema;


use Data::Dumper;

my $rolename = shift;

my $dbfile = 'db/auth.db';
my $schema = Auth::Schema->connect("dbi:SQLite:$dbfile",'','')
or die("$@");

print $schema."\n";

my $roles_rs = $schema->resultset('Role');

my $newrole = $roles_rs->create({ role => $rolename });

print "Created role: ", Dumper({ $newrole->get_columns }); 
