# Movable Type (r) (C) Six Apart Ltd. All Rights Reserved.
# This code cannot be redistributed without permission from www.sixapart.com.
# For more information, consult your Movable Type license.
#
# $Id$

package MT::DataAPI::Endpoint::v2::Asset;

use strict;
use warnings;

use MT::DataAPI::Endpoint::Asset;
use MT::DataAPI::Endpoint::Common;
use MT::DataAPI::Endpoint::v2::Tag;
use MT::DataAPI::Resource;

sub list_openapi_spec {
    +{
        tags       => ['Assets'],
        summary    => 'Retrieve assets in the specified site',
        parameters => [
            { '$ref' => '#/components/parameters/asset_search' },
            { '$ref' => '#/components/parameters/asset_searchFields' },
            { '$ref' => '#/components/parameters/asset_limit' },
            { '$ref' => '#/components/parameters/asset_offset' },
            {
                in          => 'query',
                name        => 'class',
                schema      => { type => 'string' },
                description => 'The target asset class to retrieve. Supported values are image, audio, video, file and any values added by plugins. If you want to retrieve multiple classes, specify the values separated by commas.',
            },
            {
                in     => 'query',
                name   => 'sortBy',
                schema => {
                    type => 'string',
                    enum => [
                        'file_name',
                        'created_by',
                        'created_on',
                    ],
                    default => 'created_on',
                },
                description => <<'DESCRIPTION',
#### file_name

Sort by the filename of each asset.

#### created_by

Sort by the ID of user who created each asset.

#### created_on

(default) Sort by the created time of each asset.

**Default**: created_on
DESCRIPTION
            },
            { '$ref' => '#/components/parameters/asset_sortOrder' },
            { '$ref' => '#/components/parameters/asset_fields' },
            {
                in => 'query',
                name => 'relatedAssets',
                schema => {
                    type => 'integer',
                    enum => [0, 1],
                },
                description => 'If you want to retrieve related assets (e.g. thumbnail, popup html) that generated by original asset, you should specify this parameter as true.',
            },
        ],
        responses => {
            200 => {
                description => 'No Errors.',
                content     => {
                    'application/json' => {
                        schema => {
                            type       => 'object',
                            properties => {
                                totalResults => {
                                    type => 'integer',
                                },
                                items => {
                                    type  => 'array',
                                    items => {
                                        '$ref' => '#/components/schemas/asset',
                                    }
                                },
                            },
                        },
                    },
                },
            },
            404 => {
                description => 'Site not found.',
                content     => {
                    'application/json' => {
                        schema => {
                            '$ref' => '#/components/schemas/ErrorContent',
                        },
                    },
                },
            },
        },
    };
}

sub list {
    my ( $app, $endpoint ) = @_;

    my $res = filtered_list( $app, $endpoint, 'asset' )
        or return;

    +{  totalResults => $res->{count} + 0,
        items =>
            MT::DataAPI::Resource::Type::ObjectList->new( $res->{objects} ),
    };
}

sub get_openapi_spec {
    +{
        tags       => ['Assets'],
        summary    => 'Retrieve single asset by its ID',
        parameters => [
            { '$ref' => '#/components/parameters/asset_fields' },
        ],
        responses => {
            200 => {
                description => 'No Errors.',
                content     => {
                    'application/json' => {
                        schema => {
                            '$ref' => '#/components/schemas/asset',
                        },
                    },
                },
            },
            404 => {
                description => 'Asset (or site) not found.',
                content     => {
                    'application/json' => {
                        schema => {
                            '$ref' => '#/components/schemas/ErrorContent',
                        },
                    },
                },
            },
        },
    };
}

sub get {
    my ( $app, $endpoint ) = @_;

    my ( $blog, $asset ) = context_objects(@_)
        or return;

    run_permission_filter( $app, 'data_api_view_permission_filter',
        'asset', $asset->id, obj_promise($asset) )
        or return;

    $asset;
}

