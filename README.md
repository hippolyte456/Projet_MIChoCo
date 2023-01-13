# Projet_MIChoCo
**Modélisation Informatique des CHOix en restauration COllectives**

## Données

Dans `data_CROUS` deux types de données :
- *Formulaires* : Les  informations relatives aux individus de l'étude (données renseignées eux-mêmes), variables explicatives.
- *Choix* : Leur choix d'entrée, plat et dessert, variable à expliquer.

Deux études différentes : 
- Une étude au mois d'Octobre - (4 fichiers `Resultats_formulaires` et 4 fichiers `Resultats_choix`).
- Une étude au mois de Juin au Lieu de vie (ENS) - (1 fichier `Resultats_formulaires` et 1 fichier `Resultats_choix`)

## Preprocessing des données

 - clean_csv.ipynb :
 
 	Input : Fichier `csv` (Regroupements_plats-version-article2022.csv <-- data_CROUS/data)
	Output : Fichier `csv` (Regroupements_plats-version-article2022_clean.csv --> data_CROUS/data_processed)
	
	Enlève les NaN dans "Regroupements_plats-version-article2022.csv" et remets les bons noms de Catégorie (Entrée, Plat, Dessert)
	Sauvegarde les résultats dans "Regroupements_plats-version-article2022_clean.csv"

- preprocessing.ipynb : 
 	Input : Fichier `csv` (Resultats_choix_XX_octobre.csv.csv <-- data_CROUS/data)
	Output : Fichier `csv` (Resultats_choix_XX_octobre_processed.csv --> data_CROUS/data_preprocessed)
	
- One_Hot
	
## Analyse

- analyse_prelim.ipynb
