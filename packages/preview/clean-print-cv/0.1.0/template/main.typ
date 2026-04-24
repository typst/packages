// =============================================================================
// clean-print-cv — Entry Point
// Compile:  typst compile main.typ
// Watch:    typst watch main.typ
// =============================================================================

#import "@preview/clean-print-cv:0.1.0": *

// Load CV data from YAML
#let data = yaml("cv-data.yaml")

// Apply page setup
#show: cv-page-setup

// -- Header ------------------------------------------------------------------
#cv-header(data.personal)

// -- Professional Summary ----------------------------------------------------
#cv-summary(data.summary)

// -- Professional Experience -------------------------------------------------
// (Before skills: for senior roles, what you DID matters more than tool lists)
#cv-experience(data.experience)

// -- Technical Skills --------------------------------------------------------
// (After experience: acts as an ATS keyword bank, supports the narrative above)
#cv-skills(data.skills)

// -- Key Projects ------------------------------------------------------------
#cv-projects(data.projects)

// -- Certifications ----------------------------------------------------------
#cv-certifications(data.certifications)

// -- Education ---------------------------------------------------------------
#cv-education(data.education)

// -- Languages ---------------------------------------------------------------
#cv-languages(data.languages)
