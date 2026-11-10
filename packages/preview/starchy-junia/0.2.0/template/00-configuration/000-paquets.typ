// Imports des paquets / libraries, 
// Ici on met les paquets que l'on veut utiliser dans le document
// On les trouve à cette addresse : https://typst.app/universe

// Gestion de la documentation interne du modèle, uniquement pour générer la documentation
#import "@preview/tidy:0.4.3"

// Moteur de dessin bas-niveau, inspiré de TikZ en LaTeX
#import "@preview/cetz:0.5.0"

// Dessin de diagrammes (noeuds et arêtes), surcouche de CeTZ
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#import fletcher.shapes: ellipse, pill, house, parallelogram, diamond, triangle, chevron, hexagon, octagon, cylinder, brace

// Schémas de circuits électroniques, surcouche de CeTZ
#import "@preview/zap:0.5.0"

// Glossaire
#import "@preview/glossarium:0.5.10": make-glossary, register-glossary, print-glossary, gls, glspl

// Outils pour la relecture et les marques de brouillon
#import "@preview/drafting:0.2.2": *

// Récupération des titres de la page actuelle
#import "@preview/hydra:0.6.2": hydra

// Pour le code et la programmation
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.10": *

// Placement plus fin des figures — importé, non utilisé par défaut, à activer si besoin
// #import "@preview/meander:0.4.2"

// Pour faire des Tableaux de Gantt
#import "@preview/timeliney:0.4.0"

// Visualisation de données
#import "@preview/lilaq:0.6.0" as lq

// Diagrammes interactifs de type Echart
#import "@preview/echarm:0.3.1"
