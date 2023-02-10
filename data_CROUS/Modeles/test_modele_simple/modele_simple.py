import numpy as np
import pandas as pd
from random import choice
from time import time
import matplotlib.pyplot as plt


filename = "../../data_processed/merged_one_hot/merged_Forms_Choix.csv"

df = pd.read_csv(filename, sep=',', encoding='latin1', index_col=0)
# print(df)
convives = df.loc[:, 'index']
# print(convives)
torsade = df.columns.get_loc("torsades")
# print(torsade)
entrees = df.columns[40:57]
# print(entrees)
plats = df.columns[57:88]
# print(plats)
desserts = df.columns[88:]
# print(desserts)
# torsade = plats.get_loc("rotilegumestofu")
id_accomp = [0, 10, 11, 12, 18, 19, 21, 27, 29, 30]
id_plat_ppal = [k for k in range(31) if k not in id_accomp]
accompagnements = plats[id_accomp]
# les accompagnements sont
# ['torsades', 'brocolis', 'frites', 'ratatouille', 'pommesdeterrevapeur', 'juliennedelegumes', 'riz', 'saladeverte',
# 'spaghettis', 'mousselinedepotiron', 'legumes']
plats = plats[id_plat_ppal]

# print(plats)
# print(accompagnements)

## Modele simple aleatoire

def calc_fitness_rd():
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
    fitness = abs(data_somme - rd_somme).sum()/len(convives.values)
    return fitness

## Modele avec amis

def calc_fitness_amis(inf_ami):
    # création d'un dataframe avec la colonne index et une colonne pour chaque plat remplie de 0
    ami_df = pd.DataFrame(columns=df.columns[40:])
    ami_df.insert(0, 'index', df['index'])
    ami_df = ami_df.fillna(0)

    # print(ami_df)
    # entrees = entrees.union(['test'])
    # print(entrees)


    # def get_col_name(row):
    #     b = (df.ix[row.name] == row['value'])
    #     return b.index[b.argmax()]


    cpt_skip = 0
    for convive in convives:
        entrees_temp = entrees.copy()
        plats_temp = plats.copy()
        desserts_temp = desserts.copy()
        accompagnements_temp = accompagnements.copy()
        # print(accompagnements_temp)

        # récupération de la liste des amis du convive
        amis = df.loc[df['index'] == convive].iloc[:, 22:39]
        # print(amis)

        for ami in amis.iloc[0, :]:
            if str(ami) == 'nan':
                break
            if str(ami) not in convives.values:
                cpt_skip += 1
                continue
            # print(ami)
            entrees_df = df.iloc[:, np.r_[0, 40:57]]
            plats_df = df.iloc[:, np.r_[0, 57:88]]
            desserts_df = df.iloc[:, np.r_[0, 88:118]]
            # print(entrees_df)
            # print(plats_df)
            # print(desserts_df)
            for i, small_df in enumerate([entrees_df, plats_df, desserts_df]):
            #small_df contient l'index et toutes les colonnes de plat
                ligne_ami = small_df.loc[small_df['index'] == str(ami)]  # la ligne du dataframe correspondant à l'ami
                plats_ami = ligne_ami != 0  # df booleen avec True pour chaque plat pris par l'ami
                s = pd.Series(plats_ami.values[0])  # transformation au format pd.Series
                s_index = s[s].index  # index de la series correspond à l'index des colonnes des plats
                plats_ami = ligne_ami.iloc[:, s_index]  # récupération des noms des plats à partir de l'index
                plats_ami = plats_ami.columns[1:]  # on enlève la colonne index sélectionnée également

                for _ in range(inf_ami):
                    if i == 0:  # entrees
                        entrees_temp = entrees_temp.append(plats_ami)
                    elif i == 1:  # plats
                        for plat in plats_ami.values:
                            if plat in accompagnements.values:
                                accompagnements_temp = accompagnements_temp.append(pd.Index([plat]))
                            else:
                                plats_temp = plats_temp.append(pd.Index([plat]))
                    else:  # desserts
                        desserts_temp = desserts_temp.append(plats_ami)

        # print(entrees_temp)
        # print(plats_temp)
        # print(accompagnements_temp)
        # print(desserts_temp)

        entree = choice(entrees_temp)
        plat = choice(plats_temp)
        accompagnement = choice(accompagnements_temp)
        dessert = choice(desserts_temp)
        ami_df.loc[ami_df['index'] == convive, [entree, plat, accompagnement, dessert]] = 1

    data_somme = df.iloc[:, 40:].sum(axis='index', numeric_only=True)
    # print(data_somme)
    ami_somme = ami_df.sum(axis='index', numeric_only=True)
    # print(rd_somme)
    fitness_ami = abs(data_somme - ami_somme).sum()/len(convives.values)
    return fitness_ami, cpt_skip



start = time()
N = 100  # nb d'iterations
l_inf_ami = [1, 2, 3, 5, 10, 20, 30, 50]  # nb de fois qu'on ajoute le plat d'un ami dans le pool pour le tirage
l_fitness_rd = []
l_avg_fitness_ami = []
l_std_fitness_ami = []
for inf_ami in l_inf_ami:
    l_fitness_amis = []
    for _ in range(N):
        if inf_ami == l_inf_ami[0]:
            fitness_rd = calc_fitness_rd()
            l_fitness_rd.append(fitness_rd)
        fitness_ami = calc_fitness_amis(inf_ami)[0]
        l_fitness_amis.append(fitness_ami)
    avg_fitness_rd = np.mean(l_fitness_rd)
    std_fitness_rd = np.std(l_fitness_rd)
    avg_fitness_amis = np.mean(l_fitness_amis)
    std_fitness_amis = np.std(l_fitness_amis)

    l_avg_fitness_ami.append(avg_fitness_amis)  # moyenne des fitness dans le modèle ami selon les valeurs de inf_ami
    l_std_fitness_ami.append(std_fitness_amis)
end = time()
exec_time = end - start
print(f'{exec_time} sec')

# print([0] + l_inf_ami)
# print([avg_fitness_rd] + l_avg_fitness_ami)


height = [1.843, avg_fitness_rd] + l_avg_fitness_ami
error = [0, std_fitness_rd] + l_std_fitness_ami
bars = ['GAMA', '0'] + [str(inf_ami) for inf_ami in l_inf_ami]
print(height)
print(error)
print(bars)
x_pos = np.arange(len(bars))

plt.figure()
plt.bar(x_pos, height, color=['red'] + ['blue' for _ in range(len(l_avg_fitness_ami) + 1)], yerr=error)
plt.xticks(x_pos, bars)
plt.show()


# n_row = 1
# n_col = len(l_inf_ami) + 1
# fig, axs = plt.subplots(n_row, n_col)
# st = fig.suptitle("Fitness en fonction de l'influence des amis")

# for col in range(1, n_col):
#     axs[col].bar([k for k in range(len(l_inf_ami))], l_avg_fitness_ami[col])
#     # axs[col].set_xlabel('Nombre de parties simulées par Rollout')
#     axs[col].set_ylabel('Fitness')
#     # axs[col].set_title('C =' + str(l_C[col]))
#     axs[col].set_xticks([k for k in range(len(l_inf_ami))], [str(nb_simul) for nb_simul in l_nb_simul])