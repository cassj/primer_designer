#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use Pod::Usage;
use Module::Find;
use JSON;
use IO::File;
use Data::Dumper;

use Buckley::PrimerDesigner;

# for testing
use Carp;
$SIG{ __DIE__ } = sub { Carp::confess( @_ ) };


######
# Parse Command Line Arguments

my (
    $verbose, $list_pre_processes, $list_post_processes, $list_seq_fetchers, $help,
    $seq_fetcher,
    @pre_processes,
    @post_processes,
    $config_file,
    @ids,
   );

my $result = GetOptions (
			 "seq_fetcher=s"         => \$seq_fetcher,
			 "pre_process=s"         => \@pre_processes,
			 "post_process=s"        => \@post_processes,
			 "config_file=s"         => \$config_file,
			 "identifiers=s"         => \@ids,
			 "verbose"               => \$verbose,
			 "help|h"                => \$help,    
			 "list_pre_processes"    => \$list_pre_processes,
			 "list_post_processes"   => \$list_post_processes,
			 "list_seq_fetchers"     => \$list_seq_fetchers,
 		     );


if($help){
  print "\n\tdesign_primers.pl --seq_fetcher 'Bio::SeqFetcher::Foo', --pre_process 'Buckley::PrimerDesigner::PreProcess::Foo --post_process 'Buckley::PrimerDesigner::PostProcess::Foo' id1 id2 id3 id4...\n";
  print "\n\tdesign_primers.pl --list_seq_fetchers\n";
  print "\n\tdesign_primers.pl --list_pre_processes\n";
  print "\n\tdesign_primers.pl --list_post_processes\n";
  print "\n";

}

if ($list_pre_processes){
  my @mods = useall Buckley::PrimerDesigner::PreProcess;
  print "\n", print_mods(@mods),"\n";
}

if ($list_post_processes){
  my @mods = useall Buckley::PrimerDesigner::PostProcess;
  print "\n", print_mods(@mods),"\n";
}

if ($list_seq_fetchers){
  my @mods = useall Bio::SeqFetcher;
  print"\n", print_mods(@mods),"\n";
}


sub print_mods{
  my $res = "-----\n";
  foreach (@_){
     $res .= "\n".$_."\n\t".$_->description."\n";
  }
  $res.="\n-----\n";
  return $res;
}

exit if ($list_pre_processes || $list_post_processes || $list_seq_fetchers || $help);


#####
# Primer Design

my $pd = Buckley::PrimerDesigner->new();

# Load the config file if we have one
my $config = {};

if($config_file){
  my $fh = new IO::File;
  $fh->open("< $config_file") or die "Couldn't open config file $config_file for reading";
  local $/ = undef;
  my $json = JSON->new->allow_nonref;
  my $json_text = <$fh>;
  $fh->close;
  $config = $json->decode( $json_text ) or die "Can't parse JSON in config file $config_file";

}
# params from config->{Primer3}
my $p3_params = $config->{Primer3};
$pd->primer3->set_parameters( %$p3_params );


# Need a SeqFetcher - can't get Bio::Seq from cmdline:
die "You must defined a sequence fetcher with --seq_fetcher 'Bio::SeqFetcher::XXXXXXX'" unless $seq_fetcher;

# Can we locate the seq fetcher class and instantiate it?
eval "require $seq_fetcher" or die "Couldn't load $seq_fetcher";

# sequence fetcher args from config
my %sf_args = %{$config->{$seq_fetcher} || {}};

#add bioperl style -param_name, just in case
foreach (grep {!/^-/} keys %sf_args){
    $sf_args{"-$_"}= $sf_args{$_};
}

my $sf = $seq_fetcher->new(%sf_args);
$pd->seq_fetcher($sf);

# deal with pre processors if defined
if(scalar @pre_processes){
  foreach (@pre_processes){
    eval "require $_" or die "Couldn't load $_";
    my %proc_args = %{$config->{$_} || {}};
    foreach (grep {!/^-/} keys %proc_args){
	$proc_args{"-$_"}= $proc_args{$_};
    }
    my $proc = $_->new(%proc_args);
    $pd->register_pre_process($proc);
  }
}


# deal with post processors if defined
if(scalar @post_processes){
  foreach (@post_processes){
    eval "require $_" or die "Couldn't load $_";
    my %proc_args = %{$config->{$_} || {} };
    foreach (grep {!/^-/} keys %proc_args){
	$proc_args{"-$_"}= $proc_args{$_};
    }
    my $proc = $_->new(%proc_args);
    $pd->register_post_process($proc);
  }
}


my @res = $pd->design(@ids);

# ok, for now, just print out each of the sequences with their primers:
# will add
foreach my $r (@res){
  print "\n########################\n".$r->display_id,"\n";
  print $r->seq."\n";
  my @pairs = grep {$_->isa('Bio::Tools::Primer3Redux::PrimerPair')} $r->get_SeqFeatures();
  print "No primers found\n" unless scalar @pairs;

  foreach my $p (@pairs){
    my ($amplicon_tm) = $p->annotation->get_Annotations("Tm");
    print "\nPAIR\n-------\nAmplicon MFold Tm: ". $amplicon_tm->value. "\n";
    print "Amplicon Length: ", length $p->seq->seq,"\n";

    my ($fp, $rp) = ($p->forward_primer, $p->reverse_primer);
    print "Forward\n";
    print "\t".$fp->seq->seq,"\n";
    print "\tTm: ", $fp->melting_temp,"\n";
    print "\tGC: ", $fp->gc_content,"\n";
    my ($fp_tm) = $fp->annotation->get_Annotations("Tm");
    print "\tMFold Tm: ". $fp_tm->value. "\n";

    print "Reverse\n";
    print "\t".$rp->seq->seq,"\n";
    print "\tTm: ",$rp->melting_temp,"\n";
    print "\tGC: ", $rp->gc_content,"\n";
    my ($rp_tm) = $rp->annotation->get_Annotations("Tm");
    print "\tMFold Tm: ". $rp_tm->value. "\n";

  }

}


