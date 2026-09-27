#import "@preview/satz:0.1.1": journal-entry, journal-index

// ===== Research Diary Index =====
// Placed first so the index appears before the journal entries.
#journal-index()

// ===== Entry 1 — Lab Meeting =====
#journal-entry(
  title: "Lab Meeting — Pipeline Planning",
  date: "Monday, 03/03/2026",
  keywords: "methods, pipeline, planning",
)[
  == Attending
  Jane Doe, John Smith, Alice B. Example

  == Agenda
  + Review of the updated preprocessing pipeline
  + Discussion of artefact rejection strategy
  + Planning for analysis parameters

  == Discussion
  Jane presented an updated version of the preprocessing pipeline. #lorem(15)

  We discussed trade-offs between different artefact rejection strategies:
  - *Method A.* Simple and fast, but limited coverage
  - *Method B.* #lorem(20)
  - *Method C.* Fully automated, but less transparent

  The group agreed on a hybrid approach combining automated classification with manual review.

  === Analysis Parameters
  We settled on the following parameters:

  - Regularisation: 5 %
  - Grid spacing: 5 mm
  - Covariance window: entire trial duration
  - Forward model: single-shell

  Jane noted that the single-shell model is preferred for its stability.

  == Action Items
  - [x] Share the updated script with the group
  - [ ] Implement the artefact rejection step
  - [ ] Test full pipeline on the pilot dataset
  - [ ] Schedule follow-up meeting
]

// ===== Entry 2 — Results Review =====
#journal-entry(
  title: "Individual Work — Interim Results",
  date: "Friday, 07/03/2026",
  keywords: "results, figures, analysis",
)[
  Ran the analysis overnight. The initial results look promising, with clear differences between conditions in the target regions.

  == Preliminary Observations
  + *Band A:* Stronger effects in the primary condition, particularly in frontal--parietal connections. #lorem(15)
  + *Band B:* #lorem(28)
  + *Band C:* No consistent condition differences observed.

  Generated a first-pass figure and submitted it for feedback.

  == Model Setup
  Began setting up the model. The model space will include:

  1. A null model (no differences between conditions)
  2. A target-region model (differential connectivity in key areas)
  3. A whole-brain model (all connections free to vary)
  4. A local-only model (no long-range connectivity in one condition)

  Bayesian model selection will be used to compare the families.

  == To Do
  - [x] Run analysis on final cleaned dataset
  - [x] Generate first-pass group figures
  - [ ] Prepare input files for each participant
  - [ ] Review batch script
  - [ ] Write up methods section
]

// ===== Entry 3 — Journal Club =====
#journal-entry(
  title: "Journal Club — Recent Findings in the Field",
  date: "Wednesday, 12/03/2026",
  keywords: "journal club, literature, discussion",
)[
  == Paper
  Author, A. B., Author, C. D., & Author, E. F. (2019). Revealing hidden states in working memory. *Journal of Example Studies.*

  == Key Points
  The paper demonstrates that memory contents can be decoded from neural signals even during periods when no sustained activity is present. #lorem(30)

  The main findings were:

  + Delay-period activity is only intermittently present, yet memory contents remain decodable.
  + A computational model based on short-term plasticity reproduces the behavioural and neural data.
  + The model predicts that memory can be probed — a task-irrelevant impulse elicits a memory-specific reactivation.

  == Discussion Points
  - How do we reconcile the activity-quiet framework with sustained firing in animal models?
  - Could the probe effect be used to investigate non-conscious processing?
  - #lorem(15)

  John suggested adding a retro-cue in a follow-up experiment. Alice cautioned about signal-to-noise challenges.

  == Follow-Up
  - [x] Read the companion modelling paper
  - [ ] Draft a one-page proposal for a probe experiment
  - [ ] Check whether the existing dataset has a usable trial structure
]

// ===== Entry 4 — Data Quality Check =====
#journal-entry(
  title: "Data Quality Check — Pilot Dataset Artefact Review",
  date: "Tuesday, 18/03/2026",
  keywords: "data quality, artefacts, pilot",
)[
  Ran the full pipeline on the pilot dataset. #lorem(15) Overall data quality is acceptable, but a few issues need attention.

  == Artefact Summary
  + *Type 1.* Automated method successfully isolated artefactual components in all blocks. After rejection, less than 2 % of trials were removed.
  + *Type 2.* Muscle activity was elevated in some blocks, likely due to participant fatigue. Affected trials show broadband power increases above 30 Hz.
  + *Type 3.* Two channels exhibited jump artefacts and were interpolated using neighbouring sensors.

  == Pipeline Timing
  The full pipeline takes approximately *45 minutes* per block on the lab workstation. This is acceptable for the main dataset, but parallelisation across blocks would speed things up.

  == Recommendations
  - [x] Document all preprocessing parameters
  - [ ] Set up parallel processing across participants
  - [ ] Exclude problematic blocks from further analysis
  - [ ] Run the full dataset through the pipeline
  - [ ] Double-check forward models for participants without structural scans
]
