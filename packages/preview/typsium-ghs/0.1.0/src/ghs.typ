#let validate-index(index)={
  if type(index) == str{
    return int(index.find(regex("\d+")))
  }else if type(index) == int{
    return index
  }
  return 1
}

#let ghs-info=(
  GHS01:(name:"Explosive",image:"resources/ghs-pictograms/GHS01.svg", usage:("Unstable explosives", "Explosives", "Self-reactive substances and mixtures", "Organic peroxides")),
  GHS02:(name:"Flammable",image:"resources/ghs-pictograms/GHS02.svg", usage: ("Flammable gases", "Flammable aerosols", "Flammable liquids", "Flammable solids", "Self-reactive substances and mixtures", "Pyrophoric liquids", "Pyrophoric solids", "Combustible solids", "Combustible liquids", "Self-heating substances and mixtures", "Substances and mixtures, which in contact with water, emit flammable gases", "Organic peroxides")),
  GHS03:(name:"Oxidizing",image:"resources/ghs-pictograms/GHS03.svg", usage:("Oxidizing gases", "Oxidizing liquids", "Oxidizing solids")),
  GHS04:(name:"Compressed Gas",image:"resources/ghs-pictograms/GHS04.svg", usage:("Compressed gases", "Liquefied gases", "Refrigerated liquefied gases", "Dissolved gases")),
  GHS05:(name:"Corrosive",image:"resources/ghs-pictograms/GHS05.svg", usage:("Corrosive to metals", "Skin corrosion", "Serious eye damage")),
  GHS06:(name:"Toxic",image:"resources/ghs-pictograms/GHS06.svg", usage:("Acute toxicity (oral, dermal, inhalation)",)),
  GHS07:(name:"Health Hazard",image:"resources/ghs-pictograms/GHS07.svg", usage:("Acute toxicity (oral, dermal, inhalation)", "Skin irritation", "Eye irritation", "Skin sensitization", "Specific target organ toxicity following single exposure", "Respiratory tract irritation", "Narcotic effects")),
  GHS08:(name:"Serious Health hazard",image:"resources/ghs-pictograms/GHS08.svg", usage:("Respiratory sensitization", "Germ cell mutagenicity", "Carcinogenicity", "Reproductive toxicity", "Specific target organ toxicity following single exposure", "Specific target organ toxicity following repeated exposure", "Aspiration hazard")),
  GHS09:(name:"Toxic",image:"resources/ghs-pictograms/GHS09.svg", usage:("Acute hazards to the aquatic environment", "Chronic hazards to the aquatic environment")),
)

#let ghs(
  icon,
  width:auto,
  height:auto,
  fit: "cover",
)={
  let index = calc.clamp(validate-index(icon), 1, 9)
  
  image("resources/ghs-pictograms/GHS0" + str(index) + ".svg", height: height, width: width, alt: ghs-info.at("GHS0"+ str(index)).name + " sign", fit: fit)
}