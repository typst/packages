#import "@preview/simple-cv:0.1.0": *
#show: cv.with(
  name: "Langxi Yuan",
  motto: "An ordinary man with an extraordinary dream.",
)

== Education

#entry(
  title: [Sun Yat-Sen University],
  interval: (
    start: datetime(year: 2023, month: 9, day: 1),
    end: datetime(year: 2027, month: 6, day: 30),
  ),
  title-note: [Bachelor of Computer Science],
  interval-note: [Panyu, Guangzhou],
)

== Work Experience

#entry(
  title: [NPU Inference Acceleration],
  interval: (
    start: datetime(year: 2025, month: 10, day: 21),
    end: "Present",
  ),
  title-note: [Laboratory of Robotics and Intelligent Computing, SYSU],
  interval-note: [Panyu, Guangzhou],
)

System Scheduling and Reasoning Acceleration based on Huawei NPU.
- A cross-platform abstraction layer supporting CUDA, OpenCL, and Huawei Ascend (CANN),
  providing a unified programming model across heterogeneous accelerators.
- Accelerated model inference by authoring custom operators and tuning their degree of parallelism.

#entry(
  title: [Software Development Intern],
  interval: (
    start: datetime(year: 2026, month: 8, day: 5),
    end: datetime(year: 2026, month: 11, day: 5),
  ),
  title-note: [Huawei, ICT-BG, Data Communications],
  interval-note: [Songshan Lake, Dongguan],
)

Software development for enterprise and carrier-grade networking platforms,
focused on common software components across the Data Communications product line.
- #lorem(12)
- #lorem(13)
- #lorem(11)
- #lorem(14)

== Projects

#entry(
  title: link("https://github.com/yuanlx27/simple-cv")[Simple CV],
  interval: (
    start: datetime(year: 2026, month: 4, day: 22),
    end: "Present",
  ),
)

A simple curriculum vitae (resume) template
that powers this very document you are reading right now.
- Written in Typst, a compiled typesetting language with the extensibility of LaTeX
  and the simplicity of Markdown.
- Simple by default, no fancy layouts and decorations.
  It's a CV. It just tells others what you have done and what you can do.

#entry(
  title: link("https://github.com/yuanlx27/site")[Personal Site],
  interval: (
    start: datetime(year: 2026, month: 10, day: 1),
    end: "Present",
  ),
)

A Chinese-first personal website and blog built with Astro, TypeScript, Markdown, and handwritten CSS.
- Designed responsive layouts and Chinese–English typography with system-aware themes
  and persistent light/dark preferences; content remains accessible without JavaScript.
- Implemented a Markdown publishing workflow with draft previews, tag archives,
  CJK-aware reading-time estimates, RSS, and sitemap generation.
- Automated type checks, builds, generated-site tests, and GitHub Pages deployment
  through GitHub Actions.
