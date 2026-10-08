import pandas as pd
from pathlib import Path


# =========================================================
# 1. LOAD RAW DATA
# =========================================================

data_path = Path("../data")

tickets = pd.read_csv(data_path / "tickets.csv")
agents = pd.read_csv(data_path / "agents.csv")
merchants = pd.read_csv(data_path / "merchants.csv")


# =========================================================
# 2. CONVERT DATE COLUMNS
# =========================================================

date_columns = [
    "created_at",
    "first_response_at",
    "closed_at"
]

for column in date_columns:
    tickets[column] = pd.to_datetime(
        tickets[column],
        errors="coerce"
    )


# =========================================================
# 3. CHECK DUPLICATES
# =========================================================

print("Duplicate tickets before cleaning:",
      tickets.duplicated().sum())


# =========================================================
# 4. CHECK DATA TYPES AFTER CONVERSION
# =========================================================

print("\nData types after date conversion:")
print(tickets.dtypes)


# =========================================================
# 5. CREATE SERVICE LIFECYCLE FLAG
# =========================================================

tickets["has_response"] = tickets["first_response_at"].notna()

tickets["has_resolution"] = tickets["closed_at"].notna()


# =========================================================
# 6. CREATE DATASET SUMMARY
# =========================================================

print("\n" + "=" * 60)
print("CLEANED DATA SUMMARY")
print("=" * 60)

print("\nTotal tickets:", len(tickets))

print(
    "Tickets with response:",
    tickets["has_response"].sum()
)

print(
    "Tickets without response:",
    (~tickets["has_response"]).sum()
)

print(
    "Tickets with resolution:",
    tickets["has_resolution"].sum()
)

print(
    "Tickets without resolution:",
    (~tickets["has_resolution"]).sum()
)


# =========================================================
# 7. CHECK CSAT COVERAGE
# =========================================================

print("\nCSAT scores available:",
      tickets["csat_score"].notna().sum())

print("CSAT scores missing:",
      tickets["csat_score"].isna().sum())


# =========================================================
# 8. CHECK CATEGORY MISMATCH
# =========================================================

print("\nCategory mismatch:")
print(
    tickets["category_mismatch"]
    .value_counts(dropna=False)
)


# =========================================================
# 9. SAVE CLEANED TICKETS
# =========================================================

output_path = Path("../data/tickets_cleaned.csv")

tickets.to_csv(
    output_path,
    index=False
)

print("\nCleaned tickets saved to:")
print(output_path)


# =========================================================
# 10. SAVE OTHER TABLES
# =========================================================

agents.to_csv(
    "../data/agents_cleaned.csv",
    index=False
)

merchants.to_csv(
    "../data/merchants_cleaned.csv",
    index=False
)

print("Agents and merchants saved successfully.")


# =========================================================
# END
# =========================================================

print("\n" + "=" * 60)
print("DATA CLEANING COMPLETE")
print("=" * 60)