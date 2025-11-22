#let get-person-by-name(geneal, name) = {
    geneal.persons.filter(el => {el.name == name}).at(0)
}

#let get-generation(geneal, name, level: 0) = {
    // Default : if no generation set and no parent found for person neither for its partners : 1
    let person = get-person-by-name(geneal, name)
    if person.generation != none {person.generation + level}
    else {
        if person.parents-names != none {
            let parent-name = person.parents-names.at(0)
            level = level + 1
            get-generation(geneal, parent-name, level: level)
        } else if person.partners-names == () {1 + level} else {
            let partners = person.partners-names.map(
                el => {get-person-by-name(geneal, el)}
            )
            if partners.any(el => {el.generation != none}) {
                let partners-with-generation = partners.filter(
                    el => {el.generation != none}
                )
                return partners-with-generation.at(0).generation
            }
            let partners-with-parents = partners.filter(
                el => {el.parents-names != none}
            )
            if partners-with-parents == () {1 + level} else {
                get-generation(
                    geneal, partners-with-parents.at(0).name, level: level
                )
            }
        }
    }
}

#let set-generations(geneal) = {
    geneal.persons = geneal.persons.map(
        el => {if el.generation != none {
            el
        } else {
            el.insert("generation", get-generation(geneal, el.name))
            el
        }}
    )
    geneal.unions = geneal.unions.map(
        el => {
            let parent = get-person-by-name(
                geneal,
                el.parents-names.at(0),
            )
            let generation = parent.generation
            el.insert("parents-generation", generation)
            el
        }
    )
    return geneal
}
// On centre toujours les descendants. On rapproche frères et soeurs au plus proche sans clash.

// A chaque génération, on note les coordonnées minimales (= à gauche) et maximales (= à droite) par rapport aux parents. On crée un array de dict(l: , r: ) nommé size, et un dict(nom: spacing) d'espacement après chaque enfant, nommé spacings.

// Si aucun enfant n'a d'enfant : gauche  = -nb-enfants*4/2 et droite = nb-enfants*4/2.
// taille-fratrie = nb-enfants*4
// espacements : 4 pour chaque

// Ensuite s'il y a un seul enfant qui a des enfants :
// taille-fratrie = (nb-enfants + 1)*4
// A la génération -1, g--1 = -taille-fratrie/2, d--1 = taille-fratrie/2
// pos-union-enfant = -taille-fratrie/2 + (index(enfant) + 1)*4
// Pour les générations suivantes on join à (l: g--1, r: d--1) l'array de l'enfant, en mettant à jour les entrées en leur ajoutant pos-union-enfant
// gauche = pos-union-enfant + gauche de l'enfant
// droite = pos-union-enfant + droite de l'enfant
// espacements : 4 pour chaque et 8 pour celui qui a des enfants.

// Si deux enfants au moins ont des enfants :
// On regarde s'il a fallu les décaler, c'est à dire s'il y a eu clash.
// On parcourt la liste des enfants qui ont des enfants pour trouver leur espacement les uns par rapport au suivant :
// On parcourt les enfant qui ont des enfants depuis la fin. Pour chacun, on regarde l'espacement aux suivants :
// On somme le droite du 1er et le gauche du second à chaque génération, on prend le max.
// Si ce max est inférieur à leur espacement, on compte leur espacement.
// S'il est supérieur à leur espacement, on compte ce max.
// On rentre les espacements dans un dict (nom: espacement)
// On calcule la taille de la fratrie : somme des espacements.
// pos-union-enfant = espacement + 4 - taille-fratrie/2
// A la génération -1, g--1 = -taille-fratrie/2, d--1 = taille-fratrie/2.
// A la génération -2, g--2 = pos-union-enfant-1er + gauche-enfant-1er, d--2 = pos-union-enfant-dernier + droite-enfant-dernier.
// Pour les générations suivantes on join à (l: g--1, r: d--1) l'array des enfants, en mettant à jour les entrées en leur ajoutant pos-union-enfant. Le 1er enfant donne les l: et le dernier les r:
// gauche = pos-union-enfant-1er + gauche du 1er enfant
// droite = pos-union-enfant-dernier + droite du dernier enfant
// On retourne l'array de dicts (l: , r: ) et le dict de spacings.

