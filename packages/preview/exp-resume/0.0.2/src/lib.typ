/*
 * Package entrypoint; re-exports the public API.
 * Split keeps layout in `resume.typ`, section components in `components.typ`,
 * and low-level helpers in `helpers.typ`.
 */

#import "helpers.typ": linked-text, generic-two-by-two, generic-one-by-two, dates-helper
#import "components.typ": summary, edu, work, project, certificates, extracurriculars
#import "resume.typ": resume