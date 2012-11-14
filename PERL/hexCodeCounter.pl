#!/usr/bin/perl;
use strict;
use warnings;

# Declare an array to hold the hex codes.
my @hex_codes = ();

# Declare a hash to store words and corresponding counts.
my %hash = ();

# Declare scalars to store keys or values.
my $key;
my $value;

# Declare a variable to hold the number of unique HEX codes.
my $unique_code_count = 0;

#####################################################################################
# Name: validateArg                                                              ###
# Purpose: Read in and validate the command-line argument and act on it          ##
##################################################################################
sub validateArg {
	if (@ARGV == 1) {
		if ($ARGV[0] eq "-txt") {
			readInput;	
			printToTXT;
		}
		elsif ($ARGV[0] eq "-csv") {
			readInput;	
			printToCSV;
		}
		else {
			print "\n    Invalid command-line argument: Options are -txt or -csv.\n";
		}
	}
	else {
		print "\n    Invalid number of command-line arguments: Options are -txt or -csv.\n";
	}
}

###############################################################
# Name: readInput                                          ###
# Purpose: Read in the file contents                       ##
############################################################
sub readInput {
	open(FILEIN, "<miku_hair_hex_codes_all.txt") 
		or die("\n   Unable to open file: miku_hair_hex_codes_all.txt.\n");
		
	my @input = <FILEIN>;

	close(FILEIN);

	# Store each line of input and chomp off the \n.
	foreach my $line (@input) {
		# Break up each line of input into individual words
		push(@hex_codes, split( /\s+/, $line));
	}

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
	# Open a stream to a text file to save the results
	open(FILEOUT, ">miku_hair_hex_codes_unique.txt") 
		or die("\n   Unable to open file: miku_hair_hex_codes_unique.txt.\n");
		
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
	# Open a stream to a text file to save the results
	open(FILEOUT, ">miku_hair_hex_codes_unique.csv") 
		or die("\n   Unable to open file: miku_hair_hex_codes_unique.csv.\n");
		
	# Loop through the hash to print out each key/value pair.
	while (($key, $value) = each(%hash)) {
		 print FILEOUT $key . "," . $value . "\n";
	}

	# Close the file stream.
	close(FILEOUT);	
}

##################
# Main Program ##
################

# Call the sub to validate the command-line argument
validateArg;

