---
layout: post
title:  "Elektronische Rechnung mit dem Latex Paket zugferd erstellen"
date:   2025-01-17 00:00:00 +0100
categories: latex xrechnung zugferd
---



Wie sieht eine elektronische Rechnung aus?
------------------------------------------

Durch die **europäische Norm EN 16931** wird der Rahmen für elektronische Rechnungen
in der EU vorgegeben. Da dort nur grobe Anforderungen definiert werden, muss
jeder Mitgliedsstaat eine eigene konkrete Spezifikation beschließen, die 
**Core Invoice Usage Specification (CIUS)** genannt wird.

In Deutschland heißt die CIUS **XRechnung** und diese Spezifikation ist unter
<https://xeinkauf.de/dokumente#xrechnung> frei verfügbar. Allerdings werden
durch XRechnung nur eine (Baum-)Struktur und die unbedingt erforderlichen Felder
vorgegeben, kein konkretes Dateiformat.

Gemäß EN 16931-3-1 gibt es zwei Möglichkeiten für das Dateiformat: **UBS** und 
**CII**. Beides sind XML-Formate. Die Abbildung der in EN 16931-1 bzw. XRechnung
definierten Struktur auf konkrete XML-Elemente wird in *EN 16931-3-2* bzw.
*EN 16931-3-3*. Leider sind letztere nicht kostenlos zugänglich.

XML-Dateien in einem der beiden Formate, die die Anforderungen von XRechnung
erfüllen, sind gültige elektronische Rechnungen. Allerdings sind sie für
Menschen nur schwer zu lesen. Deshalb gibt es die **ZUGFeRD** Spezifikation,
die definiert, wie man eine XML-Rechnung im CII-Format in eine menschenlesbare
PDF-Datei einbettet. Das in Frankreich verwendete **Factur-X** ist quasi
identisch zu ZUGFeRD.



Latex Paket zugferd
-------------------

