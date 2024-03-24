#import "../settings/styles.typ": *


#let renderSkills(skills: ()) = {
  for skill in skills {
    box(
      rect(
        stroke: skillsStyle.stroke,
        radius: skillsStyle.radius, 
        skill
      )
    )
    h(skillsStyle.margins.betweenSkillTags)
  }
}