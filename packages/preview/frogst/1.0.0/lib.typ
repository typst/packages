#let data = (
    "0": "zéro",
    "1": "un",
    "2": "deux",
    "3": "trois",
    "4": "quatre",
    "5": "cinq",
    "6": "six",
    "7": "sept",
    "8": "huit",
    "9": "neuf",
    "10": "dix",
    "11": "onze",
    "12": "douze",
    "13": "treize",
    "14": "quatorze",
    "15": "quinze",
    "16": "seize",
    "20": "vingt",
    "30": "trente",
    "40": "quarante",
    "50": "cinquante",
    "60": "soixante",
    "80": "quatre-vingt",
)


#let powers-of-thousand = (
    // échelle longue
    "1": "mille",       // 1e3
    "2": "million",     // 1e6
    "3": "milliard",    // 1e9
    "4": "billion",     // 1e12
    "5": "billiard",    // 1e15
    "6": "trillion",    // 1e18
    "7": "trilliard",   // 1e21
)


#let calc-n(nb) = {
    // Calcule le nombre termes d'un entier positif
    // - nb : entier positif
    // - out : entier > 0

    // Méthode 1 - maths
    if nb == 0 {
        1
    } else {
        calc.floor(calc.log(base: 10, nb)) + 1
    }
    // Méthode 2 - string
    // str(nb).len()
}


#let dec-repr(nb) = {
    // Renvoie la décomposition décimale sous la forme d'une liste
    //      (poids fort, ..., poids faible)
    // - nb : entier positif
    // - out : liste d'entiers positifs
    //
    // Exemple :
    //   dec-repr(1024)
    //   // (1, 0, 2, 4)

    // Méthode 1 - maths
    range(calc-n(nb)).rev().map(
        x => calc.rem(calc.quo(nb, calc.pow(10, x)), 10)
    )
    // Méthode 2 - string
    // str(nb).clusters().map(int)
}


#let dec-repr-to-nb(nums) = {
    // Calcule un entier depuis sa décomposition décimale
    // - nums : liste d'entiers positifs
    // - out : entier positif
    //
    // Exemple :
    //   dec-repr-to-nb((1, 0, 2, 4))
    //   // 1024

    // Méthode 1 - maths
    nums.rev().enumerate().map(((i, x)) => x * calc.pow(10, i)).sum()
    // Méthode 2 - string
    // int(nums.map(str).sum())
}


#let fr-nb-2digits(values: none, nb) = {
    // Renvoie la dénomination littérale en français de l'entier à deux
    // chiffres `nb`.
    // - `values: none` : décomposition décimale de `nb` si déjà calculée.
    // - `nb` : entier positif à deux chiffres

    // Décomposition décimale de `nb`.
    let values = if values == none { dec-repr(nb) } else { values }

    // Nombre de chiffres de `nb`. Vaut 1 ou 2.
    let N = values.len()

    if N <= 2 {
        // S'il y a bien deux chiffres
        if str(nb) in data.keys() {
            // Si le nombre est directement dans la liste de base.
            let val = data.at(str(nb))

            // Cas unique où il y a un s à la fin de `quatre-vingts`. Il n'y en
            // n'a pas pour les autres nombres, ex `quatre-vingt-sept`.
            val + if nb == 80 { "s" }

        } else {
            // Sinon, nombre composé d’éléments de la liste de base.

            // On récupère les chiffres de la dizaine et de l'unité.
            let (diz, uni) = values

            // Cas particulier pour les dizaines 70 et 90, on fait comme à la
            // dizaine précédente avec + 10 pour les unités.
            if diz in (7, 9) {
                diz -= 1
                uni += 10
            }

            // Séparateur entre la dizaine et l'unité, deux possibilités :
            //  --> ` et `  : 21, 31, ... 61, 71
            //  --> `-` : 81, 91 et toute le reste
            let sep = if diz != 8 and calc.rem(uni, 10) == 1 {
                // Pas besoin de vérifier aussi `diz != 1` et `diz != 9` car
                // - 11 : déjà dans la liste de base, ok
                // - 91 : diz = 8 et uni = 11, ok
                " et "
            } else {
                "-"
            }

            // On rappelle la fonction `fr-nb-2digits` pour `uni` au lieu de
            // directement appeler `data.at(str(unit))` car certains sont
            // encore des composés, comme par exemple uni = 17, 18, 19 pour
            // nb = 77, 97, ...
            data.at(str(10 * diz)) + sep + fr-nb-2digits(uni)
        }
    } else {
        // Si trois chiffres ou plus
        fr-nb(values: values, nb)
    }
}

