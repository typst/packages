#import "@preview/cetz:0.4.0": canvas

#import "calc-functions.typ": *
#import "draw-functions.typ": *

/// Creates a genealogy object, consisting of a #dtype((:)) with the keys #genealogy-init().keys()
/// - persons (array): An array of persons to initiate the tree. Can be left empty (the default) and add the persons after (see #cmd-[add-person] and #cmd-[add-persons]).
/// - unions (array): An array of unions between persons to initiate the tree. Can be left empty (the default) and add the unions after (see #cmd-[add-union()] and #cmd-[add-unions()]).
/// - phenos (dict): A dictionary mapping phenotypes names with their color when drawn. Can be left to the default or set to (:), and add the phenotypes later (see #cmd-[add-phenos]).
/// - config (dict): A config dictionary, setting all sizes to draw the tree. It is advised to let it to the default in this function and to modify the sizes after if needed, as forgetting or misspelling an entry in the config dictionary will lead to failure. See #cmd-[set-config].
/// -> dict
#let genealogy-init(
    persons: (),
    unions: (),
    phenos: (sane: none, ill: black),
    config: (
        person-radius: 1,
        union-dist: 3.5,
        siblings-dist: 4,
        person-botline: 0.5,
        union-vline: 2,
        person-topline: 0.5,
        union-orient: "lr"
    )
) = {
    (
        persons: persons,
        unions: unions,
        phenos: phenos,
        config: config
    )
}

/// Add a person (= an individual) to the genealogical tree dictionary. Returns the #arg[geneal] dictionary with the added person to #arg[geneal.persons]
/// - geneal (dict): A genealogical tree dictionary, typically obtained from the function #cmd-[genealogy-init]. The person will be added to #arg[geneal.persons]
/// - name (string): The name of the person. *Names must be unique*, duplicated names will lead to failure.
/// - sex (string): "f" for female, "m" for male, #dtype(none) or "unk" if unknown. Females will be drawn as a circle, males as a square, and persons of unknown sex as a diamond.
/// - generation (int): The persons generation. Generations start at 1 and get incremented at each union. This parameter must be set if the person isn't the child of anyone in the tree (see #cmd-[add-union]). If not set, it will be calculated automatically (see #cmd-[get-generation] for more details)
/// - alive (bool): Wether the person is alive or not. Dead persons will be drawn with a slash.
/// - phenos (array): A list of strings, corresponding to the phenotypes of the person. The phenotypes listed here must be present in the phenos key of the genealogy dictionary (#arg[geneal.phenos]), see #cmd-[add-phenos]
/// - label (content): A label to print on the person.
/// - label-anchor (string): a CeTZ anchor to position the label, relative to the person.
/// - pheno-label (content): A label printed below the person between brackets \[\], to write the persons phenotype.
/// - geno-label (array): An array of length 2 that will be printed below the person, to write its genotype. ("allele1", "allele2") will be printed as (allele1\/\/allele2).
/// -> dict
#let add-person(
    geneal,
    name,
    sex: none,
    generation: none,
    alive: true,
    phenos: (),
    label: none,
    label-anchor: "center",
    pheno-label: none,
    geno-label: none,
) = {
    geneal.persons.push(
        (
            name: name,
            sex: sex,
            parents-names: none,
            generation: generation,
            partners-names: (),
            alive: alive,
            phenos: phenos,
            label: label,
            pheno-label: pheno-label,
            geno-label: geno-label,
            label-anchor: label-anchor,
            coords: none,
        )   
    )
    geneal
}

/// A wrapper to add multiple persons at once to the genealogical tree dictionary. Takes a dictionary mapping a person name with the #cmd-[add-person] arguments. Returns the #arg[geneal] dictionary with the added persons to #arg[geneal.persons]
/// - geneal (dict): A genealogical tree dictionary, typically obtained from the function #cmd-[genealogy-init].
/// - persons-dict (dict): A dictionary, with the keys giving the persons names and the values consisting of dictionaries giving the arguments to pass to the function #cmd-[add-person] for each person.
#let add-persons(geneal, persons-dict) = {
    for person-name in persons-dict.keys() {
        geneal = add-person(
            geneal,
            person-name,
            ..persons-dict.at(person-name)
        )
    }
    geneal
}

