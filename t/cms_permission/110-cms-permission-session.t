#!/usr/bin/perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";    # t/lib
use Test::More;
use MT::Test::Env;
our $test_env;
BEGIN {
    $test_env = MT::Test::Env->new(
        DefaultLanguage => 'en_US',    ## for now
    );
    $ENV{MT_CONFIG} = $test_env->config_file;
}

use MT::Test;
use MT::Test::Permission;
use MT::Test::Fixture::CmsPermission::Common1;
use MT::Test::App;

sub make_id {
    my @alpha = ('a' .. 'z', 'A' .. 'Z', 0 .. 9);
    my $token = join '', map $alpha[rand @alpha], 1 .. 40;
    $token;
}

### Make test data
$test_env->prepare_fixture('cms_permission/common1');

my $aikawa = MT::Author->load({ name => 'aikawa' });

my $admin = MT::Author->load(1);

# XXX: The following tests are to make sure session items are not exposed by the listing framework
# Everything should be invalid or unknown

subtest 'mode = list' => sub {
    my $app = MT::Test::App->new('MT::App::CMS');
    $app->login($admin);
    $app->post_ok({
        __mode => 'list',
        _type  => 'session',
    });
    ok($app->generic_error =~ m!Unknown Action!i, "list by admin");

    my $sess = MT::Test::Permission->make_session(
        start => time,
        id    => make_id(),
    );
    $app->login($aikawa);
    $app->post_ok({
        __mode => 'list',
        _type  => 'session',
    });
    ok($app->generic_error =~ m!Unknown Action!i, "list by non permitted user");
};

subtest 'mode = save' => sub {
    my $app = MT::Test::App->new('MT::App::CMS');
    $app->login($admin);
    $app->post_ok({
        __mode => 'save',
        _type  => 'session',
        start  => time,
        id     => make_id(),
    });
    $app->has_invalid_request("save by admin");

    $app->login($aikawa);
    $app->post_ok({
        __mode => 'save',
        _type  => 'session',
        start  => time,
        id     => make_id(),
    });
    $app->has_invalid_request("save by non permitted user");
};

subtest 'mode = edit' => sub {
    my $sess = MT::Test::Permission->make_session(
        start => time,
        id    => make_id(),
    );
    my $app = MT::Test::App->new('MT::App::CMS');
    $app->login($admin);
    $app->post_ok({
        __mode => 'edit',
        _type  => 'session',
        id     => $sess->id,
    });
    $app->has_invalid_request("edit by admin");

    $sess = MT::Test::Permission->make_session(
        start => time,
        id    => make_id(),
    );
    $app->login($aikawa);
    $app->post_ok({
        __mode => 'edit',
        _type  => 'session',
        id     => $sess->id,
    });
    $app->has_invalid_request("edit by non permitted user");
};

subtest 'mode = delete' => sub {
    my $sess = MT::Test::Permission->make_session(
        start => time,
        id    => make_id(),
    );
    my $app = MT::Test::App->new('MT::App::CMS');
    $app->login($admin);
    $app->post_ok({
        __mode => 'delete',
        _type  => 'session',
        id     => $sess->id,
    });
    $app->has_invalid_request("delete by admin");

    $sess = MT::Test::Permission->make_session(
        start => time,
        id    => make_id(),
    );
    $app->login($aikawa);
    $app->post_ok({
        __mode => 'delete',
        _type  => 'session',
        id     => $sess->id,
    });
    $app->has_invalid_request("delete by non permitted user");
};

done_testing();
