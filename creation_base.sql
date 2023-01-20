/* -----------------------------------------------------------------------
BASE de DONNEES : système de réservation de billets de Ferry
NOM : IDJOUADIENE
PRENOM : KENZA
NUMERO ETUDIANT : 21810504
NUMERO DU GROUPE : GR4
------------------------------------------------------------------------- */

/*--------------------------------------------Création des tables---------------------------------------*/

prompt "Création de table"

CREATE TABLE PASSENGER(
   AdresseCourriel VARCHAR(40) NOT NULL,
   NumTel VARCHAR(10),
   Prenom VARCHAR(15) NOT NULL,
   Nom VARCHAR(15)NOT NULL,
   DateNaissance DATE,
   Adresse VARCHAR(50),
   CONSTRAINT PK_AdresseCourriel PRIMARY KEY (AdresseCourriel)
);

CREATE TABLE IDENTITY(
   NIdentite VARCHAR(20) NOT NULL,
   AdresseCourriel VARCHAR(40) NOT NULL,
   Nationalite VARCHAR(20) NOT NULL,
   CONSTRAINT PK_NIdentite PRIMARY KEY(NIdentite),
   CONSTRAINT FK_IdentiteAdresseCourriel FOREIGN KEY(AdresseCourriel) REFERENCES PASSENGER(AdresseCourriel)
);

CREATE TABLE RESERVATION(
   NumReservation INT NOT NULL,
   AdresseCourriel VARCHAR(40) NOT NULL,
   DateReservation DATE,
   Classe VARCHAR(20),
   PrixTotal DECIMAL,
   Statut VARCHAR(10) CHECK (Statut IN ('reserve','supprime')),
   CONSTRAINT PK_NumReservation PRIMARY KEY (NumReservation),
   CONSTRAINT FK_ReservationIdentiteAdresseCourriel FOREIGN KEY(AdresseCourriel) REFERENCES PASSENGER(AdresseCourriel)
);

CREATE TABLE LOCATION(
   IdEmplacement INT NOT NULL,
   NumReservation INT NOT NULL,
   TypeEmplacement VARCHAR(20) CHECK (TypeEmplacement IN('Fauteuil','Cabine Standard','Cabine Intérieure','Cabine Extérieure','Cabine Luxe')),
   PrixEmplacement DECIMAL,
   CONSTRAINT PK_IdEmplacement PRIMARY KEY (IdEmplacement),
   CONSTRAINT FK_ENumReservation FOREIGN KEY(NumReservation) REFERENCES RESERVATION(NumReservation)
);

CREATE TABLE CAR(
   NumImmatriculation VARCHAR(20) NOT NULL,
   NumReservation INT NOT NULL,
   Marque VARCHAR (20),
   LongueurVoiture FLOAT,
   HauteurVoiture FLOAT, 
   CONSTRAINT PK_NumImmatriculation PRIMARY KEY (NumImmatriculation),
   CONSTRAINT FK_VoitureNumReservation FOREIGN KEY(NumReservation) REFERENCES RESERVATION(NumReservation)
);

CREATE TABLE HARBOUR(
   IdPort INT NOT NULL,
   NomPort VARCHAR(20),
   Ville VARCHAR(20),
   Pays VARCHAR(20),
   CONSTRAINT PK_IdPort PRIMARY KEY (IdPort)
);

CREATE TABLE COMPANY(
   CodeCompagnie VARCHAR(20) NOT NULL,
   NomCompagnie VARCHAR(30),
   CONSTRAINT PK_CodeCompagnie PRIMARY KEY (CodeCompagnie)
);

CREATE TABLE PATH(
   NumTrajet INT NOT NULL,
   IdPort INT NOT NULL,
   CodeCompagnie VARCHAR(20) NOT NULL,
   CapaciteSieges INT,
   DateHeureDepart TIMESTAMP,
   DateHeureArrivee TIMESTAMP,
   CONSTRAINT PK_NumTrajet PRIMARY KEY (NumTrajet),
   CONSTRAINT FK_TrajetIdPort FOREIGN KEY(IdPort) REFERENCES HARBOUR(IdPort),
   CONSTRAINT FK_TrajetCodeCompagnie FOREIGN KEY(CodeCompagnie) REFERENCES COMPANY(CodeCompagnie)
);

