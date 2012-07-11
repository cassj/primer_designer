package Buckley::PrimerDesigner::PostProcess::Tile;
use base 'Buckley::PrimerDesigner::PostProcess';

use Bio::Annotation::Collection;
use Buckley::Annotation::Result::TilePosition;
use Graph;
use List::Util qw(min max);

=head1 NAME

Buckley::PrimerDesigner::PostProcess::Tile - PrimerDesigner post-process

=head1 DESCRIPTION


=head2 new


=cut

sub new{
  my $class = shift;
  my $self = $class->SUPER::new();
  my ($min_dist, $max_dist, $opt_dist) = $self->_rearrange([qw(MIN_DIST MAX_DIST OPT_DIST)], @_);


  $min_dist = 0 unless defined $min_dist;
  $max_dist = 99999 unless defined $max_dist;  
  $self->throw('Please define an optimal separation distance') unless defined $opt_dist;
  
  $self->{_min_dist} = $min_dist;
  $self->{_max_dist} = $max_dist;
  $self->{_opt_dist} = $opt_dist;
 
  return $self;
}

=head2 min_dist

Returns the minumum allowable distance between elements of tile, as specified
upon object construction. 

Default is 0

=cut
sub min_dist {
  my $self = shift;
  return $self->{_min_dist};
}


=head2 max_dist

Returns the maximum allowable distance between elements of tile, as specified
upon object construction

Default is 99999

=cut
sub max_dist {
  my $self = shift;
  return $self->{_max_dist};
}

=head2 opt_dist

Returns the optimal distance between elements of tile, as specified
upon object construction

=cut
sub opt_dist {
  my $self = shift;
  return $self->{_opt_dist};
}

=head global

Returns true - this processor operates on the entire set of 
primers / probes

=cut
sub global {
  return 1;
}

=head2 process

Returns a subref that calculates the optimal tile path for
the primers / probes on a sequence.

ll primers are returned, but members of the tile are annotated with 
a Buckley::Annotation::Result::TilePosition annotation.

=cut

sub process {
  my $self = shift;
  my $p3_res = shift;

  my @sfs = $p3_res->get_SeqFeatures;

  # this will retrieve PrimerPairs for you to process
  my @primer_pairs = grep {$_->isa('Bio::Tools::Primer3Redux::PrimerPair')} @sfs;

  # and this will retrieve single oligos 
  my @oligos = grep {$_->isa('Bio::Tools::Primer3Redux::Primer')  && $_->oligo_type eq 'ss_oligo'} @sfs;
 
  # if we have both, use primerpairs as the oligos will be internal.
  # otherwise treat oligos as probes.
  my @sfs =  scalar(@primer_pairs) ? @primer_pairs : @oligos;

  # tile the seq features
  my $g = Graph->new();
  
  # add each seq feature as a node
  # if it has a name, use it, otherwise use position.
  foreach (@sfs){
     my $name = $_->display_name;
     $name = $_->start.'-'.$_->end unless $name;
     $_->display_name($name);
     $g->add_vertex($name)
  }
  my @vs = $g->vertices();

  # Pairwise comparisons of node seq features. 
  # If distance is within allowable range, draw 
  # edge between nodes, weighted by distance proximity
  # to optimal distance.
  # While we're at it, make a note of valid start and end nodes
  my (@valid_starts, @valid_ends);
  my $seq_len = $p3_res->length;
  foreach my $i (@vs){
    foreach my $j (@vs){
      next if $i eq $j; 
      my ($v1) = grep {$_->display_name eq $i} @sfs;
      my ($v2) = grep {$_->display_name eq $j} @sfs;
      next if $v1->start > $v2->start; # skip cases we've already done
      push (@valid_starts, $i) if $v1->start < $self->max_dist;
      push (@valid_ends, $j) if ($seq_len - $v2->end) < $self->max_dist;
      my $dist = $v2->start - $v1->end;
      next if  ($dist < $self->min_dist) || ($dist > $self->max_dist); 
      my $wt = abs($dist-$self->opt_dist);
      $g->add_weighted_edge($i,$j,$wt);
    }
  }

  # we're aiming for best coverage possible, given the constraints of min and max
  # separation distances. Calculate the shortest paths through the graph:

  my $apsp = $g->APSP_Floyd_Warshall();
  my (@path, $length);
  foreach my $start (@valid_starts){
    foreach my $end (@valid_ends){
      my $l = $apsp->path_length($start, $end);
      $length = $l unless $length;
      if ($l < $length){
        $length = $l;
        @path = $apsp->path_vertices($start, $end);
      } 
    }
  } 

  if (scalar(@path)) {
    # We have a successful tile, so remove all seq features and add back just the ones 
    # in that path.
    # keep a note of anything that isn't a primer_designer related seqfeature. 
    my @other = grep {! ($_->isa('Bio::Tools::Primer3Redux::PrimerPair') || $_->isa('Bio::Tools::Primer3Redux::Primer'))} @sfs;
    
    my %lookup = map {$_ => 1} @path;
    my @sfs  = grep {$lookup{$_->display_name}} @sfs;

    $p3_res->remove_SeqFeatures();
    $p3_res->add_SeqFeature(@other);
    $p3_res->add_SeqFeature(@sfs);
 
   }else{
     warn "No valid tiles found";
   }

  return $p3_res;

}



=head2 description

=cut
sub description {
  return "Generates an optimal tile of the primers along the sequence, given an acceptable range of separation distances";
}

=head1 AUTHOR

Cass Johnston <cassjohnston@gmail.com>

=cut

1;
