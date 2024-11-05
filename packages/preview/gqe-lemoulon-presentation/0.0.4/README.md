# gqe-presentation

template [Typst web app](https://typst.app/) to generate GQE slides


## 🧑‍💻 Usage

- Directly from [Typst web app](https://typst.app/) by clicking "Start from template" on the dashboard and searching for `gqe-lemoulon-presentation`.

- With CLI:

```
typst init @preview/gqe-lemoulon-presentation:{version}
```

## Documentation

gqe-presentation is based on [touying](https://touying-typ.github.io/) package. The documentation is available [here](https://touying-typ.github.io/).

## Local installation

### Install Rust and Typst

```
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```
and then install [Typst](https://github.com/typst/typst#installation)

```
cargo install typst-cli
```

### Install the "gqe-presentation" theme on linux

clone the repository in your file system and install the theme "gqe-lemoulon-presentation" :

```
git clone https://forgemia.inra.fr/gqe-moulon/gqe-presentation.git
mkdir -p ~/.local/share/typst/packages/local/gqe-lemoulon-presentation/0.0.4/
cp -r gqe-presentation/* ~/.local/share/typst/packages/local/gqe-lemoulon-presentation/0.0.4/
```

### Start a new document

```

#import "@local/gqe-lemoulon-presentation:0.0.4":*



#show: gqe-theme.with(
  aspect-ratio: "4-3",
  gqe-font: "PT Sans"
  // config-common(handout: true),
  config-info(
    title: [Full native timsTOF data parser implementation in the i2MassChroq software package],
    subtitle: [sous titre],
    author: [Olivier Langella],
    gqe-equipe: [Base],
  ),
)




#title-slide()


#slide()[
= Bioinformatics challenges
#pave("Scientific projects and hardware")[
- High throughput
- Metaproteomics
- Instrument improvements
]
#pause
#pave("Means")[
- Free software (as a speech)
- Finding new algorithms
- Upgrade existing ones
- Controlling infrastructure
- Controlling costs
]

]


#slide()[
= Yes but...
bla bla
]

```

## 📝 License

This is GPLv3 licensed.
