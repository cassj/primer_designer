# ABSTRACT: Base class for Primer3 parameter sequence annotations.
use strict;
use warnings;
package Buckley::Annotation::Parameter::Primer3;
BEGIN {
  $Buckley::Annotation::Parameter::Primer3::VERSION = '0.001';
}
use base 'Bio::Annotation::SimpleValue';


1;

__END__
=pod

=head1 NAME

Buckley::Annotation::Parameter::Primer3 - Base class for Primer3 parameter sequence annotations.

=head1 VERSION

version 0.001

=head1 SYNOPSIS

  use Bio::Annotation::Collection;
  use Buckley::Annotation::Parameter::Primer3;

  my $col   = Bio::Annotation::Collection->new();
  my $param = Buckley::Annotation::Parameter::Primer3->new(-value => 'param_value');
  $col->add_Annotation('-PARAMNAME', $param);

=head1 DESCRIPTION

This is essentially just a Bio::Annotation::SimpleValue object. 
It is used by Buckley::PrimerDesigner to annotation sequences with 
sequence-specific Primer3 parameters

=head1 NAME

Buckley::Annotation::Parameter::Primer3 - Annotation class for Primer3 SEQUENCE_ params

=head1 AUTHOR 

Cass Johnston <cassjohnston@gmail.com>

=head1 AUTHOR

Cass Johnston <cassjohnston@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Cass Johnston.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

