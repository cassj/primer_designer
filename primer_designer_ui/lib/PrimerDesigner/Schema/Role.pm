package PrimerDesigner::Schema::Role;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("role");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "role",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->has_many(
  "user_roles",
  "PrimerDesigner::Schema::UserRole",
  { "foreign.role_id" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2011-03-01 15:16:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:46v7NGsAav3VmVeUchOXhA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
