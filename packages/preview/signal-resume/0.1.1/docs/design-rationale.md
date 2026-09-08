# Design rationale

David Resume Template v1 is based on evidence-backed constraints for senior software-engineering resumes in modern ATS and AI-assisted hiring pipelines.

## Structural decisions

### Single column

Single-column layout is the lowest-risk default for parsing and preserves an obvious reading order. Job and education dates stay on the same left-aligned line as their role or credential so extraction order remains stable across PDF parsers.

### Standard headings

The template uses Summary, Technical Skills, Experience, Education, and Additional. Conventional labels reduce interpretation burden for both parsers and reviewers.

### Typography

- Body: 11 pt
- Section headings: 12 pt
- Name: 21 pt
- Three levels maximum

The supported range is more important than any exact number. Users should avoid shrinking below 10 pt merely to force one page.

### Margins

The default 18 mm margin is approximately 0.71 inches on every side, within the recommended 0.6–0.8 inch range.

### Content hierarchy

The first bullets should carry the strongest evidence. Bullets should show scope, decisions, outcomes, and proof rather than listing duties.

### Color and decoration

The template is monochrome. No icons, sidebars, charts, progress bars, photos, or graphical proficiency indicators are included. Color must never carry essential meaning.

### File format

Typst produces a text-based PDF. Users should still validate text extraction and retain a DOCX version when requested by an employer.

## AI-era considerations

Modern hiring pipelines may combine parsing, structured fields, exact-term filtering, semantic retrieval, embeddings, ranking, and LLM-assisted review. The template therefore supports both explicit terminology and contextual evidence. It does not use hidden keywords, keyword stuffing, or prompt injection.

## Limits

No public evidence establishes a universally optimal template, font, bullet count, or spacing formula. This project implements a conservative, robust default that should be tailored to role, seniority, and truthful evidence.
