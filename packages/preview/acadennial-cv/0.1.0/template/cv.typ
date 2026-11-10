#import "@preview/acadennial-cv:0.1.0": *

// ============================================
// Default function configurations
// ============================================

#let col-cfg = (
  c1-len: 15%,
  c2-len: 1fr,
  c3-len: auto,
  col-gutter: 1em,
)

#let employment-head = employment-head.with(..col-cfg)
#let employment-head-item = employment-head-item.with(..col-cfg)
#let employment-head-item-list = employment-head-item-list.with(..col-cfg)
#let meta-entry = meta-entry.with(..col-cfg)
#let meta-entry-item = meta-entry-item.with(..col-cfg)
#let meta-entry-item-list = meta-entry-item-list.with(..col-cfg)
#let pub-item = pub-item.with(..col-cfg)
#let pub-item-list = pub-item-list.with(..col-cfg)

// ============================================
// Initialize resume settings
// ============================================
#show: resume.with(
  col-args: (
    c1-len: col-cfg.c1-len,
    c2-len: col-cfg.c2-len,
    col-gutter: col-cfg.col-gutter,
  ),
  author-info: (
    name: "Alex Debugson",
    primary-info: [
      Assistant Professor \
      MITea \
      Building 123, Room 456 \
      Cambrew, MA
    ],
    secondary-info: [
      #link("mailto:alex.debugson@mitea.edu")[alex.debugson\@mitea.edu] \
      #link("https://www.debugson.dev")[https://www.debugson.dev] \
      #link("https://linkedin.com/in/your-linkedin-username")[#linkedin-icon()] #link("https://x.com/your-x-username")[#x-icon()] #link("https://scholar.google.com/citations?user=your-scholar-id")[#google-scholar-icon()] #link("https://github.com/your-github-username")[#github-icon()] #link("https://orcid.org/0000-0000-0000-0000")[#orcid-icon()]
    ],
  ),
)

== Current Employment
#employment-head-item(
  "MITea",
  "Cambrew, MA",
)[
  Assistant Professor @ the Department of Meme Engineering and Applied Procrastination

  Lab Director and Principal Investigator, \
  SNACK Lab (Systems and Networks for Advanced Coffee Knowledge)
]

== Education
#employment-head-item-list(
  (
    c2: "Standfork University",
    c3: "Palo Latte, CA",
    body: [
      Ph.D. in Computer Science, June 2025 \
      _Thesis:_ Deep Learning Approaches to Optimal Coffee-to-Code Conversion Ratios \
      _Advisor:_ Prof. Andrew Ng-ineer

      M.S. in Computer Science, May 2022 \
      _Thesis:_ Distributed Consensus Algorithms for Office Coffee Pot Scheduling \
      _Advisor:_ Prof. Andrew Ng-ineer
    ],
  ),
  (
    c2: "Qingcha University",
    c3: "Beijing, P.R. China",
    body: [
      B.Eng. (Honors) in Software Engineering @ Yingcai Honors College, June 2019
    ],
  ),
)

== Research Interests
Machine Learning Systems, Cat Meme Classification, Distributed Coffee Brewing Optimization, Quantum Procrastination Scheduling

== Experience

#meta-entry-item-list(
  (
    c1: "2019–2025",
    c2: text(tracking: -0.1pt)[Research Assistant (Advised by Prof. Andrew Ngineer)],
    c3: "Standfork University, Palo Latte, CA, USA",
    body: [Developed novel deep learning architectures for real-time cat meme classification with 99.9% accuracy on the ImageMeow dataset. Pioneered the use of attention mechanisms for identifying optimal napping schedules based on code compilation times.],
  ),
  (
    c1: "2024",
    c2: "Research Intern (Mentored by Dr. Cache Miss)",
    c3: "Googol Inc., Mountain Brew, CA, USA",
    body: [Designed and implemented distributed systems for global coffee bean routing using blockchain technology. Reduced average coffee delivery latency by 40% through application of advanced queueing theory.],
  ),
  (
    c1: "2023–2024",
    c2: "Research Consultant",
    c3: "DeepMeme.ai Inc., San Framemeisco, CA, USA",
    body: [Led development of GPT-based meme generation pipeline with real-time dankness evaluation. Implemented federated learning framework for privacy-preserving rubber duck debugging across enterprise environments.],
  ),
)

