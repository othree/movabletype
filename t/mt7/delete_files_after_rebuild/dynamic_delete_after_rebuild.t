use strict;
use warnings;
use FindBin;
use File::Spec;

$ENV{MT_TEST_DELETE_FILES_AFTER_REBUILD} = 1;
$ENV{MT_TEST_REBUILD_ASYNC} = 0;
$ENV{MT_TEST_REBUILD_DYNAMIC} = 1;

my $file = File::Spec->canonpath("$FindBin::Bin/async_delete_after_rebuild.t");
do $file or die "$file: $!";
