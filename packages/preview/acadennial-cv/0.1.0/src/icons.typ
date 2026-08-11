// SVG icon registry and helpers for contact links.
#import "@preview/scienceicons:0.1.0" as scienceicons

#let google-scholar-svg = ```<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M12 2 1 8l11 6 9-4.91V17h2V8L12 2z"/><path d="M6 12.91V17c0 2.21 2.69 4 6 4s6-1.79 6-4v-4.09l-6 3.27-6-3.27z"/></svg>```.text
#let google-scholar-icon(color: luma(40%), height: 0.95em, baseline: 20%) = {
  box(height: height, baseline: baseline, image(bytes(google-scholar-svg.replace("currentColor", color.to-hex()))))
}

#let link-svg = ```
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10 14a5 5 0 0 0 7.07 0l2.83-2.83a5 5 0 1 0-7.07-7.07L11.4 5.5" /><path d="M14 10a5 5 0 0 0-7.07 0L4.1 12.83a5 5 0 1 0 7.07 7.07L12.6 18.5" /></svg>```.text
#let link-icon(color: luma(40%), height: 0.95em, baseline: 20%) = {
  box(height: height, baseline: baseline, image(bytes(link-svg.replace("currentColor", color.to-hex()))))
}

// Manually maintained icon table used by the resume layout.
// Add any extra scienceicons/custom icons here if you want unified defaults.
#let icon-registry = (
  "google-scholar-icon": google-scholar-icon,
  "link-icon": link-icon,
  "linkedin-icon": scienceicons.linkedin-icon,
  "github-icon": scienceicons.github-icon,
  "orcid-icon": scienceicons.orcid-icon,
  "x-icon": scienceicons.x-icon,
)

#let configure-icon-registry(
  registry: icon-registry,
  color: luma(40%),
  height: 0.95em,
  baseline: 20%,
) = {
  let configured = (:)
  for (name, icon-fn) in registry.pairs() {
    configured.insert(
      name,
      icon-fn.with(color: color, height: height, baseline: baseline),
    )
  }
  configured
}
