import pandas as pd 

# Regardons ce qu'il y a dans resulats choix 

df = pd.read_csv('data_CROUS/data_processed/Resultats_choix_21_octobre.csv', sep = ';', index_col=False)

'''
print(df.columns) #Index(['Horodateur', 'Numéro de formulaire ', 'ENTREE','Prise en double de l'entrée ', 'PLAT ', 'DESSERT','Prise en double du dessert'],dtype='object')
print(df.head(10))
print(df.shape)     # (131, 7)
print(df.index)     # RangeIndex(start=0, stop=131, step=1)
'''

# Pour commencer, regardons un peu la distribution des différents plats qui ont été choisis. 
print(type(df['PLAT '])) # <class 'pandas.core.series.Series'> 
print(type(df[['PLAT ']])) # <class 'pandas.core.frame.DataFrame'>

print('sum')
print(len(df['PLAT '].value_counts().unique())) # Combien de plats possibles ? --> 11 plats différents 
print(df['PLAT '].value_counts()) # Quel sont-ils ? 

# On observe qu'une mise en forme va être nécéssaire. En efet, à cause des espaces, les plats suivants : 
# "Boeuf  bourguignon + Torsades +Poelée brocolis" / "Boeuf bourguignon + Torsades + Poelée brocolis " / "Boeuf  bourguignon + Torsades + Poelée brocolis "
# Ne sont pas considérés comme étant les mêmes. 

# Enlevons tous les espaces:
df['PLAT '] = df['PLAT '].replace(' ', '', regex = True)
print(df['PLAT '])

# On obtient alors 
print(len(df['PLAT '].value_counts().unique())) # Combien de plats possibles ? --> 8 plats differents 
print(df['PLAT '].value_counts()) # Quel sont-ils ? 

# C'est mieux! 
# On observe tout de meme qu'il reste qqs problèmes.
# Par exemple, un '+' a été oublié, si bien que "FeuilletéSaumonoseille+TorsadesPoeléebrocolis" et "FeuilletéSaumonoseille+Torsades+PoeléeBrocolis"
# ne sont pas considérés comme équivalents. 
# --> pas d'autres choix que de rajouter le '+' à la main (?)

# Pour garder les données d'origine intactes en cas de soucis, créons un dossier 'data_processed' 
# sur lequel on travaillera et qui contiendra ce genre de modifications.   # DONE 

# On recommence et on obtient alors :
print(len(df['PLAT '].value_counts().unique())) # Combien de plats possibles ? --> 8 plats differents 
print(df['PLAT '].value_counts()) # Quel sont-ils ? 

# On observe qu'à cause d'un problème de casse, "FeuilletéSaumonoseille+Torsades+Poeléebrocolis " et "FeuilletéSaumonoseille+Torsades+PoeléeBrocolis"
# sont considérés comme 2 plats differents 
# --> on enlève la casse 
df['PLAT '] = df['PLAT '].str.lower()
# On recommence et on obtient alors :
print(len(df['PLAT '].value_counts().unique())) # Combien de plats possibles ? --> 8 plats differents 
print(df['PLAT '].value_counts()) # Quel sont-ils ? 

# Répondons à quelques questions simples : 

print(df['PLAT '].str.count("torsades").sum()) # A - Combien de personnes ont pris des torsades ? --> 96 
print(df['PLAT '].str.count("frites").sum()) # A - Combien de personnes ont pris des frites ? --> 12
print(df['PLAT '].str.count("pizza").sum()) # A - Combien de personnes ont pris des pizza ? --> 4


'''
# Séparons maintenant en plusieurs colonnes la colonne 'PLAT' en utilisant le '+' qui sépare 2 items 
# L'item i se retrouve dans la colonne 'PLAT_i'
df[['PLAT_1','PLAT_2', 'PLAT_3']] = df['PLAT '].str.split('+', expand=True)

#print(df.columns)
#print(df['PLAT_1'],df['PLAT_2'], df['PLAT_3'] )

# Problème : on voudrait que tout ce qui est "Torsades" soit dans la même colonne, tout ce qui est "Boeuf" dans la meme etc etc ... 
# Proposition d'organisation : 
# PLAT_1 reçoit ce qui est "féculents"
# PLAT_2 reçoit ce qui est "viande ou poisson"
# PLAT_3 reçoit ce qui est "légumes" 

# Pour associer chaque item à sa catégorie (féculents, viande/poisson, légumes) on utilise le fichier Regroupement_plats
df_grpmt = pd.read_csv('data_CROUS/data/Regroupements_plats-version-article2022.csv', sep = ',', index_col=False)
print(df_grpmt.columns)
print(df_grpmt['Regroupement'].value_counts())
'''
