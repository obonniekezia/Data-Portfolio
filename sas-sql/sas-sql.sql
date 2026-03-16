*Projet SAS OWONO Bonnie;

*Analyse globale;

*1;
PROC IMPORT DATAFILE='/home/u62824766/Projet SAS M1/chantiers.xlsx' 
	DBMS=XLSX
	OUT=chantier;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=chantier; RUN;




*3;
proc sql;
create table chantiers as
select distinct *
from chantier;
quit;


*4;
proc sort data=chantier out = chantier_sorted ;
by duree;
run;

*5; 
proc sql;
create table CHANTIERS_PAR_VILLE as
select duree, numero, voie, commune, pole, declarant, entreprise,
datedebut, datefin, libelle, circulation,
count(*) as nombre_chantiers
from chantier
group by commune;
quit;


proc sort data = CHANTIERS_PAR_VILLE out = CHANTIERS_PAR_VILLE_TRI;
by descending nombre_chantiers;
run;


*Exercice 2: Travailler avec des dates et fusinner; 

data chantiers ;
set chantier;
format datedebut date9. datefin date9.;
run;

proc sql;
select min(datedebut) as min_date format = date9., 
max(datedebut) as max_date format = date9.
from chantiers ;
quit;

proc sql;
select *, month(datedebut) as mois_debut,
month(datefin) as mois_fin 
from chantiers;
quit;

proc sql;
create table CHANTIERS_PAR_VILLE_JUIL_DEC24 as
select count(*) as chant_juil
from chantiers 
where datedebut > '01JUL2024'd and datefin < '31DEC2024'd
group by commune;
quit; 

proc sql;
create table join_chantier as
select *
from CHANTIERS_PAR_VILLE_JUIL_DEC24 as en_juil inner join CHANTIERS_PAR_VILLE as par_ville
on en_juil.commune = par_ville.commune;
quit;


*Exercice 3: Localisation Géographique;

data GEO_LOC;
set chantiers;
keep numero commune datedebut datefin duree pole;
label datedebut = "date_debut" datefin="date_fin" numero = "id_chantier";
run;
proc contents data=GEO_LOC;
run;

proc sql;
create table GEO_LOC as
select *,
case 
when pole in ("Nord", "Est") then "Nord-Est"
when pole in ("Sud", "Ouest") then "Sud-Ouest"
when pole = "Centre" then "Centre"
else "Vide"
end as localisation_geo
from GEO_LOC;
quit;

proc sql;
create table GEO_LOC_COUNT as 
select localisation_geo, count(*) as nb_chantiers
from GEO_LOC
group by localisation_geo;
quit;

proc sql;
create table GEO_LOC_MIN_MAX as
select localisation_geo, min(duree) as duree_min, max(duree) as duree_max
from GEO_LOC
group by localisation_geo;
quit;

proc sql;
create table FUSION_GEO_LOCATION as 
select *
from GEO_LOC_MIN_MAX as min_max inner join GEO_LOC_COUNT as count
on min_max.localisation_geo = count.localisation_geo;
quit;


*Exercice 4: Création d'un rapport;

*Var quati;

proc means data= chantiers;
var duree;
run; 

proc freq data=chantiers;
    tables pole commune entreprise declarant / nocum ;
run;

proc freq data=chantiers ;
    tables circulation*commune / nocum ;
run;
 










