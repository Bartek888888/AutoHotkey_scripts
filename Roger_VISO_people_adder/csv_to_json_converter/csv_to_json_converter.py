import csv
import json

input_csv = "Roger_VISO_people_adder\\csv_to_json_converter\\list.csv"
output_json = "Roger_VISO_people_adder\\data.json"

result = []

with open(input_csv, newline="", encoding="utf-8-sig") as f:
    reader = csv.DictReader(f, delimiter=';')

    for row in reader:
        result.append({
            "name": row["Imię"].strip(),
            "lastname": row["Nazwisko"].strip(),
            "position": row["Stanowisko"].strip()
        })

with open(output_json, "w", encoding="utf-8") as f:
    json.dump(result, f, indent=2, ensure_ascii=False)