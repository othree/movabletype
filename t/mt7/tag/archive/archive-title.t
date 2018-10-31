#!/usr/bin/perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../../lib";    # t/lib
use Test::More;
use MT::Test::Env;
use utf8;
our $test_env;

BEGIN {
    $test_env = MT::Test::Env->new(
        DeleteFilesAtRebuild => 1,
        RebuildAtDelete => 1,
    );
    $ENV{MT_CONFIG} = $test_env->config_file;
}

use Test::Base;
use MT::Test::ArchiveType;

use MT;
use MT::Test;
my $app = MT->instance;

$test_env->prepare_fixture('archive_type');

filters {
    MT::Test::ArchiveType->filter_spec
};

MT::Test::ArchiveType->run_tests;

__END__

=== mt:ArchiveTitle
--- stash
{ cd => 'cd_same_apple_orange', cat_field => 'cf_same_catset_fruit', category => 'cat_apple' }
--- template
<mt:ArchiveList><mt:ArchiveTitle>
</mt:ArchiveList>
--- expected_author
author1
author2
--- expected_php_todo_author
author1
author2
--- expected_author_daily
December  3, 2018
December  3, 2017
December  3, 2016
December  3, 2015
--- expected_author_monthly
December 2018
December 2017
December 2016
December 2015
--- expected_author_weekly
December  2, 2018 - December  8, 2018
December  3, 2017 - December  9, 2017
November 27, 2016 - December  3, 2016
November 29, 2015 - December  5, 2015
--- expected_author_yearly
2018
2017
2016
2015
--- expected_category
cat_compass
cat_eraser
cat_pencil
cat_ruler
--- expected_category_daily
December  3, 2017
December  3, 2018
December  3, 2016
December  3, 2016
December  3, 2018
--- expected_category_monthly
December 2017
December 2018
December 2016
December 2016
December 2018
--- expected_category_weekly
December  3, 2017 - December  9, 2017
December  2, 2018 - December  8, 2018
November 27, 2016 - December  3, 2016
November 27, 2016 - December  3, 2016
December  2, 2018 - December  8, 2018
--- expected_category_yearly
2017
2018
2016
2016
2018
--- expected_todo_contenttype
cd_same_apple_orange
cd_same_same_date
cd_same_apple_orange_peach
cd_same_peach
--- expected_contenttype_author
author1
author2
--- expected_contenttype_author_daily
October 31, 2018
October 31, 2017
--- expected_contenttype_author_monthly
October 2018
October 2017
--- expected_contenttype_author_weekly
October 28, 2018 - November  3, 2018
October 29, 2017 - November  4, 2017
--- expected_contenttype_author_yearly
2018
2017
--- expected_contenttype_category
cat_apple
cat_orange
cat_peach
cat_strawberry
--- expected_contenttype_category_daily
October 31, 2018
October 31, 2017
--- expected_php_todo_contenttype_category_daily
--- expected_contenttype_category_monthly
October 2018
October 2017
--- expected_php_todo_contenttype_category_monthly
--- expected_contenttype_category_weekly
October 28, 2018 - November  3, 2018
October 29, 2017 - November  4, 2017
--- expected_php_todo_contenttype_category_weekly
--- expected_contenttype_category_yearly
2018
2017
--- expected_php_todo_contenttype_category_yearly
--- expected_contenttype_daily
October 31, 2018
October 31, 2017
October 31, 2016
--- expected_contenttype_monthly
October 2018
October 2017
October 2016
--- expected_contenttype_weekly
October 28, 2018 - November  3, 2018
October 29, 2017 - November  4, 2017
October 30, 2016 - November  5, 2016
--- expected_contenttype_yearly
2018
2017
2016
--- expected_daily
December  3, 2018
December  3, 2017
December  3, 2016
December  3, 2015
--- expected_individual
entry_author1_ruler_eraser
entry_author1_ruler_eraser
entry_author1_compass
entry_author2_pencil_eraser
entry_author2_no_category
--- expected_monthly
December 2018
December 2017
December 2016
December 2015
--- expected_page
page_author2_no_folder
page_author2_water
page_author1_coffee
page_author1_coffee
--- expected_weekly
December  2, 2018 - December  8, 2018
December  3, 2017 - December  9, 2017
November 27, 2016 - December  3, 2016
November 29, 2015 - December  5, 2015
--- expected_yearly
2018
2017
2016
2015
