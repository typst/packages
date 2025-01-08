#import "@preview/t4t:0.3.2": *

#let get-person-by-name(geneal, name) = {
    geneal.persons.filter(el => {el.name == name}).at(0)
}

#let partners-names(person, filter: none) = {
    let partners = person.partners-names.filter(el => {
        if filter in ("l", "r") {
            el.at(1) == filter
        } else {true}
    }).map(el => {
        el.at(0)
    })
    partners
}

#let get-generation(geneal, name, level: 0) = {
    // Default : if no generation set and no parent found for person neither for its partners : 1
    // If implementing unions at different generation : priority = generation set by filiation, then by marriage. If union with several persons at different generations, set to the oldest. Need to take care that no impact of the order of resolving generation : resolve generation of all partners and keep the min.
    // If the default doesn't suit user's need, can set it manually. Must ensure that can't set both parents and generation, or at least that it has no effect, parents preceed.
    let person = get-person-by-name(geneal, name)
    if person.generation != none {person.generation + level}
    else {
        if person.parents-names != none {
            let parent-name = person.parents-names.at(0)
            level = level + 1
            get-generation(geneal, parent-name, level: level)
        } else if partners-names(person) == () {1 + level} else {
            let partners = partners-names(person).map(
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
        if partners-names(child) != none {
            for partner-name in partners-names(child) {
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
                    default: (r: geneal.config.siblings-dist)
                ).r
                union2-lefts.at(
                    gen - union2.parents-generation - 1
                ) = union2-lefts.at(
                    gen - union2.parents-generation - 1
                ) + sub-union.size.at(
                    gen - sub-union.parents-generation - 1,
                    default: (l: geneal.config.siblings-dist)
                ).l
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

#let is-remarriage(geneal, union) = {
    let parent0 = get-person-by-name(geneal, union.parents-names.at(0))
    let parent1 = get-person-by-name(geneal, union.parents-names.at(1))

    let parent0-remarr = if partners-names(parent0, filter: "l") == () {
        parent1.name != partners-names(parent0).at(0)
    } else {true}
    let parent1-remarr = (
        parent0.name != partners-names(parent1, filter: "l").last()
    )
    (parent0.name: parent0-remarr, parent1.name: parent1-remarr)
}

#let make-union-label(parents-names) = {
    parents-names.sorted().join("__u__")
}

#let get-names-from-label(u-label) = {
    let first-name = u-label.replace(regex("__u__.*$"), "")
    let last-name = u-label.replace(regex("^.*__u__"), "")
    return (first-name, last-name)
}

#let get-spacings(geneal, unions, sib-spacings: (:)) = {
    let spacings = (:)
    let spacings = if sib-spacings == (:) {
        for union in unions {
            let spacing = if is-remarriage(
                geneal,
                union
            ).values().any(el => {el}) {
                2*geneal.config.siblings-dist
            } else {
                2*geneal.config.siblings-dist
            }
            spacings.insert(
                make-union-label(union.parents-names),
                spacing
            )
            spacings
        }
    } else {sib-spacings}
    
    if unions.len() == 0 {
        return (:)
        
    } else if unions.len() == 1 {
        return (make-union-label(unions.at(0).parents-names): 0)
        
    } else {
        for union in unions.slice(0, -1).rev() {
            let union-num = unions.position(el => {
                el.parents-names == union.parents-names
            })

            // First we check if there is a clash at lower generation, 
            let union-spacings = ()
            for next-union in unions.slice(union-num + 1) {
                // Calculate distance between the two unions centers.
                let min-nescess-dist = get-unions-spacing(
                    geneal,
                    union,
                    next-union
                )
                
                // calculate distance between unions center if no clash
                let union-pos = spacings.keys().position(el => {
                    el == make-union-label(union.parents-names)
                })
                let next-union-pos = spacings.keys().position(el => {
                    el == make-union-label(next-union.parents-names)
                })
                let between-dist = spacings.values().slice(
                    union-pos, next-union-pos
                ).sum(default: 0)
                
                // Keep the max between the two distances
                let union-base-spacing = spacings.values().at(union-pos)
                let spacing = calc.max(between-dist, min-nescess-dist) - (between-dist - union-base-spacing)
                union-spacings.push(spacing)
            }
            
            let union-spacing = calc.max(..union-spacings)
            spacings.insert(
                make-union-label(union.parents-names),
                union-spacing
            )
        }
        return spacings
    }
}

