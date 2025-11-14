/*
Autor kódu: davidmalasek (David Malášek)

MIT License

Copyright (c) 2024 David Malášek

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Zdroj: https://github.com/davidmalasek/sklonovani-jmen
*/
#import "@preview/pyrunner:0.3.0" as py
#let genitiv-supervisor = py.compile(
  ```python
# Koho, čeho?


def genitiv(input_jmena):
    output = []
    if " " in input_jmena:
        jmena = input_jmena.split(" ")
    else:
        jmena = [input_jmena.lower()]

    for jmeno in jmena:
        jmeno = jmeno.lower()
        if jmeno[-1] == "a":
            if jmeno[-2] in ["d", "n"]:  # Anna, Linda
                output.append(jmeno[0:-1] + "y")
            elif jmeno[-2] in ["č", "j"]:  # Ivča, Kája
                output.append(jmeno[0:-1] + "i")
            elif jmeno[-2] == "ď" or jmeno[-2] == "c":  # Láďa, Danica
                output.append(jmeno[0:-1] + "i")
            elif jmeno[-2] == "g":  # Olga
                output.append(jmeno[0:-1] + "y")
            elif jmeno[-2] == "i":  # Olivia
                output.append(jmeno[0:-1] + "e")
            elif jmeno[-2] == "k":  # Eliška
                output.append(jmeno[0:-1] + "y")
            elif jmeno[-2] == "l" and jmeno[-3] == "v":  # Pavla
                output.append(jmeno[0:-1] + "y")
            elif jmeno[-2] == "l":  # Fiala, Nikola
                output.append(jmeno[0:-1] + "y")
            elif jmeno[-2] == "o":  # Figueroa
                output.append(jmeno)
            elif jmeno[-2] == "r":  # Klára, Svoboda, Kučera
                output.append(jmeno[0:-1] + "y")
            elif jmeno[-2] == "t":  # Alžběta
                output.append(jmeno[0:-1] + "y")
            elif jmeno[-2] == "v":  # Eva
                output.append(jmeno[0:-1] + "y")
            elif jmeno[-2] == "z":  # Honza, Tereza
                output.append(jmeno[0:-1] + "y")
            elif jmeno[-2] == "ň":  # Soňa
                output.append(jmeno[0:-2] + "ni")
            elif jmeno[-3] == "c" or jmeno[-2] == "h":  # Průcha
                output.append(jmeno[0:-1] + "y")
            elif jmeno[-2] in ["e", "š"]:  # Nataša, Andrea, Lea
                if jmeno[-3] == "r":
                    output.append(jmeno[0:-1] + "ji")
                else:
                    output.append(jmeno[0:-1] + "i")
            else:
                output.append(jmeno[0:-1] + "y")
        elif jmeno[-1] == "á":
            output.append(jmeno[0:-1] + "é")
        elif jmeno[-1] == "e":
            if jmeno[-2] == "g":  # George
                output.append(jmeno)
            elif jmeno[-2] == "e" or jmeno[-2] == "o":  # Lee, Zoe
                output.append(jmeno)
            elif (
                jmeno[-2] == "i" or jmeno[-2] == "c" or jmeno[-2] == "š"
            ):  # Lucie, Alice, Danuše
                output.append(jmeno)
            else:
                output.append(jmeno[0:-1] + "i")
        elif jmeno[-1] == "h" or jmeno[-1] == "i":
            if jmeno[-2] == "c":  # Bedřich, Vojtěch
                output.append(jmeno + "a")
            else:  # Sarah, Niki
                output.append(jmeno)
        elif jmeno[-1] == "k":
            if jmeno[-2] == "e":  # Malášek
                output.append(jmeno[0:-2] + "ka")
            elif jmeno[-2] == "ě":
                if jmeno[-3] == "n":  # Zbyněk
                    output.append(jmeno[0:-3] + "ňka")
                elif jmeno[-3] == "d":  # Luděk
                    output.append(jmeno[0:-3] + "ďka")
                elif jmeno[-3] == "n":  # Vaněk
                    output.append(jmeno[0:-3] + "ňka")
            else:  # Novák
                output.append(jmeno + "a")
        elif jmeno[-1] == "l":
            if jmeno[-2] == "e":
                if jmeno[-3] in ["c", "i", "u"]:  # Marcel, Samuel, Gabriel
                    output.append(jmeno + "a")
                else:  # Karel
                    output.append(jmeno[0:-2] + "la")
            elif jmeno[-2] == "o" and jmeno[-3] == "k":  # Nikol
                output.append(jmeno)
            elif jmeno[-2] in ["a", "i", "o", "s"]:  # Michal, Bohumil, Anatol, Přemysl
                output.append(jmeno + "a")
            else:  # Král
                output.append(jmeno + "e")
        elif jmeno[-1] == "m":
            if jmeno[-2] == "a":  # Miriam
                output.append(jmeno)
            else:  # Maxim
                output.append(jmeno + "a")
        elif jmeno[-1] == "o":
            if jmeno[-2] == "t":  # Oto
                output.append(jmeno[0:-1] + "y")
            else:  # Ronaldo, Santiago
                output.append(jmeno[0:-1] + "a")
        elif jmeno[-1] == "r":
            if jmeno[-2] == "a" or jmeno[-2] == "e":  # Dagmar, Ester
                if (
                    jmeno[-3] == "k"
                    or jmeno[-3] == "m"
                    or jmeno[-3] == "p"
                    or jmeno[-3] == "l"
                ):  # Otakar, Otmar, Kašpar
                    output.append(jmeno + "a")
                else:
                    output.append(jmeno)
            else:
                output.append(jmeno + "a")
        elif jmeno[-1] == "y" or jmeno[-1] == "í" or jmeno[-1] == "é":
            if jmeno[-2] == "l":  # Emily
                output.append(jmeno)
            else:  # Harry, Jiří, René
                output.append(jmeno + "ho")
        elif jmeno[-1] == "ý":
            output.append(jmeno[0:-1] + "ého")
        elif jmeno[-1] == "d":
            if jmeno[-2] == "n":  # Zikmund
                output.append(jmeno + "a")
            else:  # Ingrid
                output.append(jmeno)
        elif jmeno[-1] == "c":
            if jmeno[-2] == "n":  # Vincenc
                output.append(jmeno[0:-1] + "e")
            else:
                if jmeno[-2] == "l":  # Šolc
                    output.append(jmeno + "e")
                else:  # Vavřinec
                    output.append(jmeno[0:-2] + "ce")
        elif jmeno[-1] == "ž":
            output.append(jmeno + "e")
        elif jmeno[-1] == "t":
            if jmeno[-2] == "í":  # Vít
                output.append(jmeno + "a")
            else:  # Růt
                output.append(jmeno)
        elif jmeno[-1] == "ů":  # Petrů
            output.append(jmeno)
        elif jmeno[-1] in ["c", "j", "ř", "š"]:  # Tomáš, Ondřej, Kadlec
            output.append(jmeno + "e")
        elif jmeno[-1] == "x" or jmeno[-1] == "s":  # Max, Nikolas
            output.append(jmeno + "e")
        else:
            output.append(jmeno + "a")
    output = [item.capitalize() for item in output]
    return " ".join(output)
  ```.text
)