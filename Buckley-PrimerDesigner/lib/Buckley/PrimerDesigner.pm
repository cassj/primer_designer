# ABSTRACT: Primer design with bells on.

use strict;
use warnings;

package Buckley::PrimerDesigner;

use base 'Bio::Root::Root';

use Bio::Seq;
use Bio::SeqIO;
use Bio::Tools::Run::Primer3Redux;

use Buckley::PrimerDesigner::Result;

use Scalar::Util qw(blessed);

=head1 NAME

Buckley::PrimerDesigner - Primer3 with bells on.

=head1 DESCRIPTION

Basically a wrapper around Chris Fields's Primer3Redux wrapper
to design primers for multiple sequences, with hooks for
pre-processing of sequences and post- processing of primers

=head1 SYNOPSIS

  my $pd = Buckley::PrimerDesigner->new();

  $pd->primer3->set_parameters(PARAMNAME=>$paramvalue);

  $pd->register_pre_process(name=>'foo', subref=>$asub, description=>"what this does");
  $pd->register_post_process(name=>'bar', suref=>$bsub, description=>"blah blah blah");

  my $PDres = $pd->design(@seqs);

=cut

sub new {
  my($class,@args) = @_;
  my $self = $class->SUPER::new(@args);
  $self->{_primer3} = Bio::Tools::Run::Primer3Redux->new();
  $self->throw("primer3 not found. Is it installed?") unless -x $self->primer3->executable;
  return $self;
}


=head2 primer3

  The instance of Bio::Tools::Run::Primer3Redux that will
  be used to design the primers. See that module's docs for
  full details, but in brief:

  $pd->program_name('my_oddlynamed_p3_binary');  
  $pd->program_dir('/path/to/said/binary');

  my $current_p3_params = $pd->primer3->get_parameters;

  $pd->primer3->set_parameters(PARAMNAME => $value, OTHER_PARAMNAME => $other_value);
  my $val = $pd->primer3->PARAMNAME;
  $pd->primer3->PARAMNAME($value);

=cut

sub primer3{
  my $self = shift;
  return $self->{_primer3};
}


=head2 seq_fetcher

Specify a function to be used to fetch sequences.

If this is undefined then ->design(@seqs) expects @seqs to be an 
array of Bio::Seq objects.

If you have defined a seq_fetcher then it will be called for each 
value of @seqs to create an array of Bio::Seq objects. 


=cut

sub seq_fetcher{
   my $self = shift;
   my $subref = shift;
   $self->{_seq_fetcher} = $subref if defined $subref;
   return $self->{_seq_fetcher};
}



=head2 register_pre_process

  Register a process to be run on each sequence prior to running
  primer3.

  Processes will be run in the order in which they are defined.

  When registering a process, a name must be supplied.
  A optional description of the process may also be supplied.

  By default, a process is a "modifer". It should take a Bio::Seq
  object as a parameter, do something to it and return a Bio::Seq
  object:

    my $pre_process = sub {my $seq = shift;
                           ... do some stuff ...
                           return $modified_seq;
                          }
    $obj->register_pre_process(name         => "my_process",
                               description  => "What my process does",
                               subref       => $pre_process);


  A process can also be a "filter", which should take a Bio::Seq
  object, run some test on that sequence and return true if the
  sequence should be kept and false if it should be discarded:

    my $pre_filter = sub {my $seq = shift;
                          if (...sequence has some characteristic...){
                            return 1; #keep the seq
                          }
                          return;  #discard the seq
                         };

    $obj->register_pre_process(name      => "my_filter",
                               subref    => $pre_filter,
                               is_filter => 1 );


=cut

sub register_pre_process{
  my $self = shift;

  my %params = @_;
  my $name = $params{name} or $self->throw("No name provided");
  my $subref = $params{subref} or $self->throw("No subref provided");
  my $is_filter = $params{is_filter} || 0;
  my $description = $params{description} || '';

  $self->throw("pre_process of that name already exists") if ($self->{_pre_process} && $self->{_pre_process}->{$_});

  $self->{_pre_process}->{$name} = {subref      => $subref,
				    description => $description,
				    is_filter   => $is_filter};

  push @{$self->{_pre_process_order}}, $name;

}

=head2 registered_pre_processes

Returns an arrayref of registered pre-process names

my $pres = $obj->registered_pre_processes;

=cut

sub registered_pre_processes{
  my $self = shift;
  return $self->{_pre_process_order};
}


=head2 register_post_process

  Register a process to be run on each Primer3 result. 

  Processes will be run in the order in which they are defined.

  When registering a process, a name must be supplied.
  A optional description of the process may also be supplied.

  By default, a process is a "modifer". It should take a
  Bio::Tools::Primer3Redux::Result object as a parameter, 
  do something to it and return a Bio::Tools::Primer3Redux::Result
  object

    my $post_process = sub {my $res = shift;
                           ... do some stuff ...
                           return $modified_res;
                          }
    $obj->register_post_process(name         => "my_process",
                                description  => "What my process does",
                                subref       => $post_process);


  A process can also be a "filter", which should take a
  Bio::Tools::Primer3Redux::Result  object, run some test on it
  and return true if the result should be kept and false if it should be discarded:

    my $post_filter = sub {my $res = shift;
                          if (... res has some characteristic...){
                            return 1; #keep the res
                          }
                          return;  #discard the res
                         };

    $obj->register_post_process(name      => "my_filter",
                                subref    => $post_filter,
                                is_filter => 1 );

