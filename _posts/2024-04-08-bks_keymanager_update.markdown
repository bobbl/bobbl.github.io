---
layout: post
title:  "BKS KeyManager Update von Version 4.x auf 7.x"
date:   2024-04-09 00:00:00 +0200
categories: update
---

Schließberechtigungen für die elektrische Schließanlage BKS ixalo SE werden
mit Hilfe des [BKS KeyManagers](https://www.g-u.com/de/DE/produkte/tuertechnik/schliessanlagen/elektronische-schliesssysteme.html)
verwaltet. Bei der Installation unserer Schließanlage wurde Version 4.4.0007 (06/2017)
des KeyManagers mitgeliefert. Das Update auf die aktuelle Version 7.4 ist nicht
ganz trivial, deshalb hier eine kurze Anleitung.


Zwischenupdate auf Version 4.4.0015
--------------------------------------

Zuerst muss die alte Version des BKS KeyManagers auf Version 4.4.0015 gebracht
werden. Das ist einfach:

   * Das Update von <https://www.g-u.com/fileadmin/user_upload/Key_Manager/KM_4.4.0015.zip>
     herunterladen
   * ZIP-Datei entpacken
   * Installation mit `setup.exe` starten

Nach Abschluss der Installation kann der KeyManager wie gewohnt gestartet
werden. Die Passwörter sind unverändert und alle Daten der Schließanlage
werden automatisch übernommen.


Datensicherung durchführen
--------------------------

Mit dieser Version kann eine Datensicherung durchgeführt werden, die dann von
Version 7.x importiert werden kann:

  * KeyManager starten und Passwort angeben
  * Menüpunkt `Datei > Datensicherung durchführen...` auswählen
  * Speicherort für die Datensicherung auswählen, z.B. `Dokumente > bks44sicherung.fbk`
  * KeyManager beenden


Update auf Version 7.4.0000 (02/2024)
----------------------------------------

  * Auf der [BKS KeyManager Homepage der GU-Gruppe](https://www.g-u.com/de/DE/service/service-mit-system/service-fuer-hersteller-und-bauausfuehrende/keymanager.html)
    das **Update** auf die neueste Version des KeyManagers herunterladen. Bei mir war das
    <https://www.g-u.com/fileadmin/user_upload/Key_Manager/UPD_KM_7.4.0000_x64.exe>.
   * ZIP-Datei entpacken
   * Installation mit `setup.exe` starten

Bei diesem Update werden allerdings die Daten der Schließanlage nicht
automatisch übernommen. Dafür ist noch ein weiterer Schritt nötig:


Datensicherung einspielen
-------------------------

Weder Schließanlagendaten noch Passwörter werden durch das Update übernommen.
Deshalb muss zunächst das voreingestellte Passwort verwendet werden:

  * KeyManger (x64) starten
  * Benutzer `BKS` und Passwort `Admin` angeben
  * Das Programm behauptet zwar, jetzt die Datenbank zu importieren und verlangt
    auch noch ein zweites Mal das Passwort, das passiert aber nicht.
  * Stattdessen öffnet sich ein Fenster worin gefragt wird, ob eine neue
    Datenbank angelegt werden soll. Dieses Fenster schließen.
  * Menüpunkt `Datei > DatenRÜCKsicherung durchführen...` anklicken
  * Die zuvor gemachte Datensicherungsdatei auswählen, bei mir 
    `Dokumente > bks44sicherung.fbk`
  * Jetzt wird ein Passwort verlangt. Der Benutzer ist wieder `BKS`, diesmal
    muss jedoch das alte Passwort von der alten Installation verwendet werden.
    Auch wieder zweimal.
  
Damit ist das Update abgeschlossen, alle Daten wurden importiert  und der
KeyManager kann wie gewohnt verwendet werden.

