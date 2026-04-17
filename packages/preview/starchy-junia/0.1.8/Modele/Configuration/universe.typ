// === Imports des paquets / libraries ===
// Ici on mets les paquets que l'on veut utiliser dans le document : https://typst.app/universe

// Moteur de dessin bas-niveau (inspiré de TikZ)
#import "@preview/cetz:0.4.2" 

// Dessin de diagrammes (nœuds et arêtes), surcouche de cetz
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node // Dessin de diagrammes (nœuds et arêtes), surcouche de cetz
#import fletcher.shapes: ellipse, pill, house, parallelogram, diamond, triangle, chevron, hexagon, octagon, cylinder, brace

// Circuit électrique
#import "@preview/zap:0.5.0" 

// Glossaire
#import "@preview/glossarium:0.5.10": make-glossary, register-glossary, print-glossary, gls, glspl 

// Outils pour la relecture et les marques de brouillon
#import "@preview/drafting:0.2.2": * // Outils pour la relecture et les marques de brouillon

// Récupération des titres de la page actuelle
#import "@preview/hydra:0.6.2": hydra 

// Pour le code et la programmation
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *

// Placement plus fin des figures
#import "@preview/meander:0.4.1"

// Pour faire des Tableau de GANTT
#import "@preview/timeliney:0.4.0"

// Visualisation de données
#import "@preview/lilaq:0.6.0" as lq

// Figure en Echart
#import "@preview/echarm:0.3.1"
