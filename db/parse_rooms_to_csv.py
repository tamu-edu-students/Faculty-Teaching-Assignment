import json
import csv

def json_to_csv(json_file, csv_file):
    # Open and read the JSON file
    with open(json_file, 'r') as f:
        data = json.load(f)

    # Open the CSV file for writing
    with open(csv_file, 'w', newline='') as csvfile:
        # Create a CSV writer object
        csvwriter = csv.writer(csvfile)

        # Write the header row based on the keys from the first element of the list
        header = ["campus", "building_code", "room_number", "is_lab", "is_lecture_hall", "is_learning_studio", "capacity", "is_active", "comments"]
        csvwriter.writerow(header)

        # Write each row of data to the CSV
        for entry in data:
            # Convert the 'usage_types' list to a string, otherwise it won't be CSV-compatible
            lab = False
            lecture_hall = False
            learning_studio = False
            if entry['usage_types']:
                for type in entry['usage_types']:
                    if type == 1:
                        lecture_hall = True
                    elif type == 2:
                        learning_studio = True
                    elif type == 3:
                        lab = True
            campus = "CS"

            if entry['campus'] == 2:
                campus = "GV"
            row = [
                campus,
                entry['building_code'],
                entry['room_number'],
                lab,
                lecture_hall,
                learning_studio,
                entry['capacity'],
                entry['is_active'],
                entry['comments']
            ]
            csvwriter.writerow(row)

# Specify the input JSON file and output CSV file
json_file = 'rooms.json'
csv_file = 'rooms.csv'

# Call the function to convert JSON to CSV
json_to_csv(json_file, csv_file)
