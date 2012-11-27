#!/usr/bin/perl
use strict;
use warnings;

use Cwd;

# Package used for base conversions.
use Math::BaseCnv;

my $rgb_directory;

my @temp_rgb_files = ();
my @final_rgb_files = ();

my @all_red = ();
my @all_blue = ();
my @all_green = ();

my @dec_red = ();
my @dec_green = ();
my @dec_blue = ();

my @hex_red = ();
my @hex_green = ();
my @hex_blue = ();
	
my @pixels = ();

my $do_count = 0;

#####################################################################################
# Name: validateArgs                                                             ###
# Purpose: Read in and validate the command-line arguments                       ##
##################################################################################
sub validateArgs {
	# Validate the command-line arguments. There will either be 1 or 3 of them.
	if (@ARGV == 1) {
		if ( !(-d "$ARGV[0]")) {
			print "\n    Invalid command-line argument: 
				Must be a directory\n";	
			exit;
		}	
	}
	elsif (@ARGV == 3) {
		if ( !(-d "$ARGV[2]")) {
			print "\n    Invalid third command-line argument: 
				Must be a directory\n";	
			exit;
		}
		if ($ARGV[0] ne "-count") {
			print "\n Invalid first command-line option.
				Option is -count to automatically call hexCodeCounter.pl\n";
			exit;
		}
		else {
			$do_count = 1;
		}
		if ($ARGV[1] ne "-txt" and $ARGV[1] ne "-csv") {
			print "\n    Invalid second command-line argument.
						Must be -csv or -txt.\n";
			exit;
		}
	}
	else {
		print "\n    Invalid number of command-line arguments: 
			Syntax 1: Syntax: perl mikuHairColors.pl \"directory\"\n;
			Syntax 2: perl mikuHairColors.pl [-count] [-csv|-txt] \"directory\"\n";
			exit;
	}
}

#####################################################################################
# Name: gatherRGB                                                                ###
# Purpose: Open the 3 files containing RGB data for each pixel and store it      ##
##################################################################################
sub gatherRGB {
	if (@ARGV == 1) {
		$rgb_directory = $ARGV[0];
	}
	else {
		$rgb_directory = $ARGV[2];
	}
	
	opendir(RGBDIR, "$rgb_directory") 
		or die ("\n    Unable to open the directory: $rgb_directory.\n");
	@temp_rgb_files = readdir RGBDIR;

	# Take on the directory to get absolute file paths to open later.
	foreach(@temp_rgb_files) {
		$_ = $rgb_directory . "/" . $_;
	}
	
	close(RGBDIR);
	
	@final_rgb_files = grep { -f and $_ =~ /.* ((\(red\)|\(green\)|\(blue\))\.txt)$/ } @temp_rgb_files;

	# Make sure we have 3 files (red, green and blue)
	if (@final_rgb_files != 3) {
		print "Invalid number of text files detected detected. 
			Place one file for each channel (red, green and blue) in the directory.\n";
		exit;
	}
	
	# Give nice names to each of the 3 files
	my ($red_file, $green_file, $blue_file) 
		= ($final_rgb_files[0], $final_rgb_files[1], $final_rgb_files[2]);
	
	print "\nImporting RED decimal values.\n";
	# Open a HANDLE to the red component info
	open(REDIN, "<$red_file") 
		or die ("\n    Unable to open file: $red_file.\n");
	@all_red = <REDIN>;
	foreach(@all_red) {
		push(@dec_red, split(/\s+/, $_));
	}
	close(REDIN);
	
	print "Importing GREEN decimal values.\n";
	# Open a HANDLE to the green component info
	open(GREENIN, "<$green_file") 
		or die ("\n    Unable to open file: $green_file.\n");
	@all_green = <GREENIN>;
	foreach(@all_green) {
		push(@dec_green, split(/\s+/, $_));
	}
	close(GREENIN);		
	if (@dec_green != @dec_red) {
		print "\n    The color files inputted must contain the same number of values.\n";
		exit;
	}
	
	print "Importing BLUE decimal values.\n";
	# Open a HANDLE to the ble component info
	open(BLUEIN, "<$blue_file") 
		or die ("\n    Unable to open file: $blue_file.\n");
	@all_blue = <BLUEIN>;
	foreach(@all_blue) {
		push(@dec_blue, split(/\s+/, $_));
	}
	close(BLUEIN);
	if (@dec_blue != @dec_green) {
		print "\n    The color files inputted must contain the same number of values.\n";
		exit;
	}	
}

#####################################################################################
# Name: convertToBase16                                                          ###
# Purpose: Convert all RGB codes to Hexadecimal                                  ##
##################################################################################
sub convertToBase16 {
	 my $temp_hex = 0;
	 
	 print "\nConverting RED decimal values into base 16.\n";
	 foreach(@dec_red) {
		$temp_hex = cnv($_, 10, 16);
		if (length($temp_hex) == 1) {
			$temp_hex = "0" . $temp_hex;
		}
		push(@hex_red, $temp_hex);
	}
	
	print "Converting GREEN decimal values into base 16.\n";
	foreach(@dec_green) {
		$temp_hex = cnv($_, 10, 16);
		if (length($temp_hex) == 1) {
			$temp_hex = "0" . $temp_hex;
		}
		push(@hex_green, $temp_hex);
	}

	print "Converting BLUE decimal values into base 16.\n";
	foreach(@dec_blue) {
		$temp_hex = cnv($_, 10, 16);
		if (length($temp_hex) == 1) {
			$temp_hex = "0" . $temp_hex;
		}
		push(@hex_blue, $temp_hex);
	}	
}

#####################################################################################
# Name: appendRGB                                                                ###
# Purpose: Build up each pixel's HEX code.                                       ##
##################################################################################
sub appendRGB {
	print "\nBuilding full HEX Codes.\n";
	for (my $p = 0; $p < @hex_red; $p++) {
		push(@pixels, "#" . $hex_red[$p] . $hex_green[$p] . $hex_blue[$p]);
	}
}

#####################################################################################
# Name: exportPixels                                                             ###
# Purpose: Put the HEX codes in a text file.                                     ##
##################################################################################
sub exportPixels {
	my @name_grabber = split(/ \(/, $final_rgb_files[0]);
	my $output_file_name = $name_grabber[0] . "_all_hex.txt";
	
	print "\nExporting HEX Codes to the output file.\n";
	open(PIXELSOUT, ">$output_file_name") 
		or die("\n    Unable to open file: $output_file_name.\n");
	foreach(@pixels) {
		print PIXELSOUT $_ . "\n";
	}
	
	# If the user game the -count option, call the hexCodeCounter
	if ($do_count == 1) {
		print "Calling hexCodeCounter.pl.\n";
		system("perl hexCodeCounter.pl $ARGV[1] \"$output_file_name\"");
	}
}

##################
# Main Program ##
################

# Call the sub that validates the command-line argument
validateArgs;

# Call the sub that opens the files
gatherRGB;

# Call the sub to convert to base16.
convertToBase16;

# Call the sub to build up the HEX codes.
appendRGB;

# Call the sub to export the HEX codes to a text file.
exportPixels;