CREATE TABLE CONCERN(
   NumTrajet INT NOT NULL,
   NumReservation INT NOT NULL,
   CONSTRAINT PK_IDCONCERN PRIMARY KEY (NumTrajet, NumReservation), 
   CONSTRAINT FK_CRNumReservation FOREIGN KEY(NumReservation) REFERENCES RESERVATION(NumReservation),
   CONSTRAINT FK_CRTrajet FOREIGN KEY(NumTrajet) REFERENCES PATH(NumTrajet)
);


CREATE TABLE SERVE(
   IdPort INT NOT NULL,
   CodeCompagnie VARCHAR(20) NOT NULL,
   CONSTRAINT PK_IDSERVE PRIMARY KEY (IdPort, CodeCompagnie), 
   CONSTRAINT FK_SIDPORT FOREIGN KEY(IdPort) REFERENCES HARBOUR(IdPort),
   CONSTRAINT FK_SCODECOMPAGNIE FOREIGN KEY(CodeCompagnie) REFERENCES COMPANY(CodeCompagnie)
);

/*--------------------------------------------Triggers--------------------------------------------------------------------*/

/* Le numéro de téléphone -> doit impérativement avoir 10 chiffres */

  CREATE OR REPLACE TRIGGER NumTelEgalADixChiffres
  BEFORE INSERT OR UPDATE ON PASSENGER
  FOR EACH ROW
  DECLARE 
  MESSAGE EXCEPTION;
  BEGIN
    IF (LENGTH(:NEW.NumTel)<10)
    THEN RAISE MESSAGE;
    END IF;
  EXCEPTION
  WHEN MESSAGE THEN
  RAISE_APPLICATION_ERROR(-20324,'Numéro de téléphone non valide, veuillez saisir un nouveau numéro de téléphone à dix chiffres ! ');
  END;
  /

/* Le trajet -> La Date et Heure du départ doivent être différentes de la Date et Heure d'arrivée */

  CREATE OR REPLACE TRIGGER DateHeureDifferentes
    BEFORE INSERT OR UPDATE ON PATH
    FOR EACH ROW
    DECLARE
      MESSAGE EXCEPTION;
    BEGIN
      IF(:NEW.DateHeureDepart = :NEW.DateHeureArrivee OR :OLD.DateHeureDepart = :NEW.DateHeureArrivee OR :NEW.DateHeureDepart = :OLD.DateHeureArrivee)
        THEN RAISE MESSAGE;
      END IF;
    EXCEPTION
      WHEN MESSAGE THEN 
          RAISE_APPLICATION_ERROR(-20325,'Attention ! La date et lheure du départ doivent être différentes de la date et lheure darrivée');
      END;
      /


/*--------------------------------------------Fonction--------------------------------------------------------------------*/


/* Fonction qui retourne le nombre de réservations effectuées selon leurs status*/

CREATE OR REPLACE FUNCTION nb_reservation(stat IN RESERVATION.Statut%type)
  RETURN NUMBER
  IS Somme NUMBER;
BEGIN
  SELECT COUNT(NumReservation) INTO Somme FROM RESERVATION WHERE Statut=stat;
  RETURN Somme;
END;
/

/*-----------------------------------Remplissage de la table PASSENGER--------------------------------------------------------*/

prompt "Insertion des tuples PASSENGER"

--INSERT INTO PASSENGER VALUES (AdresseCourriel,NumTel,Prenom,Nom,DateNaissance,Adresse);

