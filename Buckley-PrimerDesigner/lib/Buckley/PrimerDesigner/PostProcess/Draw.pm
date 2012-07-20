package Buckley::PrimerDesigner::PostProcess::Draw;
use base 'Buckley::PrimerDesigner::PostProcess';

use Bio::Graphics;
use File::Spec;

=head1 NAME

Buckley::PrimerDesigner::PostProcess::Draw - PrimerDesigner post-process

=head1 DESCRIPTION


=head2 new

Parameters

 dir  : Directory in which to write image files
 type : Type of image to draw, defaults to png. 

=cut

sub new{
  my $class = shift;
  my $self = $class->SUPER::new();
  my ($dir, $type, $ext) = $self->_rearrange([qw(DIR TYPE EXT)], @_);
  $self->throw("No directory provided for PostProcess::Draw") unless $dir;
  $type = $type ? $type : 'png'; 
  $ext = $ext ? $ext : $type;
  $self->{_dir} = $dir;
  $self->{_type} = $type;
  $self->{_ext} = $ext;
  return $self;
}

=head2 dir

Returns the directory to which images are drawn.
Value is set on object creation.

=cut
sub dir{
  my $self = shift;
  return $self->{_dir};
}

=head2 type

Returns the type of image to be drawn. Default is png.
Value is set on object creation.

=cut
sub type{
 my $self = shift;
 return $self->{_type};
}

=head2 extension

Returns the file extension to be used for pictures.
Default is the value of type.
Value is set on object creation

=cut
sub extension{
  my $self = shift;
  return $self->{_ext};
}


=head2 process

Returns a subref that generates a picture of each sequence illustrating
location of primers / probes

=cut

sub process {
  my $self = shift;
  my $p3_res = shift;

  my @sfs = $p3_res->get_SeqFeatures;

  # this will retrieve PrimerPairs for you to process
  my @primer_pairs = grep {$_->isa('Bio::Tools::Primer3Redux::PrimerPair')} @sfs;
 
  # and this will retrieve single oligos 
  my @oligos = grep {$_->isa('Bio::Tools::Primer3Redux::Primer')  && $_->oligo_type eq 'ss_oligo'} @sfs;
  
  # If we have primer pairs, use those as oligos will be internal, if not use oligos.
  @sfs = scalar @primer_pairs ? @primer_pairs : @oligos;
  
  my $panel = Bio::Graphics::Panel->new(
                                     '-length'      => $p3_res->length,
                                     '-width'       => 1200,
                                     '-pad_left'    => 50,
                                     '-pad_right'   => 50,
                                     '-image_class' => 'GD',
  );
 
  my $full_length = Bio::SeqFeature::Generic->new( '-start' => 1,
                                                   '-end'   => $p3_res->length
  );

  $panel->add_track( $full_length,
                     '-glyph'   => 'arrow',
                     '-tick'    => 2,
                     '-fgcolor' => 'black',
                     '-double'  => 1,             
  );

  $panel->add_track( \@sfs,
                    '-glyph'   => 'segments',
                    '-bgcolor' => 'red',
                    '-label'   => 1

  );
  
  my $id = $p3_res->display_name;
  my $filename = File::Spec->catfile($self->dir, $id);
  $filename.='.'.$self->extension;

  open FILE, ">$filename" or $self->throw("Can't open file $filename for writing");
  #TODO - this should use $self->type not just png.
  print FILE $panel->png;
  close FILE;

  # Return the unaltered resultset.
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
