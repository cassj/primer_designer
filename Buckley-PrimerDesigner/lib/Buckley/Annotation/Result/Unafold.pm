# ABSTRACT: Class for annotations holding Unafold melt.pl Results.
use strict;
use warnings;
package Buckley::Annotation::Result::Unafold;
use base 'Bio::Annotation::SimpleValue';

=head1 NAME

Buckley::Annotation::Result::Unafold - Annotation class for Unafold results

=head1 DESCRIPTION

Just a subclass of Bio::Annotation::SimpleValue.

=head1 SYNOPSIS

  use Bio::Annotation::Collection;
  use Buckley::Annotation::Result::Unafold;

  my $col   = Bio::Annotation::Collection->new();
  my $param = Buckley::Annotation::Result::Unafold->new(-value => 'param_value');
  $col->add_Annotation('-Tm', $param);

=head1 AUTHOR 

Cass Johnston <cassjohnston@gmail.com>

=cut

1;