INSERT INTO PASSENGER VALUES ('MargotCharrier@fleckens.hu','0476850894', 'Margot', 'Charrier','27-04-1987','09, Place de la gare, 38000 Isère');
INSERT INTO PASSENGER VALUES ('ThibaultMaury@armyspy.com','0142803932', 'Thibault', 'Maury','16-07-1999','60, Rue Saint-Georges, 75009 Paris');
INSERT INTO PASSENGER VALUES ('AlainRamos@superrito.com','0142779053', 'Alain', 'Ramos','13-01-1992','06, Rue des Tournelles, 75004 Paris');
INSERT INTO PASSENGER VALUES ('FranckLefevre@teleworm.us','0139333164', 'Franck', 'Lefevre','24-05-1984', '11, Rue du Champ Gallois, 95200 Sarcelles');
INSERT INTO PASSENGER VALUES ('PatriciaDuRoy@jourrapide.com','0156083388', 'Patricia', 'Du Roy','04-04-1971','106, Rue Brancion, 75015 Paris');
INSERT INTO PASSENGER VALUES ('JulienDijouxMendes@cuvox.de','0491338140', 'Julien', 'Dijoux-Mendes','03-04-2000','44, Quai Marcel Pagnol, 13007 Marseille');
INSERT INTO PASSENGER VALUES ('GabrielDelorme@rhyta.com','0146472430', 'Gabriel', 'Delorme','30-03-1994','1, Rue de Boulainvilliers, 75016 Paris');
INSERT INTO PASSENGER VALUES ('MartineWagner@gustr.com','0495267568', 'Martine', 'Wagner','12-06-1994','04, Rue San Lazaro, 20000 Ajaccio');
INSERT INTO PASSENGER VALUES ('BernadetteNoelCollet@einrot.com','0534406717', 'Bernadette', 'Noel-Collet','29-03-1970','03, Rue Delacroix, 31000, Toulouse');
INSERT INTO PASSENGER VALUES ('DenisGregoire@jourrapide.com','0380431956', 'Denis', 'Gregoire','05-07-1999','58, RUE Monge, 21000 Dijon');
INSERT INTO PASSENGER VALUES ('PhilippeBouvet@armyspy.com','0478374454', 'Philippe', 'Bouvet','24-01-1930','04, Rue de la Charite, 69002 Lyon');
INSERT INTO PASSENGER VALUES ('SusanCollin@einrot.com','0380492993', 'Susan', 'Collin','10-11-1976','ZAC du Parc Valmy, 21000 Dijon');
INSERT INTO PASSENGER VALUES ('ThophileCharpentier@rhyta.com','0467002558', 'Tophile', 'Charpentier','28-12-1976','50, Rue des Bernadins, 75005 Paris');
INSERT INTO PASSENGER VALUES ('SabineDaniel@jourrapide.com','0144413181', 'Sabine', 'Daniel','18-05-1979','36,Rue Eugene Masse, 93190 Livry-Gargan');
INSERT INTO PASSENGER VALUES ('WilliamAubert@teleworm.us','0426009357', 'William', 'Aubert','10-06-1994','112, Rue Bugeaud, 69006 Lyon');
INSERT INTO PASSENGER VALUES ('SyliaClinique@einrot.com','0142396494', 'Sylia', 'Clinique','06-07-1975','60, Rue Rene Boulanger, 75010 Paris');
INSERT INTO PASSENGER VALUES ('MarcelPeltier@dayrep.com','0473372992', 'Marcel', 'Peltier','06-03-1986','48, Rue Fontgieve, 63000 Clemont-Ferrand');
INSERT INTO PASSENGER VALUES ('SabineSpecter@teleworm.us','0294421161', 'Sabine', 'Specter','28-02-1999','15,Impasse des Capucines, 34000 Montpellier');


/*---------------------------------------Remplissage de la table IDENTITY------------------------------------------*/

prompt "Insertion des tuples IDENTITY"

--INSERT INTO IDENTITY VALUES (NIdentite,AdresseCourriel,Nationalite);

