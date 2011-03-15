package PrimerDesigner::Schema::UserRole;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("user_role");
__PACKAGE__->add_columns(
  "user_id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "role_id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("user_id", "role_id");
__PACKAGE__->belongs_to("user_id", "PrimerDesigner::Schema::User", { id => "user_id" });
__PACKAGE__->belongs_to("role_id", "PrimerDesigner::Schema::Role", { id => "role_id" });


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2011-03-01 15:16:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:e3ZjvStbeYpcw+mDXtX2ow


# You can replace this text with custom content, and it will be preserved on regeneration
1;
