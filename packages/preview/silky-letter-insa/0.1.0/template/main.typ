#import "@local/silky-letter-insa:0.1.0": *
#show: doc => insa-short(
  author: [
    NOM Prénom\
    Rôle / Département
  ],
  date: datetime.today(), // can be replaced by a real date i.e. "23/03/2024"
  doc
)
  
// texte