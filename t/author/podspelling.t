use strict;
use warnings;
use Test::More;
use Test::Spelling 0.11;

plan( skip_all => 'Author test.  Set $ENV{TEST_AUTHOR} to a true value to run.' )
    unless $ENV{TEST_AUTHOR};

set_spell_cmd 'aspell list';
add_stopwords(<DATA>);
all_pod_files_spelling_ok;

__DATA__
stdout
stdin
stderr