#let set-subtree-unions(geneal) = {
    for union in geneal.unions {
        let union-index = geneal.unions.position(el => {
            el.parents-names == union.parents-names
        })
        let parent0 = get-person-by-name(geneal, union.parents-names.at(0))
        let parent1 = get-person-by-name(geneal, union.parents-names.at(1))
        if parent0.parents-names != none and parent1.parents-names != none {
            geneal.unions.at(union-index).insert("subtree", true)
        } else {
            geneal.unions.at(union-index).insert("subtree", false)
        }
    }
    geneal
}

#let get-descendants(geneal, union) = {
    let descs-names = ()
    let children = union.children-names.map(el => {
        get-person-by-name(geneal, el)
    })
    for child in children {
        descs-names.push(child.name)
        if child.partners-names != none {
            for partner-name in child.partners-names {
                let child-union = geneal.unions.filter(el => {
                    child.name in el.parents-names and partner-name in el.parents-names
                }).at(0)
                descs-names += get-descendants(geneal, child-union)
            }
        }
    }
    descs-names
}

#let get-unions-spacing(geneal, union1, union2) = {
    // union 1 is at the left of union2
    // Extract first union rights and second union lefts at corresponding generations, and get the max distance. Unions must have overlapping generations.
    let union1-gens = range(
        union1.parents-generation + 1,
        union1.parents-generation + union1.size.len() + 1
    )
    let union2-gens = range(
        union2.parents-generation + 1,
        union2.parents-generation + union2.size.len() + 1
    )
    let unions-gens = union1-gens.filter(el => {el in union2-gens})
    let union1-rights = union1.size.map(el => {el.r})
    let union2-lefts = union2.size.map(el => {- el.l})
    
    // First check if the two unions have married descendants
    let unions1-descs = get-descendants(geneal, union1)
    let unions2-descs = get-descendants(geneal, union2)
    let subtree-unions = geneal.unions.filter(el => {
        el.subtree and (
            (
                el.parents-names.at(0) in unions1-descs and el.parents-names.at(1) in unions2-descs
            ) or (
                el.parents-names.at(1) in unions1-descs and el.parents-names.at(0) in unions2-descs
            )
        )
    })
    if subtree-unions != () {
        // if the two unions have subtrees, distance between them is the max between the necessary distance outside of the subtree and the position of the subtree union. -> prevents calculating double subtree size. Parents of the subtree must be at the right of the first union and at the left of the second.
        for sub-union in subtree-unions {
            let sub-union-gens = range(
                sub-union.parents-generation,
                sub-union.parents-generation + sub-union.size.len() + 1
            )
            for gen in sub-union-gens {
                union1-rights.at(
                    gen - union1.parents-generation - 1
                ) = union1-rights.at(
                    gen - union1.parents-generation - 1
                ) - sub-union.size.at(
                    gen - sub-union.parents-generation - 1,
                    default: geneal.config.siblings-dist
                ).r - geneal.config.siblings-dist/2
                union2-lefts.at(
                    gen - union2.parents-generation - 1
                ) = union2-lefts.at(
                    gen - union2.parents-generation - 1
                ) - sub-union.size.at(
                    gen - sub-union.parents-generation - 1,
                    default: geneal.config.siblings-dist
                ).l - geneal.config.siblings-dist/2
            }
        }
    }
    let union1-rights = union1-rights.slice(
        unions-gens.at(0) - union1.parents-generation - 1,
        unions-gens.at(-1) - union1.parents-generation
    )
    let union2-lefts = union2-lefts.slice(
        unions-gens.at(0) - union2.parents-generation - 1,
        unions-gens.at(-1) - union2.parents-generation
    )
    let spacing = calc.max(
        ..union1-rights.zip(union2-lefts).map(el => {
            el.sum()
        })
    )
    return spacing
}

