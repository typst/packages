// =============================================================================
//  main.typ  —  Your Europass CV
// =============================================================================
//  1. Fill in your details below (override anything you need).
//  2. Run `./build.sh` — done (PDF/UA-1 accessible, fonts embedded).
//
//  All the complex layout lives in lib.typ — you never need to touch it.
//  Just replace the sample data with your own.
//
//  NOTE ON THE SAMPLE PERSONA: the flagship example keeps an Italian persona
//  written in English — a common Europass combination for EU/international
//  applications.  Replace the sample data with your own.
// =============================================================================
#import "@preview/rasko-europass:1.0.0": cv-entry, europass-cv, l

// ═══════════════════════════════════════════════════════════════════════════
//  CONFIGURE YOUR CV HERE
// ═══════════════════════════════════════════════════════════════════════════

#show: europass-cv.with(
  // ── Language ──────────────────────────────────────────────────────────
  // ISO 639-1 code.  Supported: en, it, fr, de, es, pt, nl, pl, ro, bg,
  // cs, da, el, et, fi, hr, hu, ga, lt, lv, mt, sk, sl, sv.
  // Falls back to English if the code is unrecognised.
  lang: "en",

  // ── Document metadata (accessibility / PDF-UA) ─────────────────────────
  title: "Curriculum Vitae — Mario Rossi",
  author: "Mario Rossi",

  // ── Personal Information ──────────────────────────────────────────────
  name: "Mario Rossi",
  // Anonymous, gender-neutral placeholder portrait (see assets/).
  photo: "assets/photo-placeholder.svg",
  photo-alt: l("en").at("photo-alt"),
  address: "Via Roma 42",
  postal-code: "00100",
  city: "Rome",
  country: "Italy",
  phone: "+39 333 1234567",
  email: "mario.rossi@email.it",
  nationality: "Italian",
  date-of-birth: "15/03/1990",
  // Gender is optional & inclusive: "male" | "female" | "other" |
  // "undeclared" (prefer not to say), any free text, or omit entirely.
  gender: "male",

  // ── Work Experience ───────────────────────────────────────────────────
  // Use cv-entry(…) for each job.  Every field is optional — omit what you
  // don't need.
  work-experience: (
    cv-entry(
      date-start: "Jan 2021",
      date-end: "Present",
      title: "Senior Software Engineer",
      organization: "Tech Solutions S.p.A.",
      location: "Milan, Italy",
      description: [
        - Designed and developed cloud-native microservices on AWS (Lambda, ECS, SQS)
        - Coordinated an Agile team of six developers, with code review and mentoring
        - Migrated the legacy monolithic architecture towards an event-driven architecture
        - Reduced deployment times by 40% through CI/CD pipelines with GitHub Actions
      ],
    ),
    cv-entry(
      date-start: "Sep 2018",
      date-end: "Dec 2020",
      title: "Software Developer",
      organization: "Digital Innovators S.r.l.",
      location: "Turin, Italy",
      description: [
        - Full-stack development of web applications with React, TypeScript and Node.js
        - Designed and optimised PostgreSQL databases for high-concurrency systems
        - Built RESTful APIs documented with OpenAPI/Swagger
        - Drove the migration of the entire codebase from JavaScript to TypeScript
      ],
    ),
    cv-entry(
      date-start: "Mar 2016",
      date-end: "Aug 2018",
      title: "Junior Developer",
      organization: "WebAgency Creative",
      location: "Rome, Italy",
      description: [
        - Developed responsive websites with HTML5, CSS3, JavaScript and WordPress
        - Collaborated with the design team on UI/UX interface implementation
        - Maintained and updated existing websites for over 30 clients
      ],
    ),
  ),

  // ── Education & Training ──────────────────────────────────────────────
  education: (
    cv-entry(
      date-start: "2013",
      date-end: "2015",
      title: "MSc in Computer Engineering",
      organization: "Politecnico di Milano",
      location: "Milan, Italy",
      description: [
        - Final grade: 110/110 with honours
        - Thesis: "Distributed architectures for real-time data stream processing"
        - Specialisation in Software Systems and Architectures
      ],
    ),
    cv-entry(
      date-start: "2010",
      date-end: "2013",
      title: "BSc in Computer Engineering",
      organization: "Sapienza University of Rome",
      location: "Rome, Italy",
      description: [
        - Final grade: 108/110
        - Core subjects: Algorithms, Databases, Computer Networks, Operating Systems
      ],
    ),
  ),

  // ── Personal Skills ───────────────────────────────────────────────────
  mother-tongue: "Italian",

  // CEFR self-assessment: Listening, Reading, Spoken Interaction,
  // Spoken Production, Writing.  Levels: A1, A2, B1, B2, C1, C2.
  other-languages: (
    (
      lang: "English",
      listening: "C1",
      reading: "C1",
      interaction: "B2",
      production: "B2",
      writing: "C1",
    ),
    (
      lang: "French",
      listening: "B1",
      reading: "B2",
      interaction: "A2",
      production: "A2",
      writing: "B1",
    ),
    (
      lang: "Spanish",
      listening: "A2",
      reading: "A2",
      interaction: "A2",
      production: "A1",
      writing: "A1",
    ),
  ),

  digital-skills: [
    - *Languages:* TypeScript/JavaScript, Python, Java, SQL, Rust
    - *Cloud & DevOps:* AWS (Lambda, ECS, S3, RDS, SQS), Docker, Kubernetes, Terraform, CI/CD (GitHub Actions, GitLab CI)
    - *Frameworks:* React, Next.js, Node.js, Express, FastAPI, Spring Boot
    - *Databases:* PostgreSQL, MongoDB, Redis, DynamoDB
    - *Tools:* Git, Linux, VS Code, Jira, Confluence, Figma
  ],

  comm-skills: [
    - Strong communication skills developed through team leadership and collaboration with international stakeholders
    - Experience presenting technical projects to non-technical audiences and training junior developers
    - Negotiation skills gained in project management and client-facing roles
  ],

  org-skills: [
    - Management of software projects with Agile/Scrum methodology (certified Scrum Master)
    - Ability to plan and prioritise activities across multiple concurrent projects
    - Organisation of technical workshops and company-wide knowledge-sharing sessions
  ],

  job-skills: [
    - Design of distributed software architectures and microservices
    - Requirements analysis and technical documentation
    - Code review and mentoring of junior developers
    - Performance optimisation of highly scalable systems
  ],

  driving-licence: "Category B",

  // ── Legal Declaration ─────────────────────────────────────────────────
  signature-place: "Rome",
  signature-date: "15 September 2025",
)
