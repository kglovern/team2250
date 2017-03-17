#!/usr/bin/perl

#
# TODO:
#  - Determine exactly which sta fields we want from crime stats
#  - Output missing fields to error file
#  - Parse population data
#  - Parse economic data
#

#
#   Packages and modules
#
use strict;
use warnings;
use version;   our $VERSION = qv('5.16.0');
use Text::CSV  1.32;

#
#  Variables
#
my $COMMA = q{,};
my $EMPTY = q{};
my $dataLoc = q{data/};
my $csv = Text::CSV->new({ binary=> 1, sep_char => $COMMA });
my $crimeStatsFile;
my $fh;
my $outputStr;
# Arrays
my @records;
my @relevantFields;
# Hashes
my %crimeData;

#
# Check for correct # of args - CHANGE THIS AS WE ADD FILES TO PARSE
#
if ($#ARGV != 0) {
   print "Usage: murderRate.pl <crime data file>\n";
   exit;
} else {
   $crimeStatsFile = $ARGV[0];
}

#
# Attempt to open and parse the crime stats file
#
print "Provided crime stats file: $crimeStatsFile\n";

open $fh, '<', $crimeStatsFile
   or die "Unable to open $crimeStatsFile\n";

@records = <$fh>;

close $fh;

shift @records; #Get rid of header info - we don't need to store that

foreach my $rec ( @records ) {
   if ( $csv->parse($rec) ) {
      my @fields = $csv->fields();
      $crimeData{$fields[0]}{$fields[1]}{$fields[2]}{$fields[3]} = $fields[6];
   } else {
      warn "Could not parse: $rec\n";
   }
}

#
# Output the data into a new file format
#

# What statistic fields we want
@relevantFields = ("Actual incidents",
                   "Rate per 100,000 population",
                   "Total, adult charged",
                   "Total, youth charged");

while (my ($year, $locs) = each %crimeData) {
   my $yearFile = $dataLoc.$year."Crime.csv";

   print "Outputting: $yearFile\n";

   open $fh, ">:encoding(utf8)", $yearFile
      or die "Unable to open $yearFile for writing";

   while (my ($loc, $violations) = each %$locs) {
      while (my ($violation, $stats) = each %$violations) {

         $outputStr = "\"$loc\"".$COMMA."\"$violation\"";

         foreach my $field ( @relevantFields ) {
            if (exists $stats->{$field}) {
               my $value = $stats->{$field};
               $outputStr = $outputStr.$COMMA.$value;
            } else {
               $outputStr = $outputStr.$COMMA."0";
            }
         }
         print $fh $outputStr."\n"; # Print the line to the current file
      }
   }
   close $fh
}

print "\n\nTODO: Reformating population data\n";

print "\n\nTODO: Reformating economic data\n";