#let get-union-sizes-compact(geneal, union) = {
    let children = union.children-names.map(el => {
        get-person-by-name(geneal, el)
    })
    let married = children.filter(el => {partners-names(el) != ()})
    // initiate basic spacings dict. Spacing is the distance between the left of a child and the left of the next child. If the child has partners, their spacings are stored with they key child-name + __u__ + partner-name.
    let spacings = (:)
    if children.len() == 0 {
        return (
            size: ((l: 0, r: 0),), spacings: (:)
        )
    }
    for child in children {
        if child in married {
            for partner-name in partners-names(child) {
                let child-u-lab = make-union-label((child.name, partner-name))
                let child-union = geneal.unions.find(el => {
                    child-u-lab == make-union-label(el.parents-names)
                })
                let spacing = if is-remarriage(
                    geneal,
                    child-union
                ).values().any(el => {el}) {
                    2*geneal.config.siblings-dist
                } else {
                    2*geneal.config.siblings-dist
                }
                spacings.insert(
                    make-union-label((child.name, partner-name)),
                    spacing
                )
            }
        } else {
            spacings.insert(child.name, geneal.config.siblings-dist)
        }
    }

    if married.len() == 0 {
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
    } else if (
        married.len() == 1 and partners-names(married.at(0)).len() == 1) {
        // if only one child is a parent with only one marriage.
        let sib-size = spacings.values().sum()
        let g1 = ((l: -sib-size/2, r: sib-size/2),)
        let child-index = union.children-names.position(el => {
            el == married.at(0).name
        })
        let child-union-pos = -sib-size/2 + (child-index + 1)*geneal.config.siblings-dist // position relative to parents union center
        let union-sizes = geneal.unions.filter(el => {
            married.at(0).name in el.parents-names
        }).at(0).size.map(el => {
            (l: el.l + child-union-pos, r: el.r + child-union-pos)
        })
        (size: g1 + union-sizes, spacings: spacings)
    } else {
        // if more than one union among children : more than one child is a parent or at least one child with a remarriage.
        // Cycle through all unions : multiple unions of the different children.
        // calculate spacings between unions
        // from these spacings, calculate spacings between the different partners of a child, and between children (~= sum of spacings between partners)
        let children-unions-unsrt = geneal.unions.filter(un => {
            union.children-names.any(cn => {cn in un.parents-names})
        })
        let children-unions = ()
        for child-name in union.children-names {
            let child = get-person-by-name(geneal, child-name)
            for partner-name in partners-names(child) {
                children-unions.push(children-unions-unsrt.find(el => {
                    child-name in el.parents-names and partner-name in el.parents-names
                }))
            }
        }

        let act_spacings = get-spacings(
            geneal,
            children-unions,
            sib-spacings: spacings
        )
        let spacings = act_spacings
        
        // calculate unions siblings size
        let siblings-size = spacings.values().sum()
        let g1 = ((l: -siblings-size/2, r: siblings-size/2),)

        // Calculate sizes relative to the parents
        let relsizes = ()
        for child-union in children-unions {
            let union-pos = spacings.keys().position(el => {
                el == make-union-label(child-union.parents-names)
            })
            let relpos = spacings.values().slice(0, union-pos).sum(default: 0) - siblings-size/2 + geneal.config.siblings-dist // + siblings-dist to be in the middle of the union
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

#let get-root-unions(geneal) = {
    let root-names = geneal.persons.filter(el => {
        el.parents-names == none
    }).map(el => {
        el.name
    })
    let parent-names = geneal.unions.map(el => {
        el.parents-names
    })
    let root-couples = parent-names.filter(el => {
        el.at(0) in root-names and el.at(1) in root-names
    })
    return geneal.unions.filter(el => {
        root-couples.any(coup => {
            make-union-label(coup) == make-union-label(el.parents-names)
        })
    })
}

#let get-root-spacings(geneal) = {
    // Returns a dict of root-couple.join(): spacing to add after the couple
    let root-unions = get-root-unions(geneal)
    return get-spacings(geneal, root-unions)
}

#let set-person-coords(geneal, person-name, coord) = {
    let person-pos = geneal.persons.position(el => {el.name == person-name})
    geneal.persons.at(person-pos).coords = coord
    geneal
}

#let set-union-coords(geneal, parents-names, coord) = {
    let union-pos = geneal.unions.position(el => {
        make-union-label(el.parents-names) == make-union-label(parents-names)
    })
    geneal.unions.at(union-pos).coords = coord
    geneal
}