#let get-union-sizes-compact(geneal, union) = {
    let children = union.children-names.map(el => {
        get-person-by-name(geneal, el)
    })
    let with-childs = children.filter(el => {el.partners-names != ()})
    let spacings = children.map(el => {
        if el in with-childs {(el.name, geneal.config.siblings-dist*2)} else {(el.name, geneal.config.siblings-dist)}
    }).fold(
        (:),
        (dict, el) => {
            dict.insert(el.at(0), el.at(1))
            dict
        }
    )

    if with-childs.len() == 0 {
        // if no child is a parent
        (
            size: (
                (
                    l: -spacings.values().sum()/2,
                    r: spacings.values().sum()/2
                ),
            ),
            spacings: spacings
        )
    } else if with-childs.len() == 1 {
        // if only one child is a parent
        let sib-size = spacings.values().sum()
        let g1 = ((l: -sib-size/2, r: sib-size/2),)
        let child-index = union.children-names.position(el => {
            el == with-childs.at(0).name
        })
        let child-union-pos = -sib-size/2 + (child-index + 1)*geneal.config.siblings-dist // position relative to parents union center
        let union-sizes = geneal.unions.filter(el => {
            with-childs.at(0).name in el.parents-names
        }).at(0).size.map(el => {
            (l: el.l + child-union-pos, r: el.r + child-union-pos)
        })
        (size: g1 + union-sizes, spacings: spacings)
    } else {
        // if more than one child is a parent
        // calculate spacings between siblings
        for child in with-childs.slice(0, -1).rev() {
            // First we check if there is a clash at lower generation, 
            let child-pos = with-childs.position(el => {el == child})
            let child-spacings = ()
            for next-child in with-childs.slice(child-pos + 1) {
                let child-union = geneal.unions.filter(el => {
                    child.name in el.parents-names
                }).at(0)
                let next-child-union = geneal.unions.filter(el => {
                    next-child.name in el.parents-names
                }).at(0)
                // Calculate distance between the two unions centers.
                let min-nescess-dist = get-unions-spacing(
                    geneal,
                    child-union,
                    next-child-union
                )
                // calculate distance between unions center if no clash
                let child-pos-sibs = children.position(el => {el == child})
                let next-child-pos-sibs = children.position(el => {el == next-child})
                let between-dist = spacings.values().slice(
                    child-pos-sibs, next-child-pos-sibs
                ).sum(default: 0)
                // Keep the max between the two distances
                let spacing = calc.max(between-dist, min-nescess-dist) - (between-dist - geneal.config.siblings-dist*2)
                child-spacings.push(spacing)
            }
            let child-spacing = calc.max(..child-spacings)
            spacings.insert(child.name, child-spacing)
        }
        
        // calculate unions siblings size
        let siblings-size = spacings.values().sum()
        let g1 = ((l: -siblings-size/2, r: siblings-size/2),)

        // Calculate sizes relative to the parents
        let relsizes = ()
        for child in with-childs {
            let child-union = geneal.unions.filter(el => {
                child.name in el.parents-names
            }).at(0)
            let child-pos = union.children-names.position(el => {
                el == child.name
            })
            let relpos = spacings.values().slice(0, child-pos).sum(default: 0) - siblings-size/2 + geneal.config.siblings-dist // + siblings-dist to be in the middle of the union
            let relsize = child-union.size.map(el => {
                (l: el.l + relpos, r: el.r + relpos)
            })
            relsizes.push(relsize)
        }
        
        // Make all sizes array the same length
        let max-depth = calc.max(..relsizes.map(el => {el.len()}))
        let relsizes = relsizes.map(el => {
            if el.len() < max-depth {
                el + ((l: none, r: none),)*(max-depth - el.len())
            } else {el}
        })
        
        // Calculate union size : left as the min and right as the max of the sizes relative to the parents between generations.
        let union-sizes = ()
        for depth in range(max-depth) {
            let min-left = calc.min(
                ..relsizes.map(el => {
                    el.at(depth).l
                }).filter(el => {el != none})
            )
            let max-right = calc.max(
                ..relsizes.map(el => {
                    el.at(depth).r
                }).filter(el => {el != none})
            )
            union-sizes.push((l: min-left, r: max-right))
        }
        (size: g1 + union-sizes, spacings: spacings)
    }
}

