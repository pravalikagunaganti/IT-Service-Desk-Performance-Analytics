import pandas as pd

# =========================================================
# 1. LOAD DATASETS
# =========================================================

tickets = pd.read_csv("../data/tickets.csv")
agents = pd.read_csv("../data/agents.csv")
merchants = pd.read_csv("../data/merchants.csv")


# =========================================================
# 2. BASIC DATA PROFILING
# =========================================================

datasets = {
    "Tickets": tickets,
    "Agents": agents,
    "Merchants": merchants
}

for name, df in datasets.items():

    print("\n" + "=" * 60)
    print(name)
    print("=" * 60)

    print("\nShape:")
    print(df.shape)

    print("\nColumns:")
    print(df.columns.tolist())

    print("\nData Types:")
    print(df.dtypes)

    print("\nMissing Values:")
    print(df.isnull().sum())

    print("\nDuplicate Rows:")
    print(df.duplicated().sum())


# =========================================================
# 3. INVESTIGATE INCOMPLETE TICKETS
# =========================================================

print("\n" + "=" * 60)
print("INCOMPLETE TICKETS ANALYSIS")
print("=" * 60)

# Tickets without an assigned agent
unassigned = tickets[tickets["assigned_agent_id"].isna()]

print("\nTickets without assigned agent:", len(unassigned))

print("\nMissing values in these tickets:")
print(unassigned.isnull().sum())

print("\nFirst 10 incomplete tickets:")
print(
    unassigned[
        [
            "ticket_id",
            "created_at",
            "priority",
            "assigned_agent_id",
            "first_response_at",
            "closed_at",
            "ttfr_hours",
            "resolution_hours",
            "response_breached",
            "resolution_breached",
            "is_reopened",
            "csat_score"
        ]
    ].head(10)
)


# =========================================================
# 4. CHECK DATE COLUMNS
# =========================================================

print("\n" + "=" * 60)
print("DATE COLUMN CHECK")
print("=" * 60)

for column in ["created_at", "first_response_at", "closed_at"]:

    converted = pd.to_datetime(
        tickets[column],
        errors="coerce"
    )

    print(f"\n{column}")
    print("Valid dates:", converted.notna().sum())
    print("Invalid dates:", converted.isna().sum())
    print("Minimum:", converted.min())
    print("Maximum:", converted.max())


# =========================================================
# 5. CHECK CATEGORY MISMATCH VALUES
# =========================================================

print("\n" + "=" * 60)
print("CATEGORY MISMATCH VALUES")
print("=" * 60)

print(
    tickets["category_mismatch"]
    .value_counts(dropna=False)
)


# =========================================================
# END
# =========================================================

print("\n" + "=" * 60)
print("PROFILING COMPLETE")
print("=" * 60)
