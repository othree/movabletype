# Movable Type (r) (C) Six Apart Ltd. All Rights Reserved.
# This code cannot be redistributed without permission from www.sixapart.com.
# For more information, consult your Movable Type license.
#
# $Id$

package MT::DataAPI::Resource::v5::TemplateMap;

use strict;
use warnings;

sub fields {
    [
        {
            name => 'id',
            type => 'MT::DataAPI::Resource::DataType::Integer',
        },
    ];
}

1;

__END__

=head1 NAME

MT::DataAPI::Resource::v5::TemplateMap - Movable Type class for resources definitions of the MT::TemplateMap.

=head1 AUTHOR & COPYRIGHT

Please see the I<MT> manpage for author, copyright, and license information.

=cut