sub get_thumbnail_openapi_spec {
    +{
        tags        => ['Assets'],
        summary     => 'Get thumbnail of an asset',
        description => <<'DESCRIPTION',
This endpoint requires one of parameter 'width' or 'height' or 'scale' Also, cannot use these parameters at same time.
DESCRIPTION
        parameters => [{
                in          => 'query',
                name        => 'width',
                schema      => { type => 'integer' },
                description => "The width of the thumbnail to generate. If this is the only parameter specified then the thumbnail's width will be scaled proportionally to the height. When a value longer than the original image is specified, it will be ignored.",
            },
            {
                in          => 'query',
                name        => 'height',
                schema      => { type => 'integer' },
                description => "The height of the thumbnail to generate. If this is the only parameter specified then the thumbnail's height will be scaled proportionally to the width. When both of height and width are specified, the longer side of the original image will be processed, and the lesser side will be scaled proportionally.",
            },
            {
                in          => 'query',
                name        => 'scale',
                schema      => { type => 'string' },
                description => 'The percentage by which to reduce or increase the size of the current asset.',
            },
            {
                in     => 'query',
                name   => 'square',
                schema => {
                    type => 'integer',
                    enum => [0, 1],
                },
                description => 'If set to "1" then the thumbnail generated will be square, where the length of each side of the square will be equal to the shortest side of the image.',
            },
        ],
        responses => {
            200 => {
                description => 'No Errors.',
                content     => {
                    'application/json' => {
                        schema => {
                            type       => 'object',
                            properties => {
                                height => { type => 'integer' },
                                width  => { type => 'integer' },
                                url    => { type => 'string' },
                            },
                        },
                    },
                },
            },
            404 => {
                description => 'Asset (or site) not found.',
                content     => {
                    'application/json' => {
                        schema => {
                            '$ref' => '#/components/schemas/ErrorContent',
                        },
                    },
                },
            },
        },
    };
}

sub get_thumbnail {
    my ( $app, $endpoint ) = @_;

    my $asset = get(@_) or return;

    if ( !$asset->isa('MT::Asset::Image') ) {
        return $app->error(
            $app->translate(
                'The asset does not support generating a thumbnail file.'),
            400
        );
    }

    my $width  = $app->param('width');
    my $height = $app->param('height');
    my $scale  = $app->param('scale');
    my $square = $app->param('square');

    if ( $width && $width !~ m/^\d+$/ ) {
        return $app->error( $app->translate( 'Invalid width: [_1]', $width ),
            400 );
    }
    if ( $height && $height !~ m/^\d+$/ ) {
        return $app->error(
            $app->translate( 'Invalid height: [_1]', $height ), 400 );
    }
    if ( $scale && $scale !~ m/^\d+$/ ) {
        return $app->error( $app->translate( 'Invalid scale: [_1]', $scale ),
            400 );
    }

    my %param = (
        $width  ? ( Width  => $width )  : (),
        $height ? ( Height => $height ) : (),
        $scale  ? ( Scale  => $scale )  : (),
        ( $square && $square eq 'true' ) ? ( Square => 1 ) : (),
    );

    my ( $thumbnail, $w, $h ) = $asset->thumbnail_url(%param)
        or return $app->error( $asset->error, 500 );

    return +{
        url    => $thumbnail,
        width  => $w,
        height => $h,
    };
}

sub update_openapi_spec {
    +{
        tags        => ['Assets'],
        summary     => 'Update an asset',
        description => <<'DESCRIPTION',
- Authorization is required.
- This method accepts PUT and POST with __method=PUT.

#### Permissions

- Manage Assets
DESCRIPTION
        requestBody => {
            content => {
                'application/x-www-form-urlencoded' => {
                    schema => {
                        type       => 'object',
                        properties => {
                            asset => {
                                '$ref' => '#/components/schemas/asset_updatable',
                            },
                        },
                    },
                },
            },
        },
        responses => {
            200 => {
                description => 'No Errors.',
                content     => {
                    'application/json' => {
                        schema => {
                            '$ref' => '#/components/schemas/asset',
                        },
                    },
                },
            },
            404 => {
                description => 'Asset (or site) not found.',
                content     => {
                    'application/json' => {
                        schema => {
                            '$ref' => '#/components/schemas/ErrorContent',
                        },
                    },
                },
            },
        },
    };
}

sub update {
    my ( $app, $endpoint ) = @_;

    my ( $blog, $orig_asset ) = context_objects(@_)
        or return;
    my $new_asset = $app->resource_object( 'asset', $orig_asset )
        or return;

    save_object( $app, 'asset', $new_asset, $orig_asset, ) or return;

    $new_asset;
}

