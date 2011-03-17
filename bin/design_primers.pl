#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use Pod::Usage;

use Module::Find;
use Buckley::PrimerDesigner;

## Parse Command Line Arguments
my (
    $verbose, $list_pre_processes, $list_post_processes, $list_seq_fetchers, $help,
    $seq_fetcher,
    @pre_processes,
    @post_processes,
    $seq_fetcher_params,
    $pre_process_params,
    $post_process_params
   );

my $result = GetOptions (
			 "seq_fetcher=s"         => \$seq_fetcher,
			 "pre_process=s"         => \@pre_processes,
			 "post_process=s"        => \@post_processes,
			 "seq_fetcher_params=s"  => \$seq_fetcher_params,
			 "pre_process_params=s"  => \$pre_process_params,
			 "post_process_params=s" => \$post_process_params,
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



#ok, actually run the primer stuff.

