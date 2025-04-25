import pandas as pd
import difflib
from collections import defaultdict

# Load the CSV files
fivetran_df = pd.read_csv("Fivetran.csv")
salesforce_df = pd.read_csv("Salesforce.csv")

# Normalize helper
def normalize(s):
    return s.lower().replace("_", "").strip()

# Organize by normalized table names
fivetran_by_table = defaultdict(list)
for _, row in fivetran_df.iterrows():
    fivetran_by_table[normalize(row.table_name)].append((row.table_name, row.column_name, normalize(row.column_name)))

salesforce_by_table = defaultdict(list)
for _, row in salesforce_df.iterrows():
    salesforce_by_table[normalize(row.table_name)].append((row.table_name, row.column_name, normalize(row.column_name)))

# Find matches by exact normalized table name and similar column names
matched = []
for table_norm in salesforce_by_table:
    if table_norm in fivetran_by_table:
        for sf_table, sf_col, sf_col_norm in salesforce_by_table[table_norm]:
            for ft_table, ft_col, ft_col_norm in fivetran_by_table[table_norm]:
                similarity = difflib.SequenceMatcher(None, sf_col_norm, ft_col_norm).ratio()
                if similarity == 1: ##> 0.9:
                    matched.append({
                        "Salesforce Table": sf_table,
                        "Salesforce Column": sf_col,
                        "Fivetran Table": ft_table,
                        "Fivetran Column": ft_col,
                        "Column Similarity": round(similarity, 2)
                    })

# Create DataFrame and save
matched_df = pd.DataFrame(matched)
matched_df.sort_values(by=["Salesforce Table", "Salesforce Column"], inplace=True)
matched_df.to_csv("salesforce_fivetran_mapped_columns.csv", index=False)

print("✅ Mapping file saved as 'salesforce_fivetran_mapped_columns.csv'")