sub delete_openapi_spec {
    +{
        tags        => ['Assets'],
        summary     => 'Delete an asset',
        description => <<'DESCRIPTION',
- Authorization is required.
- This method accepts DELETE and POST with __method=DELETE.

#### Permissions

- Manage Assets
DESCRIPTION
        responses => {
            200 => {
                description => 'No Errors.',
                content     => {
                    'application/json' => {
                        schema => {
                            '$ref' => '#/components/schemas/asset',
                        },
                    },
                },
            },
            404 => {
                description => 'Asset (or site) not found.',
                content     => {
                    'application/json' => {
                        schema => {
                            '$ref' => '#/components/schemas/ErrorContent',
                        },
                    },
                },
            },
        },
    };
}

sub delete {
    my ( $app, $endpoint ) = @_;

    my ( $blog, $asset ) = context_objects(@_)
        or return;

    run_permission_filter( $app, 'data_api_delete_permission_filter',
        'asset', $asset )
        or return;

    $asset->remove
        or return $app->error(
        $app->translate(
            'Removing [_1] failed: [_2]', $asset->class_label,
            $asset->errstr
        ),
        500
        );

    $app->run_callbacks( 'data_api_post_delete.asset', $app, $asset );

    $asset;
}

sub list_for_entry_openapi_spec {
    +{
        tags       => ['Assets', 'Entries'],
        summary    => 'Retrieve assets that related with specified entry',
        parameters => [
            { '$ref' => '#/components/parameters/asset_limit' },
            { '$ref' => '#/components/parameters/asset_offset' },
            {
                in          => 'query',
                name        => 'class',
                schema      => { type => 'string' },
                description => 'The target asset class to retrieve. Supported values are image, audio, video, file and any values added by plugins. If you want to retrieve multiple classes, specify the values separated by commas.',
            },
            {
                in     => 'query',
                name   => 'sortBy',
                schema => {
                    type => 'string',
                    enum => [
                        'file_name',
                        'created_by',
                        'created_on',
                    ],
                    default => 'created_on',
                },
                description => <<'DESCRIPTION',
#### file_name

Sort by the filename of each asset.

#### created_by

Sort by the ID of user who created each asset.

#### created_on

(default) Sort by the created time of each asset.

**Default**: created_on
DESCRIPTION
            },
            { '$ref' => '#/components/parameters/asset_sortOrder' },
            { '$ref' => '#/components/parameters/asset_fields' },
        ],
        responses => {
            200 => {
                description => 'No Errors.',
                content     => {
                    'application/json' => {
                        schema => {
                            type       => 'object',
                            properties => {
                                totalResults => {
                                    type => 'integer',
                                },
                                items => {
                                    type  => 'array',
                                    items => {
                                        '$ref' => '#/components/schemas/asset',
                                    }
                                },
                            },
                        },
                    },
                },
            },
            404 => {
                description => 'Site or entry not found.',
                content     => {
                    'application/json' => {
                        schema => {
                            '$ref' => '#/components/schemas/ErrorContent',
                        },
                    },
                },
            },
        },
    };
}

sub list_for_entry {
    my ( $app, $endpoint ) = @_;
    return _list_for_entry( $app, $endpoint, 'entry' );
}

sub list_for_page_openapi_spec {
    +{
        tags       => ['Assets', 'Pages'],
        summary    => 'Retrieve assets that related with specified page',
        parameters => [
            { '$ref' => '#/components/parameters/asset_limit' },
            { '$ref' => '#/components/parameters/asset_offset' },
            {
                in          => 'query',
                name        => 'class',
                schema      => { type => 'string' },
                description => 'The target asset class to retrieve. Supported values are image, audio, video, file and any values added by plugins. If you want to retrieve multiple classes, specify the values separated by commas.',
            },
            {
                in     => 'query',
                name   => 'sortBy',
                schema => {
                    type => 'string',
                    enum => [
                        'file_name',
                        'created_by',
                        'created_on',
                    ],
                    default => 'created_on',
                },
                description => <<'DESCRIPTION',
#### file_name

Sort by the filename of each asset.

#### created_by

Sort by the ID of user who created each asset.

#### created_on

(default) Sort by the created time of each asset.

**Default**: created_on
DESCRIPTION
            },
            { '$ref' => '#/components/parameters/asset_sortOrder' },
            { '$ref' => '#/components/parameters/asset_fields' },
        ],
        responses => {
            200 => {
                description => 'No Errors.',
                content     => {
                    'application/json' => {
                        schema => {
                            type       => 'object',
                            properties => {
                                totalResults => {
                                    type => 'integer',
                                },
                                items => {
                                    type  => 'array',
                                    items => {
                                        '$ref' => '#/components/schemas/asset',
                                    }
                                },
                            },
                        },
                    },
                },
            },
            404 => {
                description => 'Site or page not found.',
                content     => {
                    'application/json' => {
                        schema => {
                            '$ref' => '#/components/schemas/ErrorContent',
                        },
                    },
                },
            },
        },
    };
}

