#!/usr/bin/perl;
use strict;
use warnings;

use Cwd;
use Cwd 'abs_path';

# Declare variables to hold the input and output file names.
my $input_file = "";
my $output_file = "";

# Declare an array to hold the hex codes.
my @hex_codes = ();

# Declare a hash to store words and corresponding counts.
my %hash = ();

# Declare scalars to store keys or values.
my $key;
my $value;

# Declare a variable to hold the number of unique HEX codes.
my $unique_code_count = 0;

###############################################################
# Name: readInput                                          ###
# Purpose: Read in the file contents                       ##
############################################################
sub readInput {
	$input_file = abs_path($ARGV[1]);
	
	# Validate file name
	if ($input_file !~ /_all_hex\.txt$/) {
		print "\n    Invalid input file.
			Input file must end with _all_hex.txt.\n";
		exit;
	}
	
	open(FILEIN, "<$input_file") 
		or die("\n   Unable to open file: $input_file.\n");
		
	my @input = <FILEIN>;

	close(FILEIN);
	
	# Validate file format
	foreach(@input) {
		if ($_ !~ /^#[0-9A-F]{6}\n$/) {
			print "\n    Invalid input file format.
				Input file must contain one HEX Code per line.\n";
			exit;
		}
	}
	
	print "\nReading in all HEX Codes.\n";
	# Store each line of input and chomp off the \n.
	foreach my $line (@input) {
		# Break up each line of input into individual words
		push(@hex_codes, split( /\s+/, $line));
	}

	print "\nChecking for and counting number of unique HEX Codes.\n";
	# Loop through each part and check whether it is a key entry in the hash.
	foreach $key (@hex_codes) {
		# If the HEX code exists as a key, increment its value.
		if (exists($hash{$key})) {
			# print "\n    Duplicate detected.\n";
			$hash{$key}++;
		}
		# If the HEX code does not exists as a key, initialize its value to 1
		else {
			$unique_code_count++;
			$hash{$key} = 1;
		}
	}		
}

###############################################################
# Name: printToTxTXT                                       ###
# Purpose: Print out the info to a text file               ##
############################################################
sub printToTXT {
	my @name_grabber = split(/_all_hex/, $input_file);
	$output_file = $name_grabber[0] . "_unique_hex.txt";
	
	# Open a stream to a text file to save the results
	open(FILEOUT, ">$output_file") 
		or die("\n   Unable to open file: $output_file.\n");
	
	print "\nPrinting to: $output_file.\n";
	# Print table header
	printf FILEOUT "%-10.10s %30.30s\n", "HEX CODE", "OCCURENCES";
	print FILEOUT ("-" x 42);
	print FILEOUT "\n";
	# Loop through the hash to print out each key/value pair.
	while (($key, $value) = each(%hash)) {
		 printf FILEOUT "%-10.10s %30.30s\n", $key, $value;
	}

	# Print out totals of interest.
	print FILEOUT "\n    Total # of HEX Codes (Pixels) Analyzed: " . @hex_codes . "\n";
	print FILEOUT "    Total # of Unique HEX Codes: " . $unique_code_count . "\n";

	# Close the file stream.
	close(FILEOUT);	
}

###############################################################
# Name: printToCSV                                         ###
# Purpose: Print out the info to a text file               ##
############################################################
sub printToCSV  {
	my @name_grabber = split(/_all_hex/, $input_file);
	$output_file = $name_grabber[0] . "_unique_hex.csv";

	# Open a stream to a text file to save the results
	open(FILEOUT, ">$output_file") 
		or die("\n   Unable to open file: $output_file.\n");
	
	print "\nPrinting to: $output_file.\n";
	# Loop through the hash to print out each key/value pair.
	while (($key, $value) = each(%hash)) {
		 print FILEOUT $key . "," . $value . "\n";
	}

	# Close the file stream.
	close(FILEOUT);	
}

#####################################################################################
# Name: validateArgs                                                             ###
# Purpose: Read in and validate the command-line arguments and act on them       ##
##################################################################################
sub validateArgs {
	if (@ARGV == 2) {
		if (!( -f $ARGV[1])) {
			print "\n    The second command-line argument must be a file.\n";
			exit;
		}
		if ($ARGV[0] eq "-txt") {
			readInput;	
			printToTXT;
		}
		elsif ($ARGV[0] eq "-csv") {
			readInput;	
			printToCSV;
		}
		else {
			print "\n    Invalid first command-line argument: Options are -txt or -csv.\n";
			exit;
		}		
	}
	else {
		print "\n    Invalid number of command-line arguments: 
			Syntax: perl hexCodeCounter.pl [-txt|-csv] [file] \n";
		exit;
	}
}

##################
# Main Program ##
################

# Call the sub to validate the command-line argument
validateArgs;