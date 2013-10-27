#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use Test::Pod::Coverage 1.04;
plan( skip_all => 'Author test.  Set $ENV{TEST_AUTHOR} to a true value to run.' )
    unless $ENV{TEST_AUTHOR};

all_pod_coverage_ok();