== Awards and Honors

#meta-entry-item-list(
  c2-text-args: (weight: "regular"),
  item-spacing: 0.8em,
  (c1: "5/Applicants", c2: "Golden Rubber Duck Fellowship, MITea Department of Meme Engineering"),
  (c1: "1/Applicants", c2: "Best Procrastinator Researcher Award, International Procrastination Society"),
  (c1: "42/Worldwide", c2: "Rising Star in Meme Learning and Coffee Systems, MLMemes 2025"),
  (c1: "94/U.S.", c2: "NSF MemeSys Early-Career Investigators Travel Grant"),
  (c1: "7/100+", c2: "Outstanding Debugging Performance Award, Stack Overflowers Anonymous"),
  (c1: "Top 1%", c2: "Excellent Graduate of Beijing Province (cleared 10,000+ LeetCode problems)"),
)


== Research and Publications

#pubs-reset()

=== Preprints

#pub-item-list(
  [*Alex Debugson*, Cache Miss, RAM Shortage, and GPU Heatstroke. Attention is All You Knead: A Transformer Approach to Automated Sourdough Monitoring. _In Submission_, 2025.],
  [Stack Overflow, *Alex Debugson*, Null Pointer, and Seg Fault. BREAD: Bidirectional Encoder Representations from Artisanal Doughs. _In Submission_, 2025.],
)

=== Journal

#pub-item-list(
  [*Alex Debugson*, GPU Heatstroke, Cache Miss, and Virtual Memory. DeepBrewNet: Neural Architecture Search for Optimal Coffee Brewing Parameters. _Journal of Machine Learning for Beverage Science (JMLBS)_, 42(3):128–145, 2024.],
  [Null Pointer, *Alex Debugson*, Stack Overflow, and Heap Corruption. MemeMorph: A Survey of Deep Learning Techniques for Cross-Platform Meme Translation. _ACM Computing Surveys on Internet Culture_, 56(2):1–38, 2023.],
)

=== Conference

#pub-item-list(
  [*Alex Debugson*, Cache Miss, RAM Shortage, and Seg Fault. MemeNet: Deep Convolutional Neural Networks for Dankness Classification. In _Proceedings of the Conference on Cat Videos and Meme Recognition (CVMR)_, pages 404–418, 2024.],
  [Stack Overflow, *Alex Debugson*, Null Pointer, and CPU Throttle. GIF-PT: Generative Pre-trained Transformer for Animated Memes. In _Proceedings of Neural Information Processing for MEMEs (NeuralMEMEs)_, pages 1–14, Mem Francisco, CA, 2024.],
  [*Alex Debugson*, RAM Shortage, Buffer Overflow, and Exception Handler. RestNet: Deep Residual Learning for Optimal Napping Schedule Prediction. In _Proceedings of the International Conference on Machine Learning for Procrastination (ICMLP)_, pages 256–270, Snoozeville, USA, 2023.],
  [Cache Miss, *Alex Debugson*, and GPU Heatstroke. YOLO: You Only Live Once, So Why Not Debug? In _Proceedings of USE-LINUX Security Symposium_, pages 1337–1350, 2023.],
  [*Alex Debugson*, Null Pointer, Exception Handler, and Kernel Panic. CaffQL: A Query Language for Distributed Coffee Bean Analytics at Scale. In _Proceedings of the ACM SIGMOD International Conference on Management of Beverages (SIGBEV)_, pages 314–327, Seattle, WA, 2022.],
)

=== Workshop

#pub-item-list(
  [*Alex Debugson*, Null Pointer, and Seg Fault. AlphaNope: Mastering the Game of Procrastination through Deep Reinforcement Napping. In _Workshop on Advances in Doing Nothing (WADN)_, June 2024.],
)

=== Poster

#pub-item-list(
  [*Alex Debugson*, Cache Miss, CPU Throttle. Blockchain for Pizza Delivery: A Decentralized Approach to Optimal Topping Distribution. In _Proceedings of SIGMEME Poster Session_. *Best Pizza Topping Algorithm Award*, Pepperoni City, NY, 2022.],
)

== Grants and Funding

