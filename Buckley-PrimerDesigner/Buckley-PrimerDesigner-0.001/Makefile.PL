
use strict;
use warnings;



use ExtUtils::MakeMaker 6.31;



my %WriteMakefileArgs = (
  'ABSTRACT' => 'Primer design with bells on.',
  'AUTHOR' => 'Cass Johnston <cassjohnston@gmail.com>',
  'BUILD_REQUIRES' => {
    'Bio::Root::Test' => '0',
    'Bio::SeqFetcher::Ensembl::TranscriptIDtocDNASeq::WithExons' => '0',
    'Bio::Tools::Run::Unafold::melt' => '0'
  },
  'CONFIGURE_REQUIRES' => {
    'ExtUtils::MakeMaker' => '6.31'
  },
  'DISTNAME' => 'Buckley-PrimerDesigner',
  'EXE_FILES' => [],
  'LICENSE' => 'perl',
  'NAME' => 'Buckley::PrimerDesigner',
  'PREREQ_PM' => {
    'Bio::Annotation::SimpleValue' => '0',
    'Bio::Root::Root' => '0',
    'Bio::Seq' => '0',
    'Bio::SeqIO' => '0',
    'Bio::Tools::Run::Primer3Redux' => '0',
    'Scalar::Util' => '0'
  },
  'VERSION' => '0.001',
  'test' => {
    'TESTS' => 't/*.t'
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



