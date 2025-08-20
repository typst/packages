#let first-name = "Miles"
#let last-name = "Dyson"
#let sub-title = ""
#let profile-image = "template/img/portrait.png"
#let language = "en"


#if language == "en" {
  sub-title = "Software Engineer with a knack for human-friendly AI solutions"
} else if language == "es" {
  sub-title = "Ingeniero de software con un talento para soluciones de IA centradas en el usuario"
}

#let info = (
  address: "Los Angeles, CA",
  telephone: "+1 (555) 123-4567",
  email: "m.dyson@skynet.ai",
  linkedin: "linkedin.com/in/milesdyson",
  github: "github.com/skynetguy",
)


