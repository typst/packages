#import "@preview/cyber-cv-letter:0.1.0": letter

#show: letter.with(
  author: (
    name: "Sarah Connor",
    tagline: "AI Security Engineer · Adversarial ML & Red Teaming",
    email: "sarah@sconnor.dev",
    location: "Austin, TX (US)",
    links: ("github.com/sconnor", "linkedin.com/in/sarahconnor"),
  ),
  accent: sys.inputs.at("accent", default: "red"),
  accent-scope: sys.inputs.at("accent-scope", default: "full"),
  paper: sys.inputs.at("paper", default: "a4"),
  show-icons: sys.inputs.at("show-icons", default: "true") == "true",
  show-footer: sys.inputs.at("show-footer", default: "true") == "true",
  keywords: ("Adversarial ML", "Red Teaming", "LLM Security"),
  // paragraph-spacing: override the letter-only default (space-letter-paragraph, src/theme.typ) if needed.
  date: "1 September 2026",
)

Dear Hiring Manager,

I am writing to apply for the Staff AI Security Engineer role on your detection team. Over the past six years I have moved from applied machine learning into security engineering and, most recently, into building the adversarial and red-team defenses that keep production LLM systems safe to ship.

At Cyberdyne Systems I built an automated prompt-injection fuzzing harness that surfaced more than 40 high-severity jailbreaks across six production LLM features before they ever reached customers, and led adversarial robustness reviews that cut a fraud-detection model's evasion rate from 18% to under 2%. I also designed the model-extraction detection pipeline now running across every customer-facing inference endpoint we operate.

Earlier, at Skynet Analytics, I authored the organization's first threat model for LLM-integrated services — since adopted company-wide — and embedded security gating directly into the MLOps CI/CD pipeline, cutting the time to patch critical model-serving CVEs from three weeks to four days.

Your team's work on production LLM safety is exactly the kind of problem I want to keep solving, and I would welcome the chance to bring that experience to your organization.

Thank you for your consideration.

Best regards, \
Sarah Connor