INSERT INTO IDENTITY VALUES ('12FR12345','MargotCharrier@fleckens.hu','FR');
INSERT INTO IDENTITY VALUES ('13FR13345','ThibaultMaury@armyspy.com','FR');
INSERT INTO IDENTITY VALUES ('14FR14345','AlainRamos@superrito.com','FR');
INSERT INTO IDENTITY VALUES ('15FR15345','FranckLefevre@teleworm.us','FR');
INSERT INTO IDENTITY VALUES ('17FR17345','PatriciaDuRoy@jourrapide.com','FR');
INSERT INTO IDENTITY VALUES ('18FR18345','JulienDijouxMendes@cuvox.de','FR');
INSERT INTO IDENTITY VALUES ('19FR19345','GabrielDelorme@rhyta.com','FR');
INSERT INTO IDENTITY VALUES ('21FR12445','MartineWagner@gustr.com','FR');
INSERT INTO IDENTITY VALUES ('22FR12545','BernadetteNoelCollet@einrot.com','FR');
INSERT INTO IDENTITY VALUES ('23FR12645','DenisGregoire@jourrapide.com','FR');
INSERT INTO IDENTITY VALUES ('23FR12745','PhilippeBouvet@armyspy.com','FR');
INSERT INTO IDENTITY VALUES ('23FR12845','SusanCollin@einrot.com','FR');
INSERT INTO IDENTITY VALUES ('23FR12945','ThophileCharpentier@rhyta.com','FR');
INSERT INTO IDENTITY VALUES ('23FR12355','SabineDaniel@jourrapide.com','FR');
INSERT INTO IDENTITY VALUES ('23FR12665','WilliamAubert@teleworm.us','FR');
INSERT INTO IDENTITY VALUES ('23FR12675','SyliaClinique@einrot.com','FR');
INSERT INTO IDENTITY VALUES ('23FR12685','MarcelPeltier@dayrep.com','FR');
INSERT INTO IDENTITY VALUES ('23FR12695','SabineSpecter@teleworm.us','FR');


/*-----------------------------------Remplissage de la table RESERVATION----------------------------------*/

prompt "Insertion des tuples RESERVATION

--INSERT INTO RESERVATION VALUES (NumReservation,AdresseCourriel,DateReservation,Classe,PrixTotal,Statut);

INSERT INTO RESERVATION VALUES (1,'MargotCharrier@fleckens.hu','30-09-2021', 'Premiere Classe', '1300','supprime');
INSERT INTO RESERVATION VALUES (2,'ThibaultMaury@armyspy.com', '02-12-2022', 'Classe Economique', '650' ,'reserve');
INSERT INTO RESERVATION VALUES (3,'AlainRamos@superrito.com','09-11-2021', 'Classe Economique', '180' ,'supprime');
INSERT INTO RESERVATION VALUES (4,'FranckLefevre@teleworm.us','15-06-2020', 'Premiere Classe', '2200','supprime');
INSERT INTO RESERVATION VALUES (5,'PatriciaDuRoy@jourrapide.com' ,'21-11-2021', 'Premiere Classe', '2900','reserve');
INSERT INTO RESERVATION VALUES (6,'JulienDijouxMendes@cuvox.de', '18-02-2021', 'Premiere Classe'  , '3100','reserve');
INSERT INTO RESERVATION VALUES (7,'GabrielDelorme@rhyta.com', '08-01-2021', 'Premiere Classe', '2600','reserve');
INSERT INTO RESERVATION VALUES (8,'MartineWagner@gustr.com', '25-05-2021', 'Premiere Classe', '2100','reserve');
INSERT INTO RESERVATION VALUES (9,'BernadetteNoelCollet@einrot.com', '21-04-2020', 'Premiere Classe', '380' ,'supprime');
INSERT INTO RESERVATION VALUES (10,'DenisGregoire@jourrapide.com', '26-09-2019', 'Classe Economique', '420' ,'reserve');
INSERT INTO RESERVATION VALUES (11,'PhilippeBouvet@armyspy.com','17-07-2022', 'Classe Economique', '360' ,'supprime');
INSERT INTO RESERVATION VALUES (12,'SusanCollin@einrot.com', '05-01-2020', 'Classe Economique', '2800','supprime');
INSERT INTO RESERVATION VALUES (13,'ThophileCharpentier@rhyta.com', '17-04-2021', 'Classe Economique', '2750','reserve');
INSERT INTO RESERVATION VALUES (14,'SabineDaniel@jourrapide.com', '16-03-2022', 'Classe Economique', '330' ,'supprime');
INSERT INTO RESERVATION VALUES (15,'WilliamAubert@teleworm.us', '31-07-2020', 'Premiere Classe', '475' ,'reserve');
INSERT INTO RESERVATION VALUES (16,'SyliaClinique@einrot.com', '13-12-2021', 'Premiere Classe', '2400','reserve');
INSERT INTO RESERVATION VALUES (17, 'MarcelPeltier@dayrep.com', '03-11-2021', 'Classe Economique', '290' ,'reserve');
INSERT INTO RESERVATION VALUES (18,'PhilippeBouvet@armyspy.com','11-06-2018', 'Premiere Classe', '730' ,'supprime');
INSERT INTO RESERVATION VALUES (19,'SyliaClinique@einrot.com', '02-02-2019', 'Classe Economique', '400','supprime');
INSERT INTO RESERVATION VALUES (20,'PhilippeBouvet@armyspy.com','08-01-2020', 'Premiere Classe', '1630' ,'supprime');


