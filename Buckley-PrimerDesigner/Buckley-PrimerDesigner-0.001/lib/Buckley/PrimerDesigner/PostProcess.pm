use strict;
use warnings;

package Buckley::PrimerDesigner::PostProcess;
BEGIN {
  $Buckley::PrimerDesigner::PostProcess::VERSION = '0.001';
}
use base 'Buckley::PrimerDesigner::Process';

sub description {
  return "Base class for PrimerDesigner Post-Processes. Don't use directly.";
}


1;

__END__
=pod

=head1 NAME

Buckley::PrimerDesigner::PostProcess

=head1 VERSION

version 0.001

=head1 SYNOPSIS

  package Buckley::PrimerDesigner::PostProcess::DoSomething;

  {
    my $callback = sub{my $bioseq = shift; ... do some stuff ... return $bioseq || undef;}
    sub callback{ return $callback; }
  }

  1;

And elsewhere:

  my $pd = Buckley::PrimerDesigner->new();
  my $post_proc = Buckley::PrimerDesigner::PostProcess:DoSomething->new();  #blessed subref.
  $pd->register_post_process(name=>'do_stuff', subref=>$post_proc->callback, description=>"a thing which does stuff");
  my $PDres = $pd->design(@seqs);

=head1 DESCRIPTION

PrimerDesigner can just take a subref as a post-process, but if you make it a
subclass of PostProcess instead it will work with the web interface.

=head1 NAME

Buckley::PrimerDesigner::PostProcess - Base class for PostProcesses in PrimerDesigner

=head1 METHODS - from L<Buckley::PrimerDesigner::Process>

=head2 new

Constructor

=head2 process

Should be overridden by subclasses to return a subref to use as a process

=head2 description

=head1 AUTHOR

Cass Johnston <cassjohnston@gmail.com>

=head1 AUTHOR

Cass Johnston <cassjohnston@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Cass Johnston.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