Mit dem Paket [zugferd](https://ctan.org/pkg/zugferd) können ZUGFeRD-Rechnungen
mit Latex erstellt werden. Da im ZUGFeRD-Format eine XRechnung eingebettet wird,
kann damit auch eine einfache XRechnung in Form einer XML-Datei erzeugt werden.

Um eine XML-Datei in eine PDF einzubetten und das von ZUGFeRD geforderte Format
PDF/A-3 zu unterstützen, benötigt zugferd eine nach dem 13.09.2024 erstellte
Version des Latex-Pakets
[pdfmanagement-testphase](https://ctan.org/pkg/pdfmanagement-testphase).

Anfang 2025 sind beide Latex-Paket in vielen Linux- bzw. Latex-Distributionen,
wie z.B. Ubuntu 24.04 (Noble Numbat) noch nicht enthalten. Man kann Latex-Pakete
zwar nachinstallieren oder gleich TeX Live mit den neuesten Paketen manuell
installieren, beides ist aber nicht ganz einfach und automatische Updates
dadurch nicht mehr möglich. Außerdem soll die PDF-Funktionalität bald in den
Latex-Kernel integriert werden, wodurch die Abhängigkeit wegfiele.

Deshalb habe ich mich dazu entschlossen, zugferd nicht über das Paketmanagement
einzubinden, sondern die benötigten Dateien von Hand einzubinden.



zugferd mit alter Latex Version verwenden
-----------------------------------------

Anstatt die Pakete zugferd und pdfmanagement-testphase einzubinden, werden die
darin enthaltenen Dateien einfach in das Arbeitsverzeichnis kopiert. Man kann
die Dateien einer neuere Ubuntu-Version entnehmen. Die erste Ubuntu-Version,
die zugferd enthält ist eine Vorabversion von Ubuntu 25.04 (Plucky Puffin).

zugferd ist im Ubuntu-Paket
[texlive-extra](https://packages.ubuntu.com/plucky/texlive-latex-extra)
enthalten. Es besteht aus zwei Dateien:

    texlive-extra-2024.20241115/texmf-dist/tex/latex/zugferd/zugferd.sty
    texlive-extra-2024.20241115/texmf-dist/tex/latex/zugferd/zugferd-invoice.sty

pdfmanagement-testphase is im Ubuntu-Paket
[texlive-base](https://packages.ubuntu.com/plucky/texlive-base)
unter dem Pfad
`texlive-base-2024.20241115/texmf-dist/tex/latex/pdfmanagement-testphase`
zu finden. Es enthält deutlich mehr Dateien:

    color-ltx.sty
    colorspace-patches-tmp-ltx.sty
    hgeneric-testphase.def
    hyperref-colorschemes.def
    l3backend-testphase-dvipdfmx.def
    l3backend-testphase-dvips.def
    l3backend-testphase-dvisvgm.def
    l3backend-testphase.lua
    l3backend-testphase-luatex.def
    l3backend-testphase-pdftex.def
    l3backend-testphase-xetex.def
    l3pdffield-testphase.sty
    pdfmanagement-firstaid.sty
    pdfmanagement-testphase.ltx
    pdfmanagement-testphase.sty
    xcolor-patches-tmp-ltx.sty

Wenn man nur pdfTeX nutzt reichen folgende vier Dateien:

    l3backend-testphase-pdftex.def
    pdfmanagement-testphase.ltx
    pdfmanagement-testphase.sty
    zugferd.sty

Eventuell muss in zugferd.sty noch die Zeile

    \IfPackageAtLeastF{pdfmanagement-testphase}{2024/09/13}{

durch

    \IfPackageAtLeastTF{pdfmanagement-testphase}{2024/09/13}{}{

ersetzt werden.

Auf GitHub gibt es die
[gepatchten Dateien](https://github.com/bobbl/sammelsurium/tree/master/zugferd-latex).



Eigener Rechnungsstil
---------------------

Für eigene Rechnungen muss noch eine sty-Datei mit dem eigenen Rechnungsstil erstellt
werden. Man kann einfach die bei zugferd mitgelieferte Datei
[zugferd-invoice.sty](https://raw.githubusercontent.com/TeXhackse/LaTeX-ZUGFeRD/refs/heads/main/zugferd-invoice.sty)
an die eigenen Bedürfnisse anpassen. Meine
[Beispielrechnung](https://github.com/bobbl/sammelsurium/tree/master/zugferd-latex)
mit leicht angepasstem Rechnungsstil und allen zugferd-Dateien gibt es auf GitHub.



Validatoren
-----------

### XRechnung

  * [E-Rechnungs-Validator des Serviceportals Baden-Württemberg](https://erechnungsvalidator.service-bw.de/):
    sehr genaue Prüfung
  * <https://peppol.munich-enterprise.com/xrechnung/>: zuverlässiger Client-seitiger XRechnungs-Validator
  * Das GitHub-Repository der [Koordinierungsstelle für IT-Standards](https://github.com/itplr-kosit)
    enthält Offline-Validatoren

### ZUGFeRD

  * <https://erechnungs-validator.de/>: ZUGFeRD-Validator
  * <https://www.portinvoice.com/>: Prüfung mit mehreren Validatoren, bis zu 10 Rechnungen am Tag
  * Nach Registrierung können über die [ZUGFeRD-Community](https://www.zugferd-community.net/)
    beliebig viele Rechnungen bei portinvoice.com geprüft werden
  * Links zu weiteren Validatoren: <https://easyfirma.net/e-rechnung/zugferd/validatoren>



Open-Source-Projekte
--------------------

  * [Mustang](https://github.com/ZUGFeRD/mustangproject/): Java Bibliothek und Server
  * [OpenXRechnungToolbox](https://jcthiele.github.io/OpenXRechnungToolbox/):
    Java Applikation zur Offline-Prüfung von XRechnungen
  * [Offizielle Validierungsdateien](https://github.com/ConnectingEurope/eInvoicing-EN16931)
