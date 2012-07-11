# ABSTRACT: Class for annotations regarding position in a tile 
use strict;
use warnings;
package Buckley::Annotation::Result::TilePosition;
use base 'Bio::Annotation::SimpleValue';

=head1 NAME

Buckley::Annotation::Result::TilePosition - Annotation class for a tiling of primers or probes

=head1 DESCRIPTION

Just a subclass of Bio::Annotation::SimpleValue.

=head1 SYNOPSIS

  use Bio::Annotation::Collection;
  use Buckley::Annotation::Result::TilePosition;

  my $col   = Bio::Annotation::Collection->new();
  my $tilepos = Buckley::Annotation::Result::TilePosition->new(-position => $pos_in_tile);
  $col->add_Annotation($tilename, $tilepos);

=head1 AUTHOR 

Cass Johnston <cassjohnston@gmail.com>

=cut

1;
