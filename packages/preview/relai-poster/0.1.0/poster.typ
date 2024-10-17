#import "relai_poster_template.typ": poster
#show: doc => poster(
  doc,
  text("Example title", size: 60pt, weight: "bold"),
  flipped: false, // change for landscape
  n_columns: 2,
  authors: (
    ("name": "Max Mustermann", "affiliation": "TUM", "email": "max.mustermann@tum.de"),
    ("name": "Erika Musterfrau", "affiliation": "LMU", "email": "erika.musterfrau@lmu.de"),
  ),
  references: (
    ("url": "https://zuseschoolrelai.de", "label": "zuseschoolrelai.de"),
    //("url": "https://arxiv.org/abs/...", "label": "ArXiv"),
  ),
  font_size: 30pt,
)

= Example section
#lorem(200)

= Example section
#lorem(100)