/// Add an union between persons to a genealogical tree dictionary. Must give the parents names as an array of length 2 and the children names as an array of length at least 1. Returns the #arg[geneal] dictionary with the added union to #arg[geneal.unions]. if #arg[geneal.config.union-orient] is set to "lr" (the default), the order the parents-names are given determines the order they will be drawn. 
/// - geneal (dict): A genealogical tree dictionary, typically obtained from the function #cmd-[genealogy-init].
/// - parents-names (array): An array of length 2, containing 2 strings giving the parents names. Every name in the array *must* match a person name field in the persons array of geneal.persons.
/// - children-names (array): An array of length at least 1, containing strings giving the names of the children of the two parents. Every name in the array *must* match name field in the persons array of geneal.persons.
#let add-union(geneal, parents-names, children-names) = {
    let parent0-index = geneal.persons.position(el => {el.name == parents-names.at(0)})
    let parent1-index = geneal.persons.position(el => {el.name == parents-names.at(1)})
    geneal.persons.at(parent0-index).partners-names.push(
        (parents-names.at(1), "r")
    )
    geneal.persons.at(parent1-index).partners-names.insert(
        0,
        (parents-names.at(0), "l")
    )
    for child-name in children-names {
        let child-index = geneal.persons.position(el => {el.name == child-name})
        geneal.persons.at(child-index).parents-names = parents-names
    }
    geneal.unions.push((
        children-names: children-names,
        parents-names: parents-names,
        parents-generation: none,
        size: none,
        spacings: none,
        coords: none
    ))
    geneal
}

/// A wrapper to add multiple unions at once to a genealogical tree dictionary. Takes an arbitrary number of arrays of length 2 containing the parents-names and children-names argument of #cmd-[add-union]. Returns the #arg[geneal] dictionary with the added unions to #arg[geneal.unions].
/// - geneal (dict): A genealogical tree dictionary, typically obtained from the function #cmd-[genealogy-init].
/// - ..unions (arrays): An arbitrary number of arrays of length 2. The first element is the array of parents names (see parents-names in #cmd-[add-union]). The second is the array of children-names (see children-names in #cmd-[add-union])
/// -> dict
#let add-unions(geneal, ..unions) = {
    let to-add = unions.pos()
    for union in to-add {
        geneal = add-union(geneal, ..union)
    }
    geneal
}

/// Add phenotypes to the phenotypes array of a genealogical tree dictionary. Returns the #arg[geneal] dictionary with the added phenotypes to #arg[geneal.phenos]
/// - geneal (dict): A genealogical tree dictionary, typically obtained from the function #cmd-[genealogy-init]
/// - phenos (dict): A dictionary, the keys give the phenotypes names, and the values a color to draw the corresponding phenotype.
#let add-phenos(geneal, phenos: (:)) = {
    for pheno in phenos.keys() {
        geneal.phenos.insert(pheno, phenos.at(pheno))
    }
    geneal
}

/// Sets the configuration of a genealogical tree dictionary. Returns the #arg[geneal] dictionary with the modified configuration dictionary (#arg[geneal.config]). Allows to modify :
/// - #arg[person-radius] : the persons size (radius for women, half size of the square for men)
/// - #arg[union-dist] : distance between parents center. Determines the size of the horizontal union line between two persons.
/// - #arg[siblings-dist] : default distance between siblings.
/// - #arg[person-botline] : the length of the line going down from the south anchor of a person to the union line with its partner.
/// - #arg[union-vline] : The length of the line going down from the center of a union line to the horizontal line joining siblings.
/// - #arg[person-topline] : The length of the line going up from the north anchor of a person to the horizontal line joining siblings.
/// - #arg[union-orient] : The orientation of the unions relatively to a child. Either "l" : the partners are always drawn to the left of the child, "r" : the partners are always drawn to the right of the child, or "lr" : the partners are drawn in the order of the parents-names array when defining the union in #cmd-[add-union], allowing you to flip each union orientation at will by modifying the order of the parents-names array : first parent will be drawn at the left and second at the right.
/// - geneal (dict): A genealogical tree dictionary, typically obtained from the function #cmd-[genealogy-init]
/// - config (dict): A configuration dictionary. Available keys are #genealogy-init().config.keys(). Giving a key not in this list will fail. Length values can be any #doc("layout/length") or a float.
/// -> dict
#let set-config(geneal, config) = {
    for cfg in config {geneal.config.at(cfg) = config.at(cfg)}
    geneal
}

/// Draws the #arg[geneal] genealogical tree dictionary. This function must be called in a #link("https://typst.app/universe/package/cetz/")[CeTZ] canvas, allowing additions and modifications to the tree. Before drawing the tree, different informations are computed : generations are set for each person, and necessary spacing between persons are calculated.
/// - geneal (dict): A genealogical tree dictionary, typically obtained from the function #cmd-[genealogy-init]. Will not draw persons who are not parents neither child of anyone (person name isn't found neither in a parents-names nor in a children-name field of #arg[geneal.unions]).
/// -> content
#let draw-tree(geneal) = {
    let geneal = set-generations(geneal)
    let geneal = set-subtree-unions(geneal)
    let geneal = set-unions-sizes-compact(geneal)
    let geneal = set-coords(geneal)
    
    draw-persons(geneal)
    draw-unions(geneal)
}

