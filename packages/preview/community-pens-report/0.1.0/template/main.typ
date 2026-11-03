#import "@preview/community-pens-report:0.1.0": *

// =============================================================
//  PENS Final Project (Proyek Akhir) report
//  Fill in your own data in the `thesis.with(...)` call below.
//  Everything after that call is the body of your report.
// =============================================================

#show: thesis.with(
  // ---- Title & document identity ----
  title: [
    SMART MASSAGE MACHINE: \
    IMPLEMENTATION OF A BODY CONTOUR \
    AND AREA IDENTIFICATION SYSTEM USING \
    SENSOR FUSION
  ],
  document-title: "Smart Massage Machine: Implementation of a Body Contour and Area Identification System Using Sensor Fusion",
  document-type: "Proyek Akhir",
  degree: "Gelar Sarjana Terapan (S.Tr.T.)",
  year: "2026",
  city: "Surabaya",
  date: "16 Juli 2026",

  // ---- Author ----
  author: "Azzam Abidurrahman Mujahid",
  student-id-label: "NRP.",
  student-id: "4122600021",

  // ---- Institution ----
  study-program: [Program Studi Sarjana Terapan \ Teknik Mekatronika],
  department: "Jurusan Teknik Mekanika dan Energi",
  institution: "Politeknik Elektronika Negeri Surabaya",
  coordinator-role: "Koordinator Program Studi Sarjana Terapan Teknik Mekatronika",
  coordinator: (name: "Novian Fajar Satria, S.ST., M.T.", id: "NIP. 199011292019031015"),

  // ---- Advisors & examiners ----
  advisors: (
    (name: "Dr. Eny Kusumawati, S.Pd., M.Pd.", id: "NIP. 197307192008122001"),
    (name: "Eko Budi Utomo, S.ST., M.T.", id: "NIP. 199005202019031014"),
    (name: "Mohamad Nasyir Tamara, S.ST., M.T.", id: "NIP. 198508072015041003"),
  ),
  examiners: (
    (name: "Examiner 1, S.T., M.T.", id: "NIP. 000000000000000000"),
    (name: "Examiner 2, S.T., M.T.", id: "NIP. 000000000000000000"),
  ),

  // ---- Abstracts ----
  abstract-en: [
    Write the English abstract here. It should summarise the problem,
    the method, the main results, and the conclusion of the final project.
  ],
  abstract-en-keywords: "Smart Massage Machine, Sensor Fusion, 3D Scanning, Point Cloud, Massage Trajectory",
  abstract-id: [
    Tulis abstrak bahasa Indonesia di sini, berisi ringkasan masalah,
    metode, hasil utama, dan kesimpulan proyek akhir.
  ],
  abstract-id-keywords: "Smart Massage Machine, Sensor Fusion, Pemindaian 3D, Point Cloud, Lintasan Pijat",

  // ---- Foreword & acknowledgement (optional) ----
  foreword: [
    Write your foreword here. Thank God and everyone who helped you
    complete this final project.

    #v(4em)

    #align(right, block(width: 45%)[
      #set par(first-line-indent: 0pt, justify: false)
      Surabaya, 16 July 2026

      #v(3.5em)

      *Azzam Abidurrahman Mujahid*
    ])
  ],
  acknowledgement: [
    Write your acknowledgement here, thanking your family, advisors,
    and everyone who supported you.
  ],

  // ---- End matter (optional) ----
  supplementary: [
    #heading(level: 1, numbering: none, outlined: true)[SUPPLEMENTARY MATERIAL]

    *Attachment 1. Source Code*

    #link("https://github.com/azzamjhd/scanner-system", "Github Repository")

    *Attachment 2. Journal*
  ],
  author-bio: [
    #heading(level: 1, numbering: none, outlined: true)[Author Biography]

    #table(
      columns: 3,
      stroke: none,
      align: (left, left),
      inset: 4pt,
      [Name], [:], [Azzam Abidurrahman Mujahid],
      [Birthdate], [:], [Lumajang, January 2, 2004],
      [Email], [:], [azzamujahid214\@gmail.com],
    )
  ],
)

// =============================================================
//  BODY — everything below is the body of your report.
//  Put your chapter files here (uncomment as you add them).
// =============================================================
#include "chapters/01_introduction.typ"
// #include "chapters/02_literature_review.typ"
// #include "chapters/03_methodology.typ"
// #include "chapters/04_experiments.typ"
// #include "chapters/05_closing.typ"

// =============================================================
//  REFERENCES — keep at the very end. The .bib file lives in the
//  same folder as main.typ.
// =============================================================
#heading(level: 1, numbering: none, outlined: true)[REFERENCES]
#bibliography("references.bib", title: none, style: "ieee")
