/**
* Name: changesizedata
* remet à l'échelle les données
* Author: Patrick Taillandier
* Tags: 
*/

model changesizedata

global {
	// taille réelle
	float size_x <- 19.48; //15.3;//
	float size_y <-  8.81; //10.96;//
	
	//dossier des données à reprojeter
	string folder_path <- "../includes/ENS/ENS 28 octobre V2/includes/Shapefiles/";	


	string folder_path_plats <- "../includes/ENS/ENS 28 octobre V2/includes/Shapefiles/";	
	
	shape_file murs_shape_file <- shape_file(folder_path + "murs.shp", 2154);
	
	
	string ENTREE <- "entree";
	string PLAT <- "plat";
	string DESSERT <- "dessert";
	string CAISSE <- "caisse";
	string PLATEAU <- "plateau";
	map<string,rgb> couleur_type <- [ENTREE::#green, PLAT::#orange, DESSERT:: #red,CAISSE::#gray, PLATEAU::#blue]; //Couleur des ilots 
	geometry shape <- envelope(murs_shape_file);
	
	init {
		shape_file ilots_shape_file <- shape_file(folder_path+ "ilots.shp",2154);
		shape_file plats_shape_file <- shape_file(folder_path_plats + "plats.shp",2154);
		shape_file portes_shape_file <- shape_file(folder_path + "portes.shp",2154);
		shape_file queues_shape_file <- shape_file(folder_path + "queues.shp",2154);

		create mur from: murs_shape_file;
		
		create ilot from: ilots_shape_file;
		create porte from: portes_shape_file;
		create queue from: queues_shape_file;
		create plat from: plats_shape_file ;// with: [Categorie::get("Catégorie")];
		
		float ratio_x <- size_x / world.shape.width;
		float ratio_y <- size_y / world.shape.height;
		
		ask mur {
			shape <- polygon(shape.points collect {each.x * ratio_x, each.y * ratio_y});
		}
		folder_path<- folder_path_plats + "generated/" ;
		save mur type: shp to: folder_path + "murs.shp";
		ask ilot {
			shape <- polygon(shape.points collect {each.x * ratio_x, each.y * ratio_y});
		}
		
		save ilot type: shp to: folder_path + "ilots.shp" attributes: ["Nom", "Type"];
		ask porte {
			shape <- polygon(shape.points collect {each.x * ratio_x, each.y * ratio_y});
		}
		
		save porte type: shp to: folder_path + "portes.shp" attributes: ["Nom"];
		ask queue {
			shape <- line(shape.points collect {each.x * ratio_x, each.y * ratio_y});
		}
		
		save queue type: shp to: folder_path + "queues.shp";
		ask plat {
			location <- {location.x * ratio_x, location.y * ratio_y};
		}
		
		save plat type: shp to: folder_path + "plats.shp" attributes: ["Nom", "Vege", "Nb_points", "age_f","genre_f","imc_f","intercept", "CO_imcsex", "Categorie"];
	}
}

species plat {
	int Vege;
	int Nb_points;
	string type;
	int nb_choix;
	int Influences <- 1;
	string Nom;
	float age_f;
	float genre_f;
	float imc_f; 
	float intercept;
	float CO_imcsex; 
	string Categorie;
	
	aspect default {
		draw hexagon(0.4) color:#blue border: #black;
	}
}

species queue {
	aspect default {
		draw shape color: #red;
	}
}

species porte {
	string Nom;
	aspect default {
		draw square(0.5) color: #blue;
	}
}

//Species which represent the wall
species mur {
	aspect default {
		draw shape color: #black ; //ici juste la trace des murs du shapefile 
	}
}
species ilot {
	string Nom;
	string Type;
	aspect default {
		draw shape color: couleur_type[Type];
	}
}
experiment changesizedata type: gui {
	output {
		display map {
			species mur;
			species queue;
			species porte;
			species ilot;
			species plat;
		}
	}
}