#let set-unions-sizes-compact(geneal) = {
    // On parcourt les unions à partir de la plus haute génération, on calcule les tailles et on les set
    for union in geneal.unions.sorted(key: el => {
        -el.parents-generation
    }) {
        let size = get-union-sizes-compact(geneal, union).size
        let spacings = get-union-sizes-compact(geneal, union).spacings
        let union-index = geneal.unions.position(el => {
            el.parents-names == union.parents-names
        })
        geneal.unions.at(union-index).insert("size", size)
        geneal.unions.at(union-index).insert("spacings", spacings)
    }
    geneal
}

#let get-union-size-wide(geneal, union) = {
    // Attention, à appliquer à une union dont toutes les tailles des unions des enfants sont connues
    // minimum 7 cm. Un enfant sans partner vaut 4. Avec partner : on prend la taille de l'union.
    // on crée un array avec les tailles alouées à chaque enfant, on somme les tailles, et on prend le maximum entre la valeur obtenue et 7.
    let children-size = union.children-names.map(child-name => {
        let child = get-person-by-name(geneal, child-name)
        if child.partners-names == () {
            geneal.config.siblings-dist
        } else {
            geneal.unions.filter(union => {
                child-name in union.parents-names
            }).map(union => {
                union.size
            }).sum()
        }
    }).sum()
    return calc.max(geneal.config.siblings-dist*2, children-size)
}

#let set-unions-sizes-wide(geneal) = {
    // On parcourt les unions à partir de la plus haute génération, on calcule les tailles et on les set
    for union in geneal.unions.sorted(key: el => {
        -el.parents-generation
    }) {
        let size = get-union-size-wide(geneal, union)
        let union-index = geneal.unions.position(el => {
            el.parents-names == union.parents-names
        })
        geneal.unions.at(union-index).insert("size", size)
    }
    geneal
}

#let get-root-couples(geneal) = {
    let root-names = geneal.persons.filter(el => {
        el.parents-names == none
    }).map(el => {
        el.name
    })
    let parent-names = geneal.unions.map(el => {
        el.parents-names
    })
    return parent-names.filter(el => {
        el.at(0) in root-names and el.at(1) in root-names
    })
}

#let get-root-spacings(geneal) = {
    // Returns a dict of root-couple.join(): spacing to add after the couple
    let root-couples = get-root-couples(geneal)
    let spacings = (:)
    if root-couples.len() > 1 {
        for root-couple in root-couples.slice(0, -1).rev() {
            let couple-spacings = ()
            let couple-index = root-couples.position(el => {el == root-couple})
            let root-union = geneal.unions.filter(el => {
                    root-couple == el.parents-names
            }).at(0)
            for next-root-couple in root-couples.slice(couple-index + 1) {
                let next-couple-index = root-couples.position(el => {
                    el == next-root-couple
                })
                let next-root-union = geneal.unions.filter(el => {
                    next-root-couple == el.parents-names
                }).at(0)
                // Calculate distance between the two unions centers.
                let min-nescess-dist = get-unions-spacing(
                    geneal,
                    root-union,
                    next-root-union
                )
                // enter couple spacing in spacings if no clash : distance with next
                if next-couple-index - couple-index == 1 {
                    spacings.insert(root-couple.join(), min-nescess-dist)
                }
                // calculate distance between couples
                let roots-between = root-couples.slice(
                    couple-index,
                    next-couple-index
                )
                let between-dist = roots-between.map(el => {
                    spacings.at(el.join())
                }).sum(default: 0)
                // Keep the max between the two distances
                let couple-spacing = calc.max(between-dist, min-nescess-dist) - between-dist + spacings.at(root-couple.join())
                couple-spacings.push(couple-spacing)
            }
            let max-couple-spacing = calc.max(..couple-spacings)
            spacings.insert(root-couple.join(), max-couple-spacing)
        }
    }
    spacings
}