#let fr-nb-3digits(values: none, nb) = {
    // Renvoie la dénomination littérale en français de l'entier à trois
    // chiffres `nb`.
    // - `values: none` : décomposition décimale de `nb` si déjà calculée.
    // - `nb` : entier positif à trois chiffres

    // Décomposition décimale de `nb`.
    let values = if values == none { dec-repr(nb) } else { values }

    // Nombre de chiffres de `nb`. Vaut 1, 2 ou 3.
    let N = values.len()

    if N <= 2 {
        // Si deux chiffres, ok.
        fr-nb-2digits(values: values, nb)
    } else if N == 3 {
        // Si trois chiffres.

        // Chiffre des centaines
        let cent = values.first()
        if cent == 0 {
            // Dans le cas, on sait jamais où `cent` vaut 0. On évite ainsi
            // tout bug.
            fr-nb-2digits(values: values.slice(1), nb)
        } else {
            // Cas trois chiffres avec `cent` différent de 0.

            // Chiffre des centaines via la liste de base
            let cent = data.at(str(cent))

            // Nombre à deux chiffres qui suit via la fonction `fr-nb-2digits`
            let diz-uni = fr-nb-2digits(
                values: values.slice(1),
                // Reste de la division euclidienne de `nb` par 100
                calc.rem(nb, 100)
            )

            // Tableau des règles. La ligne cent = 0 est prise en compte avant.
            //
            //                         diz-uni
            //              |      0      |      N > 0       |
            //       -------|-------------|------------------|
            //          0   |      -      |      douze       |
            //  cent    1   |    cent     |    cent douze    |
            //        N > 1 | trois cents | trois cent douze |

            // Préfixe et suffixe
            let (pref, suff) = if cent != "un" or diz-uni != "zéro" {
                // Tout sauf le cas en haut à gauche
                (
                    // Préfixe. Si cent > 1, on l'ajoute en préfixe avec un
                    // espace
                    if cent != "un" { cent + " " },
                    // Suffixe. Si diz-uni != 0, alors on l'ajoute en suffixe.
                    // Sinon, on peut mettre le "s".
                    if diz-uni != "zéro" { " " + diz-uni } else { "s" }
                )
            } else {
                // Cas en haut à gauche, c'est juste "cent" en fait.
                (none, none)
            }

            // Résultat
            pref + "cent" + suff
        }
    } else {
        // Si strictement plus que trois chiffres
        fr-nb(values: values, nb)
    }
}

