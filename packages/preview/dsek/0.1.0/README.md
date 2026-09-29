# `dsek` - Typst templates for the D-guild

Document types for the [D-guild](https://dsek.se)'s various documents, in Typst.

## Usage

> **IMPORTANT**
>
> To generate documents in stylistic accordance with [guild guidelines](https://www.dsek.se/api/pdf/styrdokument/releases/download/latest/riktlinje_for_grafisk_profil.pdf), you ***must install the correct fonts yourself***, as they are [not included](https://github.com/typst/packages/blob/0ae72156dda3d538389175adcd1f53de6b0ef354/docs/resources.md#fonts-are-not-supported-in-packages) in the Typst package. These fonts can be found [here](https://github.com/Dsek-LTH/dsek-typst/tree/bdffbc21c779afd1f09c34c09cd81c1ca4ad459a/fonts), and should thankfully only need to be installed globally once if you're producing documents locally. If using the typst web app, simply upload the font files to your project and Typst should pick up on them automatically.

To use the `dsek` templates in your project, import it and apply a template using a show rule. For example:

```typst
#import "@preview/dsek:0.1.0": *
#show: motion.with(
    title: "Typst-mallar för styrdokumenten",
    meeting: "HTM1",
    authors: (name: "Truls Teknolog"),
)

= Introduktion

Allt började med DoD:en...
```

The currently available templates (along with their Swedish bindings) are:

- Governing
    - [`guideline`](./examples/guideline.pdf?raw=true) / [`riktlinje`](./examples/guideline.pdf?raw=true)
    - [`policy`](./examples/policy.pdf?raw=true)
    - [`regulations`](./examples/regulations.pdf?raw=true) / [`reglemente`](./examples/regulations.pdf?raw=true)
    - [`statutes`](./examples/statutes.pdf?raw=true) / [`stadgar`](./examples/statutes.pdf?raw=true)
    - [`strategic-goals`](./examples/strategic-goals.pdf?raw=true) / [`strategiska-mål`](./examples/strategic-goals.pdf?raw=true)
- Meetings
    - [`motion`](./examples/motion.pdf?raw=true)
    - [`proposal`](./examples/proposal.pdf?raw=true) / [`proposition`](./examples/proposal.pdf?raw=true)
    - [`board-response`](./examples/board-response.pdf?raw=true) / [`styrelsens-svar`](./examples/board-response.pdf?raw=true)
    - [`consideration`](./examples/consideration.pdf?raw=true) / [`handling`](./examples/consideration.pdf?raw=true)
    - [`notice`](./examples/notice.pdf?raw=true) / [`kallelse`](./examples/notice.pdf?raw=true)
    - [`agenda`](./examples/agenda.pdf?raw=true) / [`föredragningslista`](./examples/agenda.pdf?raw=true)
    - [`minutes`](./examples/minutes.pdf?raw=true) / [`protokoll`](./examples/minutes.pdf?raw=true)
- Misc
    - [`requirements-profile`](./examples/requirements-profile.pdf?raw=true) / [`kravprofil`](./examples/requirements-profile.pdf?raw=true)
    - [`nomination-proposal`](./examples/nomination.pdf?raw=true) / [`valförslag`](./examples/nomination.pdf?raw=true)
    - [`plan-of-operations`](./examples/plan-of-operations.pdf?raw=true) / [`verksamhetsplan`](./examples/plan-of-operations.pdf?raw=true)
    - [`equal-treatment-plan`](./examples/equal-treatment-plan.pdf?raw=true) / [`likabehandlingsplan`](./examples/equal-treatment-plan.pdf?raw=true)

> **NOTE**
>
> Almost all templates have slightly differing parameters. Check the documentation if you're unsure which one goes where.

Click on each template name to see an example document using that template. You can click [here](examples/src) to view the source code for each example, or [read the full documentation here](./docs/templates-docs.pdf?raw=true).

## License

This package is licensed under the [MIT license](LICENSE). The _D-sektionen_ name and logo are trademarks of D-sektionen inom TLTH, are excluded from the MIT license, and are included solely for use in D-guild documents. See [dsek.se](https://dsek.se) for details.
