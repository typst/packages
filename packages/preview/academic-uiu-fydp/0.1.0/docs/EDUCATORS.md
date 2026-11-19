# Educator guide

UIU CSE Final Year Design Project Report follows the structure of the supplied UIU CSE LaTeX FYDP template.
It is a community adaptation. Review it against the current departmental rubric
before distributing it to a class.

## Prepare a course copy

1. Run `python3 scripts/project.py check` and inspect `build/fydp.pdf` and
   `build/fydp-1.pdf`.
2. Review the chapter prompts, standards terminology, P1–P7/A1–A5 mappings,
   citation style, title-page wording, and required front matter.
3. Adapt chapter guidance in `template/chapters/`; make formatting changes in
   `lib.typ`. Record your changes and preserve the original attribution.
4. Distribute a complete repository snapshot, or use the published version once
   accepted. Specify the exact compiler and package version in course materials.
5. Give students [the student guide](STUDENTS.md) and explain which prompts to
   replace, which sections are mandatory, and which assessment rubric applies.

Do not distribute only `template/` before package publication: its entry point
depends on the future Universe import. A repository copy builds through root
`main.typ`; include `lib.typ` and all student files.

## Suggested review points

| Area | Review |
| --- | --- |
| Introduction | Problem, motivation, measurable objectives, method, outcomes |
| Background | Cited sources, comparisons, gap analysis |
| Design | Requirements, diagrams, alternatives, rationale, plan, contributions |
| Implementation | Reproducible environment, tests, evaluation, evidence |
| Standards and constraints | Applicable standards, costs, constraints, justified engineering mappings |
| Conclusion | Outcomes against objectives, limitations, future work |
| Report quality | Clear captions, correct references, attribution, consistent formatting |

The starter deliberately leaves engineering mappings unselected. Students must
justify them from their own work. The inherited labels are prompts rather than
a substitute for current accreditation definitions or course requirements.

## Customization and versioning

The configuration reference lists supported options. For a class-wide change,
keep one reviewed layout and distribute a tagged snapshot. Avoid changing a
published package version's contents. A future release should use a new version,
with corresponding imports updated together.

`scripts/project.py check` compiles local and initialized-package variants; CI runs
this as part of release packaging. These checks catch broken imports, missing
assets, invalid citations, and layout syntax errors. They do not assess research
quality or guarantee that a long student report will have acceptable page breaks.

For offline labs, distribute the repository with Typst 0.15.0 available on `PATH`.
Normal local builds require no network, external packages, Python libraries, or
system font installation. Python is needed only for the helper commands.

## Attribution and redistribution

Credit Swakkhar Shatabda for the original LaTeX template and Shaad Ahmmed for the
Typst adaptation, retain a CC BY 4.0 link, and identify your course modifications.
Keep `NOTICE`, `LICENSE`, and the student-facing `template/NOTICE.md` with shared
sources. Do not imply institutional approval unless you have it.

The repository and release bundle do not distribute a university logo. If your institution
provides redistribution permission, document its terms before including a logo
in any public package. Students can supply a permitted logo in their own reports.
