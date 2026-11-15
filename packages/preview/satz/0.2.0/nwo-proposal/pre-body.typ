#import "components.typ": nwo-text, nwo-key-output
// Shared 2026 pre-proposal starter. Short example responses are not a submission.
// Replace all placeholders; use nwo-text for final plain-text word checks.
#context {
  let p = state("satz-nwo-profile").get()
  [
    = NWO domain and field of research
    #if p.domain == "zonmw" [
      This information is entered in Mijn ZonMw, section “Project information”.
    ] else [
      == NWO domain
      #p.domain-name

      == Main field of research
      [Enter the official research-field name and code.]
    ]

    = Evidence-based curriculum vitae
    == Academic profile
    #if p.scheme == "veni" [
      [Replace with a 400–700 word evidence-based academic profile.]
    ] else [
      === General academic profile
      [Describe your research agenda, relevant qualities and achievements.]

      === Leadership and mentorship
      [Explain your approach, evidence and development plans.]
    ]
    // For final plain text:
    // #nwo-text("academic-profile", "Your complete narrative...")

    == Key output
    #nwo-text("research-culture", "In this example field, outputs include protocols, software and research articles. Their value is assessed through methodological quality, reproducibility and evidence of reuse.")

    #nwo-key-output(
      reference: [A. Example (2024). A reproducible measurement protocol. Example Research.],
      output-type: [Research article],
      contribution: [Describe your own contribution and explain why this output demonstrates qualities relevant to the research idea. Replace this illustrative entry with a real output.],
      indicators: ([Describe one relevant quality indicator with evidence.],),
    )
    // Across all key outputs: follow the form's 700-word aggregate limit and
    // exclusions; Veni also requires at least 400 narrative words.

    = Research idea
    #if p.scheme == "veni" and p.domain == "zonmw" [
      Enter this section in Mijn ZonMw, section “Project information”.
    ] else [
    *Title:* Reliable measurements across laboratories

    *Key words:* measurement, reproducibility, calibration

    #nwo-text("research-idea", "Measurement protocols often differ across laboratories, making results difficult to compare. This project will develop and validate a shared calibration protocol. Independent recordings will test whether the protocol distinguishes genuine changes from instrument variation. The outputs will include a documented procedure, an openly available analysis implementation and an evaluation of the conditions under which the method succeeds or fails.")

    ]

    = Administrative details
    #[
      == Personal details
      Title(s), initial(s), surname(s): [Enter details; omit first names.]

      == Doctorate
      #table(
        columns: (auto, 1fr),
        [University / college], [Enter institution],
        [Date of PhD award], [dd-mm-yyyy],
        [Supervisor(s)], [Enter names],
        [Thesis title], [Enter title],
      )

      == Prospective host institution
      Host institution: [Enter institution]

      Research group: [Enter group / department]

      == Work experience since completing your (first) PhD
      List appointments chronologically, with the current appointment last.

      #table(
        columns: (1fr, 1fr, auto, auto, 1fr),
        table.header([*Post / contract*], [*Period*], [*FTE*], [*Research FTE*], [*Institution*]),
        [Enter post], [Start–end], [0.0], [0.0], [Enter institution],
      )
      Special circumstances, if applicable: [Explain within 100 words.]

      #if p.scheme == "vici" [
        == Net academic research time
        [Complete the calculations and explanation required by the Vici form.]
      ]
    ]

    #heading(numbering: none, bookmarked: false)[Applicant statements]
    Extension clause: [Yes / No; confirmation date if applicable.]

    [Read and complete the official scientific-integrity, animal-research,
    biosecurity, current-contact and double-funding declarations.]

    Initial(s) and surname(s): [Enter details]

    Place and date: [Enter details]
  ]
}
