/// = Prooftree
/// Some acronyms will be used:
/// * lbl-tree: 
///     A 'line-by-line' tree, where a tree is represented by a sequence of 'lines', each stating 
///     how many premises it should have.
/// * s-tree:
///     A 'structured' tree, the IR of proof trees. These have a nested structure mirroring that
///     of the tree they represent
/// * ss-tree: 
///     A 'semi-structured' tree, providing an alternate way for users to define proof trees.
///     These are not yet implemented.

#import "utils.typ": *

/// Enabling debugging mode will give all the prooftree blocks thin red outlines,
/// and some various other markers to help with development.
#let __debug_mode = false

/// Do/show `b` if we are in debugging mode.
#let __debug_trace(b) = {
    if __debug_mode {b}
    else {}
}

/// How to outline prooftree blocks when debugging.
#let block_stroke = __debug_trace((paint: red, thickness: .15pt))

/// The block config used by most of the prooftrees.
#let qblock = block.with(breakable: false, stroke: block_stroke, inset: 0pt)



// The default assert prepends with 'assertion error',
// we want the user to immediately know it is in a prooftree error
// welp just realised this prepends with 'panic' anyways.
#let __mk_err_str(message) = "prooftree Error: " + message
#let assert_ = assert
#let assert(cond, msg) = {
    if not cond [
        #panic(__mk_err_str(msg))
    ]
}



/*************************************************************************************************/
// Printing to content

/*****************************************************************************/
// Printing Inferences

/// Types:
/// Dimensions = dict(width, height)

/// The return structure of the main show functions
/// - conc_dim (Dimensions):
/// - block_dim (Dimensions):
/// - block (content):
/// - conc_start_x (length): 
/// -> TreeShowReturn
#let _mk_show_return(conc_dim, block_dim, block, conc_start_x) = {
    (   conc_dim: conc_dim
    ,   block_dim: block_dim
    ,   block: block
    ,   conc_start_x: conc_start_x
    )
}

/// Build a block containing the conclusion
/// - styles       (styles):
/// - conclusion   (content):
/// - alignment    (alignment):
/// - conc_start_x (length):
/// -> TreeShowReturn
#let __show_conclusion(
    styles       : __kw_arg,
    tree_config  : __kw_arg,
    conclusion   : __kw_arg,
    alignment    : __kw_arg,
    conc_start_x : __kw_arg
) = {
    let conc = align(alignment + left, qblock(conclusion.content))
    _mk_show_return(measure(conc, styles), measure(conc,styles), conc, conc_start_x)
}


/// Create a `Label`, storing the content of the label and its spacing from the inference line.
/// - content (content)
/// - spacing (length)
/// -> Label 
#let __mk_label(content, spacing) = if is_not_none(content) {
    (   content: from_none(content, none)
    ,   spacing: from_none(spacing, 0pt)
    )
}


/// Format a s-tree with no premises
/// -> TreeShowReturn
#let _show_axi_tree(
    styles       : __kw_arg,
    tree_config  : __kw_arg,
    conclusion   : __kw_arg
) = __show_conclusion(
        styles       : styles,
        tree_config  : tree_config,
        conclusion   : conclusion,
        alignment    : bottom,
        conc_start_x : 0pt
    )

/// Format the block of premises preceding a conclusion.
/// All premises are assumed to have already been formatted.
///
/// - first_premise (TreeShowReturn): The leftmost premise, assumed to have already been formatted.
/// - mid_premises (array[TreeShowReturn]): The middle premises, in order of left-to-right.
/// - last_premise (TreeShowReturn): The rightmost premise.
/// - is_unary (bool): true when the inference is unary; 
///     i.e. there is only one premise, the `first_premise`.
/// -> (content, length): 
///     The `content` is the formatted block.
///     The `length` is the distance from the left boundary of the block to the end of the
///     conclusion of the rightmost premise.
#let __show_premise_block(
    tree_config   : __kw_arg,
    first_premise : __kw_arg,
    mid_premises  : __kw_arg,
    last_premise  : __kw_arg,
    is_unary      : __kw_arg
) = {
    // __check_kw_args(first_premise, mid_premises, last_premise, is_unary)
    let ret_content
    let last_p_end_x

    if is_unary {
        last_p_end_x = first_premise.conc_start_x + first_premise.conc_dim.width
        ret_content = qblock(first_premise.block)
    } else {
        
        let p_spacing = tree_config.premises_spacing
        let all_but_last_premise_x =  (
            (first_premise.block_dim.width)
            + p_spacing 
            + mid_premises.map(p => p.block_dim.width + p_spacing).sum(default: 0pt) 
        )
        last_p_end_x = all_but_last_premise_x + last_premise.conc_start_x + last_premise.conc_dim.width

        ret_content = align(bottom,qblock(stack(
            dir: ltr,
            pad(first_premise.block, right: p_spacing),
            ..(mid_premises.map(p => pad(p.block, right: p_spacing))),
            last_premise.block,
        )))
    }
    return (ret_content, last_p_end_x)
}

