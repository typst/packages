#import "../template/settings/styles.typ": *


#let render-skills(
  styles: (),
  skills: (),
) = {
  for skill in skills {
    box(
      rect(
        stroke: styles.skills-style.stroke,
        radius: styles.skills-style.radius,
        skill,
      ),
    )
    h(styles.skills-style.margins.between-skill-tags)
  }
}
