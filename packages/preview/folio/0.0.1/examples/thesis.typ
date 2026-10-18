#import "@preview/folio:0.0.1": project-doc

#let thesis-data = (
  project: (
    name: "Sentiment Analysis of Reddit Threads",
    description: "2026 Honors Thesis in Computational Linguistics",
  ),
  initiation: (
    pitch: "Apply transformer-based models to analyze emotional drift in niche communities.",
    business_case: "Academic research requirement for graduation.",
    objectives: (
      (id: "OBJ-1", description: "Collect 1M comments", priority: "high"),
      (id: "OBJ-2", description: "Fine-tune BERT model", priority: "high"),
      (id: "OBJ-3", description: "Write 60-page report", priority: "neutral"),
    ),
  ),
  baselines: (
    scope: (
      in_scope: ("Data scraping", "Model training", "Statistical analysis"),
      out_of_scope: ("Real-time web dashboard", "Deployment to production"),
    ),
    schedule: (
      milestones: (
        (
          id: "M1",
          date: "2026-05-15",
          title: "Proposal Defense",
          status: "Done",
        ),
        (
          id: "M2",
          date: "2026-11-01",
          title: "Draft Submission",
          status: "Pending",
        ),
      ),
    ),
  ),
  governance: (
    team: (
      (role: "Candidate", name: "I. M. Student", email: "student@uni.edu"),
      (role: "Supervisor", name: "Dr. Knows-A-Lot", email: "prof@uni.edu"),
    ),
  ),
  closure: (
    lessons_learned: (
      (
        category: "Process",
        issue: "API rate limits were tighter than expected",
        recommendation: "Always budget 2x time for data collection",
      ),
    ),
    sign_off: (
      (name: "Dean of Science", role: "Approval"),
    ),
  ),
)

#show: project-doc(
  data: thesis-data,
  config: (
    sections: (
      status_report: false,
      risk_matrix: false,
      issue_log: false,
      change_log: false,
    ),
  ),
)
