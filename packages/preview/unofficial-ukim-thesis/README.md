# Typst template for a thesis at UKIM

![alt text](https://upload.wikimedia.org/wikipedia/en/4/46/Kiril.metodij.png)

An unofficial template for a thesis (undergraduate or otherwise) at **Ss. Cyril and Methodius University in Skopje (UKIM)**. 

Loosely based on [formatting guidelines](https://ih.pmf.ukim.edu.mk/tabs/view/4ed73e984d2647d8ff6e00f78b569286) by the Department of Chemistry, part of the Faculty of Natural Sciences.

Primarily appropriate for undergraduate degrees, but probably applicable to higher degrees as well. 

# Quickstart

Your most important parts of the template are the ones placed at the top of the examples: 

- **title-mk** - refers to the title in Macedonian. 
- **title-en** - refers to the title in English
- **institution** - the institution (department, faculty, university)
- **logo** - the image on the cover. By default, this is the UKIM logo, but you can easily change this by 
- **author** - your name
- **year** - year completed
- **location** - location of the department
- **mentor** - your mentor
- **committee** - the three members of your committee including your mentor                                                
- **defense-date** - optional defense date 
- **promotion-date** - optional promotion date
- **abstract-mk** - abstract in Macedonian
- **keywords-mk** - keywords in Macedonian
- **abstract-en** - abstract in English
- **keywords-en** - keywords in English
- **dedication** - optional dedication to family members, students, advisors...

# Bibliography / Користена литература
At the bottom of the main page you can add a bibliography section:

```
#bibliography("biblio.yml", title: "Користена литература")
```

The blibliography in the "biblio.yml" file should look something like this, with a new section for each cited resource:
```
avtor:
    type: Article
    author:
        - Avtorski, Avtor
        - Drug, Avtor
        - Tret, Avtor
    title:
        value: "Some Paper: A paper about something that happens somewhere"
        verbatim: true
    date: 2025
    page-range: 1-10
    serial-number:
        doi: 00.0000/0000000.00000000
    parent:
        - type: Proceedings
          title: Journal of Something That Happens
          publisher: Association for Some Kind of Research
          location: Skopje, Macedonia
          serial-number: { isbn: "000-000000000" }
```
