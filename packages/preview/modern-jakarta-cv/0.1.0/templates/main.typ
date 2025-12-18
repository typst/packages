#import "../template.typ": *

// Apply the global layout settings defined in template.typ
#show: project

// --- HEADER SECTION ---
// Centered name with clickable professional links.
#align(center)[
  #text(18pt, weight: "bold")[Callista Putmanda] \
  #v(0.1em)
  #text(size: 9pt)[
    callista.p\@email.com | 
    #link("https://github.com/callistap")[github.com/callistap] | 
    #link("https://linkedin.com/in/callistaputmanda")[linkedin.com/in/callistaputmanda] | 
    #link("https://callista-marketing.framer.website")[Portfolio]
  ]
]

// --- PROFESSIONAL SUMMARY ---
#section("Summary")
#text(size: 9.5pt)[
Strategic and creative Marketing graduate from Universitas Indonesia with a strong focus on Digital Growth and Brand Management. Experienced in managing cross-channel campaigns, analyzing consumer behavior data, and optimizing social media ROI. Proven ability to execute data-driven marketing strategies that increased brand engagement by 35% during internship roles in fast-paced industries.
]

// --- EDUCATION ---
#section("Education")
#entry(
  title: "Bachelor of Economics (Marketing Major)",
  sub_title: "Universitas Indonesia",
  date: "Sept 2021 — July 2025",
  description: [
    - *GPA: 3.92 / 4.00* — Specialized in Digital Marketing and Consumer Insights.
    - *Honors:* National Marketing Competition Finalist; Recipient of Excellence Scholarship.
    - *Relevant Coursework:* Strategic Brand Management, Market Research, and Digital Analytics.
  ]
)

// --- WORK EXPERIENCE ---
#section("Work Experience")
#entry(
  title: "Growth Marketing Specialist",
  sub_title: "Lumina Consumer Goods",
  date: "Aug 2025 — Present",
  location: "Jakarta, Indonesia",
  description: [
    - Spearheaded a multi-channel digital launch for a new product line, resulting in a 20% increase in monthly recurring revenue (MRR) within the first quarter.
    - Optimized Google Ads and Meta Ads performance, achieving a 15% reduction in Customer Acquisition Cost (CAC) through meticulous A/B testing and keyword optimization.
  ]
)

#entry(
  title: "Brand Management Intern",
  sub_title: "Global Brands Co.",
  date: "Jan 2024 — July 2024",
  location: "Jakarta, Indonesia",
  description: [
    - Assisted in the execution of nationwide brand awareness campaigns reaching 1M+ unique users across social platforms.
    - Conducted comprehensive competitor analysis and market trend reporting to inform quarterly strategy adjustments.
  ]
)

// --- ORGANIZATIONAL EXPERIENCE ---
#section("Organizational Experience")
#entry(
  title: "Head of Public Relations",
  sub_title: "Economics Student Board (BEM FEB UI)",
  date: "Jan 2023 — Jan 2024",
  location: "Depok, Indonesia",
  description: [
    - Managed external communications for major events, securing 10+ media partners and 5 major sponsors.
    - Led a team of 10 in revitalizing digital presence, resulting in a 50% growth in Instagram reach.
  ]
)

// --- PROJECTS ---
#section("Projects")
#project_entry(
  title: "Market Analysis: Gen Z Skincare Trends",
  category: "Academic Research Project (SPSS, Google Trends)",
  description: [
    - Conducted primary research on skincare purchasing habits of 500+ Gen Z respondents in Jakarta.
    - Delivered a comprehensive report highlighting the significant shift towards sustainable packaging.
  ]
)

#project_entry(
  title: "EcoPrint: Sustainable Fashion Startup Campaign",
  category: "Strategy Competition (Canva, Meta Business Suite)",
  description: [
    - Designed a 3-month digital marketing roadmap for a hypothetical eco-friendly fashion brand.
    - Won \"Best Strategy Presentation\" for innovative use of short-form video content.
  ]
)

// --- SKILLS & CERTIFICATION ---
#section("Skills & Certification")
#grid(
  columns: (1fr, 1fr),
  gutter: 1.5em,
  [
    - *Digital Marketing:* SEO, SEM, PPC, Email Marketing
    - *Analytics:* Google Analytics (GA4), Mixpanel, Tableau
  ],
  [
    - *Tools:* Mailchimp, HubSpot CRM, Meta Business
    - *Languages:* English (IELTS 8.0), Indonesian (Native)
  ]
)