sub list_for_page {
    my ( $app, $endpoint ) = @_;
    return _list_for_entry( $app, $endpoint, 'page' );
}

sub _list_for_entry {
    my ( $app, $endpoint, $class ) = @_;

    my ( $blog, $entry ) = context_objects(@_)
        or return;

    run_permission_filter( $app, 'data_api_view_permission_filter',
        $class, $entry->id, obj_promise($entry) )
        or return;

    my %terms = ( class => '*' );
    my %args = (
        join => MT->model('objectasset')->join_on(
            'asset_id',
            {   blog_id   => $blog->id,
                object_ds => 'entry',
                object_id => $entry->id,
            },
        ),
    );
    my $res = filtered_list( $app, $endpoint, 'asset', \%terms, \%args )
        or return;

    +{  totalResults => $res->{count},
        items =>
            MT::DataAPI::Resource::Type::ObjectList->new( $res->{objects} ),
    };
}

sub list_for_tag {
    my ( $app, $endpoint ) = @_;

    my $tag = MT::DataAPI::Endpoint::v2::Tag::_retrieve_tag($app) or return;

    run_permission_filter( $app, 'data_api_view_permission_filter',
        'tag', $tag->id, obj_promise($tag) )
        or return;

    my %terms = ( class => '*' );
    my %args = (
        join => MT->model('objecttag')->join_on(
            undef,
            {   object_id         => \'= asset_id',
                object_datasource => 'asset',
                blog_id           => \'= asset_blog_id',
                tag_id            => $tag->id,
            },
        ),
    );
    my $res = filtered_list( $app, $endpoint, 'asset', \%terms, \%args )
        or return;

    return +{
        totalResults => ( $res->{count} || 0 ),
        items =>
            MT::DataAPI::Resource::Type::ObjectList->new( $res->{objects} ),
    };
}

sub list_for_site_and_tag_openapi_spec {
    +{
        tags       => ['Assets', 'Tags'],
        summary    => 'Retrieve assets that related with specified tag',
        parameters => [
            { '$ref' => '#/components/parameters/asset_limit' },
            { '$ref' => '#/components/parameters/asset_offset' },
            {
                in          => 'query',
                name        => 'class',
                schema      => { type => 'string' },
                description => 'The target asset class to retrieve. Supported values are image, audio, video, file and any values added by plugins. If you want to retrieve multiple classes, specify the values separated by commas.',
            },
            {
                in     => 'query',
                name   => 'sortBy',
                schema => {
                    type => 'string',
                    enum => [
                        'file_name',
                        'created_by',
                        'created_on',
                    ],
                    default => 'created_on',
                },
                description => <<'DESCRIPTION',
#### file_name

Sort by the filename of each asset.

#### created_by

Sort by the ID of user who created each asset.

#### created_on

(default) Sort by the created time of each asset.

**Default**: created_on
DESCRIPTION
            },
            { '$ref' => '#/components/parameters/asset_sortOrder' },
            { '$ref' => '#/components/parameters/asset_fields' },
        ],
        responses => {
            200 => {
                description => 'No Errors.',
                content     => {
                    'application/json' => {
                        schema => {
                            type       => 'object',
                            properties => {
                                totalResults => {
                                    type => 'integer',
                                },
                                items => {
                                    type  => 'array',
                                    items => {
                                        '$ref' => '#/components/schemas/asset',
                                    }
                                },
                            },
                        },
                    },
                },
            },
            404 => {
                description => 'Site or tag not found.',
                content     => {
                    'application/json' => {
                        schema => {
                            '$ref' => '#/components/schemas/ErrorContent',
                        },
                    },
                },
            },
        },
    };
}

