#import "internal.typ"

/// An inference with `num_premises` many premises.
/// 
/// - num_premises (int): The number of premises of the inference. 
/// - conclusion (content): The conclusion of the inference; the part that goes under the line.
/// - right_spacing (length): When this tree is itself a premise, how much spacing between this tree and the premise to the right, if any.
/// - left_label (content): The label to the left of the inference line.
/// - left_label_spacing (length): The spacing between the left label and the inference line.
/// - right_label (content): The label to the right of the inference line.
/// - right_label_spacing (length): The spacing between the right label and the inference line
/// - line_config (LineConfig?): The configuration of the current inference line directly, overrides the `tree_config`. See `line_config` for parameters.
/// -> dictionary:  A dictionary with the information needed for the tree parser.
#let nary(
        num_premises
    ,   conclusion
    ,   right_spacing: 0pt
    ,   left_label: none
    ,   left_label_spacing: 0pt
    ,   right_label: none
    ,   right_label_spacing: 0pt
    ,   line_config: none
)   = internal._mk_tree_line(
        num_premises: num_premises
    ,   body: conclusion
    ,   right_spacing: right_spacing
    ,   left_label: left_label
    ,   left_label_spacing: left_label_spacing
    ,   right_label: right_label
    ,   right_label_spacing: right_label_spacing
    ,   line_config: line_config
)

/// `nary` with 0 premises.
/// See docs for `nary` for more information.
#let axi = nary.with(0)

/// `nary` with 1 premise.
/// See docs for `nary` for more information.
#let uni = nary.with(1)

/// `nary` with 2 premises.
/// See docs for `nary` for more information.
#let bin = nary.with(2)

/// nary with 3 premises.
/// See docs for `nary` for more information.
#let tri = nary.with(3)

/// `nary` with 4 premises.
/// See docs for `nary` for more information.
#let quart = nary.with(4)

/// `nary` with 5 premises.
/// See docs for `nary` for more information.
#let quint = nary.with(5)
/*****************************************************************************/
/// == Configuration

/// Create a configuration for the formatting of the inference line.
///
/// - overhang (length): The amount by which the line hangs left and right past the premises.
///     This is overriden by `overhang_l` and `overhang_r` if they are set.
/// - overhang_l (length): The amount by which the line hangs left past the premises.
///     This overrides `overhang` only on the left side.
/// - overhang_r (length): The amount by which the line hangs right past the premises.
///     This overrides `overhang` only on the right side.
/// - stroke (length): The stroke of the line, with the same options as `typst`'s `line` function.
/// -> dictionary: A dictionary with the information needed for tree builder. 
#let line_config(
    overhang: internal.default_line_config.overhang_l,
    overhang_l: none,
    overhang_r: none,
    stroke: internal.default_line_config.stroke
) = internal._mk_line_config(
    overhang: overhang,
    overhang_l: overhang_l,
    overhang_r: overhang_r,
    stroke: stroke
)

/// The default line configuration.
#let default_line_config = internal.default_line_config


/// Create a format configuration for a tree.
///
/// This controls many aspects of the look of the tree, such as the spacing between premises, the line style, etc.
/// The default configuration is `default_tree_config`; this config that obtained by passing no arguments to this function.
///
/// - premises_spacing (length): The spacing between premises. This can be overriden by individual premises.
/// - spacing_between_next_premise (length): Currently does nothing.
/// - vertical_spacing (length): The vertical spacing between premises, the line and the conclusion.
/// - line_config (line_config): The configuration of the inference line, see `line_config`.
/// -> dictionary: A dictionary with the information needed for tree builder.
#let tree_config(
        premises_spacing: 10pt
    ,   spacing_between_next_premise: none
    ,   vertical_spacing: 2.2pt   
    ,   line_config: default_line_config
) = {
    internal._mk_tree_config(   
        premises_spacing: premises_spacing
    ,   spacing_between_next_premise: spacing_between_next_premise
    ,   vertical_spacing: vertical_spacing  
    ,   line_config: line_config
    )
}

/// The default tree configuration.
#let default_tree_config = tree_config()

/*****************************************************************************/
/// == Displaying trees

#let _show_str_tree(tree) = internal.__show_str_tree(default_tree_config, tree)

/// Construct and display a line-by-line tree
/// This is the main function of the package.
/// Positional arguments are parsed as premises, and the last argument is the conclusion.
/// Named arguments are used to configure the tree, and override the `tree_config`.
///
/// - tree_config (tree_config): The configuration of the tree.
/// - ..args (content, any): The premises, conclusion and extra configurations of the tree.
/// -> content: The tree.
#let tree(
    tree_config: default_tree_config,
    ..args
) = internal._parse_then_show(tree_config: tree_config, args)