/*-----------------------------------Remplissage de la table HARBOUR----------------------------------------*/

prompt "Insertion des tuples HARBOUR"

--INSERT INTO HARBOUR VALUES (IdPort,NomPort,Ville,Pays);

INSERT INTO HARBOUR VALUES (21053, 'Port de Southampton','Southampton','Royaume-Uni');
INSERT INTO HARBOUR VALUES (78544, 'Port de Marseille','Marseille','France');
INSERT INTO HARBOUR VALUES (27345, 'Port de Saint-Malo','Saint-Malo','France');
INSERT INTO HARBOUR VALUES (82500, 'Port de Bari','Bari','Italie');
INSERT INTO HARBOUR VALUES (37347, 'Port de Oslo','Oslo','Norvège');
INSERT INTO HARBOUR VALUES (23877, 'Port de kiel','Kiel','Allemagne');
INSERT INTO HARBOUR VALUES (12926, 'Port de Tanger Med','Tanger','Maroc');
INSERT INTO HARBOUR VALUES (80852, 'Port de Havre','Havre','France');
INSERT INTO HARBOUR VALUES (24358, 'Port de Durrës','Durrës','Albanie');
INSERT INTO HARBOUR VALUES (62390, 'Port de Copenhague','Copenhague','Danemark');
INSERT INTO HARBOUR VALUES (65802, 'Port de Barcelone','Barcelone','Espagne');
INSERT INTO HARBOUR VALUES (18774, 'Port de Corfou','Corfou','Grèce');
INSERT INTO HARBOUR VALUES (94358, 'Port de Ajaccio','Ajaccio','France');


/*-------------------------------------Remplissage de la table LOCATION-----------------------------------*/

prompt "Insertion des tuples LOCATION"

--INSERT INTO LOCATION VALUES (IEmplacement,NumReservation,TypeEmplacement,PrixEmplacement);

INSERT INTO LOCATION VALUES (100,2,'Fauteuil','18');
INSERT INTO LOCATION VALUES (102, 6,'Cabine Standard', '56');
INSERT INTO LOCATION VALUES (103,7,'Cabine Intérieure', '130');
INSERT INTO LOCATION VALUES (104,8,'Cabine Extérieure', '180');
INSERT INTO LOCATION VALUES (105,10,'Cabine Luxe', '220');
INSERT INTO LOCATION VALUES (106,15,'Fauteuil', '18');
INSERT INTO LOCATION VALUES (107,16,'Cabine Intérieure', '130');
INSERT INTO LOCATION VALUES (108,17,'Cabine Extérieure', '180');
INSERT INTO LOCATION VALUES (109,3,'Cabine Standard', '56');
INSERT INTO LOCATION VALUES (110,4,'Fauteuil', '18');
INSERT INTO LOCATION VALUES (111,9,'Fauteuil', '18');


/*-------------------------------------Remplissage de la table CAR---------------------------------------------*/

prompt "Insertion des tuples CAR"

--INSERT INTO CAR VALUES (NumImmatriculation,NumReservation,Marque,LongueurVoiture, HauteurVoiture);