#let fr-nb(nb) = {
    // Renvoie la dénomination littérale en français de l'entier à `nb`.
    // - `nb` : entier positif ou négatif
    // La fonction gère les entiers négatifs en ajoutant simplement 'moins'
    // devant.

    if type(nb) == int {
        // On ne traite que les entiers.

        // Booléen si le nombre est négatif ou non
        let is-negative = nb < 0

        // On passe à la valeur absolue
        let nb = calc.abs(nb)

        // Décomposition décimale de `nb` sous la forme d'une liste
        //      (poids fort, ..., poids faible)
        let values = dec-repr(nb)

        // Nombre de chiffres de `nb`. Est toujours > 0.
        let N = values.len()

        let res = if N <= 3 {
            // Si trois chiffres ou moins, alors on appelle directement la
            // fonction `fr-nb-3digits`.
            fr-nb-3digits(values: values, nb)
        } else {
            // Si strictement plus de trois chiffres.

            // Nombre de puissances de mille
            let P = calc.quo(N - 1, 3)

            if P <= int(powers-of-thousand.keys().last()) {
                // On vérifie que le nombre peut être écrit avec la liste de
                // base des puissances de mille.

                // On itère de p = P à 1 (inclus) par pas de -1.
                // Cela va donc gérer les paquets de trois jusqu'au millier
                // inclus (cf mille p = 1, million p = 2, ...).
                let res = range(P, 0, step: -1).map(p => {
                    // Récupération du facteur mille, million, milliard, ...,
                    // dans la liste de base.
                    let factor = powers-of-thousand.at(str(p))

                    // On récupère la décomposition décimale de cette itération
                    let nums = values.slice(0, -3 * p)
                    nums = if nums.len() > 3 { nums.slice(-3) } else { nums }

                    // Si la décomposition est (0, 0, 0), alors on n'affiche
                    // rien de cette itération. `res` est alors rempli avec un
                    // `none` qui est ensuite filtré.
                    if nums.any(x => x != 0) {
                        // On détermine le texte du nombre à trois chiffres
                        // associé. Il s'agit du préfixe du `factor` auquel on
                        // retire le "s" de "cents" s'il est présent car il y a
                        // toujours le `factor` qui va suivre.
                        let pref = fr-nb-3digits(
                            values: nums,
                            dec-repr-to-nb(nums)
                        ).replace("cents", "cent")

                        // Règles:
                        // - mille *invariable*, pas les autres
                        // - jamais de "un" devant mille, pas les autres

                        //                         factor
                        //              |    mille    |  million, ...  |
                        //       -------|-------------|----------------|
                        //          0   |      -      |        -       |
                        //  pref    1   |    mille    |   un million   |
                        //        N > 1 | trois mille | trois millions |

                        // Équivalent du tableau ci-dessus. Le cas pref = 0 est
                        // déjà pris en compte.
                        if p > 1 or pref != "un" {
                            // Tout, sauf le cas en haut à gauche.
                            pref + " " + factor + {
                                // On ajoute un "s" à la fin uniquement si pas
                                // "mille" et si pref différent de "un".
                                if p > 1 and pref != "un" { "s" }
                            }
                        } else {
                            // Cas en haut à gauche.
                            // p = 1 et pref = "un", donc juste "mille" en
                            // fait.
                            factor
                        }
                    }

                // On enlève les 'none'. Le fait de mettre à la place du 'none'
                // un caractère vide "" sans le filtre ne fonctionnerait pas
                // car on aurait deux fois le séparateur " ".
                }).filter(x => x != none).join(" ")

                // Ajout de la dernière itération (p = 0) où il n'y pas de
                // suffixe. On récupère sa décomposition décimale.
                let nums = values.slice(-3)

                // On l'ajoute uniquement si tous les éléments de la
                // décomposition sont différents de 0, ie si le nombre à trois
                // chiffres est différent de 0.
                res += if nums.any(x => x != 0) {
                    " " + fr-nb-3digits(values: nums, dec-repr-to-nb(nums))
                }

                // Résultat final
                res
            }
        }

        // Ajout de "moins" dans le cas négatif
        if is-negative { "moins " } + res
    }
}


#let fr-int(nb) = {
    // Écrit un entier avec des espaces fines tous les trois chiffres
    if type(nb) == int {
        // On ne traite que les entiers.

        // Booléen si le nombre est négatif ou non
        let is-negative = nb < 0

        // On passe à la valeur absolue
        let nb = calc.abs(nb)

        // Décomposition décimale de `nb` sous la forme d'une liste
        //      (poids fort, ..., poids faible)
        let values = dec-repr(nb)

        // Nombre de chiffres de `nb`. Est toujours > 0.
        let N = values.len()

        let res = if N <= 3 {
            // Si moins de trois chiffres, alors pas d'espace
            $#nb$
        } else {
            // Nombre de groupes de trois termes
            // Ex : 12029 --> 12 029
            //            --> deux groupes : P = 2
            //            et first = len(12) = 2
            let P = calc.quo(N - 1, 3) + 1

            // first : nombre d'éléments dans le groupe du tout début. Peut
            // être 1, 2 ou 3.
            let first = calc.rem(N, 3)
            first = if first == 0 { 3 } else { first }

            // Compliqué, mais fonctionnel. On construit les groupes de trois
            // en fonction de la valeur de `first`, puis on les joint avec une
            // espace fine insécable.
            range(P)
                .map(
                    i => values
                        .slice(
                            // Dans le cas ou first < 3, pour le premier groupe
                            // (i = 0), il nous faut la valeur 0.
                            calc.max(0, 3 * (i - 1) + first),
                            3 * i + first
                        )
                        .map(str)
                        .join()
                )
                .map(x => $#x$)
                .join(math.thin)
        }
        // Dans le cas négatif. Faut-il un `thin` ?
        if is-negative { $- thin$ } + res
    }
}
