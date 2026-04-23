// Configuration centralisée du rapport
// Modifiez uniquement ces 2 structures pour tout configurer ⬇️

// 1️⃣ CONFIGURATION PRINCIPALE
#let config = (
  cours: "nom_du_cours",
  titre: "titre",
  sous-titre: "sous-titre",
  filiere: "Système industriel",
  version: "1.1",
  date: datetime.today().display("date"),
  language: "fr",
  logo: "logo Hes.png",
  cover-image: "logo_photo.png",
  size-image: 140pt,
  titre-image: "titre",
  afficher-glossaire: true,
  afficher-annexes: true,
  afficher-bibliographie: true,
  afficher-numéros-équations: true,
)

// 2️⃣ AUTEURS (active: true/false pour ajouter/enlever)
#let auteurs = (
  (
    active: true,
    prenom: "Amaury",
    nom: "Wailliez",
    abreviation: "A.W",
    email: "amaury.wailliez@hes-so.ch",
    signature: "signature.png",
  ),
  (
    active: false,
    prenom: "Deuxième",
    nom: "Auteur",
    abreviation: "D.A",
    email: "exemple@hes-so.ch",
    signature: "signature.png",
  ),
  // possibilé de rajouter plusieurs élève
)

// 3️⃣ PROFESSEURS (active: true/false pour ajouter/enlever)
#let professeurs = (
  (
    active: true,
    prenom: "PPrénom",
    nom: "Nom",
    email: "exemple@hes-so.ch",
  ),
  //possibilité de mettre plusieur professeurs
)


