# CTU report

This template serves as slight modification of [basic-report](https://github.com/roland-KA/basic-report-typst-template) to comply with CTU's graphics manual.

## Fonts

This template uses Technika font for headings. This can be downloaded from this repository, Petr Olšák's [CTUstyle3 repository](https://github.com/olsak/CTUstyle3) or for CTU students from [official source](https://www.cvut.cz/logo-a-graficky-manual).

## Usage

```typst
#import "@preview/ctu-report:0.2.0": *

#show: it => ctu-report(
  doc-category: "Laboratorní návod",
  doc-title: "Jak zpojit diodu",
  author: "Mgr. Hubert Dřímal",
  affiliation: "Katedra trpaslíků a permoníků",
  language: "cs",
  faculty: "F3",
  it,
)
```
Possible values for faculty:

| Shortcode       | Czech name                                         | English name                                             |
|-----------------|----------------------------------------------------|----------------------------------------------------------|
| CVUT (fallback) | České vysoké učení technické v Praze               | Czech Technical University in Prague                     |
| F1              | Fakulta stavební                                   | Faculty of Civil Engineering                             |
| F2              | Fakulta strojní                                    | Faculty of Mechanical Engineering                        |
| F3              | Fakulta elektrotechnická                           | Faculty of Electrical Engineering                        |
| F4              | Fakulta jaderná a fyzikálně inženýrská             | Faculty of Nuclear Sciences and Physical Engineering     |
| F5              | Fakulta architektury                               | Faculty of Architecture                                  |
| F6              | Fakulta dopravní                                   | Faculty of Transportation Sciences                       |
| F7              | Fakulta biomedicínského inženýrství                | Faculty of Biomedical Engineering                        |
| F8              | Fakulta informačních technologií                   | Faculty of Information Technology                        |
| CIIRC           | Český institut informatiky, robotiky a kybernetiky | Czech Institute of Informatics, Robotics and Cybernetics |
| KU              | Kloknerův ústav                                    | Klokner Institute                                        |
| MUVS            | Masarykův ústav vyšších studií                     | Masaryk Institute of Advanced Studies                    |
| UCEEB           | Univerzitní centrum energeticky efektivních budov  | University Centre for Energy Efficient Buildings         |
| UTEF            | Ústav technické a experimentální fyziky            | Institute of Experimental and Applied Physics            |
| UTVS            | Ústav tělesné výchovy a sportu                     | Institute of Physical Education and Sport                |
