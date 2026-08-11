#let select-faculty-logo(
  faculty: none,
  ..kwargs
) = {
  if faculty == none {
    return none
  }
  let fclty = upper(faculty)
  if text.lang == "nl" {
    image("icoon_UGent_"+fclty+"_NL_RGB_2400_kleur.png",
          alt: "Logo van de faculteit",
	        ..kwargs)
  } else /*any other lang, assume english logos*/ {
    image("icon_UGent_"+fclty+"_EN_RGB_2400_color.png",
	        alt: "Faculty logo",
          ..kwargs)
  }
}


#let select-ugent-logo(
  ..kwargs
) = {
  if text.lang == "nl" {
    image("logo_UGent_NL_RGB_2400_kleur.png",
          alt: "Logo universiteit Gent",
          ..kwargs)
  } else /*any other lang, assume english logos*/ {
    image("logo_UGent_EN_RGB_2400_color.png",
          alt:"Ghent university logo",
          ..kwargs)
  }
}
