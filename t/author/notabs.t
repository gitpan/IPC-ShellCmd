use Test::More;
use Test::NoTabs;
use FindBin qw($Bin);
use Cwd qw(abs_path);
plan( skip_all => 'Author test.  Set $ENV{TEST_AUTHOR} to a true value to run.' )
    unless $ENV{TEST_AUTHOR};
all_perl_files_ok(abs_path("$Bin/../../lib"));

