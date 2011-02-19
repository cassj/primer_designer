# ABSTRACT: Base class for Primer3 parameter sequence annotations.
use strict;
use warnings;
package Buckley::Annotation::Parameter::Primer3;
use base 'Bio::Annotation::SimpleValue';

=head1 NAME

Buckley::Annotation::Parameter::Primer3 - Annotation class for Primer3 SEQUENCE_ params

=head1 DESCRIPTION

This is essentially just a Bio::Annotation::SimpleValue object. 
It is used by Buckley::PrimerDesigner to annotation sequences with 
sequence-specific Primer3 parameters

=head1 SYNOPSIS

  use Bio::Annotation::Collection;
  use Buckley::Annotation::Parameter::Primer3;

  my $col   = Bio::Annotation::Collection->new();
  my $param = Buckley::Annotation::Parameter::Primer3->new(-value => 'param_value');
  $col->add_Annotation('-PARAMNAME', $param);

=head1 AUTHOR 

Cass Johnston <cassjohnston@gmail.com>

=cut

1;
