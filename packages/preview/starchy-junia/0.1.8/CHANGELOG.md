# Suivi des versions / Version history

---

## Français

Version 1 :
Ajouté :
  - Gestion de la page de garde paramétrable
  - Gestion des métadonnées du document
  - Gestion des bibliothèques utilisateurs
  - Définition du format du document et de la langue

Version 2 : 
Ajouté :
  - Ajout de la police "Latin Modern"
  - Gestion du pied de page et du haut de page
  - Style centralisé

Version 3 :
Ajouté :
  - Ajout de la bibliothèque "glossarium"
  - Gestion des citations bibliographiques et appels lexique automatisé
    - Mise en couleur automatique selon une fonction 

Version 4 : 
Ajouté :
  - Gestion du mode "ébauche"
    - Modification des tailles de marges 
    - Variable pour l'activation
  - Gestion des tailles de titres selon les niveaux (1-6)
    
Version 5 : 
Ajouté :
  - Modèle renommé
  - Ajout de commentaires pour expliquer les fonctions et le fonctionnement du modèle 
  - Réécriture de certaines fonctions trop compliquées pour l'utilisation
    - Utilisation de "hydra" pour le haut de page et les titres
  - Gestion paramétrée des tailles de titres en une seule fonction
  - Numérotation par chapitres des figures dans le corps du document
  - Ajout de paramètres dans le modèle pour les filigranes brouillon et confidentiel
Retiré : 
  - Mode ébauche :
    - Modification des tailles de marges en mode ébauche
    - Variables en dehors du modèle

Version 6 :
Ajouté :
  - Modification de la gestion des annexes
    - Ajout d'une fonction de basculement
    - Mise en couleur des citations vers les annexes (violet)
    - Style centralisé des annexes
  - Ajout d'un paramètre pour la numérotation des équations mathématiques
  - Ajout de "l'article" `Chap.` avant la citation d'un chapitre dans le document.

Version 7 :
Ajouté :
  - Ajout de la gestion de langue
    - Traduction de certaines parties "fixe" en français et en anglais
  - Ajout du paramètre `formation` pour plus de modularité sur la page de garde
  - Gestion dynamique des sommaires selon leurs positions dans le document
    - Affichage dans le sommaire principal 
    - Numérotation des titres
  - Gestion de l'affichage des titres dans les fonctions de "basculement"

Retiré :
  - Variable `entrees_glossaire` relative au lexique dans le modèle
    - Import direct depuis E_Lexique.typ

Version 8 :
Ajouté :
  - Gestion de la taille des notes de bas de page (9pt)
  - Légende des tableaux positionnée au-dessus (conformité charte)
  - Refactorisation en fonctions "maison" pour les sections du pré-sommaire
    et post-sommaire (lexique, sommaires, bibliographie)
  - Affichage de tous les titres dans les signets PDF
    - Pré-sommaire : bookmarked activé explicitement
    - Annexes : bookmarked désactivé
  - Nouvelle gestion du sommaire des annexes par position dans le document
    - Ciblage via .after(<end_of_main_doc>) — suppression du label <annexe> manuel
  - Centralisation du délimitateur FR/EN dans liste_trad_auto
  - Centralisation du mois dans liste_trad_auto (suppression de la double variable)
  - Correction du code postal de l'adresse JUNIA (59104 → 59014)
  - Fonction pour l'affichage de plusieurs pages d'un PDF
  
Retiré :
  - Appels directs aux fonctions Typst dans main.typ pour les sections
    (sommaire, lexique, listes, bibliographie) → remplacés par #show: f_*
  - Fonction f_trad_auto() → accès direct à liste_trad_auto
  - Double gestion de la date selon la langue (mois_annee == auto avec lang_doc)
    → unifié dans liste_trad_auto via la clé mois_date

---

## English

Version 1:
Added:
  - Parameterized cover page management
  - Document metadata management
  - User library management
  - Document format and language definition

Version 2:
Added:
  - Added "Latin Modern" font
  - Header and footer management
  - Centralised style

Version 3:
Added:
  - Added "glossarium" library
  - Bibliographic citation and automated glossary entry management
    - Automatic colour-coding via a function

Version 4:
Added:
  - Draft mode management
    - Margin size adjustment
    - Activation variable
  - Heading size management per level (1–6)

Version 5:
Added:
  - Template renamed
  - Comments added to explain functions and template behaviour
  - Rewriting of overly complex functions for easier use
    - Use of "hydra" for headers and section titles
  - Parameterised heading size management in a single function
  - Chapter-numbered figure captions in the document body
  - Draft and confidential watermark parameters added to the template
Removed:
  - Draft mode:
    - Margin size adjustment in draft mode
    - Variables defined outside the template

Version 6:
Added:
  - Modified appendix management
    - Addition of a switch function
    - Colour-coded appendix citations (purple)
    - Centralised appendix style
  - New parameter for mathematical equation numbering
  - Addition of the "Chap." article before chapter citations in the document

Version 7:
Added:
  - Language management
    - Translation of certain "fixed" parts into French and English
  - Addition of the `formation` parameter for more modularity on the cover page
  - Dynamic table of contents management based on position in the document
    - Display in the main table of contents
    - Heading numbering
  - Dynamic heading display in switch functions
Removed:
  - `entrees_glossaire` variable related to the glossary in the template
    - Direct import from E_Lexique.typ

Version 8:
Added:
  - Footnote size management (9pt)
  - Table captions positioned above (charter compliance)
  - Refactoring into custom functions for pre-TOC and post-TOC sections
    (glossary, TOCs, bibliography)
  - All headings displayed in PDF bookmarks
    - Pre-TOC: bookmarked enabled explicitly
    - Appendices: bookmarked disabled
  - New appendix TOC management by position in the document
    - Targeting via .after(<end_of_main_doc>) — removal of the manual <annexe> label
  - Centralisation of the FR/EN delimiter in liste_trad_auto
  - Centralisation of the month in liste_trad_auto (removal of the double variable)
  - Correction of JUNIA postal code (59104 → 59014)
  - Function for displaying multiple pages of a PDF
Removed:
  - Direct calls to Typst functions in main.typ for sections
    (TOC, glossary, lists, bibliography) → replaced by #show: f_*
  - Function f_trad_auto() → direct access to liste_trad_auto
  - Dual date management per language (mois_annee == auto with lang_doc)
    → unified in liste_trad_auto via the mois_date key