INSERT INTO CAR VALUES ('AA-228-AB',17,'Audi A1','3,97','1,42');
INSERT INTO CAR VALUES ('BA-143-CA',9,'BMW M5','4,97','1,47');
INSERT INTO CAR VALUES ('AB-654-AF',5,'Ford B-MAX','4,08','1,59');
INSERT INTO CAR VALUES ('AC-323-BC',4,'Citroen berlingo','4,75','1,80');
INSERT INTO CAR VALUES ('CB-444-FA',10,'Dacia Logan MCV','4,51','1,54');
INSERT INTO CAR VALUES ('BB-934-AG',16,'Toyota Yaris','3,95','1,51');
INSERT INTO CAR VALUES ('AZ-134-ZZ',5,'Fiat 500','3,54','1,48');
INSERT INTO CAR VALUES ('AR-295-AD',13,'Renault Clio','4,27','1,45');
INSERT INTO CAR VALUES ('CR-938-RA',2,'Volkswagen Arteon','4,86','1,45');
INSERT INTO CAR VALUES ('SR-763-HZ',7,'Mercedes-benz','4,42','1,42');


/*--------------------------------------Remplissage de la table COMPANY---------------------------------*/

prompt "Insertion des tuples COMPANY"

--INSERT INTO COMPANY VALUES (CodeCompagnie,NomCompagnie);

INSERT INTO COMPANY VALUES ('MN','La Meridionale');
INSERT INTO COMPANY VALUES ('LD','LD Lines');
INSERT INTO COMPANY VALUES ('DFDS','DFDS Seaways');
INSERT INTO COMPANY VALUES ('CL', 'Color Line');
INSERT INTO COMPANY VALUES ('BF','Brittany Ferries');
INSERT INTO COMPANY VALUES ('GNV','Grandi Navi Veloci');
INSERT INTO COMPANY VALUES ('VF', 'Ventouris Ferries');
INSERT INTO COMPANY VALUES ('CF', 'Corsica Ferries');



/*-----------------------------------------Remplissage de la table PATH---------------------------------------------------------*/

prompt "Insertion des tuples PATH"

--INSERT INTO PATH VALUES (NumTrajet,IdPort,CodeCompagnie,CapaciteSieges,DateHeureDepart,DateHeureArrivee);

