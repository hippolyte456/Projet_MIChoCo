/**
* Name: Generationparams
* Based on the internal skeleton template. 
* Author: admin_ptaillandie
* Tags: 
*/

model Generationparams

global {
	string dossier_chemin <- "../includes/ENS/ENS 28 octobre V2/includes/Shapefiles/generated/";
	list<string> categories <- ['Charcuterie','Crudités','Entrée poisson','Salade féculents','Viande +','Pizza','Accompagnement +','Accompagnement','Viande','Poisson','Vege','Fruit','Produit laitier','Crème dessert','Fruits gourmands','Dessert gourmand','Fromage'];
	
	//["riche", "neutre", "pauvre"];
	init {
		list<string> categories2 <- categories collect (each replace("é","e") replace("è","e") replace(" ","_") replace("+","_"));
		list<string> plats;
		
		string val <- "";
		string val2 <- "";
		loop p over: categories2 {
			write "float " + p + "_correction <- 0.0;";
			val <- val + p + "_correction,";
			val2 <- val2 + p + "_correction+\",\"+";
		}
		
		write "map<string, float> correction_groupe;";
		loop p over: categories2 {
			write "parameter " + p + "_correction var:"+ p +"_correction min: -0.5 max: 0.5 step: 0.05;";
			
		}
		
		loop i from: 0 to: length(categories) -1 {
			string cat <- categories[i];
			string catRev <- categories2[i];
			write "correction_groupe[ \"" +cat+ "\" ] <-" + catRev + "_correction";
		}
		write val;
		
		write val2;
		
		
	}
	
}


experiment Generationparams type: gui ;