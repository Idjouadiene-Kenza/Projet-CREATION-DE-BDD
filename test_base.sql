/* -----------------------------------------------------------------------
BASE de DONNEES : système de réservation de billets de Ferry
NOM : IDJOUADIENE
PRENOM : KENZA
NUMERO ETUDIANT : 21810504
NUMERO DU GROUPE : GR4
------------------------------------------------------------------------- */

/* -------------Test du trigger "NumTelEgalADixChiffres"---------------------- */

INSERT INTO PASSENGER (AdresseCourriel,NumTel,Prenom,Nom,DateNaissance,Adresse) VALUES  ('SabrinaLichag@teleworm.us','066143','Sabrina','Lichag','05/01/1990','34, Av Division-Leclerc, 94230 Cachan');
UPDATE PASSENGER SET NumTel = '88927' WHERE AdresseCourriel = 'SyliaClinique@einrot.com';

/* -------------------Test du trigger "DateHeureDifferentes"--------------------*/

INSERT INTO PATH VALUES (530930,78544,'MN', 320,TO_DATE('2024-01-02 12:00','YYYY/MM/DD HH24:MI'),TO_DATE('2023-01-02 12:00','YYYY/MM/DD HH24:MI'));

UPDATE PATH SET DateHeureDepart = TO_DATE('2021-12-05 09:15','YYYY/MM/DD HH24:MI') WHERE NumTrajet = 715257 AND IdPort = 27345 AND CodeCompagnie = 'BF';
UPDATE PATH SET DateHeureArrivee = TO_DATE('2021-12-05 09:15','YYYY/MM/DD HH24:MI') WHERE NumTrajet = 715257 AND IdPort = 27345 AND CodeCompagnie = 'BF';


/* -------------------Test de la fonction "nb_reservation"--------------------*/

SELECT nb_reservation('reserve') FROM DUAL;
SELECT nb_reservation('supprime') FROM DUAL;