#let get-spacings-coords(geneal, u-spacings: none, parents-union: none) = {
    let coords = (persons: (:), unions: (:))
    
    let spacings = if u-spacings == none {
        parents-union.spacings
    } else {
        u-spacings
    }
    
    let radius = geneal.config.person-radius
    let botline = geneal.config.person-botline
    let topline = geneal.config.person-topline
    let vline = geneal.config.union-vline
    let sib-dist = geneal.config.siblings-dist
    let u-dist = geneal.config.union-dist
    let gen-height = radius*2 + botline + vline + topline

    let u-left-x = if parents-union == none {
        - sib-dist
    } else {
        parents-union.coords.at(0) + parents-union.size.at(0).l
    }

    for lab in spacings.keys() {
        // If the item in the spacings array corresponds to a person
        if not lab.contains("__u__") {
            let person = get-person-by-name(geneal, lab)
            let p-spacing-pos = spacings.keys().position(el => {
                el == lab
            })
            let p-spacing = spacings.values().slice(0, p-spacing-pos).sum(
                default: 0
            )
            coords.persons.insert(
                lab,
                (
                    u-left-x + p-spacing + sib-dist/2,
                    - gen-height*(person.generation - 1)
                )
            )

        // else if the item corresponds to an union
        } else {
            let union = geneal.unions.find(el => {
                make-union-label(el.parents-names) == lab
            })
            let u-spacing-pos = spacings.keys().position(el => {
                el == lab
            })
            let parent0 = get-person-by-name(
                geneal,
                union.parents-names.at(0)
            )
            let parent1 = get-person-by-name(
                geneal,
                union.parents-names.at(1)
            )
            let union-spacing = if (
                parent0.coords != none and parent1.coords != none
            ) {
                (parent0.coords.at(0) + parent1.coords.at(0))/2
            } else {
                spacings.values().slice(
                    0,
                    u-spacing-pos
                ).sum(default: 0)
            }

            if union.coords == none and lab not in coords.unions.keys() {
                coords.unions.insert(
                    lab,
                    (
                        u-left-x + union-spacing + sib-dist,
                        - gen-height*(parent0.generation - 1)
                    )
                )
            }
            
            if parent0.coords == none and parent0.name not in coords.persons.keys() {
                coords.persons.insert(parent0.name,
                    (
                        coords.unions.at(lab).at(0) - u-dist/2,
                        - gen-height*(union.parents-generation - 1)
                    )
                )
            }

            if parent1.coords == none and parent1.name not in coords.persons.keys() {
                let parent1-lefts = partners-names(parent1, filter: "l")
                let spacings-p = spacings.pairs()
                let last-left-pos = spacings-p.position(el => {
                    let u-lab = get-names-from-label(el.at(0))
                    parent1-lefts.last() in u-lab and parent1.name in u-lab
                })
                let left-spacing = spacings-p.slice(
                    0,
                    last-left-pos
                ).map(el => {
                    el.at(1)
                }).sum(default: 0)

                // set coords at the right of the last left partner.
                coords.persons.insert(
                    parent1.name,
                    (
                        u-left-x + left-spacing + sib-dist + u-dist/2,
                        - gen-height*(parent1.generation - 1)
                    )
                )
            }
        }
    }
    return coords
}


// set coordinates for each child and its eventual partners in an union, knowing the parents coords.
#let set-coords(geneal) = {
    let root-spacings = get-root-spacings(geneal)
    let root-coords = get-spacings-coords(geneal, u-spacings: root-spacings)
    for (name, coord) in root-coords.persons {
        let person-pos = geneal.persons.position(el => {
            el.name == name
        })
        geneal.persons.at(person-pos).coords = coord
    }
    for (lab, coord) in root-coords.unions {
        let union-pos = geneal.unions.position(el => {
            make-union-label(el.parents-names) == lab
        })
        geneal.unions.at(union-pos).coords = coord
    }
    let max-gen = calc.max(..geneal.unions.map(el => {el.parents-generation}))
    for gen in range(1, max-gen + 1) {
        let gen-unions = geneal.unions.filter(el => {
            el.parents-generation == gen
        })
        for union in gen-unions {
            let coords = get-spacings-coords(geneal, parents-union: union)
            for (name, coord) in coords.persons {
                let person-pos = geneal.persons.position(el => {
                    el.name == name
                })
                geneal.persons.at(person-pos).coords = coord
            }
            for (lab, coord) in coords.unions {
                let union-pos = geneal.unions.position(el => {
                    make-union-label(el.parents-names) == lab
                })
                geneal.unions.at(union-pos).coords = coord
            }
        }
    }
    geneal
}
