/**
* Name: RUSaclaybisV2
* Based on the internal empty template. 
* Author: Damien
* Tags: 
*/


model RUSaclaybisV2

/* Insert your model definition here */

global{
	//des constantes pour pouvoir les manipuler plus facilement dans le code après	
	//string HEALTHY <- "Healthy";
	//string CLASSIQUE <- "Classique";
	//string GLOUTON <- "Glouton";
	//string LEADER <- "leader";
	//string SUIVEUR_PRECOCE <- "suiveur précoce";
	//string SUIVEUR_TARDIF <- "suiveur tardif";
	//string REFRACTAIRE <- "réfractaire";
	//string SH <- "SH";
	//string H <- "H";
	//string NH <- "NH";
	//string NG <- "NG";
	//string G <- "G";
	//string SG <- "SG";
	string ENTREE <- "entree";
	string PLAT <- "plat";
	string DESSERT <- "dessert";
	string CAISSE <- "caisse";
	string PLATEAU <- "plateau";
	
	float fitness;
	bool end_simulation <- false ;
	//PARAMETRES DU MODELE
    int nombre_etudiants <- 500 ;
    
    //pas pour l'expérience influence_facteurs
    int pas_debut <-0;
    int pas_fin <-10;
    
    float coeff_autre_moyenne <- 0.6;
    float coeff_autre_sociale_et<- 0.1;
    float coeff_amis_moyenne <- 0.5;
    float coeff_amis_et <- 0.1;
	float influence_sociale_moyenne <- 0.7;
	float influence_sociale_et <- 0.9;
	float influence_env_moyenne <- 0.2;
	float influence_env_et <- 0.1; 
	float delta_moyenne <- 0.1;
	float delat_et <- 0.0;
	float choix_personnel_moyenne <- 0.3;
	float choix_personnel_et <- 1.0;
    
	float proba_depassement1point <- 0.6;
	float proba_manque1point <- 0.8;
	float proba_depassement2points <- 0.2; 
	float force_perception_plat <- 0.2; // à quel point un plat qui est à coté de moi va m'influencer
	
	float proba_autre_entree <- 0.1; //probabilité de prendre une autre entree
	float proba_autre_dessert <- 0.4; //probabilité de prendre un autre dessert
	float proba_encore <- 0.8; //probabilite de prendre même entree ou même dessert 
	float temps_entre_groupes <- 14 #s;
	
	int seuil_influence_etudiant_queue <- 6; // à partir de combien d'étudiants dans la queue je suis influencé (négativement)
	
	float Charcuterie_correction <- 0.2;
	float Crudites_correction <- -0.1;
	float Entree_poisson_correction <- -0.55;
	float Salade_feculents_correction <- 0.4;
	float Viande___correction <- 0.15;
	float Pizza_correction <- -0.85;
	float Accompagnement___correction <-0.25;
	float Accompagnement_correction <- -0.6;
	float Viande_correction <- 0.65;
	float Poisson_correction <- 0.65;
	float Vege_correction <- -0.9;
	float Fruit_correction <- -0.5;
	float Produit_laitier_correction <- 0.9;
	float Creme_dessert_correction <- -0.25;
	float Fruits_gourmands_correction <- -0.75;
	float Dessert_gourmand_correction <- 0.85;
	float Fromage_correction <- 0.4;

	float proba_vegetarien <- 0.05;
	
	int Nb_points_attendu <- 6;
	float distance_perception <- 2.5 #m;
	int Nb_etudiants_servis <- 0; 
	int plat_points;
	float step <- 1.0 #s;
	
	map<string,float> duration_type <- [ENTREE::10 #s, PLAT::15 #s, DESSERT:: 10 #s,CAISSE::10 #s, PLATEAU::3 #s];
	//map<string,float> proportion_profil <- [LEADER::2.5, SUIVEUR_PRECOCE::47.5, SUIVEUR_TARDIF:: 34,REFRACTAIRE::16];
	//map<string,float> alpha_profil <- [LEADER::0.1, SUIVEUR_PRECOCE::2.0, SUIVEUR_TARDIF:: 1.0,REFRACTAIRE::-0.1];
	//map<string,float> beta_profil <- [LEADER::2.0, SUIVEUR_PRECOCE::1.0, SUIVEUR_TARDIF::1.0,REFRACTAIRE::1.0];
	map<string, float> proba_choix_act <- [ENTREE::0.25, PLAT::0.5, DESSERT::0.25];
	map<string,rgb> couleur_type <- [ENTREE::#green, PLAT::#orange, DESSERT:: #red,CAISSE::#gray, PLATEAU::#blue]; //Couleur des ilots 
	
	map<string, file> imagefile_type  <- map<string, file>(mode_batch ? [] : [
		"Froid1"::image_file("../includes/visualisation/entree.png"),
		"Froid2"::image_file("../includes/visualisation/froid.png"),
		"Refrigere"::image_file("../includes/visualisation/entree.png"),
		"Grillades"::image_file("../includes/visualisation/grillades.png"),
		"Pizzas"::image_file("../includes/visualisation/pizzas.png"),
		"Pates":: image_file("../includes/visualisation/pates.png"), 
		"Caisse1":: image_file("../includes/visualisation/caisse1.png"),
		"Caisse2":: image_file("../includes/visualisation/caisse2.png"),
		"Plateau"::image_file("../includes/visualisation/plateau.png")
	]);
	
	string scenario <- "LDV_21_octobre" among: [ "LDV_21_octobre",  "LDV_22_octobre",  "ENS_28_octobre", "ENS_29_octobre"];
	string lieu_scenario <- (scenario split_with "_") [0];
	string jour_scenario <-  (scenario split_with "_") [1];
	string mois_scenario <-  (scenario split_with "_") [2];
	
	string dossier_chemin <- "../includes/" + lieu_scenario + "/" + lieu_scenario +  " " + jour_scenario + " " + mois_scenario + " V2/includes/Shapefiles/generated/" ;
	string formulaire_chemin <- "../includes/Resultats_formulaires_"  + jour_scenario + "_" + mois_scenario+  ".csv";
	string resultat_chemin <- "../includes/Resultats_choix_"+ jour_scenario + "_" + mois_scenario+  ".csv";
	
	map<string, int> plats_prix_obs;
	bool generate_etudiants_fichier <- true;

	shape_file ilots_shape_file <- shape_file(dossier_chemin + "ilots.shp");
	shape_file murs_shape_file <- shape_file(dossier_chemin + "murs.shp");
	shape_file plats_shape_file <- shape_file(dossier_chemin + "plats.shp");
	shape_file portes_shape_file <- shape_file(dossier_chemin + "portes.shp");
	shape_file queues_shape_file <- shape_file(dossier_chemin + "queues.shp");
	
	
	bool mode_batch <- false;
	bool end_simu <- false;
	bool I_say_so <-false;
	geometry shape <- envelope(murs_shape_file);
	list<porte> entrees_piece;
	list<porte> sorties_piece;
	list<cell> cell_utilisables;
	
	list<plat> entrees;
	list<plat> plats;
	list<plat> accompagnements;
	
	list<plat> desserts;
	
	list<ilot> ilots_plateaux;
	list<ilot> ilots_entrees;
	list<ilot> ilots_plats;
	list<ilot> ilots_desserts;
	list<ilot> ilots_caisses;
	
	int nb_amis_max <- 5; //Nombre maximum d'amis avec lesquels l'agent va manger
    
	bool affichage_trace <- false parameter: true category: "Visualisation";
	int trace_longueur <- 10 parameter: true category: "Visualisation";
	bool affichage_perception <- false parameter: true category: "Visualisation";
	
	
	list<cell> cellules_chemin;

	geometry poly_inter;
	list<cell> internal_cells;
	
	
	map<string,int> nb_tot_obs;
	map<string,int> nb_tot_sim;
	
	//map<string,list<int>> scores_type <- [HEALTHY::[0,1],CLASSIQUE::[2,3],GLOUTON::[4,5]];
	//map<string,list<int>> scores_cat_personne <- [SH::[0,2],H::[3,4],NH::[5,6], NG::[7,8], G::[9,10],SG::[11,12]];
	//map<string,list<string>> correspondance_personne_type <- [HEALTHY::[SH,H],CLASSIQUE::[NH,NG],GLOUTON::[G,SG]];
	
	
	float Nb_points_moyen_personne;
	float Nb_points_moyen_plat;
	map<string,int> plats_choisis;
	
	list<float> Nb_points_final;
	
	string manage_name(string nom) {
		
		if first(nom) = " " {
			nom <- copy_between(nom,1, length(nom));
		} 
		loop while: last(nom) = " " {
			nom <- copy_between(nom,0, length(nom) -1);
		}
		nom <- nom replace("â", "a") replace("à", "a") replace("é", "e") replace("è", "e")replace("ê", "e") replace("ô", "o") replace ("'", " ") ;
		
		return nom;
	}
	
	
	
	reflex manage_stuck_agents when: cycle > 1000 and every(10000 #cycle) and not empty(etudiant){
		ask etudiant with_max_of each.Nb_points_etudiant {
			ma_cellule.is_free <- true;
			do die;
		}
	}
	reflex fin_simu when: empty(etudiant) and generate_etudiants_fichier {
		fitness <- 0.0;
		
		
		
		map<string, list<plat>> plats_per_groupe <- plat group_by (each.groupe);
		
		if not mode_batch {write "\n**** choix groupes ****";}
		loop n over: plats_per_groupe.keys {
			list<plat> ps <- plats_per_groupe[n];
			if ps sum_of each.Nb_points > 0 {
				float obs <- 0.0;
				float sim <- 0.0;
				ask ps {
					obs <- obs +(Nom in plats_choisis.keys ?plats_choisis[Nom] : 0.0);
					sim <- sim + nb_choix;
				}
				fitness <- fitness + abs(obs - sim);
				if not mode_batch {write n + " "+ sample(obs) + " " + sample(sim);}
				nb_tot_obs[n] <- obs;
				nb_tot_sim[n] <-sim;
			}
			
		}
		if not mode_batch {write "\n**** fitness: " + fitness + " ****";} else {
			write "simulation : " + int(self) + " fitness: " + fitness;
		
		}
		if mode_batch {
			string parameters <- ""+coeff_autre_moyenne+","+coeff_autre_sociale_et+","+coeff_amis_moyenne+","+coeff_amis_et+","+influence_sociale_moyenne+","+influence_sociale_et+","+
			influence_env_moyenne+","+influence_env_et+","+delta_moyenne+","+delat_et+","+choix_personnel_moyenne+","+choix_personnel_et+","+proba_depassement1point+","+proba_manque1point+","+
			proba_depassement2points+","+force_perception_plat+","+proba_autre_entree+","+proba_autre_dessert+","+proba_encore+","+temps_entre_groupes+","+seuil_influence_etudiant_queue +","+
			Charcuterie_correction+","+Crudites_correction+","+Entree_poisson_correction+","+Salade_feculents_correction+","+Viande___correction+","+Pizza_correction+","+Accompagnement___correction+","+Accompagnement_correction+","+Viande_correction+","+Poisson_correction+","+Vege_correction+","+Fruit_correction+","+Produit_laitier_correction+","+Creme_dessert_correction+","+Fruits_gourmands_correction+","+Dessert_gourmand_correction+","+Fromage_correction;

			string result <- copy(parameters) + "," + fitness;
			save result type:text to:dossier_chemin + "resultats_all_simu.csv" rewrite:false;
			end_simulation <- true;
		
		} else {
			
			write "**** choix plats ****";
			ask plat {
				if Nb_points > 0 {
					float val_obs <- Nom in plats_choisis.keys ?plats_choisis[Nom] : 0.0;
					write Nom + " " + sample(type) + " "+ sample(Categorie) + " " + sample(groupe)+ " " + sample(val_obs) + " " +  sample(nb_choix);
					fitness <- fitness + abs(val_obs - nb_choix);
					
					
				}
			}
			
			//write sample(nb_tot_obs);
			//write sample(nb_tot_sim);
			do pause;
		}
		
		//save parameters + ","+ (simulations mean_of each.fitness) type:text to:dossier_chemin + "resultats_finaux.csv" rewrite:false;
	
	}
	action generation_population_fichier {
		map<string,list<string>> plats_choisis_ind;
		matrix data_choix <- matrix(csv_file(resultat_chemin,";", true));
		loop i from: 0 to: data_choix.rows -1  {
			string id <- data_choix[1,i];
			list<string> entrees_str <- string(data_choix[2,i]) split_with ("+") - ["Pas d'entrée"];
			list<string> plats_str <- string(data_choix[4,i]) split_with ("+");
			list<string> dessert_str <- string(data_choix[5,i]) split_with ("+") - ["Pas de dessert"];
			plats_choisis_ind[id] <- (entrees_str + plats_str + dessert_str) collect manage_name(each);
		}
		
		
		
		matrix data <- matrix(csv_file(formulaire_chemin,";", true));
		loop i from: 0 to: data.rows -1  {
			string id <- data[0,i];
			string genre_str <- data[1,i];
			int age_v <- int(data[2,i]);
			float imc_v <- float(string(data[5,i]) replace (",","."));
			bool is_veg <- string(data[8,i]) = "Oui";
			list<string> amis_str_v;
			loop j from: 22 to: 26 {
				string ami_str <- string(data[j,i]);
				if ami_str != "" {
					amis_str_v<<ami_str;
				}
			}
			if age_v > 0 and (id in plats_choisis_ind.keys){
				if imc_v = 0 {
					imc_v <- gauss(24.0,8.0);
				}
				create etudiant with: (
					age:age_v, 
					id_str:id,
					genre:genre_str,
					imc:imc_v,
					amis_str:amis_str_v,
					est_vegetarien: is_veg
				);
			}
			
			
		}
		
		
		list<string> etudiants_id <- etudiant collect each.id_str;
		ask plat {
			plats_choisis[Nom] <- 0;
		}
		loop id over: plats_choisis_ind.keys inter etudiants_id {
			loop p over:  plats_choisis_ind[id] {
				if p in plats_choisis.keys {
					plats_choisis[p] <- plats_choisis[p]  + 1;
				} else {				
					if not mode_batch {write p; }
				}
			}
		} 
		
		if not mode_batch {	write sample(plats_choisis);}
		if not mode_batch {write sample(length(etudiant));}
		
		map<string, etudiant> edut_id <- etudiant as_map (each.id_str::each);
		ask etudiant {
			if length(amis_str) > 0 {
				list<etudiant> ami_g <- amis_str collect (edut_id[each]);
				ami_g <- ami_g where (each != nil);
				if not empty(ami_g) {
					amis <- ami_g as_map (each::["solidarite"::rnd(0.5, 1.0), "familiarite"::rnd(0.5, 1.0), "dominance"::rnd(-1.0,1.0), "appreciation"::rnd(0.5, 1.0), "trust"::rnd(0.5, 1.0)]);
					loop ami over: amis.keys {
						amis[ami]["force"] <- sum(amis[ami].values);
					}
				}
			}
		}
		csv_file Regroupements_plats_csv_file <- csv_file("../includes/Regroupements_plats.csv", ";", true);
		matrix data_gp <- matrix(Regroupements_plats_csv_file);
		loop i from: 0 to: data_gp.rows -1 {
			string nom_p <- manage_name(string(data_gp[1,i]));
			string gn <- string(data_gp[2,i]);
			ask plat where (each.Nom = nom_p) {groupe <- gn;}
			
			
		}
	
	}
	
	
	init{
		create plat from: plats_shape_file ;
		if generate_etudiants_fichier {
			do generation_population_fichier;
		}
	  	create queue from: queues_shape_file {
	  		cells <- cell overlapping self; //en créant queue, il y a des cellules qui se superposent
	  		graph g <- as_edge_graph(shape);
	  		using topology(g) {
	  			cells <- cells sort_by (each distance_to last(shape.points));
	  		}
	  		loop times: length(cells) {
	  			etudiants << nil;
	  		}
	  		
	  	}
		//Creation of the wall and initialization of the cell is_wall attribute
		create ilot from: ilots_shape_file {
			ask cell overlapping self {
				is_wall <- true;
			}
			plats_proposes <- plat overlapping self;
			ask plats_proposes {
				ilot_correspondant <- myself;
				type <- myself.Type;
			}
			queue_service <- queue closest_to self;
			shape <- shape simplification 1.0;
			
		}

		create mur from: murs_shape_file {
			ask cell overlapping self {
				is_wall <- true;
			}
		}
		poly_inter <- polygon(remove_duplicates(mur[0].shape.points + mur[2].shape.points + mur[1].shape.points));
		ask cell overlapping (world.shape - poly_inter) {
			is_wall <- false;
		}
		ask cell overlapping poly_inter { //les cellules qui superposent le monde 
			if (location overlaps poly_inter) {
				internal_cells << self;
			}
		}
		ask queue {
			ask cells {
				cellules_chemin << self;
			}
		}
		//Creation of the exit and initialization of the cell is_exit attribute
		create porte from: portes_shape_file {
			ask cell overlapping self {
				is_wall <- false;
			}
		}
		entrees_piece <- porte where ("Entree" in each.Nom);
		sorties_piece <- porte where ("Sortie" in each.Nom);
		ilots_plateaux <- ilot where (each.Type = PLATEAU);
		ilots_entrees <- ilot where (each.Type = ENTREE);
		ilots_plats <- ilot where (each.Type = PLAT);
		ilots_desserts <- ilot where (each.Type = DESSERT);
		ilots_caisses <- ilot where (each.Type = CAISSE);
		ask ilot {
			temps_service <- duration_type[Type];
		}
		cell_utilisables <- cell where not(each.is_wall);
		cell_utilisables <- cell_utilisables - cellules_chemin ;
		ask cell {color <- #black;} //c'est ici que le mur est noir ou violet 
		ask cell_utilisables {color <- #white;}
		ask ilot {
			list<cell> cellules_dessous <- cell overlapping self ;
			cellules_a_cotes <- remove_duplicates(cellules_dessous accumulate each.neighbors) inter cell_utilisables;
			ask cellules_a_cotes  {
				color <- #orange; //cellules à coté des ilots 
			}
			ask plats_proposes {
			 	using topology(world) {
					cellule_service <- myself.cellules_a_cotes closest_to self;
				}
			}
			if (Type = ENTREE) {
				entrees <- entrees + plats_proposes;
			} else if (Type = PLAT) {
				plats <- plats + plats_proposes;
			} else if (Type = DESSERT) {
				desserts <- desserts + plats_proposes;
			}
		}
		entrees <- entrees sort_by each.Nb_points;
		accompagnements <- plats where (each.Nb_points = 0);
		plats <- plats where (each.Nb_points > 0);
		plats <- plats sort_by each.Nb_points;
		
		plat_points <- plats min_of each.Nb_points;
		desserts <- desserts sort_by each.Nb_points;
		ask queue {
			float coeff <- 1/ length(cells);
			loop i from: 0 to: length(cells) - 1 {
				ask cells[i] {
					color <- rgb(i * 255 * coeff, 0,0); //la cellule s'assombrit au fur et à mesure qu'on avance dans la queue
				}
			}
		}
		//write remove_duplicates(plat collect each.groupe);
		map<string,float> correction_groupe;
		correction_groupe[ "Charcuterie" ] <-Charcuterie_correction;
		correction_groupe[ "Crudités" ] <-Crudites_correction;
		correction_groupe[ "Entrée poisson" ] <-Entree_poisson_correction;
		correction_groupe[ "Salade féculents" ] <-Salade_feculents_correction;
		correction_groupe[ "Viande +" ] <-Viande___correction;
		correction_groupe[ "Pizza" ] <-Pizza_correction;
		correction_groupe[ "Accompagnement +" ] <-Accompagnement___correction;
		correction_groupe[ "Accompagnement" ] <-Accompagnement_correction;
		correction_groupe[ "Viande" ] <-Viande_correction;
		correction_groupe[ "Poisson" ] <-Poisson_correction;
		correction_groupe[ "Vege" ] <-Vege_correction;
		correction_groupe[ "Fruit" ] <-Fruit_correction;
		correction_groupe[ "Produit laitier" ] <-Produit_laitier_correction;
		correction_groupe[ "Crème dessert" ] <-Creme_dessert_correction;
		correction_groupe[ "Fruits gourmands" ] <-Fruits_gourmands_correction;
		correction_groupe[ "Dessert gourmand" ] <-Dessert_gourmand_correction;
		correction_groupe[ "Fromage" ] <-Fromage_correction;
		ask plat {
			correction <- correction_groupe[groupe];
		}
	}
	
	
	reflex arrivee_etudiant when: every(temps_entre_groupes) {
		if not generate_etudiants_fichier  {
			if nombre_etudiants > 0 {
				int nb_amis <-  rnd(1,min(nb_amis_max, nombre_etudiants)); // creation groupes d'amis entre 1 et 6 (minimum entre nb amis max et le nombre d'étudiants pas encore entrés dans le RU) 
				porte la_porte <- one_of(entrees_piece); //la porte d'entrée du groupe est l'une des entrées 
				cell cellule_entree <- cell(la_porte.location ) ; //la cellule d'entrée est celle où se trouve la porte
				list<cell> cellule_entrees <- ([cellule_entree] + cellule_entree.neighbors) where each.is_free; //les cellules adjacentes libres sont disponibles pour les membres du groupe
				loop while: length(cellule_entrees) < nb_amis { //tant que le nombre d'amis est sup au nombre de cellules d'entrée,
					cellule_entrees <- cellule_entrees + one_of(cellule_entrees).neighbors; //on ajoute une cellule avoisinante 
					cellule_entrees <- cellule_entrees where each.is_free; //qui est libre 
				}
				create etudiant number: nb_amis returns: groupe_cree{
					ma_cellule <-(one_of(cellule_entrees));
					cellule_entrees >> ma_cellule;
					location <- ma_cellule.location;
					ma_cellule.is_free <- false;
					nombre_etudiants <- nombre_etudiants -1;
					est_actif <- true;
				}
				if length(groupe_cree) > 1 {
					ask groupe_cree { //on attribue des valeurs d'amitié aux membres du groupe si plus de 1 personne 
						amis <- (groupe_cree - self) as_map (each::["solidarite"::rnd(0.5, 1.0), "familiarite"::rnd(0.5, 1.0), "dominance"::rnd(-1.0,1.0), "appreciation"::rnd(0.5, 1.0), "trust"::rnd(0.5, 1.0)]);
						loop ami over: amis.keys {
							amis[ami]["force"] <- sum(amis[ami].values);
						}
					}
				}
			}
		} else {
			list<etudiant> non_actif <- etudiant where (not each.est_actif);
			if not empty(non_actif) {
				porte la_porte <- one_of(entrees_piece); //la porte d'entrée du groupe est l'une des entrées 
				cell cellule_entree <- cell(la_porte.location ) ; //la cellule d'entrée est celle où se trouve la porte
				list<cell> cellule_entrees <- ([cellule_entree] + cellule_entree.neighbors) where each.is_free; //les cellules adjacentes libres sont disponibles pour les membres du groupe
			
				etudiant to_enter <- one_of(non_actif);
				ask [to_enter] + ((to_enter.amis.keys) where (not dead(each) and not each.est_actif)){
					est_actif <- true;
					ma_cellule <-(one_of(cellule_entrees));
					cellule_entrees >> ma_cellule;
					if ma_cellule = nil {
						using topology(world) {
							ma_cellule <- (cell_utilisables where each.is_free) closest_to la_porte ;
						}
					}
					location <- ma_cellule.location;
					ma_cellule.is_free <- false;
					
				}
			}
		}
		
	}
	
	reflex end_simulation when: empty(etudiant) and (nombre_etudiants = 0) {
		
		Nb_points_moyen_personne <-mean(Nb_points_final);
		ask plat {
			plats_choisis[self.Nom] <- nb_choix;
			Nb_points_moyen_plat <- Nb_points_moyen_plat + (nb_choix * Nb_points);
		}
		Nb_points_moyen_plat <- Nb_points_moyen_plat / (plat sum_of each.nb_choix);
		if(not mode_batch)
		{
			do pause;	
		} else {
			end_simu <- true;
		}
	}
	
}

species queue {
	list<cell> cells;
	list<etudiant> etudiants;
	
	reflex avancement_etudiants {
		loop i from: 1 to: length(cells) -1 {
			cell cellule <- cells[i-1];	
			if (cellule.is_free) {
				etudiant etudiant_avancant <- etudiants[i];
				if (etudiant_avancant != nil) and not(etudiant_avancant.en_attente) {
					etudiants[i] <- nil;
					etudiants[i-1] <- etudiant_avancant;
					etudiant_avancant.ma_cellule.is_free <- true;
					etudiant_avancant.ma_cellule <- cellule;
					cellule.is_free <- false;
					
					etudiant_avancant.location <- cellule.location;
					ask etudiant_avancant {do manage_trace;}
						
					if (etudiant_avancant.final_target = cellule) {
						ask etudiant_avancant{
							do commande;
						}
					}
				}
			}
			
		}
	}
	
	action ajoute(etudiant un_etudiant) {
		add un_etudiant to: etudiants at: length(cells) - 1;
	}
	aspect default {
		draw shape color: #red;
	}
}

species plat {
		//on lui affecte une couleur aléatoire
	//int Nutriscore;
	int Vege;
	int Nb_points;
	string type;
	float correction;
	ilot ilot_correspondant;
	list<float> proba_choix; 
	int nb_choix;
	int Influences <- 1;
	cell cellule_service;
	string Nom;
	string Categorie;
	string groupe;
	//coefficients poids des variables age, genre et imc = importance de ces variables pour le choix individuel
	float age_f; //<- rnd(-1.0,1.0); //aléatoire en 0 et 1
	float genre_f; //<- rnd(-1.0,1.0);
	float imc_f; // <- rnd(-1.0,1.0);
	float intercept;
	float CO_imcsex; 
	//equation de choix du plat en fonction de age, genre et corpulence = prévision du choix individuel 
	
	
	float force_choix(etudiant e) {
		//reg <- intercept + (e.age /25.0) *  age_f + genre_f * (e.genre = "M" ? 1.0 : 0.0) + imc_f *e.imc /24 + CO_imcsex*(e.genre = "M" ? 1.0 : 0.0)*e.imc;
		//return exp(reg)/(1+exp(reg));
		//return intercept + (e.age /25.0) *  age_f + genre_f * (e.genre = "M" ? 1.0 : 0.0) + imc_f *e.imc /24 + CO_imcsex*(e.genre = "M" ? 1.0 : 0.0)*e.imc;
		 float val <- exp(intercept + (e.age /25.0) *  age_f + genre_f * (e.genre = "M" ? 1.0 : 0.0) + imc_f *e.imc /24 + CO_imcsex*(e.genre = "M" ? 1.0 : 0.0)*e.imc);
		 return ((val/(1+val)) + correction);
	}
	//ce sont des caractéristiques de l'étudiant qui vont être attribuées aux différents plats
	 
	//rgb color <- rgb(Nutriscore/5.0 * 255, (1 - Nutriscore/5.0) * 255, 0);
	aspect default {
		draw hexagon(0.4) color:#blue border: #black;
	}
}

//Species exit which represent the exit
species porte {
	string Nom;
	aspect default {
		draw square(0.5) color: #blue;
	}
	aspect demo3D {
		draw square(0.5) depth: 2.0 color: #orange;
	}
}
//Species which represent the wall
species mur {
	aspect default {
		draw shape color: #black ; //ici juste la trace des murs du shapefile 
	}
	
	aspect demo3D {
		draw shape + 0.1 texture: image_file("../includes/visualisation/wall.jpg") depth: 2.0;
	}
}
species ilot {
	string Nom;
	string Type;
	list<plat> plats_proposes;
	float temps_service;
	list<cell> cellules_a_cotes;
	queue queue_service;
	aspect default {
		draw shape color: couleur_type[Type];
	}
	
	aspect demo3D {
		draw shape texture: [imagefile_type[Nom],image_file("../includes/visualisation/black.png")] depth: 1.0;
	}
}

species etudiant skills:[moving] schedules: etudiant where each.est_actif{
	//Définition des caractéristiques des étudiants qui vont déterminer leurs préférences individuelles 
	int age <- rnd(18,25);
	bool est_actif <- false;
	string genre <- flip(0.5) ? "M" : "F";
	float imc <- gauss(24.0,8.0) #kg/#m2 min:10 #kg/#m2 max:50 #kg/#m2 ;
	list<string> amis_str;
	string id_str;
	plat entree_prise;
	plat entree_prise2;
	plat plat_pris;
	plat dessert_pris;
	plat dessert_pris2; 
	plat accompagnement;
	bool est_vegetarien <- flip(proba_vegetarien);
	
	bool a_plateau <- false;
	bool a_paye <- false;
	bool a_entree <- false;
	bool a_entree2 <- false;
	bool a_plat <- false;
	bool a_dessert <- false;
	bool a_dessert2 <- false;
	bool a_accompagnement <- false;
	int nb_choix; 
	int Nb_points_init <- 0;
	int Nb_points_etudiant <- 0; 
	//gauss(Nb_points_attendu,ecart_type_Nb_points) min: 0.0 max: 8.0;
	//float Nb_points <- Nb_points_init min: 0.0 max: 8.0;
	bool use_social_architecture <- true; 
	
	map<etudiant, map<string,float>> amis;
	
	int Influences <- 1;
	list<point> last_locs;
	float coeff_autre min: 0.0 max: 1.0 <- gauss(coeff_autre_moyenne, coeff_autre_sociale_et); //importance des étudiants lambda dans le choix 0.01
	float coeff_amis min: 0.0 max: 1.0 <- gauss(coeff_amis_moyenne, coeff_amis_et);  //importance des amis dans le choix 0.02
	float poids_influence_sociale min: 0.0 max: 1.0 <- gauss(influence_sociale_moyenne, influence_sociale_et); //importance globale de l'influence sociale rnd(1.0)
	float poids_influence_environnement min: 0.0 max: 1.0 <- gauss(influence_env_moyenne, influence_env_et); //importance globale de l'influence environnementale rnd(1.0) 
	float delta min: 0.0 max: 1.0 <- gauss(delta_moyenne, delat_et);  //coefficient d'importance, de sensibilité au temps d'attente pour avoir un plat.rnd(1.0)
	float poids_choix_personnel min: 0.0 max: 1.0 <- gauss(choix_personnel_moyenne, choix_personnel_et);  //importance globale donnée aux pref individuelles  rnd(1.0) 
	
	bool envisage_deux_entrees <- flip(proba_autre_entree); // est-ce qu'il envisage de prendre 2 entrees
	bool envisage_deux_desserts <- flip(proba_autre_dessert);  // est-ce qu'il envisage de prendre 2 desserts
	
 	bool envisage_manque_1_point <- flip(proba_manque1point);  // est-ce qu'il envisage de manquer 1 point
 	bool envisage_depassement_1_point <- flip(proba_depassement1point);  // est-ce qu'il envisage de dépasser de 1 point
 	bool envisage_depassement_2_points <- envisage_depassement_1_point and flip(proba_depassement2points);  //est-ce qu'il envisage de dépasser de 2 points
 
 	bool plus_de_entree <- false;
 	bool plus_de_dessert <- false;
	
	//float proba_choix <- 1/nb_choix;//min: 0.0 max: 12.0//
	//list<float> probas_choix <- plat collect each.proba_choix;  
	//string categorie <- score_cat(score_init);
	//string profil;
	//float alpha;
	//float beta;
	
	//on lui affecte une couleur aléatoire
	//rgb color -> {rgb(score/12.0 * 255, (1 - score/12.0) * 255, 0)};
	
	
	//chacun a sa vitesse de déplacement (gaussienne avec moyenne de 2.0 Km/h et écart type de 0.5 - avec un min et un max)
	float speed <- gauss(2.0, 0.5) #km/#h  min: 2.5 #km/#h max: 7.0 #km/#h ;
	
	//l'endroit où il souhaite se déplacer
	cell target;
	cell final_target;
	cell ma_cellule;
	float temps_attendu update: temps_attendu + step;
	ilot ilot_destination;
    
	
	bool en_attente <- false;
	bool attente_queue <- false;
	path chemin_a_suivre;
    
    queue queue_courante <- nil;
    
    //Graphical representation 
	float mysize;
	string my_file;
	pair init_rotation;
	float translation;
	
	string activite <- PLATEAU;
	
	
    
    init {
			my_file <- one_of(["../includes/3Dmodel/female03/female03.obj", 
							"../includes/3Dmodel/holdingMale01/holdingMale01.obj",
							"../includes/3Dmodel/girlStanding/girlStanding.obj",
							"../includes/3Dmodel/boyStanding/boyStanding.obj"
							]);
			mysize <- rnd(1.3,1.8);
			translation <- mysize/2.0;
			init_rotation <- 90::{-1,0,0};
			
			//if(!hasFriend)){
			//friend <- one_of(etudiant where ((!each.hasFriend)and(each distance_to self <1#m)));
			//if(!(friend=nil)){
				//hasFriend<-true;
				//do add_social_link(new_social_link(friend,gauss(0.5,0.12),gauss(0.0,0.33),gauss(0.5,0.12),gauss(0.5,0.12)));
				//solidarity <- get_solidarity(get_social_link(new_social_link(friend)));
				//ask friend{
					//friend <- myself;
					//hasFriend<-true;
					//do add_social_link(new_social_link(friend,gauss(0.5,0.12),gauss(0.0,0.33),gauss(0.5,0.12),gauss(0.5,0.12)));
					//solidarity <- get_solidarity(get_social_link(new_social_link(friend)));
				//}
			//}
		//}
	}
	
	float influence_autre(plat un_plat) {
		float influence_autre <- 0.0;
		
		list<etudiant> autres <- (etudiant at_distance distance_perception) where each.est_actif;
		list<etudiant> amis_proche <- amis.keys inter autres;
		autres <- autres - amis.keys; //définition des individus lambda pour l'agent considéré
		if (un_plat.type = ENTREE) {
			list<etudiant> amis_qui_ont_choisi <- amis_proche where (each.entree_prise != nil); //etudiants amis qui ont pris une entrée
			if not empty(amis_qui_ont_choisi) {influence_autre <- coeff_amis * amis_qui_ont_choisi sum_of ((amis[each]["force"] * ((each.entree_prise = un_plat) ?  1.0 : 0.0)));}
			if not empty(autres) {influence_autre <- influence_autre + coeff_autre * (autres count (each.entree_prise = un_plat));} //on y ajoute l'influence des autres 
		} else if (un_plat.type = PLAT) {
			list<etudiant> amis_qui_ont_choisi <-amis_proche where (each.plat_pris != nil);
			if not empty(amis_qui_ont_choisi) {influence_autre <- coeff_amis * amis_qui_ont_choisi sum_of ((amis[each]["force"]  * ((each.plat_pris = un_plat) ?  1.0 : 0.0)));}
			if not empty(autres) {influence_autre <- influence_autre + coeff_autre * (autres count (each.plat_pris = un_plat)); }
		} else if (un_plat.type = DESSERT) {
			list<etudiant> amis_qui_ont_choisi <- amis_proche where (each.dessert_pris != nil);
			if not empty(amis_qui_ont_choisi) {influence_autre <- coeff_amis * amis_qui_ont_choisi sum_of ((amis[each]["force"] * ((each.dessert_pris = un_plat) ?  1.0 : 0.0)));}
			if not empty(autres) {influence_autre <- influence_autre + coeff_autre * (autres count (each.dessert_pris = un_plat)); }
		}
			
		return influence_autre;
	}

	float influence_environnement(plat un_plat) {
		float influence_environnement <- (self distance_to un_plat) <= distance_perception ? force_perception_plat : 0.0;
		
		int nombre_etudiants_queue <- length(un_plat.ilot_correspondant.queue_service.etudiants);
		if (nombre_etudiants_queue > seuil_influence_etudiant_queue) {
			influence_environnement <- influence_environnement - delta * nombre_etudiants_queue;
		} 
		
		return influence_environnement;
		//if (un_plat.type = ENTREE) {
			/*influence_environnement <- coeff_perceptions * influence_sens
			influence_environnement <- influence_environnement + (1-delta*Temps_attente) */
		//}
	}
	
	float compute_proba(plat un_plat){
		// fonction de l'évaluation du plat X_plat par l'étudiant
		//write un_plat.Nom + " -> perso: " + (poids_choix_personnel * un_plat.force_choix(self)) + " social:" + (poids_influence_sociale * influence_autre(un_plat) ) + " env: " +  poids_influence_environnement * influence_environnement(un_plat);
		
		return  poids_choix_personnel * un_plat.force_choix(self) + poids_influence_sociale * influence_autre(un_plat) +poids_influence_environnement * influence_environnement(un_plat);
		
	}
	
	
	//string score_cat(float val) {
		//int val_int <- round(val);
		//loop sp over: scores_cat_personne.keys {
			//list<int> vs <- scores_cat_personne[sp];
			//if (val_int >= vs[0] and val_int <= vs[1]) {
				//return sp;
			//}
		//}
	//}
     
   
   list<plat> selection_plat_possible(list<plat> plats_a_selectionner) {
   	 list<plat> plats_possibles_init <- copy(plats_a_selectionner);
    if est_vegetarien {
   	 	plats_possibles_init <- plats_possibles_init  where (each.Vege = 1); 
   	 }
   	 list<plat> plats_possibles;
    	loop p over: plats_possibles_init {
    		
    		int point_si_choix <- Nb_points_etudiant + p.Nb_points;
    		if (point_si_choix > Nb_points_attendu) {
				if point_si_choix = (Nb_points_attendu + 1) and  envisage_depassement_1_point{
					plats_possibles << p;
				} else if (Nb_points_etudiant = (Nb_points_attendu + 2)) and  envisage_depassement_2_points {
					plats_possibles << p;
				}
			} else {
				plats_possibles << p;
			}
		}
		//si il ne veut pas prendre un plat déjà pris, on l'enleve
	if not flip(proba_encore) {
		plats_possibles <- plats_possibles - [plat_pris, entree_prise,entree_prise2, dessert_pris,dessert_pris2];
	}	 
   	
   	 return plats_possibles;
   }
    
    plat choix_plat(list<plat> plats_possibles_init, bool force_choix) { 
    	//string cat_pers <- score_cat(val);
    	//string type;
    	list<plat> plats_possibles <- selection_plat_possible(plats_possibles_init);
    	if empty(plats_possibles) {
    		if force_choix {
    			plats_possibles <-est_vegetarien ? plats_possibles_init  where (each.Vege = 1) :  plats_possibles_init ;
    		}else {
    			return nil;
    		}
    		
    	}
    	
    	list<float> probas_choix <- plats_possibles collect compute_proba(each); //collecte les "probas" de choix pour chaque plat 
    	float min_val <- min(probas_choix); //plat avec la plus petite valeur de proba
    	
    	if (probas_choix first_with (each > 0)) = nil  { //si aucun plat intéressant, renvoie un des plats possible aléatoirement
    		if (not force_choix and (Nb_points_etudiant = (Nb_points_attendu - 1)) and envisage_manque_1_point) {
    			return nil;
    		}
    		probas_choix <- probas_choix collect (each - min_val);
    		if (sum(probas_choix) = 0.0) {
    			return one_of(plats_possibles);
    		} else {
    			return plats_possibles[rnd_choice(probas_choix)];
    		}
    		
    		
    	}
    	if (min_val) < 0.0 {
    		probas_choix <- probas_choix collect (each< 0 ? 0.0 : each); //on enleve le plat avec la valeur minimale si négative 
    	}
    	return plats_possibles[rnd_choice(probas_choix)]; //Loterie des plats en fonction des probabilites 
    	//AJOUTER ICI LE LANCEMENT DE CHRONOMETRE ?
    	//float temps_influence update: temps_influence + step;

    		//if (cat_pers in correspondance_personne_type[cat]) {
    			//type <- cat;
    			//break;
    		//}
    	//} 
    	//return one_of(plats_possibles where (each.type = type));
    }
    
	reflex deplacement when: target != nil and not attente_queue{
		ma_cellule.is_free <- true;
		point prev_loc <- copy(location);
		do follow path: chemin_a_suivre;
		cell new_cell <- cell(location);
		if (not new_cell.is_free) {
			location <- prev_loc;
			do goto (target: target, on:([new_cell, target] + cell_utilisables) where (each.is_free));
			if prev_loc = location {
				list<cell> cells <- ma_cellule.neighbors where (each.is_free and not each.is_wall);
				if not empty(cells) {
					do goto target: one_of(cells).location;
				}
			}
			new_cell <- cell(location);
			
		}
		ma_cellule <- new_cell;
		ma_cellule.is_free <- false;
		if (ma_cellule = target) {
			target <- nil;
			if (queue_courante != nil) {
				attente_queue <- true;
				ask queue_courante {
					do ajoute(myself);
				}
			} else {
				en_attente <- true;
			}
			
		}
		do manage_trace;
	}
	
	/*reflex influence_autres when: avec_influence_autres{ //AJOUTER ICI LES INFLUENCES 
		list<etudiant> voisins <- etudiant at_distance distance_perception;
		if (not empty(voisins)) {
			int N <- length(voisins);
			//Ajout par moi : Pinf = x*n amis + Somme des forces des amitiés + y * n pairs + z 
			// float x <- 0.1;
			// int n_amis <- nombre friend dans champ de perception 
			//Somme de forces des amitiés selon BEN
			// float y <- 0.05;
			// int n_pairs : nombre student not friend dans champ de perception 
			// int z <- 0 ou  z <- 1; 
			//Déjà présents :
			//float gamma <- 0.5 * exp(-1 * (N - 7)^2/(2*2.8^2));
			//float diff <-alpha /N *  gamma;
			//float resultat;
			//loop cat over: scores_cat_personne.keys {
				//list<etudiant> voisins_cat <- voisins where (each.categorie = cat);
				//if not empty(voisins_cat) {
					//float somme;
					//ask voisins_cat {
						//somme <- somme + beta * (score - myself.score);
					//}
					//resultat <-  length(voisins_cat) * somme;
				//}
			//}
			//diff <- diff * resultat;
			//score <- score + diff;
		}
	}*/
	
	//AJOUTER ICI REFLEX INFLUENCES PHYSIQUES NON SOCIALES 
	
	action manage_trace {
		loop while:(length(last_locs) > trace_longueur) {
			last_locs >> first(last_locs);
		}  	
		last_locs << location;
	}
	
	action commande {
		final_target <- nil;
		temps_attendu <- 0.0;
		en_attente <- true;
		//temps_influence <- 0.0; 
	} 
	//Evolution proba choix act influences physiques / influences sociales 
	//acts[PLAT]
	//acts[ENTREE]
	//acts[DESSERT] 
	//proba_choix_act <- [ENTREE::0.25, PLAT::0.5, DESSERT::0.25]; 
	
	string choix_type_activite { //choix du  prochain item 
		if a_paye {
			return "";
		}
		int ecart_point <- Nb_points_attendu - Nb_points_etudiant;
		if (envisage_depassement_1_point) {
			if envisage_depassement_2_points {
				ecart_point <- ecart_point + 2;
			} else {
				ecart_point <- ecart_point + 1;
			}
		}
		 
		//si il est deja au point max en fonction de s'il souhaite depasser ou non, il va a la caisse
		if (ecart_point <= 0) {
			return CAISSE;
		}
		if not a_plat and ((ecart_point - plat_points) <= 0) {
			return PLAT;
		} 
		map<string,float> acts <- copy(proba_choix_act);
		
		if plus_de_entree {
			acts[ENTREE] <- 0;
		}
		if plus_de_dessert {
			acts[DESSERT] <- 0;
		}
		
		
		if (a_entree){ 
			if (not envisage_deux_entrees or a_entree2){
				acts[ENTREE] <- 0;
			} 
		} 
		
		if (a_plat) {
			acts[PLAT] <- 0;
		}  
		if (a_dessert){ 
			if (not envisage_deux_desserts or a_dessert2){
				acts[DESSERT] <- 0;
			} 
		} 
		
		if sum(acts.values) <= 0.0{ //quand plus rien dans la liste acts :
			if a_paye {return "";} //si a paye, ca renvoit CAISSE
			return CAISSE;
		}
		else {
			return acts.keys[rnd_choice(acts.values)]; 
		}
		//return one_of(acts); //choix aléatoire des acts parmi ceux qui sont dans la liste 
	}
	
	reflex attente_service when: en_attente{ //il faut que l'ilot destination soit choisi 
		float temps_attente <- ilot_destination = nil ? 0.0 : ilot_destination.temps_service;
		
		if (temps_attendu >= temps_attente) {
			en_attente <- false;
			attente_queue <- false;
			if (queue_courante != nil) {
				int index <- queue_courante.etudiants index_of self;
				if (index >= 0) {
					queue_courante.etudiants[index] <- nil;
				}
				queue_courante.etudiants >> self;
			}
			
			if activite = PLATEAU {
				a_plateau <- true;
	    	} else if activite = ENTREE {
	    		plat entree <- a_entree ? entree_prise2 : entree_prise;
	    		entree.nb_choix <- entree.nb_choix + 1; //l'entree prise a été choisie une fois en plus
	    		Nb_points_etudiant <- Nb_points_etudiant + entree.Nb_points; 
	    		 if (a_entree) {
	    		 	a_entree2 <- true ;
	    		 } else {
	    		 	a_entree <- true ;
	    		 }
	    		
	    	}else if activite = PLAT {
	    		plat_pris.nb_choix <- plat_pris.nb_choix + 1; //le plat pris a ete choisi une fois en plus 
	    		Nb_points_etudiant <- Nb_points_etudiant + plat_pris.Nb_points;
	    		a_plat <- true;
	    		if accompagnement != nil {
	    			 accompagnement.nb_choix <- accompagnement.nb_choix + 1; //le plat pris a ete choisi une fois en plus 
	    			 a_accompagnement <- true;
	    		}
	    	}else if activite = DESSERT {
	    		plat dessert <- a_dessert? dessert_pris2 : dessert_pris;
	    		dessert.nb_choix <- dessert.nb_choix + 1; //l'entree prise a été choisie une fois en plus
	    		Nb_points_etudiant <- Nb_points_etudiant + dessert.Nb_points; 
	    		 if (a_dessert) {
	    		 	a_dessert2 <- true ;
	    		 } else {
	    		 	a_dessert <- true ;
	    		 }
	    		
	    	} else if activite = CAISSE {
	    		a_paye <- true;
	    		Nb_etudiants_servis <- Nb_etudiants_servis +1;
	    	} else {
	    		// il a tout fini.
	    		ma_cellule.is_free <- true;
	    		if not mode_batch {
	    			write name + " " + sample(est_vegetarien)+ " "+ ((entree_prise = nil) ? "": (" a pris entree1:" +entree_prise.Nom))
	    			+((entree_prise2 = nil) ? "": (" a pris entree2:" +entree_prise2.Nom))
	    			+((plat_pris = nil) ? "": (" a pris plat:" +plat_pris.Nom))
	    			+((accompagnement = nil) ? "": (" a pris accompagnement:" +accompagnement.Nom))
	    			+ ((dessert_pris = nil) ? "": (" a pris dessert:" +dessert_pris.Nom))
	    			+((dessert_pris2 = nil) ? "": (" a pris dessert2:" +dessert_pris2.Nom));
	    		}
	    		Nb_points_final << Nb_points_etudiant;
	    		do die;
	    	}
	    	activite <- choix_type_activite(); //C'est là que la fonction choix_type_activite entre en jeu 
	    }
		temps_attendu <- temps_attendu + step;
		
	}
	
	reflex choix_destination when: final_target = nil and not en_attente{ 
    	attente_queue <- false;
    	if activite = PLATEAU {
    		ilot_destination <- one_of(ilots_plateaux);
    		final_target <- first(ilot_destination.queue_service.cells);
    	} else if activite = ENTREE  {
    		//ilot_destination <- one_of(ilots_entrees);
    		//final_target <- first(ilot_destination.queue_service.cells);
    		plat entree <- choix_plat(entrees, false);
    		if (entree =nil) {
    			plus_de_entree <- true;
    			activite <- choix_type_activite();
    		} else {
	    		if (a_entree) {
	    			entree_prise2 <- entree; 
	    		} else {
	    			entree_prise <- entree; 
	    		}
	    		ilot_destination <- entree.ilot_correspondant;
	    		final_target <-entree.cellule_service;
    		}
    		
    	}else if activite = PLAT {
    		//ilot_destination <- one_of(ilots_plats);
    		//final_target <- first(ilot_destination.queue_service.cells);
    		plat_pris <-  choix_plat( plats , true);
    		accompagnement <- choix_plat( accompagnements, false);
    		if plat_pris = nil {ask world {do pause;}}
    		ilot_destination <- plat_pris.ilot_correspondant;
    		final_target <-plat_pris.cellule_service;
    	}else if activite = DESSERT {
    		plat dessert <- choix_plat(desserts, false);
    		if (dessert =nil) {
    			plus_de_dessert <- true;
    			activite <- choix_type_activite();
    		} else {
	    	
	    		if (a_dessert) {
	    			dessert_pris2 <- dessert; 
	    		} else {
	    			dessert_pris <- dessert; 
	    		}
	    		ilot_destination <- dessert.ilot_correspondant;
	    		final_target <-dessert.cellule_service;	
	    	}
    	} else if activite = CAISSE {
    		ilot_destination <- one_of(ilots_caisses);
    		final_target <- first(ilot_destination.queue_service.cells);
    		
    	} else {
    		queue_courante <- nil;
    		ilot_destination <- nil;
    		using topology(world) {final_target <- cell((sorties_piece closest_to self).location);}
    		target <- final_target;
    	}
    	if (ilot_destination != nil) {
    		queue_courante <- ilot_destination.queue_service;
    		if not (final_target in queue_courante.cells) {
    			using topology(world) {
    				final_target <- (queue_courante.cells closest_to final_target);
    			}	
    		} 
    		target <- last(ilot_destination.queue_service.cells);
    	}
    	
    	if (target != nil  and (!target.is_queue or target.is_free)) {
    		chemin_a_suivre <- ([ma_cellule, target] + cell_utilisables) path_between (ma_cellule, target);
    	} else {
    		chemin_a_suivre <- nil;
    	}
    	
    }
    
		
	aspect default {
		if est_actif {
			if (affichage_perception) {
				draw circle(distance_perception).contour + 0.01 color: color ;
			}
			if (est_vegetarien) {
				draw circle(0.25) color: #cyan;
			}
			draw triangle(0.35) rotate: heading + 90.0 color: color border: #black;
		}
	}
		
	aspect trace {
		if est_actif {
			if (affichage_trace) {
				draw line(last_locs, 0.05) color: color ;
			}
		}
	}
	aspect demo3D {
		if est_actif {
			if (affichage_perception) {
				draw circle(distance_perception).contour + 0.01 color: color;
			}
			if (est_vegetarien) {
				draw circle(0.25) color: #cyan;
			}
			draw obj_file(my_file,init_rotation) at: location + {0,0,0.2 + mysize/2.0} size: {2,2,mysize}  rotate: heading - 90.0   ;
			
			int cpt <- 0;
			if (a_entree) {
				draw cube(0.3) at: location + {0,0,2} color: #blue ; //entree_prise.color
				cpt <- cpt + 1;
			}
			if (a_plat) {
				draw cube(0.3) at: location + {0,0,2 + cpt * 0.25} color: #cyan ; //plat_pris.color
				cpt <- cpt + 1;
			}
			if (a_dessert) {
				draw cube(0.3) at: location + {0,0,2 + cpt * 0.25} color:#white ;//dessert_pris.color
			}
		}
	}	
}

grid cell cell_width: 0.3 cell_height: 0.3 neighbors: 8 {
	bool is_wall <- false;
	bool is_free <- true;
	bool is_queue <- false;
}

//Espèce seuil 
// Evolution seuil s = nu * e(sigma*t) 
//float s
//float nu
//float sigma 
//float t temps passé pour être suceptible de changer de décision 

//LANCE 100 FOIS LA SIMULATION AVEC ET SANS INFLUENCE SOCIALE POUR VOIR SON IMPACT
//experiment exploration_impact_influence type:batch repeat: 100 until: end_simu{
	//parameter avec_influence_autres var: avec_influence_autres among: [false, true] ;
	//parameter mode_batch var: mode_batch <- true;
	//reflex resultat {
		//write "*************** " + (avec_influence_autres ? "avec" : "sans") + " influence sociale";
		//write "Score moyen: " + (simulations mean_of each.score_moyen_personne ) + " ecart type: " + standard_deviation (simulations collect each.score_moyen_personne );
		//write "Score plat moyen: " + (simulations mean_of each.score_moyen_plat ) + " ecart type: " + standard_deviation (simulations collect each.score_moyen_plat );
	//}
//}

experiment Profils_batch type:batch repeat:2 until:end_simulation{
parameter mode_batch var:mode_batch <- true;
reflex information{
map<string,list<int>> nombre_fois_pris;
ask simulations{
ask plat{
if not (Nom in nombre_fois_pris.keys){
nombre_fois_pris[Nom]<-[];
}
nombre_fois_pris[Nom] << nb_choix;
}
}
loop p over: nombre_fois_pris.keys{
write "Plat : " + p + " Moyenne : " + mean(nombre_fois_pris[p]) + " Ecart-type : " + standard_deviation(nombre_fois_pris[p]) + " données: " +  plats_choisis[p];
} //fin loop p
}
} //fin experience


experiment Ru_Saclay_debug type:gui;
experiment Ru_Saclay type:gui{
	float minimum_cycle_duration <- 0.05;
	output{
		//layout #split;
		display map type: opengl draw_env: false{
			grid cell border: #black;
			species mur refresh: false;
			species porte refresh: false;
			species queue refresh: false;
			species ilot refresh: false;
			species plat refresh: false;
			species etudiant;
		}
	
		display graphiques {
			chart "Nombre de fois choisi - entrees" type: histogram size: {1.0,1/3} { //chart c'est pour un graphique
				loop p over: entrees {
					data p.Nom value: p.nb_choix ;//color: p.color
				}
			}
			
			chart "Nombre de fois choisi - plats" type: histogram  size: {1.0,1/3} position: {0.0,1/3}{
				loop p over: plats {
					data p.Nom value: p.nb_choix ;//color: p.color
				}
			}
			
			chart "Nombre de fois choisi - desserts" type: histogram  size: {1.0,1/3} position: {0.0,2/3}{
				loop p over: desserts {
					data p.Nom value: p.nb_choix ;//color: p.color
				}
			}
		}
		
		
		monitor "Nombre etudiants pas entrés" value: nombre_etudiants;
		monitor "Nombre étudiants dans restaurant" value: 500 - nombre_etudiants - Nb_etudiants_servis; 
		monitor "Nombre etudiants installés" value: Nb_etudiants_servis; 
		monitor "Nombre points moyen" value: Nb_points_moyen_personne;
	}
}

experiment calibration type: batch until:end_simulation keep_seed: true repeat: 1{
	parameter coeff_autre_moyenne var: coeff_autre_moyenne min: 0.0 max: 1.0 step: 0.1;
    parameter coeff_autre_sociale_et var: coeff_autre_sociale_et min: 0.0 max: 1.0 step: 0.1;
    parameter coeff_amis_moyenne var: coeff_amis_moyenne min: 0.0 max: 1.0 step: 0.1;
    parameter coeff_amis_et var: coeff_amis_et min: 0.0 max: 1.0 step: 0.1;
	parameter influence_sociale_moyenne var: influence_sociale_moyenne min: 0.0 max: 1.0 step: 0.1;
	parameter influence_sociale_et var: influence_sociale_et min: 0.0 max: 1.0 step: 0.1;
	parameter influence_env_moyenne var: influence_env_moyenne min: 0.0 max: 1.0 step: 0.1;
	parameter influence_env_et var: influence_env_et min: 0.0 max: 1.0 step: 0.1;
	parameter delta_moyenne var: delta_moyenne min: 0.0 max: 1.0 step: 0.1;
	parameter delat_et var: delat_et min: 0.0 max: 1.0 step: 0.1;
	parameter choix_personnel_moyenne var: choix_personnel_moyenne min: 0.0 max: 1.0 step: 0.1;
	parameter choix_personnel_et var: choix_personnel_et min: 0.0 max: 1.0 step: 0.1;
    
    
	parameter proba_depassement1point var: proba_depassement1point min: 0.0 max: 1.0 step: 0.1;
	parameter proba_manque1point var: proba_manque1point min: 0.0 max: 1.0 step: 0.1;
	parameter proba_depassement2points var: proba_depassement2points min: 0.0 max: 1.0 step: 0.1;
	parameter force_perception_plat var: force_perception_plat min: 0.0 max: 3.0 step: 0.1;// à quel point un plat qui est à coté de moi va m'influencer
	
	parameter proba_autre_entree var: proba_autre_entree min: 0.0 max: 1.0 step: 0.1; //probabilité de prendre une autre entree ou un autre dessert
	parameter proba_autre_dessert var: proba_autre_dessert min: 0.0 max: 1.0 step: 0.1; //probabilité de prendre une autre entree ou un autre dessert
	parameter proba_encore var: proba_encore min: 0.0 max: 1.0 step: 0.1;//probabilite de prendre même entree ou même dessert 
	parameter temps_entre_groupes  var: temps_entre_groupes min: 10.0 max: 60.0 step: 1.0;
	
	parameter seuil_influence_etudiant_queue var: seuil_influence_etudiant_queue min:1 max: 10 step: 1;// à partir de combien d'étudiants dans la queue je suis influencé (négativement)
	
	parameter Charcuterie_correction var:Charcuterie_correction min: -1.0 max: 1.0 step: 0.05;
	parameter Crudites_correction var:Crudites_correction min: -1.0 max: 1.0 step: 0.05;
	parameter Entree_poisson_correction var:Entree_poisson_correction min: -1.0 max: 1.0 step: 0.05;
	parameter Salade_feculents_correction var:Salade_feculents_correction min: -1.0 max: 1.0 step: 0.05;
	parameter Viande___correction var:Viande___correction min: -1.0 max: 1.0 step: 0.05;
	parameter Pizza_correction var:Pizza_correction min: -1.0 max: 1.0 step: 0.05;
	parameter Accompagnement___correction var:Accompagnement___correction min: -1.0 max: 1.0 step: 0.05;
	parameter Accompagnement_correction var:Accompagnement_correction min: -1.0 max: 1.0 step: 0.05;
	parameter Viande_correction var:Viande_correction min: -1.0 max: 1.0 step: 0.05;
	parameter Poisson_correction var:Poisson_correction min: -1.0 max: 1.0 step: 0.05;
	parameter Vege_correction var:Vege_correction min: -1.0 max: 1.0 step: 0.05;
	parameter Fruit_correction var:Fruit_correction min: -1.0 max: 1.0 step: 0.05;
	parameter Produit_laitier_correction var:Produit_laitier_correction min: -1.0 max: 1.0 step: 0.05;
	parameter Creme_dessert_correction var:Creme_dessert_correction min: -1.0 max: 1.0 step: 0.05;
	parameter Fruits_gourmands_correction var:Fruits_gourmands_correction min: -1.0 max: 1.0 step: 0.05;
	parameter Dessert_gourmand_correction var:Dessert_gourmand_correction min: -1.0 max: 1.0 step: 0.05;
	parameter Fromage_correction var:Fromage_correction min: -1.0 max: 1.0 step: 0.05;

	//method pso num_particles: 30 weight_inertia:0.7 weight_cognitive: 1.5 weight_social: 1.5  iter_max: 10000  minimize: fitness  ;  
	method genetic pop_dim: 30 crossover_prob: 0.7 mutation_prob: 0.1 improve_sol: false stochastic_sel: false nb_prelim_gen: 5 max_gen: 10000  minimize: fitness  ;  
	init {
		mode_batch <- true;
		string parameters <-"coeff_autre_moyenne,coeff_autre_sociale_et,coeff_amis_moyenne,coeff_amis_et,influence_sociale_moyenne,influence_sociale_et,influence_env_moyenne,influence_env_et,delta_moyenne,delat_et,choix_personnel_moyenne,choix_personnel_et,proba_depassement1point,proba_manque1point,proba_depassement2points,force_perception_plat,proba_autre_entree,proba_autre_dessert,proba_encore,temps_entre_groupes,seuil_influence_etudiant_queue,Charcuterie_correction,Crudites_correction,Entree_poisson_correction,Salade_feculents_correction,Viande___correction,Pizza_correction,Accompagnement___correction,Accompagnement_correction,Viande_correction,Poisson_correction,Vege_correction,Fruit_correction,Produit_laitier_correction,Creme_dessert_correction,Fruits_gourmands_correction,Dessert_gourmand_correction,Fromage_correction";
		parameters <- parameters + ",fitness";
		save parameters type:text to:dossier_chemin + "resultats_all_simu.csv";
		gama.pref_parallel_simulations <- true;
//		gama.pref_parallel_simulations_all <- true;
		gama.pref_parallel_threads <- 24;
	}
	
}




experiment Ru_Saclay_3D type:gui{
	float minimum_cycle_duration <- 0.05;
	output{
		layout #split /* consoles: false */navigator: false editors: false parameters: false;
		display map type: opengl draw_env: false background: #black synchronized: true {
			
			species mur aspect: demo3D refresh: false;
			
			species porte aspect: demo3D refresh: false;
			graphics "sol" {
				loop c over: internal_cells {
					draw c.shape texture:"../includes/visualisation/sol.jpg";
					
				}
				
			}
			species ilot aspect: demo3D  refresh: false;
			species etudiant aspect: trace;
			species etudiant aspect: demo3D ;
			
		}
		
		display choix_plat {
			chart "Nombre de fois choisi - entrees" type: histogram size: {1.0,1/3} {
				loop p over: entrees {
					data p.Nom value: p.nb_choix ;//color: p.color
				}
			}
			
			chart "Nombre de fois choisi - plats" type: histogram  size: {1.0,1/3} position: {0.0,1/3}{
				loop p over: plats {
					data p.Nom value: p.nb_choix ;//color: p.color
				}
			}
			
			chart "Nombre de fois choisi - desserts" type: histogram  size: {1.0,1/3} position: {0.0,2/3}{
				loop p over: desserts {
					data p.Nom value: p.nb_choix  ;//color:p.color
				}
			}
		}
		
	}
}



experiment impact_facteurs_choix type: batch parent: display_results until: end_simulation repeat:1 {
	
	init {
		mode_batch <- true;
//		gama.pref_parallel_simulations_all <- false;
		gama.pref_parallel_simulations <- true;
		gama.pref_parallel_threads <- 8;
		choix_personnel_et <- 0.0;
		influence_sociale_et <- 0.0;
		influence_env_et <- 0.0; 
		
		
		choix_personnel_moyenne <- 0.0;
		influence_sociale_moyenne <- 0.0;
		influence_env_moyenne <- 1.0;
		
	}
}


experiment display_results type: batch until: end_simulation repeat:1 { 
	
	parameter choix_personnel_moyenne var: choix_personnel_moyenne min:0.0 max:1.0 step:0.5;
	parameter influence_env_moyenne var: influence_env_moyenne min:0.0 max:1.0 step:0.5;
	parameter influence_sociale_moyenne var: influence_sociale_moyenne min:0.0 max:1.0 step:0.5;
	
	//sauvegarde des résultats
	reflex check{
		write "choix_personnel_moyenne:" +choix_personnel_moyenne +  " influence_env_moyenne: "+ influence_env_moyenne+ " influence_sociale_moyenne: " + influence_sociale_moyenne+" fitness: "+fitness;
	}
	
	list<map<string,int>> resultats;
	map<string,int> donnees_reelles;
	
	
	float marge <- 5.0;
	init {
		
		mode_batch <- true;
//		gama.pref_parallel_simulations_all <- false;
		gama.pref_parallel_simulations <- true;
		gama.pref_parallel_threads <- 8;
	}
	
	
	reflex end_replication {
		ask simulations {
			myself.resultats << self.nb_tot_sim; //rempli la liste de map resultat avec la méthode| nb_tot_sim est dans le global 
			write "self.nb_tot_sim"+self.nb_tot_sim+"fitness"+fitness+"choix_personnel_moyenne"+choix_personnel_moyenne;
			myself.donnees_reelles <- self.nb_tot_obs;
			
			save "self.nb_tot_sim"+self.nb_tot_sim+"fitness"+fitness+"choix_personnel_moyenne"+choix_personnel_moyenne+  " influence_env_moyenne: "+ influence_env_moyenne+ " influence_sociale_moyenne: " + influence_sociale_moyenne to: "Mathieu_display_results.csv" type:csv rewrite: false;
			
			
		}
		do update_outputs(true);
	}

		
	
} //fin de l'expérience