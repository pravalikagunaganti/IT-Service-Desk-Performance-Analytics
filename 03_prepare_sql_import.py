import pandas as pd

data_path = r"C:\Users\gunig\PycharmProjects\IT_Service_Desk_Analytics\data"

tickets = pd.read_csv(data_path + r"\tickets_cleaned.csv")

# Select the incomplete tickets
incomplete_tickets = tickets[tickets["first_response_at"].isna()].copy()

print("Incomplete tickets:", len(incomplete_tickets))

# Save them
output_file = data_path + r"\tickets_incomplete.csv"
incomplete_tickets.to_csv(output_file, index=False)

print("Saved:", output_file)