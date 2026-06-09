import csv
from pathlib import Path
base = Path(__file__).resolve().parents[2] / 'datasets' / 'Motor_Therfts' / 'Raw'
files = [
    'locations.csv',
    'make_details.csv',
    'stolen_vehicles_db_data_dictionary.csv',
    'stolen_vehicles.csv'
]

for file_name in files:
    input_path = base / file_name
    output_path = base / f"{input_path.stem}_uncleaned.csv"
    with input_path.open('r', newline='', encoding='utf-8') as inf:
        reader = list(csv.reader(inf))
    rows = [row[:] for row in reader]

    if file_name == 'locations.csv':
        rows.insert(3, ['117', 'Westland', 'New Zealand', '85,000', ''])
        rows.insert(5, ['102', 'Auckland', 'New Zealand', '1,695,200', '343.09'])
        rows.append(['118', 'South Zealand', 'New Zealand', 'one hundred thousand', '20.5'])
        rows.append(rows[2])
    elif file_name == 'make_details.csv':
        rows.append(['639', 'MysteryMake', ''])
        rows.append(['502', 'ADLY', 'Standard'])
        rows.append(['640', '', 'Luxury'])
        rows.insert(2, ['503', 'Alpha', 'UnknownType'])
    elif file_name == 'stolen_vehicles_db_data_dictionary.csv':
        rows.append(['stolen_vehicles', 'location_id', ''])
        rows.append(['make_details', 'make_id', 'Unique ID of the make'])
        rows.append(rows[1])
    elif file_name == 'stolen_vehicles.csv':
        rows.append(['311', 'Roadbike', '611', '2009', 'VL800', 'Black', '03/31/2022', '102'])
        rows.append(['312', '', '9999', '2022', 'UNKNOWN VEHICLE', 'Silver', '2022-04-31', '999'])
        rows.append(['313', 'Trailer', '', '2019', 'MYSTERY', '', '13/01/2022', '114'])
        rows.append(['16', 'Trailer', '623', '2021', 'JOBMATE', '', '2/8/2022', '109'])
        rows.insert(10, ['999', 'Boat Trailer', '623', '2023', 'NEW BOAT', 'Silver', '', '102'])

    with output_path.open('w', newline='', encoding='utf-8') as outf:
        writer = csv.writer(outf)
        writer.writerows(rows)
    print(f'Created {output_path}')
