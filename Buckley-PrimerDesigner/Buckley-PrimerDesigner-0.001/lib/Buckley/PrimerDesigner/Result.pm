# ABSTRACT: Primer design with bells on.

# Don't think this is actually being used for anything. 
# Delete?

use strict;
use warnings;

package Buckley::PrimerDesigner::Result;
BEGIN {
  $Buckley::PrimerDesigner::Result::VERSION = '0.001';
}
use base 'Bio::Root::Root';


sub new {
  my $class = shift;
  my $self = {};
  bless {}, $class;
  return $self;
}



1;

__END__
=pod

=head1 NAME

Buckley::PrimerDesigner::Result - Primer design with bells on.

=head1 VERSION

version 0.001

=head1 SYNOPSIS

=head1 DESCRIPTION

A class to store the results of a L<Buckley::PrimerDesigner> run.
Includes methods to output the results textually and graphically.

=head1 NAME

Bio::PrimerDesigner::Result - A class to store results from Buckley::PrimerDesigner

=head1 AUTHOR 

Cass Johnston <cassjohnston@gmail.com>

=head1 AUTHOR

Cass Johnston <cassjohnston@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Cass Johnston.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