/// Get the dimensions of a label.
/// - styles (styles):
/// - label (TreeLabel):
/// -> ((width (length), height (length)), length):
///     `width` and `height` are those of the label as given by `measure`.
///     The rightmost `length` is the total length of the label 
///     including its spacing.
#let __tree_label_dim(styles, label) = {
    if is_not_none(label) and is_not_none(label.content) {
        let dim = measure(label.content, styles)
        (dim, label.spacing + dim.width)
    } else {
        ((width: 0pt, height: 0pt), 0pt)
    }
}

/// Format the inference line and its labels, if any.
///
/// - styles       (styles): 
/// - tree_config  (TreeConfig): 
/// - left_label   (TreeLabel?): 
/// - right_label  (TreeLabel?): 
/// - line_start_x (length): 
///     The distance to the right of the block's leftmost boundary at which the line should start.
/// - line_length  (length): 
/// -> content
#let __show_inference_line_block(
    styles       : __kw_arg,
    tree_config  : __kw_arg,
    left_label   : __kw_arg,
    right_label  : __kw_arg,
    line_start_x : __kw_arg,
    line_length  : __kw_arg
    ) = {
    let (L_label_dim, L_label_total_h_space)  = __tree_label_dim(styles, left_label)
    let (R_label_dim, R_label_total_h_space)  = __tree_label_dim(styles, right_label)

    align(left + horizon,{
        stack(dir: ltr, spacing: 0pt,

            // Place the left label
            if is_not_none(left_label) {
                place(
                    dx: line_start_x - L_label_total_h_space, 
                    dy: - L_label_dim.height / 2, 
                    left_label.content
                )
            },

            // The inference line
            line(start: (line_start_x, 0pt), length: line_length, stroke: tree_config.line_config.stroke),

            // Place the right label
            if is_not_none(right_label) {
                place(
                    dy: - R_label_dim.height / 2, 
                    dx: right_label.spacing,
                    right_label.content
                )
            }
        )

        // Show the midpoint of the line
        __debug_trace(place(
            line(
                start: (line_start_x + line_length / 2, 2pt), 
                stroke: 1pt + blue, angle: -90deg, length: 4pt
            )
        ))
    })
}

/// Format a s-tree with one or more premises.
/// `first_premise`, `last_premise`, and each premise in `mid_premises` are assumed to have already
/// been formatted.
///
/// - conclusion    (content: content, spacing: length):
/// - first_premise (TreeShowReturn):
/// - mid_premises  (list[TreeShowReturn]):
/// - last_premise  (TreeShowReturn):
/// - left_label    (TreeLabel?) :
/// - right_label   (TreeLabel?):
/// - is_unary      (bool):
/// -> TreeShowReturn
#let _show_nary_tree(
    styles         : __kw_arg,
    tree_config    : __kw_arg,
    conclusion     : __kw_arg,
    first_premise  : __kw_arg,
    mid_premises   : __kw_arg,
    last_premise   : __kw_arg,
    left_label     : __kw_arg,
    right_label    : __kw_arg,
    is_unary       : __kw_arg,  
) = {
    // The leftmost point of the first premise's conclusion
    let first_p_start_x = first_premise.conc_start_x
    // The rightmost point of the last premise's conclusion
    let last_p_end_x

    // Premises: all stuff above the line
    let (premise_block, last_p_end_x) = __show_premise_block(
        tree_config: tree_config,
        first_premise: first_premise,
        mid_premises: mid_premises,
        last_premise: last_premise,
        is_unary: is_unary
    )

    let conc_dim = measure(conclusion.content, styles)
    let p_line_length = last_p_end_x - first_p_start_x
    let p_total_len = measure(premise_block, styles).width

    let line_length = calc.max(conc_dim.width, last_p_end_x - first_p_start_x)

    let line_start_x
    let conc_start_x

    if (conc_dim.width < p_line_length) {
        line_start_x = first_p_start_x
        conc_start_x = line_start_x + (line_length - conc_dim.width) / 2
    } else if (conc_dim.width < p_total_len) {
        line_start_x = p_total_len / 2 - conc_dim.width / 2
        conc_start_x = line_start_x
    } else {
        line_start_x = 0pt
        conc_start_x = 0pt
    }

    let get_overhang(h) = if is_not_none(h) {
        h
    } else if is_not_none(tree_config.line_config.overhang) {
        tree_config.line_config.overhang
    } else {
        0pt
    }

    let overhang_l = get_overhang(tree_config.line_config.overhang_l)
    let overhang_r = get_overhang(tree_config.line_config.overhang_r)

    line_start_x -= overhang_l
    line_length += overhang_l + overhang_r


    // The line and possibly labels.
    let line_block = __show_inference_line_block(
        styles       : styles,
        tree_config  : tree_config,
        left_label   : left_label,
        right_label  : right_label,
        line_start_x : line_start_x,
        line_length  : line_length
    )

    // The conclusion
    let conc_block = __show_conclusion(
        styles       : styles,
        conclusion   : conclusion,
        alignment    : horizon,
        conc_start_x : conc_start_x
    )

    // final proof block
    let prf_block = qblock(pad(
        align(center + bottom, 
            stack(
                spacing: tree_config.vertical_spacing,
                qblock(premise_block),
                line_block,
                align(left,pad(left: conc_start_x, conc_block.block))
            )
        )
    ))

    _mk_show_return(
        conc_dim, 
        measure(prf_block, styles), 
        prf_block, 
        conc_start_x
    )
}