INSERT INTO PATH VALUES (570937,78544,'MN', 500,TO_DATE('2023-01-02 12:00','YYYY/MM/DD HH24:MI'),TO_DATE('2023-01-05 07:00','YYYY/MM/DD HH24:MI'));
INSERT INTO PATH VALUES (715257,27345,'BF', 1940,TO_DATE('2022-12-05 09:15','YYYY/MM/DD HH24:MI'),TO_DATE('2022-12-05 18:20','YYYY/MM/DD HH24:MI'));
INSERT INTO PATH VALUES (668447,82500,'LD', 2400,TO_DATE('2023-02-16 22:00','YYYY/MM/DD HH24:MI'),TO_DATE('2022-02-17 08:00','YYYY/MM/DD HH24:MI'));
INSERT INTO PATH VALUES (673289,37347,'DFDS', 600,TO_DATE('2023-02-28 15:00','YYYY/MM/DD HH24:MI'),TO_DATE('2022-03-01 10:00','YYYY/MM/DD HH24:MI'));
INSERT INTO PATH VALUES (190328,23877,'CL', 1054,TO_DATE('2023-03-09 14:00','YYYY/MM/DD HH24:MI'),TO_DATE('2022-03-10 10:00','YYYY/MM/DD HH24:MI'));
INSERT INTO PATH VALUES (331288,12926,'GNV', 940,TO_DATE('2023-07-15 18:30','YYYY/MM/DD HH24:MI'),TO_DATE('2022-07-17 03:00','YYYY/MM/DD HH24:MI'));
INSERT INTO PATH VALUES (610035,80852,'BF', 1940,TO_DATE('2022-12-30 14:00','YYYY/MM/DD HH24:MI'),TO_DATE('2022-12-30 19:15','YYYY/MM/DD HH24:MI'));
INSERT INTO PATH VALUES (496535,82500,'VF', 1120,TO_DATE('2022-08-11 20:00','YYYY/MM/DD HH24:MI'),TO_DATE('2022-08-12 07:00','YYYY/MM/DD HH24:MI'));
INSERT INTO PATH VALUES (694112,94358,'CF', 500,TO_DATE('2023-09-08 19:00','YYYY/MM/DD HH24:MI'),TO_DATE('2022-09-09 10:30','YYYY/MM/DD HH24:MI'));
INSERT INTO PATH VALUES (794453,12926,'MN', 500,TO_DATE('2023-03-05 17:00','YYYY/MM/DD HH24:MI'),TO_DATE('2023-03-07 11:00','YYYY/MM/DD HH24:MI'));
INSERT INTO PATH VALUES (468390,21053,'BF', 1940,TO_DATE('2021-12-24 10:00','YYYY/MM/DD HH24:MI'),TO_DATE('2022-12-24 19:30','YYYY/MM/DD HH24:MI'));
INSERT INTO PATH VALUES (605907,94358,'LD', 2400,TO_DATE('2022-05-09 20:10','YYYY/MM/DD HH24:MI'),TO_DATE('2022-05-10 06:10','YYYY/MM/DD HH24:MI'));
INSERT INTO PATH VALUES (462012,62390,'DFDS', 600,TO_DATE('2020-08-20 10:30','YYYY/MM/DD HH24:MI'),TO_DATE('2022-08-21 05:30','YYYY/MM/DD HH24:MI'));
INSERT INTO PATH VALUES (732776,37347,'CL',1054,TO_DATE('2019-10-03 16:00','YYYY/MM/DD HH24:MI'),TO_DATE('2019-10-04 12:00','YYYY/MM/DD HH24:MI'));
INSERT INTO PATH VALUES (706232,65802,'GNV', 940,TO_DATE('2020-09-13 09:30','YYYY/MM/DD HH24:MI'),TO_DATE('2020-09-13 18:00','YYYY/MM/DD HH24:MI'));
INSERT INTO PATH VALUES (210272,21053,'BF', 1940,TO_DATE('2021-06-18 10:00','YYYY/MM/DD HH24:MI'),TO_DATE('2021-06-18 15:30','YYYY/MM/DD HH24:MI'));
INSERT INTO PATH VALUES (503183,18774,'VF', 1120,TO_DATE('2020-11-16 22:00','YYYY/MM/DD HH24:MI'),TO_DATE('2022-11-16 09:00','YYYY/MM/DD HH24:MI'));


/*---------------------------------------Remplissage de la table CONCERN------------------------------------------*/

prompt "Insertion des tuples CONCERN"

--INSERT INTO CONCERN VALUES (NumTrajet,NumReservation);

INSERT INTO CONCERN VALUES (570937, 2);
INSERT INTO CONCERN VALUES (715257, 5);
INSERT INTO CONCERN VALUES (668447, 6);
INSERT INTO CONCERN VALUES (673289, 7);
INSERT INTO CONCERN VALUES (190328, 8);
INSERT INTO CONCERN VALUES (331288, 10);
INSERT INTO CONCERN VALUES (610035, 13);
INSERT INTO CONCERN VALUES (496535, 15);
INSERT INTO CONCERN VALUES (694112, 16);
INSERT INTO CONCERN VALUES (794453, 17);
INSERT INTO CONCERN VALUES (468390, 1);
INSERT INTO CONCERN VALUES (605907, 3);
INSERT INTO CONCERN VALUES (462012, 4);
INSERT INTO CONCERN VALUES (732776, 9);
INSERT INTO CONCERN VALUES (706232, 11);
INSERT INTO CONCERN VALUES (210272, 12);
INSERT INTO CONCERN VALUES (503183, 14);


/*-------------------------------------Remplissage de la table SERVE-------------------------------------*/

prompt "Insertion des tuples SERVE"

