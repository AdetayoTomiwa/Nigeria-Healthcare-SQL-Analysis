import pandas as pd
import psycopg2
from psycopg2.extras import execute_values

# --- CONNECTION ---
conn = psycopg2.connect(
    host="localhost",
    database="nigeria_health_intelligence",
    user="postgres",
    password="Your_Password_Here",  # Replace with your actual password
    port=5432
)
cur = conn.cursor()

print("Connected successfully.")

# ================================================
# 1. LOAD STATES (manual — 37 states + zones)
# ================================================
states = [
    ("Abia", "South East"), ("Adamawa", "North East"), ("Akwa Ibom", "South South"),
    ("Anambra", "South East"), ("Bauchi", "North East"), ("Bayelsa", "South South"),
    ("Benue", "North Central"), ("Borno", "North East"), ("Cross River", "South South"),
    ("Delta", "South South"), ("Ebonyi", "South East"), ("Edo", "South South"),
    ("Ekiti", "South West"), ("Enugu", "South East"), ("FCT", "North Central"),
    ("Gombe", "North East"), ("Imo", "South East"), ("Jigawa", "North West"),
    ("Kaduna", "North West"), ("Kano", "North West"), ("Katsina", "North West"),
    ("Kebbi", "North West"), ("Kogi", "North Central"), ("Kwara", "North Central"),
    ("Lagos", "South West"), ("Nasarawa", "North Central"), ("Niger", "North Central"),
    ("Ogun", "South West"), ("Ondo", "South West"), ("Osun", "South West"),
    ("Oyo", "South West"), ("Plateau", "North Central"), ("Rivers", "South South"),
    ("Sokoto", "North West"), ("Taraba", "North East"), ("Yobe", "North East"),
    ("Zamfara", "North West")
]

execute_values(cur, 
    "INSERT INTO states (state_name, geopolitical_zone) VALUES %s ON CONFLICT (state_name) DO NOTHING",
    states
)
conn.commit()
print(f"States loaded: {len(states)} rows")

# ================================================
# 2. LOAD POPULATION (Table 2 from Excel — 2006-2016)
# ================================================
pop_df = pd.read_excel(
    r'C:\Users\Tomiwa ADETAYO\Desktop\SQL Project\Original Datasets\Population Forecasts.xlsx',  # Update path if needed
    sheet_name='Table 2',
    skiprows=1,
    header=0
)

# Clean: drop rows where STATE is null or 'STATE'
pop_df = pop_df[pop_df.iloc[:, 0].notna()]
pop_df = pop_df[pop_df.iloc[:, 0] != 'STATE']
pop_df.columns = ['state_name', '2006','2007','2008','2009','2010','2011','2012','2013','2014','2015','2016']

# Standardise state names to match GRID3
name_map = {
    'ABIA': 'Abia', 'ADAMAWA': 'Adamawa', 'AKWA/IBOM': 'Akwa Ibom',
    'ANAMBRA': 'Anambra', 'BAUCHI': 'Bauchi', 'BAYELSA': 'Bayelsa',
    'BENUE': 'Benue', 'BORNO': 'Borno', 'CROSS RIVER': 'Cross River',
    'DELTA': 'Delta', 'EBONYI': 'Ebonyi', 'EDO': 'Edo', 'EKITI': 'Ekiti',
    'ENUGU': 'Enugu', 'FCT ABUJA': 'FCT', 'GOMBE': 'Gombe', 'IMO': 'Imo',
    'JIGAWA': 'Jigawa', 'KADUNA': 'Kaduna', 'KANO': 'Kano',
    'KATSINA': 'Katsina', 'KEBBI': 'Kebbi', 'KOGI': 'Kogi', 'KWARA': 'Kwara',
    'LAGOS': 'Lagos', 'NASARAWA': 'Nasarawa', 'NIGER': 'Niger', 'OGUN': 'Ogun',
    'ONDO': 'Ondo', 'OSUN': 'Osun', 'OYO': 'Oyo', 'PLATEAU': 'Plateau',
    'RIVERS': 'Rivers', 'SOKOTO': 'Sokoto', 'TARABA': 'Taraba', 'YOBE': 'Yobe',
    'ZAMFARA': 'Zamfara', 'NIGERIA': None  # exclude national total
}