/*****************************************************************************/
// Printing trees

/// The structure of a formatted tree
#let _mk_showed_tree(m_content, m_spacing) = {
    (   content: default_if_none(m_content, [])
    ,   spacing: default_if_none(m_spacing, 0pt)
    )
}

#let _mk_line_config(
    overhang: none,
    overhang_l: none,
    overhang_r: none,
    stroke: none
) = {

    let overhang_l = default_if_none(overhang_l, overhang)
    let overhang_r = default_if_none(overhang_r, overhang)

    return (   stroke: stroke
    ,   overhang: overhang
    ,   overhang_l: overhang_l
    ,   overhang_r: overhang_r
    )
}

#let default_line_config = _mk_line_config(
    overhang: 2pt,
    stroke: 1pt + black
)


#let _mk_tree_config(
        premises_spacing: __kw_arg
    ,   spacing_between_next_premise: __kw_arg
    ,   vertical_spacing: __kw_arg  
    ,   line_config: __kw_arg
) = {
    (   premises_spacing: premises_spacing
    ,   spacing_between_next_premise: spacing_between_next_premise
    ,   vertical_spacing: vertical_spacing  
    ,   line_config: line_config
    )
}

/// Convert structured tree to content
#let _show_str_sub_tree(styles, tree_config, tree) = {
    let num_premises = tree.premises.len()
    let conc = _mk_showed_tree(tree.conclusion, tree.spacing)

    // Recurse on a premise
    let prepare_premise(premise) = _show_str_sub_tree(styles, tree_config, premise)

    let line_config = tree_config.line_config
    if is_not_none(tree.line_config) {
        line_config += tree.line_config
    }

    let tree_config = tree_config
    tree_config.line_config = line_config


    if num_premises == 0 {
        _show_axi_tree(
            styles       : styles,
            tree_config  : tree_config,
            conclusion   : conc
        )
    } else if num_premises == 1 {
        let premise = prepare_premise(tree.premises.first())
        
        _show_nary_tree(
            styles        : styles,
            tree_config   : tree_config,
            conclusion    : conc,
            first_premise : premise,
            mid_premises  : (),
            last_premise  : none,
            left_label    : tree.left_label,
            right_label   : tree.right_label,
            is_unary      : true
        )
    } else {
        let first_premise = prepare_premise(tree.premises.first())
        let last_premise = prepare_premise(tree.premises.last())
        let mid_premises = tree.premises.slice(1, num_premises - 1).map(prepare_premise)
        
        _show_nary_tree(
            styles        : styles,
            tree_config   : tree_config,
            conclusion    : conc,
            first_premise : first_premise,
            mid_premises  : mid_premises,
            last_premise  : last_premise,
            left_label    : tree.left_label,
            right_label   : tree.right_label,
            is_unary      : false
        )
        
    }
}

/// Convert structured tree to content
#let __show_str_tree(tree_config, tree) = {
    style(styles => {
        let prt_tree = _show_str_sub_tree(styles, tree_config, tree)
        align(center,qblock(width: prt_tree.block_dim.width, prt_tree.block))
    })
}

/*************************************************************************************************/
/// == Building Trees
/*****************************************************************************/
/// === Flat Trees

/// The raw input form.
#let _mk_tree_line(
        num_premises: __kw_arg
    ,   body: __kw_arg
    ,   right_spacing: none
    ,   left_label: none
    ,   left_label_spacing: none
    ,   right_label: none
    ,   right_label_spacing: none
    ,   line_config: none
) = {
    // __check_kw_args(num_premises, body)
    assert(
        num_premises >= 0, 
        "Inference line with a negative number of premises: $k"
        .replace("$k", str(num_premises))
    )
    /// raw_tree
    ( num_premises: num_premises // : Nat
    , conclusion: body // : content
    , spacing: right_spacing // : length
    , left_label: __mk_label(left_label, left_label_spacing)
    , right_label: __mk_label(right_label, right_label_spacing)
    , line_config: line_config
    )
}

