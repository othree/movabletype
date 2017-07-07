# Movable Type (r) (C) 2001-2017 Six Apart, Ltd. All Rights Reserved.
# This code cannot be redistributed without permission from www.sixapart.com.
# For more information, consult your Movable Type license.
#
# $Id$

package MT::ArchiveType::ContentTypeYearly;

use strict;
use base qw( MT::ArchiveType );

use MT::Util qw( remove_html encode_html );

sub name {
    return 'ContentTypeYearly';
}

sub archive_label {
    return MT->translate("CONTENTTYPE-YEARLY_ADV");
}

1;