#meta-entry-item-list(
  c2-text-args: (weight: "regular"),
  (c1: "2024–2027", c2: "NSF CAREER Award: Automated Procrastination Detection and Mitigation in Large-Scale Software Development, $550,000. Role: PI"),
  (c1: "2023–2025", c2: "Googol Research Award: Real-time Cat Meme Quality Assessment Using Federated Learning, $100,000. Role: PI"),
  (c1: "2024–2026", c2: "DeepMeme.ai Industry Partnership: Privacy-Preserving Rubber Duck Debugging Infrastructure, $75,000. Role: Co-PI with Dr. Stack Overflow"),
)

== Academic Service

#meta-entry-item-list(
  c2-text-args: (weight: "regular"),
  (c1: "2023–2025", c2: "Head, NSF Coffee Systems Research Advisory Council"),
  (c1: "2024", c2: "Program Committee Member, International Meme Conference (IMC) 2024"),
  (c1: "2024", c2: "Pre-review Taskforce, USE-LINUX NSDI 2025"),
  (c1: "2020–2025", c2: "Reviewer for multiple conferences and journals, including:", body: [NeuralMEMEs, USE-LINUX Annual Technical Conference (ATC), IEEE Transactions on Cat Meme Classification (TCMC), ACM SIGMEME, Conference on Very Large Meme Databases (VLMDB), International Conference on Coffee Computing (ICCC)]),
)

== Teaching and Mentoring Experience

=== Teaching

#meta-entry-item-list(
  c2-text-args: (weight: "regular"),
  (
    c1: "2022",
    c2: [*Student Instructor*, Data Clinics in Collaboration with Starmemes Coffee],
    c3: "Cambrew, MA",
    body: [Mentored collaborative project with master's students to optimize espresso extraction parameters using Bayesian optimization. Created interactive Jupyter notebooks demonstrating gradient descent for coffee grinder calibration.],
  ),
  (
    c1: "2020",
    c2: [*Teaching Assistant*, CS15400 Introduction to Meme Systems],
    c3: "Cambrew, MA",
    body: [Assisted 200+ students in hands-on projects including implementing a distributed cat meme cache with LRU eviction policy. Pioneered remote rubber duck debugging sessions during pandemic.],
  ),
)

=== Mentoring

#meta-entry-item-list(
  c2-text-args: (weight: "regular"),
  (c1: "MITea", c2: [*Byte Overflow*, Ph.D. student, coauthored \[1,2,4,5\], working on multiple follow-ups about deep learning for pizza topping prediction.]),
  (c1: "MITea", c2: [*Pixel Dropout*, Master student → Googol. Coauthored \[3\], now optimizing coffee bean supply chains at scale.]),
  (c1: "MITea", c2: [*Memory Leak*, Ph.D. student, coauthored \[7\], researching garbage collection strategies for deprecated memes.]),
  (c1: "Standfork", c2: [*Compile Error*, Undergraduate student, exploring quantum algorithms for procrastination scheduling.]),
  (c1: "Standfork", c2: [*Syntax Error*, Undergraduate student → DeepMeme.ai. Worked on rubber duck debugging augmented reality prototype.]),
)

== Invited Talks

#meta-entry-item-list(
  c2-text-args: (weight: "regular"),
  (c1: "2024-2025", c2: [Speaker, 'From Cat Memes to Coffee Dreams: A Journey Through Applied Procrastination' \@_Standfork University, MITea, CMeow (Carnegie Meowllon), Barkeley, Prints-a-ton, Hardvard, Qingcha University, Oxfork_]),
  (c1: "2023", c2: [Speaker, 'MemeNet: Deep Learning for Dankness Classification' _\@CVMR'23_]),
  (c1: "2022", c2: [Invited Speaker, 'Why Your Coffee Code Doesn't Compile: A Debugging Journey' _\@Googol Systems Seminar_]),
)

== Media Coverage

#meta-entry-item-list(
  c2-text-args: (weight: "regular"),
  (c1: "2024", c2: [Featured in _Tech Crunch_: "MITea Professor's AI Can Tell if Your Meme Will Go Viral"]),
  (c1: "2024", c2: [Interview in _Wired Magazine_: "The Science Behind Perfect Coffee-Driven Coding"]),
  (c1: "2023", c2: [_NPR All Tech Considered_: "How Machine Learning is Revolutionizing Procrastination"]),
  (c1: "2023", c2: [_The New York Times Technology Section_: "Blockchain for Pizza: The Future of Food Delivery?"]),
)
