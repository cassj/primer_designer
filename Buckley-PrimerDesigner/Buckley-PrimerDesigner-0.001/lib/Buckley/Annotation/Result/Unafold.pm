# ABSTRACT: Class for annotations holding Unafold melt.pl Results.
use strict;
use warnings;
package Buckley::Annotation::Result::Unafold;
BEGIN {
  $Buckley::Annotation::Result::Unafold::VERSION = '0.001';
}
use base 'Bio::Annotation::SimpleValue';


1;

__END__
=pod

=head1 NAME

Buckley::Annotation::Result::Unafold - Class for annotations holding Unafold melt.pl Results.

=head1 VERSION

version 0.001

=head1 SYNOPSIS

  use Bio::Annotation::Collection;
  use Buckley::Annotation::Result::Unafold;

  my $col   = Bio::Annotation::Collection->new();
  my $param = Buckley::Annotation::Result::Unafold->new(-value => 'param_value');
  $col->add_Annotation('-Tm', $param);

=head1 DESCRIPTION

Just a subclass of Bio::Annotation::SimpleValue.

=head1 NAME

Buckley::Annotation::Result::Unafold - Annotation class for Unafold results

=head1 AUTHOR 

Cass Johnston <cassjohnston@gmail.com>

=head1 AUTHOR

Cass Johnston <cassjohnston@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Cass Johnston.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

