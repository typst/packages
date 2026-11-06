#import "@preview/vivid-cv:0.1.0": *

// ─────────────────────────────────────────────
//  Personal information
// ─────────────────────────────────────────────
#let name = "Loïc Fontaine"
#let job-title = "Full-stack Software Engineer"
#let location = "City, Country"
#let email = "you@example.com"
#let github = "loicfontaine"
#let linkedin = "loicfontaine-suisse"
#let phone = "+1 234 567 890"
#let personal-site = "lfontaine.ch"

#show: resume.with(
  // ── Identity ──────────────────────────────
  author: name,
  title: job-title,
  location: location,
  email: email,
  github: github,
  linkedin: linkedin,
  phone: phone,
  personal-site: personal-site,

  // ── Photo ─────────────────────────────────
  // Set show-photo: false to remove the photo entirely.
  show-photo: true,
  photo: "/example/photo.jpg",
  photo-size: 140pt,

  // ── About / intro ─────────────────────────
  // Customise the section title for your language:
  //   English  → "About me"  or  "Profile"
  //   French   → "À propos"  or  "Profil"
  //   German   → "Über mich" or  "Profil"
  // Set about-title: "" to hide the heading.
  about-title: "About me",
  about-beside: [
    // ~3 lines max — shown beside the photo.
    Write a short intro paragraph here. Keep it to 2–3 sentences so it
    sits neatly beside your photo. Use this space to summarise your experience, skills and career goals. Make it specific to the type of roles you're applying for.
  ],
  // Optional — full-width paragraph below the photo row.
  // Remove or set to `none` if you don't need it.
  about-below: [
    A second paragraph that spans the full page width, below the photo row. Use this for overflow from the first paragraph, or to add a complementary statement.
  ],

  // ── Footer ────────────────────────────────
  // Set to "" to hide.
  reference: "References available upon request",

  // ── Colours ───────────────────────────────
  header-color: "#06332a", // banner background
  name-color: "#ffdf2b", // your name inside the banner
  heading-color: "#303f3c", // == section headings
  text-color: "#303f3c", // body text
  photo-border: "#ffffff", // photo ring

  // ── Typography ────────────────────────────
  font: "Avenir Next",
  author-font-size: 20pt,
  font-size: 10pt,

  // ── Layout ────────────────────────────────
  paper: "a4", // or "us-letter"
  lang: "en",
  icon: true,

  // ── Banner height (advanced) ───────────────
  // The template calculates the banner height automatically.
  // Uncomment and adjust if the result looks off on your setup.
  // banner-height-override: 115pt,
)

// ─────────────────────────────────────────────
//  Skills
// ─────────────────────────────────────────────
== Skills
*Languages:* TypeScript/JavaScript, Python, PHP, SQL \
*Frontend:* Vue.js, React.js, Tailwind CSS, REST APIs \
*Backend & Cloud:* Node.js, Laravel, MySQL, Google Cloud, AWS \
*Tools:* Docker, CI/CD, Git, Agile, UI/UX \
*Languages:* English (native), French (B2), German (A2)

// ─────────────────────────────────────────────
//  Work experience
// ─────────────────────────────────────────────
== Work Experience

#work(
  title: "Senior Software Engineer",
  location: "San Francisco, CA",
  company: "Acme Corp",
  dates: dates-helper(start-date: "Jan 2023", end-date: "Present"),
)
- Led development of a microservices platform handling 10k req/s
- Mentored 3 junior engineers and introduced weekly code reviews

#work(
  title: "Software Engineer",
  location: "Remote",
  company: "Startup Inc.",
  dates: dates-helper(start-date: "Jun 2021", end-date: "Dec 2022"),
)
- Built a full-stack SaaS product from scratch using Vue.js and Laravel
- Reduced page load times by 40% through caching and query optimisation

// ─────────────────────────────────────────────
//  Education
// ─────────────────────────────────────────────
== Education

#edu(
  institution: "University of Example",
  location: "Geneva, Switzerland",
  dates: dates-helper(start-date: "Sept 2018", end-date: "Jun 2021"),
  degree: "BSc Computer Science",
  consistent: true,
)
- Graduated with honours
- Thesis on distributed systems and consensus algorithms

// ─────────────────────────────────────────────
//  Projects  (optional section)
// ─────────────────────────────────────────────
== Projects

#project(
  name: "My Open Source Tool",
  url: "github.com/yourusername/my-tool",
  dates: dates-helper(start-date: "2022", end-date: "Present"),
)
- A CLI tool for automating deployment workflows; 300+ GitHub stars

// ─────────────────────────────────────────────
//  Volunteering  (optional section)
// ─────────────────────────────────────────────
// == Volunteering
//
// #work(
//   title:   "Board member",
//   company: "Local NGO",
//   dates:   dates-helper(start-date: "2020", end-date: "Present"),
//   location: "Geneva, Switzerland",
// )
// - Organised fundraising events and managed social media presence
