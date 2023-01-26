import pandas as pd
from random import choice

filename = "../../data_processed/merged_one_hot/merged_Forms_Choix.csv"

df = pd.read_csv(filename, sep=',', encoding='latin1')

convives = df["index"]
# torsade = df.columns.get_loc("torsades")
entrees = df.columns[40:57]
plats = df.columns[57:88]
desserts = df.columns[88:]
id_accomp = [0, 10, 11, 12, 18, 19, 26, 28, 29, 30]
id_plat_ppal = [k for k in range(31) if k not in id_accomp]
accompagnements = plats[id_accomp]
plats = plats[id_plat_ppal]

# print(plats)
# print(accompagnements)

## Modele simple aleatoire

random_df = pd.DataFrame(columns=df.columns[40:])
random_df.insert(0, 'index', df['index'])
random_df = random_df.fillna(0)
# print(random_df)

for convive in convives:
    entree = choice(entrees)
    plat = choice(plats)
    accompagnement = choice(accompagnements)
    dessert = choice(desserts)
    random_df.loc[random_df['index'] == convive, [entree, plat, accompagnement, dessert]] = 1

fitness = 0

print(random_df)
