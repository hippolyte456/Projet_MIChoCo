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

 - `clean_csv.ipynb` :  
 	**Input :** Fichier .csv (Regroupements_plats-version-article2022.csv ← data_CROUS/data)  
	**Output :** Fichier .csv (Regroupements_plats-version-article2022_clean.csv ➔ data_CROUS/data_processed)  
	  
	Enlève les NaN dans "Regroupements_plats-version-article2022.csv" et remets les bons noms de Catégorie (Entrée, Plat, Dessert)  
	Sauvegarde les résultats dans "Regroupements_plats-version-article2022_clean.csv"  

- `preprocessing.ipynb` :  
 	**Input :** Fichier .csv (Resultats_choix_XX_octobre.csv ← data_CROUS/data)  
	**Output :** Fichier .csv (Resultats_choix_XX_octobre_processed.csv ➔ data_CROUS/data_preprocessed)  
	
	  
- Dossier **One_Hot** :
	- `OneHot Formulaires.ipynb` :  
		**Input :** 4 Fichiers .csv (Resultats_formulaires_XX_octobre.csv ← data_CROUS/data)  
		**Output :** Fichier .csv (One_Hot_Formulaires.csv ➔ One_Hot)
		
		
		Récupère les fichiers *Formulaires* brut, les pré-traite, transforme les variables catégorielles en variables numériques notamment par One Hot Encoding.

- Dossier **One_Hot_R** :
	- `One_Hot_R.Rmd` :  
		**Input :** Fichier .csv (Resultats_choix_XX_octobre_processed.csv ← data_CROUS/data_preprocessed)  
		**Output :** Fichier .csv (OneHotEncoding_choix_XX_oct_processed.csv ➔ One_Hot_R)
	
		Récupère les fichiers *Choix* pré-traités et y applique du One Hot Encoding sur les entrées, plats et desserts.
		Il faudra surement modifier ce fichier pour agisse sur les 4 fichiers d'Octobre à la fois et ne sorte qu'un fichier des sortie (cf One_Hot_Formulaires).
		
## Analyse

- `analyse_prelim.ipynb`

- Dossier **Stat_R** :  
	- `Stat_R.rmd`  
		**Input :** Fichier .csv (Merged.csv (*Formulaires* + *Choix*) )  
		**Output :** Figures		

		Statistiques de base sur les données : ACP et visualisation des variables explicatives (Taille, Faim...)

## Remarque diverses à reprendre 
- dans le merged final : à rajouter le numéro du jour de chaque enregistrement // un moyen de recupérer uniquement les colonnes de choix du jour...?
- attention, on a un problème de merge par num
- métrique entre les choix à définir
- 

https://docs.google.com/document/d/1Ehz_2gBzxZPtm9B04zATLbHiuWhKMypZ55qOL8rHuM4/edit
