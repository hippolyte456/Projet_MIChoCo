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

data_somme = df.iloc[:, 40:].sum(axis='index', numeric_only=True)
# print(data_somme)
rd_somme = random_df.sum(axis='index', numeric_only=True)
# print(rd_somme)
fitness = abs(data_somme - rd_somme).sum()
print(fitness)

## Modele avec amis

ami_df = pd.DataFrame(columns=df.columns[40:])
ami_df.insert(0, 'index', df['index'])
ami_df = ami_df.fillna(0)

# entrees = entrees.union(['test'])
# print(entrees)


# def get_col_name(row):
#     b = (df.ix[row.name] == row['value'])
#     return b.index[b.argmax()]


convive = '0A2A'
amis = df.loc[df['index'] == convive].iloc[:, 23:40]
print(amis)
for ami in amis.iloc[0,:]:
    if str(ami) == 'nan':
        break
    print(ami)
    ligne_ami = df.loc[df['index'] == ami]
    ligne_ami_entrees = ligne_ami.iloc[:, 40:57]
    # print(ligne_ami_entrees)
    # ligne_ami_entrees = ligne_ami_entrees.loc[ligne_ami_entrees != '0.0'].index
    print(ligne_ami_entrees.loc[ligne_ami_entrees.index].eq(ligne_ami_entrees, axis=0).idxmax(axis=1))
    # ligne_ami_entrees = ligne_ami_entrees.apply(lambda row: row[row == '1'].index, axis=1)
    # print(ligne_ami_entrees)
# entrees = entrees.append(pd.Index(['chou']))
# print(entrees)

# for convive in convives:
#     amis = df.loc[df['index'] == convive].iloc[:, 23:40]
#     for ami in amis.iloc[0, :]:
#         if str(ami) == 'nan':
#             break
#         ligne_ami = df.loc[df['index'] == ami]
#         ligne_ami_entrees = ligne_ami.iloc[40:57]
#
#
#     entree = choice(entrees)
#     plat = choice(plats)
#     accompagnement = choice(accompagnements)
#     dessert = choice(desserts)
