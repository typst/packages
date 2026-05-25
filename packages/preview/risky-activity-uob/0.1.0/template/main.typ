#import "@preview/risky-activity-uob:0.1.0": risk-assessment, risk-table, action-plan-table, sign-on-table, signature-box

#show: risk-assessment.with(
  title: [],
  date-produced: [],
  review-date: [],
  overview: [],
  duration: [],
  location: [],
  assessment-type: [],
)

// Hazard Identified | Who might be harmed and how | Existing controls | Severity | Likelihood | Risk rating | Action required
#risk-table(
  [],[],[],[],[],[],
  [],[],[],[],[],[],
  [],[],[],[],[],[],
  [],[],[],[],[],[],
  [],[],[],[],[],[],
  [],[],[],[],[],[],
  
)

#v(8pt)
#signature-box("Assessor signature")

#pagebreak()

= Risk Assessment Action Plan

// Hazard No. | Action to be taken | By whom | Target date | Review date | Outcome at review date
#action-plan-table(
  [],[],[],[],[],[],
  [],[],[],[],[],[],
)

#signature-box("Responsible manager's signature")
#signature-box("Responsible manager's signature")

#pagebreak()

= Risk Assessment Sign-On Sheet

// Print Name | Signature | Date
#sign-on-table(
  [],[],[],
  [],[],[],
)