--INSERT INTO SERVE VALUES (IdPort,CodeCompagnie);
INSERT INTO SERVE VALUES (78544,'MN');
INSERT INTO SERVE VALUES (12926, 'MN');
INSERT INTO SERVE VALUES (27345,'BF');
INSERT INTO SERVE VALUES (21053, 'BF');
INSERT INTO SERVE VALUES (82500,'LD');
INSERT INTO SERVE VALUES (94358, 'LD');
INSERT INTO SERVE VALUES (37347,'DFDS');
INSERT INTO SERVE VALUES (62390, 'DFDS');
INSERT INTO SERVE VALUES (23877,'CL');
INSERT INTO SERVE VALUES (37347, 'CL');
INSERT INTO SERVE VALUES (12926,'GNV');
INSERT INTO SERVE VALUES (65802, 'GNV');
INSERT INTO SERVE VALUES (80852,'BF');
INSERT INTO SERVE VALUES (82500, 'VF');
INSERT INTO SERVE VALUES (18774, 'VF');
INSERT INTO SERVE VALUES (94358, 'CF');


/*--------------------------------------------Requêtes--------------------------------------------------------------------*/

/*------------------------Requêtes avec GROUP BY ------------------------*/
 
/*
1. Donner le nombre de reservations effectuées par chaque voyageur (Nom et Prenom) par ordre décroissant.
*/

prompt "Donner le nombre de reservations effectuées par chaque voyageur (Nom et Prenom) par ordre décroissant"

SELECT Nom, Prenom, COUNT(*) AS Nombre_Reservations FROM PASSENGER P
JOIN RESERVATION ON P.AdresseCourriel = RESERVATION.AdresseCourriel
GROUP BY P.AdresseCourriel, Nom, Prenom
ORDER BY Nombre_Reservations DESC;


/*
2. Quelles sont les compagnies ayant effectuées le plus de trajets ?
*/

prompt "Quelles sont les compagnies ayant effectuées le plus de trajets"

SELECT C.CodeCompagnie, NomCompagnie, COUNT(*) FROM COMPANY C,PATH
WHERE (C.CodeCompagnie=PATH.CodeCompagnie)
GROUP BY C.CodeCompagnie,NomCompagnie
HAVING COUNT (*) >= ALL(SELECT COUNT (*) FROM PATH GROUP BY PATH.CodeCompagnie);

/*------------------------Requête avec DIVISION ------------------------*/

/*
Quels sont les voyageurs pour lequeles toutes les réservations sont confirmées ?
*/

prompt "Quels sont les voyageurs pour lequeles toutes les réservations sont confirmées"

SELECT P1.AdresseCourriel, P1.Nom, P1.Prenom, COUNT(*) AS NbResConfirmes FROM PASSENGER P1
WHERE NOT EXISTS
            (SELECT R.AdresseCourriel FROM RESERVATION R
            WHERE Statut = 'reserve'
            AND P1.AdresseCourriel=R.AdresseCourriel
            AND NOT EXISTS(
              SELECT * FROM PASSENGER P2
                WHERE P2.AdresseCourriel = P1.AdresseCourriel
                AND P2.Nom = P1.Nom
                AND P2.Prenom = P1.Prenom
                AND (P1.AdresseCourriel <> P2.AdresseCourriel)
            ))
            GROUP BY P1.AdresseCourriel, P1.Nom, P1.Prenom
            ORDER BY AdresseCourriel; 


/*------------------------ Requête avec une sous requête ------------------------*/

/* Existe t'il des homonymes (AdresseCourriel, Prenom) parmi les Voyageurs ? */
prompt "Existe til des homonymes (AdresseCourriel, Prenom) parmi les Voyageurs"


/*------------------------ AVEC PARTITION ------------------------*/

prompt "avec partition"

SELECT AdresseCourriel,Prenom FROM PASSENGER
WHERE Prenom IN (SELECT Prenom FROM PASSENGER GROUP BY Prenom HAVING COUNT (*)>1)
ORDER BY Prenom;

/*--------------------Avec une sous requête corrélée --------------*/

prompt "Avec une sous requête corrélée"

SELECT P1.AdresseCourriel, P1.Prenom FROM PASSENGER P1
WHERE EXISTS
(SELECT * FROM PASSENGER P2 WHERE (P1.AdresseCourriel<>P2.AdresseCourriel) AND (P1.Prenom = P2.Prenom))
ORDER BY Prenom;

/*