/*****************************************************************************/
/// === 'Structured' Trees
/// These are an intermediate form.
/// - premises (list[str_tree])
/// - conclusion (content)
/// -> str_tree
#let _mk_str_tree(
        premises
    ,   conclusion
    ,   left_label
    ,   right_label
    ,   spacing
    ,   line_config
) = {
    ( premises: premises // : List Tree
    , conclusion: conclusion // : content
    , left_label: left_label // : Maybe TreeLabel
    , right_label: right_label // : Maybe TreeLabel
    , spacing: spacing // : length
    , line_config: line_config // : Maybe LineConfig
    )
}

#let _test_mk_str_tree_(ps, c) = _mk_str_tree(ps, c, none, none, 0pt, none)

/// These extra constructors are useful for building tests.
#let snary(..args, conclusion) = {
    let tree_config_override = args.named()
    let premises = args.pos()
    _mk_str_tree(premises, conclusion)
}

#let _str_axi(c) = _test_mk_str_tree_((), c)
#let _str_uni(p, c) = _test_mk_str_tree_((p,), c)
#let _str_bin(p1, p2, c) = _test_mk_str_tree_((p1,p2), c)

/*****************************************************************************/
/// === Parsing line-by-line trees to structured

/// Parse a line-by-line tree.
/// The root of the tree is at the end of the list.
///
/// - stats (list[raw_tree])
/// -> (str_tree, list[raw_tree])
///     The recursive tree and list of statements left to consume.
#let __parse_tree(stats) = {
    assert(stats.len() > 0, "malformed tree: not enough premises")
    let stat = stats.pop()
    let curr_stats = stats
    let premises = ()

    if stat.num_premises > 0 {
        let i = stat.num_premises
        while i > 0 {
            let (p, ss) = __parse_tree(curr_stats)
            curr_stats = ss
            premises.push(p)
            i -= 1
            assert(curr_stats.len() >= i, 
                "malformed tree: not enough premises for conclusion: $c"
                .replace("$c", repr(stat.conclusion))
            )
        }
        premises = premises.rev()
    }
    (
        _mk_str_tree(
            premises,
            stat.conclusion,
            stat.left_label,
            stat.right_label,
            stat.spacing,
            stat.line_config
        ),   
        curr_stats
    )
}

/// Parse a flat tree to structured
/// - stats (list[raw_tree])
/// -> str_tree
#let _parse_tree(stats) = {
    let (tree, stats_left) = __parse_tree(stats)
    assert(stats_left.len() == 0, 
        "malformed prooftree: not all premises consumed, $n many were left:  $stats"
        .replace("$stats", repr(stats))
        .replace("$n", str(stats_left.len()))
    )
    tree
}

/*****************************************************************************/
/// Semi-structured trees: the structure is given by the user.
/// The idea is for these to be mixes of nested arrays and dictionaries

// TODO change these to functions that parse nested arrays/dicts

#let saxi(conclusion) = _test_mk_str_tree_((), conclusion)
#let suni(t, c) = _test_mk_str_tree_((t,), c)
#let sbin(t1, t2, c) = _test_mk_str_tree_((t1,t2), c)


/*****************************************************************************/
/// Parse-show pipeline functions

/// Parse a line-by-line tree and display it
#let __parse_then_show(tree_config, stats) = {
    let tree = _parse_tree(stats)
    __show_str_tree(tree_config, tree)
}


/// Parse a line-by-line tree and display it
/// - tree_config (TreeConfig):
/// - stats: Any kw_args are assumed to be overriding the tree_config.
///     The user could possibly use this to also store stuff, if at some point we add the ability for the proof cell to access the config.
/// -> content: The tree as formatted content, ready for display.
#let _parse_then_show(
    tree_config: __kw_arg,
    args
    ) = {
    let tree_config_override = args.named()
    let tree_config = tree_config + tree_config_override
    let tree_lines = args.pos()
    __parse_then_show(tree_config, tree_lines)
}


/// Display the structured tree.
#let stree(tree_config, ..args, stree) = {
    assert(
        args.pos().len() == 0, 
        "`stree` too many positional arguments: $n were given, only 1 is expected."
            .replace("$n", args.pos().len())
    )
    let tree_config_override = args.named()
    let tree_config = tree_config + tree_config_override
    __show_str_tree(tree_config, stree)
}