pop_rows = []
for _, row in pop_df.iterrows():
    raw_name = str(row['state_name']).strip().upper()
    clean_name = name_map.get(raw_name)
    if clean_name is None:
        continue
    for year in range(2006, 2017):
        val = row[str(year)]
        if pd.notna(val):
            pop_rows.append((clean_name, year, int(val), None, None))

execute_values(cur,
    "INSERT INTO population (state_name, year, total_population, male_population, female_population) VALUES %s",
    pop_rows
)
conn.commit()
print(f"Population rows loaded: {len(pop_rows)}")

# ================================================
# 3. LOAD FACILITIES (GRID3)
# ================================================
fac_df = pd.read_excel(
    r'C:\Users\Tomiwa ADETAYO\Desktop\SQL Project\Original Datasets\GRID3_NGA_health_facilities_v2_0_-3153096973727326472.xlsx'
)

fac_rows = []
for _, row in fac_df.iterrows():
    fac_rows.append((
        int(row['nhfr_uid']) if pd.notna(row['nhfr_uid']) else None,
        str(row['facility_name'])[:255] if pd.notna(row['facility_name']) else None,
        str(row['state'])[:100] if pd.notna(row['state']) else None,
        str(row['lga'])[:100] if pd.notna(row['lga']) else None,
        str(row['ward'])[:100] if pd.notna(row['ward']) else None,
        str(row['ownership'])[:50] if pd.notna(row['ownership']) else None,
        str(row['ownership_type'])[:100] if pd.notna(row['ownership_type']) else None,
        str(row['facility_level'])[:50] if pd.notna(row['facility_level']) else None,
        str(row['facility_level_option'])[:100] if pd.notna(row['facility_level_option']) else None,
        float(row['latitude']) if pd.notna(row['latitude']) else None,
        float(row['longitude']) if pd.notna(row['longitude']) else None,
        str(row['last_updated'])[:10] if pd.notna(row['last_updated']) else None
    ))

execute_values(cur,
    """INSERT INTO facilities 
       (nhfr_uid, facility_name, state_name, lga_name, ward, ownership, ownership_type,
        facility_level, facility_level_option, latitude, longitude, last_updated)
       VALUES %s""",
    fac_rows
)
conn.commit()
print(f"Facilities loaded: {len(fac_rows)} rows")

# ================================================
# 4. LOAD DISEASE INDICATORS (Malaria + TB)
# ================================================
malaria_df = pd.read_csv(r'C:\Users\Tomiwa ADETAYO\Desktop\SQL Project\Original Datasets\malaria_indicators_nga (1).csv')
tb_df = pd.read_csv(r'C:\Users\Tomiwa ADETAYO\Desktop\SQL Project\Original Datasets\tuberculosis_indicators_nga.csv')

malaria_df['disease'] = 'Malaria'
tb_df['disease'] = 'TB'
disease_df = pd.concat([malaria_df, tb_df], ignore_index=True)

disease_rows = []
for _, row in disease_df.iterrows():
    disease_rows.append((
        str(row['disease']),
        str(row['GHO (CODE)'])[:100] if pd.notna(row['GHO (CODE)']) else None,
        str(row['GHO (DISPLAY)'])[:255] if pd.notna(row['GHO (DISPLAY)']) else None,
        int(row['YEAR (DISPLAY)']) if pd.notna(row['YEAR (DISPLAY)']) else None,
        float(row['Numeric']) if pd.notna(row['Numeric']) else None,
        str(row['Value'])[:100] if pd.notna(row['Value']) else None,
        float(row['Low']) if pd.notna(row['Low']) else None,
        float(row['High']) if pd.notna(row['High']) else None
    ))

execute_values(cur,
    """INSERT INTO disease_indicators
       (disease, indicator_code, indicator_name, year, numeric_value, value_display,
        low_estimate, high_estimate)
       VALUES %s""",
    disease_rows
)
conn.commit()
print(f"Disease indicator rows loaded: {len(disease_rows)}")

# ================================================
# DONE
# ================================================
cur.close()
conn.close()
print("\nAll data loaded successfully. Database is ready.")