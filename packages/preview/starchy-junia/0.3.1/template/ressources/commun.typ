// =============================================================================
// COMMUN — modèle, paquets et fonctions personnalisées
// =============================================================================
// Ce fichier est importé dans `squelette.typ` et dans chaque fiche de `fiches/` :
// tout ce qui est défini ou importé ici y est disponible.
// Ajouter ici les paquets, fonctions et figures utilisés dans plusieurs fiches.
// Autres paquets disponibles : https://typst.app/universe
// =============================================================================

// Modèle starchy-junia — seul endroit où figure sa version, à modifier lors d'une mise à jour
#import "@preview/starchy-junia:0.3.1": *

// Moteur de dessin bas-niveau, inspiré de TikZ en LaTeX
#import "@preview/cetz:0.5.2"

// Dessin de diagrammes (noeuds et arêtes), surcouche de CeTZ
// Formes des noeuds : `fletcher.shapes.ellipse`, `fletcher.shapes.diamond`…
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

// Schémas de circuits électroniques, surcouche de CeTZ
#import "@preview/zap:0.6.0"

// Diagrammes de Gantt
#import "@preview/timeliney:0.4.0"

// Visualisation de données
#import "@preview/lilaq:0.6.0" as lq

// Diagrammes interactifs de type Echart
#import "@preview/echarm:0.4.0"

// =============================================================================
// FONCTIONS ET FIGURES PERSONNALISÉES
// =============================================================================
// Ex : #let schema-principal = figure(rect(), caption: [Schéma principal])
