#!/usr/local/bin/python3
# -*- coding: utf-8 -*-

__author__="""Co-Pierre Georg (co-pierre.georg@uct.ac.za)"""

import os
import csv
from datetime import datetime
import sys

# ###########################################################################
# METHODS
# ###########################################################################

def split_csv_by_timestamp(input_folder, input_file, output_folder, timestamp_column):
    line_count = 0

    # Create the full path to the input file
    input_path = os.path.join(input_folder, input_file)
    print("  << " + str(datetime.now()) + " WORKING ON: ", input_path)
    # Open the input CSV file
    with open(input_path, 'r') as csvfile:
        reader = csv.reader(csvfile, delimiter=';')
        header = next(reader)  # Read the header row
        
        # Iterate over each row in the CSV file
        for row in reader:
            line_count += 1
            if line_count % 10000 == 0:
                print("    << " + str(datetime.now()) + "   COUNT: " + str(line_count))

            # Extract the timestamp from the specified column
            try:
                timestamp_str = row[timestamp_column]
            except IndexError:
                print("      << ERROR WITH ROW:", row)
            try:
                timestamp = datetime.strptime(timestamp_str, '%Y-%m-%d %H:%M:%S %Z')
            except ValueError:
                timestamp = datetime.strptime(timestamp_str, '%Y-%m-%d %H:%M:%S')
            year_month = timestamp.strftime('%Y-%m')
            
            # Create the output directory if it doesn't exist
            output_dir = os.path.join(output_folder, year_month)
            os.makedirs(output_dir, exist_ok=True)
            
            # Create the output file path
            output_file_path = os.path.join(output_dir, f'{year_month}.csv')
            
            # Write the row to the appropriate output file
            with open(output_file_path, 'a', newline='') as output_csvfile:
                writer = csv.writer(output_csvfile, delimiter=';')
                # If this is the first row in the file, write the header
                if os.path.getsize(output_file_path) == 0:
                    writer.writerow(header)
                writer.writerow(row)
    print("  << " + str(datetime.now()) + "  FILE(S) WRITTEN TO: ", output_folder + "/")

# ###########################################################################
# MAIN
# ###########################################################################

if __name__ == "__main__":
    # The script expects 4 command-line arguments
    input_folder = sys.argv[1]
    input_file = sys.argv[2]
    output_folder = sys.argv[3]
    timestamp_column = int(sys.argv[4])  # Column number should be passed as an integer

    split_csv_by_timestamp(input_folder, input_file, output_folder, timestamp_column)
