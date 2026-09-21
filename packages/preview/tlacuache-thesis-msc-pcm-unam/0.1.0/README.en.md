# tlacuache-thesis-pcc-unam template

🇲🇽 [Español](README.md)

This repository provides a thesis template for the Master's Program in Mathematical Sciences at the Universidad Nacional Autónoma de México (UNAM).

The design is based on the [tlacuache-thesis-fc-unam](https://github.com/davidalencia/tlacuache-thesis-fc-unam) template, originally created for undergraduate thesis at the Faculty of Sciences. The cover has been adapted to (approximately) comply with the graduate program requirements.

## Usage

⚠️ Note: This template is not currently available in the official Typst package repository.

- Clone the repository:
  ```bash
  git clone git@github.com:rubal501/tlacuache-thesis-pccm-unam.git
  ```
- Import the template in your main file:
  ```typ
  #import "./tlacuache-thesis-pccm-unam/lib.typ":*
  ```

## Configuration

You can configure your thesis with these lines at the beginning of your main file.

```typ
#import "./tlacuache-thesis-pccm-unam/lib.typ":*

#show: thesis.with(
  titulo: [Titulo],
  autor: [Autor],
  asesor: [Asesor],
  asesorAD: [Instituto 1],
  lugar: [Ciudad de México, México],
  agno: [#datetime.today().year()],
  bibliography: bibliography("references.bib"),
)

// Your thesis goes here
```

### Cover parameters

| Parameter   | Description                                                      | Default value                   |
|-------------|------------------------------------------------------------------|---------------------------------|
| `titulo`    | Thesis title                                                     | `[Titulo]`                      |
| `autor`     | Author's full name                                               | `[Autor]`                       |
| `asesor`    | Thesis advisor's name                                            | `[Asesor]`                      |
| `asesorAD`  | Advisor's institutional affiliation (institute or faculty)       | `[Adscripción]`                 |
| `lugar`     | City and country where the thesis is presented                   | `[Ciudad de México, México]`    |
| `agno`      | Year of presentation                                             | Current year                    |

### Content parameters

| Parameter         | Description                                                  | Default value     |
|-------------------|--------------------------------------------------------------|-------------------|
| `bibliography`    | Reference to the bibliography file (`bibliography(...)`)     | `[]` (none)       |
| `abstract`        | Thesis abstract                                              | `[]` (none)       |
| `agradecimientos` | Acknowledgements section                                     | `[]` (none)       |

You could also create a pdf for just a chapter with bibliography, by using the following lines.

```typ
#import "./tlacuache-thesis-pccm-unam/lib.typ":chapter


// loading bibliography is completely optional
#show: chapter.with(bibliography: bibliography("references.bib"))

// Your chapter goes here
```

You could even create a pdf for just a section of a chapter.

```typ
#import "./tlacuache-thesis-pccm-unam/lib.typ":section


// loading bibliography is completely optional
#show: section.with(bibliography: bibliography("references.bib"))

// Your section goes here
```

## 🫶 Acknowledgements

- [David Valencia Rodríguez](https://github.com/davidalencia) for developing the original template.

## 🚨 Disclaimer

This template is not official and is not affiliated with the Mathematical Sciences Graduate Program at UNAM. Use it at your own discretion.