sub list_for_site_and_tag {
    my ( $app, $endpoint ) = @_;

    my ( $tag, $site_id )
        = MT::DataAPI::Endpoint::v2::Tag::_retrieve_tag_related_to_site($app)
        or return;

    run_permission_filter( $app, 'data_api_view_permission_filter',
        'tag', $tag->id, obj_promise($tag) )
        or return;

    my %terms = ( class => '*' );
    my %args = (
        join => MT->model('objecttag')->join_on(
            undef,
            {   object_id         => \'= asset_id',
                object_datasource => 'asset',
                blog_id           => $site_id,
                tag_id            => $tag->id,
            },
        ),
    );
    my $res = filtered_list( $app, $endpoint, 'asset', \%terms, \%args )
        or return;

    return +{
        totalResults => ( $res->{count} || 0 ),
        items =>
            MT::DataAPI::Resource::Type::ObjectList->new( $res->{objects} ),
    };
}

sub upload_openapi_spec {
    +{
        tags        => ['Assets'],
        summary     => 'Upload a file',
        description => <<'DESCRIPTION',
#### Permissions

- upload
DESCRIPTION
        parameters => [{
                in     => 'query',
                name   => 'overwrite_once',
                schema => {
                    type => 'integer',
                    enum => [0, 1],
                },
                description => 'If specify "1", the API always overwrites an existing file with the uploaded file. This parameter is available in Movable Type 6.1.2',
            },
        ],
        requestBody => {
            required => JSON::true,
            content  => {
                'multipart/form-data' => {
                    schema => {
                        type       => 'object',
                        properties => {
                            site_id => {
                                type        => 'integer',
                                description => 'The site ID.',
                            },
                            path => {
                                type        => 'string',
                                description => 'The upload destination. You can specify the path to the under the site path.',
                            },
                            file => {
                                type        => 'string',
                                format      => 'binary',
                                description => 'Actual file data',
                            },
                            autoRenameIfExists => {
                                type        => 'integer',
                                description => 'If this value is "1" and a file with the same filename exists, the uploaded file is automatically renamed to a random generated name. Default is "0".',
                                enum        => [0, 1],
                                default     => 0,
                            },
                            normalizeOrientation => {
                                type        => 'integer',
                                description => 'If this value is "1" and the uploaded file has orientation information in Exif data, this file\'s orientation is automatically normalized. Default is "1".',
                                enum        => [0, 1],
                                default     => 1,
                            },
                        },
                    },
                },
            },
        },
        responses => {
            200 => {
                description => 'No Errors.',
                content     => {
                    'application/json' => {
                        schema => {
                            '$ref' => '#/components/schemas/asset',
                        },
                    },
                },
            },
            404 => {
                description => 'Site not found.',
                content     => {
                    'application/json' => {
                        schema => {
                            '$ref' => '#/components/schemas/ErrorContent',
                        },
                    },
                },
            },
            409 => {
                description => 'Uploaded file already exists.',
                content     => {
                    'application/json' => {
                        schema => {
                            type       => 'object',
                            properties => {
                                error => {
                                    type       => 'object',
                                    properties => {
                                        code    => { type => 'integer' },
                                        message => { type => 'string' },
                                        data    => {
                                            type       => 'object',
                                            properties => {
                                                fileName => { type => 'string' },
                                                path     => { type => 'string' },
                                                temp     => { type => 'string' },
                                            },
                                        },
                                    },
                                },
                            },
                        },
                    },
                },
            },
            413 => {
                description => 'Upload file size is larger than CGIMaxUpload.',
                content     => {
                    'application/json' => {
                        schema => {
                            '$ref' => '#/components/schemas/ErrorContent',
                        },
                    },
                },
            },
        },
    };
}

sub upload {
    my ( $app, $endpoint ) = @_;

    my $site_id = $app->param('site_id');
    if ( !( defined($site_id) && $site_id =~ m/^\d+$/ ) ) {
        return $app->error(
            $app->translate( 'A parameter "[_1]" is required.', 'site_id' ),
            400 );
    }

    $app->param( 'blog_id', $site_id );
    $app->delete_param('site_id');

    my $site = MT->model('blog')->load($site_id);
    $app->blog($site);

    MT::DataAPI::Endpoint::Asset::upload( $app, $endpoint );
}

1;

__END__

=head1 NAME

MT::DataAPI::Endpoint::v2::Asset - Movable Type class for endpoint definitions about the MT::Asset.

=head1 AUTHOR & COPYRIGHT

Please see the I<MT> manpage for author, copyright, and license information.

=cut
