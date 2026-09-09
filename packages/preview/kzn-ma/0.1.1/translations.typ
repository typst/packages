/*
 * ==========================================================
 * Project: Typst Academic Thesis Template (KZN)
 * File: translations.typ
 * Description:
 *   A comprehensive Typst template for academic theses and
 *   dissertations. Provides functions for title pages, headers,
 *   footers, table of contents, list of figures/tables, figure
 *   and table formatting with subfigures, and full document
 *   layout management. Supports multilingual documents (DE/EN/FR)
 *   with customizable fonts, spacing, and numbering schemes.
 *
 * Authors: Christian Prim and Lukas Zuberbühler
 * License: MIT License
 * ==========================================================
 *
 * Copyright (c) 2026 Christian Prim and Lukas Zuberbühler
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#let title = (
  de: "Schreiben einer Maturarbeit",
  en: "Writing a Maturity Thesis",
  fr: "Rédaction d'un travail de maturité",
  it: "Scrivere una tesi di maturità",
  es: "Escribir un trabajo de madurez",
)

#let subtitle = (
  de: "Mit dem Textsatzsystem Typst",
  en: "Using the Typst Typesetting System",
  fr: "Avec le système de composition Typst",
  it: "Con il sistema di composizione Typst",
  es: "Con el sistema de composición Typst",
)

#let thesis-type-beginners-guide = (
  de: "Eine Anleitung für Einsteiger",
  en: "A Guide for Beginners",
  fr: "Un guide pour débutants",
  it: "Una guida per principianti",
  es: "Una guía para principiantes",
)

#let thesis-type-ma = (
  de: "Maturarbeit",
  en: "Maturity Thesis",
  fr: "Travail de maturité",
  it: "Lavoro di maturità",
  es: "Trabajo de madurez",
)

#let thesis-type-sa = (
  de: "Selbständige Arbeit",
  en: "Independent Research Paper",
  fr: "Travail indépendant",
  it: "Lavoro indipendente",
  es: "Trabajo independiente",
)

#let thesis-type-fmp = (
  de: "Fachmaturitätsarbeit",
  en: "Fachmaturität Thesis",
  fr: "Travail de maturité spécialisée",
  it: "Lavoro di maturità specializzata",
  es: "Trabajo de madurez especializada",
)

#let abstract-title = (
  de: "Abstract",
  en: "Abstract",
  fr: "Résumé",
  it: "Abstract",
  es: "Resumen",
)

#let preface-title = (
  de: "Vorwort",
  en: "Preface",
  fr: "Préface",
  it: "Prefazione",
  es: "Prefacio",
)

#let ai-declaration-title = (
  de: "Erklärung zur Nutzung von KI",
  en: "AI Usage Declaration",
  fr: "Déclaration d'utilisation de l'IA",
  it: "Dichiarazione sull'uso dell'IA",
  es: "Declaración de uso de IA",
)

#let acknowledgments-title = (
  de: "Danksagung",
  en: "Acknowledgments",
  fr: "Remerciements",
  it: "Ringraziamenti",
  es: "Agradecimientos",
)

#let toc-title = (
  de: "Inhaltsverzeichnis",
  en: "Table of Contents",
  fr: "Table des matières",
  it: "Indice",
  es: "Índice",
)

#let lof-title = (
  de: "Abbildungsverzeichnis",
  en: "List of Figures",
  fr: "Liste des figures",
  it: "Elenco delle figure",
  es: "Lista de figuras",
)

#let lot-title = (
  de: "Tabellenverzeichnis",
  en: "List of Tables",
  fr: "Liste des tableaux",
  it: "Elenco delle tabelle",
  es: "Lista de tablas",
)

#let biblio-title = (
  de: "Literatur",
  en: "References",
  fr: "Bibliographie",
  it: "Bibliografia",
  es: "Bibliografía",
)

#let appendix-title = (
  de: "Anhang",
  en: "Appendix",
  fr: "Annexe",
  it: "Appendice",
  es: "Apéndice",
)

#let written-by = (
  de: "Verfasst von",
  en: "Written by",
  fr: "Écrit par",
  it: "Scritto da",
  es: "Escrito por",
)

#let supervised-by = (
  de: "Betreut durch",
  en: "Supervised by",
  fr: "Sous la direction de",
  it: "Supervisionato da",
  es: "Supervisado por",
)

#let submitted-on = (
  de: "Abgegeben am",
  en: "Submitted on",
  fr: "Soumis le",
  it: "Presentato il",
  es: "Presentado el",
)

#let heading-desc = (
  de: "Kap.",
  en: "Chapter",
  fr: "Chap.",
  it: "Cap.",
  es: "Cap.",
)

#let fig-desc = (
  de: "Abb.",
  en: "Fig.",
  fr: "Fig.",
  it: "Fig.",
  es: "Fig.",
)

#let tab-desc = (
  de: "Tab.",
  en: "Tab.",
  fr: "Tab.",
  it: "Tab.",
  es: "Tab.",
)

#let appendix-desc = (
  de: "Anh.",
  en: "App.",
  fr: "Ann.",
  it: "All.",
  es: "Anex.",
)

#let cover-image = (
  de: "Abbildung auf der Titelseite von",
  en: "Cover image from",
  fr: "Illustration en page de titre de",
  it: "Immagine sulla pagina del titolo di",
  es: "Imagen en la portada de",
)

#let anonymous-version = (
  de: "anonymisierte Version",
  en: "anonymised version",
  fr: "version anonymisée",
  it: "versione anonimizzata",
  es: "versión anonimizada",
)

#let and-str = (
  de: " und ",
  en: " and ",
  fr: " et ",
  it: " e ",
  es: " y ",
)
