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


######
# Parse Command Line Arguments

my (
    $verbose, $list_pre_processes, $list_post_processes, $list_seq_fetchers, $help,
    $seq_fetcher,
    @pre_processes,
    @post_processes,
    $config_file
   );

my $result = GetOptions (
			 "seq_fetcher=s"         => \$seq_fetcher,
			 "pre_process=s"         => \@pre_processes,
			 "post_process=s"        => \@post_processes,
			 "config_file=s"         => \$config_file,
			 "verbose"               => \$verbose,
			 "help|h"                => \$help,    
			 "list_pre_processes"    => \$list_pre_processes,
			 "list_post_processes"   => \$list_post_processes,
			 "list_seq_fetchers"     => \$list_seq_fetchers
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


# Load the config file if we have one
my $config = {};

if($config_file){
  my $fh = new IO::File;
  $fh->open("< $config_file") or die "Couldn't open config file $config_file for reading";
  $/ = undef;
  my $json = JSON->new->allow_nonref;
  my $json_text = <$fh>;
  $fh->close;
  $config = $json->decode( $json_text ) or die "Can't parse JSON in config file $config_file";
  warn Dumper $config;
}



#new primer designer object:
my $pd = Buckley::PrimerDesigner->new();

# params from config->{Primer3}
#$pd->primer3->set_parameters( %params );




# Need a SeqFetcher - can't get Bio::Seq from cmdline:
die "You must defined a sequence fetcher with --seq_fetcher 'Bio::SeqFetcher::XXXXXXX'" unless $seq_fetcher;

# Can we locate the seq fetcher class and instantiate it?
eval "require $seq_fetcher" or die "Couldn't load $seq_fetcher";

#my $sf = new $seq_fetcher($sf_args);
#$pd->seq_fetcher($sf->process);
#
## deal with pre processors if defined
#if(scalar @pre_processes){
#  foreach (@pre_processes){
#    eval "require $_" or die "Couldn't load $_";
#    my $proc = $_->new($proc_args);
#    $pd->register_pre_process(name   => '',
#			      subref => $proc->process
#			     );
#  }
#}
#
#
## deal with post processors if defined
#if(scalar @post_processes){
#  foreach (@post_processes){
#    eval "require $_" or die "Couldn't load $_";
#    my $proc = $_->new();
#    $pd->register_pre_process(name   => '',
#			      subref => $proc->process
#			     );
#  }
#}
#

# run the primer design

#my @res = $pd->design(@ids);