=cut


sub register_post_process{
  my $self = shift;

  my %params = @_;
  my $name = $params{name} or $self->throw("No name provided");
  my $subref = $params{subref} or $self->throw( "No subref provided");
  my $is_filter = $params{is_filter} || 0;
  my $description = $params{description} || '';

  $self->throw("post_process of that name already exists") if ($self->{_post_process} && $self->{_post_process}->{$_});

  $self->{_post_process}->{$params{name}} = {subref      => $subref,
					    description => $description,
					    is_filter   => $is_filter};
  push @{$self->{_post_process_order}}, $name;

}

=head2 registered_post_processes

Returns an arrayref of registered post-process names

my $pres = $obj->registered_post_processes;

=cut

sub registered_post_processes{
  my $self = shift;
  return $self->{_post_process_order};
}





=head2 design

Runs pre-processing, primer3 and post-processing on the given sequences.

  my $primers = $pd->design(@seqs);

By default, @seqs is expected to be an arrayref of Bio::Seq objects.

Alternatively you can use a seq_fetcher function to resolve an arrayref of
something else into an array of Bio::Seq objects.

You can use a predefined SeqFetcher, For example:

  use Buckley::PrimerDesigner::SeqFetcher::Ensembl::GeneID;
  $pd->seq_fetcher(Buckley::PrimerDesigner::SeqFetcher::Ensembl->by_gene_id(-species => 'mouse', -foo => 'bar'));
  $pd->design(@ensembl_ids);

Or you can define your own function

  my $subref = sub {
    my @seqs = @_;
    ... convert @seqs to Bio::Seq objects somehow ...
    return @bioseqs;
  }
  $pd->seq_fetcher($subref);

C<design> Returns a Buckley::PrimerDesigner::Result object.

my $get_from_ensembl = sub {my $id = shift; ... fetch from ensembl... ; return $bioseq_obj;}
$pd->seq_fetcher($get_from_ensembl);
$pd->design(@ensembl_ids);


=cut

sub design {
  my $self = shift;
  my @seqs = @_;

  $self->throw("No sequences given") unless scalar(@seqs);

  # If we need to, convert the seqs to Bio::Seq objects
  my $sf = $self->seq_fetcher;
  if (defined $sf){
    @seqs = $self->seq_fetcher->fetch(@seqs);
    $self->throw("No sequences returned by seq_fetcher") unless scalar(@seqs);
  }


  # Run any pre-processes on the sequences
  if (defined $self->registered_pre_processes){
    foreach my $proc_name (@{$self->registered_pre_processes}){
      my $proc = $self->{_pre_process}->{$proc_name}->{subref};
      if ($self->{_pre_process}->{$proc_name}->{is_filter} ){
	@seqs = grep { &$proc($_) } @seqs;
      }else{
	@seqs = map { &$proc($_) } @seqs;
      }
    }
  }

  my @results;

  foreach my $seq (@seqs){

    #do we have any sequence specific parameters set?
    my $ac = $seq->annotation;

    my @annot_keys = $ac->get_all_annotation_keys;
    my $test = sub { my $obj = shift; return blessed $obj && $obj->isa('Buckley::Annotation::Parameter::Primer3')};
    my @annots  = grep { &$test([$ac->get_Annotations($_)]->[0]) }  @annot_keys;

    # temporarily set sequence specific annotations, unless they override a global setting
    # Note that this *will* override other local settings, so you if you've got multiple pre-processes
    # registered, you need to make sure that they don't clobber each other's settings. Will improve this at some point.
    my %local_settings;
    foreach (@annots){
      my ($val) = $ac->get_Annotations($_);
      $self->throw("Sequence-specific parameter trying to override global Primer3 parameter $_") if defined $self->primer3->$_;
      $self->warn("Resetting the local value of $_ - this probably means your pre-processes are clobbering each others settings. This may not be what you want") if defined $local_settings{$_};
      $local_settings{$_} = $val->value;
    }

    $self->primer3->set_parameters(%local_settings);

    # and run primer3 with these settings.
    my $res_obj = $self->primer3->run($seq);

    # fetch a Bio::Tools::Primer3Redux::Result object
    my $res = $res_obj->next_result;

    # Do we need to add the original seq features here?
    my $new_seq = $res->get_processed_seq;
    $new_seq->annotation($seq->annotation);
    foreach my $feat ($seq->get_SeqFeatures) { $new_seq->add_SeqFeature($_) }
    
    push @results, $new_seq;

    # reset sequence specific annotations
    foreach (@annots){
       $self->primer3->$_(undef);
    }

  }

  # Run any post-processing on the results
  if (defined $self->registered_post_processes){
    foreach my $proc_name (@{$self->registered_post_processes}){
      my $proc = $self->{_post_process}->{$proc_name}->{subref};
      if ($self->{_post_process}->{$proc_name}->{is_filter} ){
	@results = grep { &$proc($_) } @results;
      }else{
	@results = map { &$proc($_) } @results;
      }
    }

  }

  return @results;
}




=head1 AUTHOR 

Cass Johnston <cassjohnston@gmail.com>

=cut

1;
