#import "@preview/mitex:0.2.7": *
#import "@preview/physica:0.9.8": *
#import "@preview/chemformula:0.1.3": *
#import "@preview/fei-thesis:0.0.2": *

= Štruktúra záverečnej práce <sec:StrukturaPrace>
Za záverečnú prácu považujeme bakalársku, diplomovú
a~dizertačnú prácu @zakon1312002.
Práca napísaná v~slovenskom jazyku má tieto časti @vyhlaska2332011 @usmernenie562011:

+ Úvodná časť
  + obal
  + titulný list
  + zadanie
  + poďakovanie (nepovinné)
  + abstrakt v slovenskom jazyku
  + abstrakt v anglickom jazyku
  + obsah
  + zoznam ilustrácií, obrázkov (nepovinné)
  + zoznam tabuliek (nepovinné)
  + zoznam skratiek a značiek (odporúčané)
+ Hlavná textová časť
  + úvod
  + jadro
    - súčasný stav riešenej problematiky doma a v zahraničí
    - cieľ práce
    - metodika práce a metódy skúmania
    - výsledky práce
    - diskusia
  + záver
  + zoznam použitej literatúry
+ Záverečná časť
  + dodatky (podľa potreby)
  + prílohy (podľa potreby)

== Úvodná časť práce
Hlavným obsahom úvodnej časti sú formálne náležitosti práce a musia byť zaradené v~poradí podľa zoznamu v~úvode tejto kapitoly.

=== Obálka, titulný list, zadanie
Začiatočné stránky práce automaticky generuje univerzitný
informačný systém AIS vo formáte PDF.
Môžeme ich do záverečnej práce vložiť pomocou funkcie `fei-assignment()`,
ktorá vloží PDF súbor so zadaním na samostatné stránky.
Aby boli všetky informácie aktuálne,
treba venovať pozornosť vyplneniu údajových
premenných v~úvode hlavného súboru `main.typ`. @GSM

Zadanie vložíme v~hlavnom súbore `main.typ` nasledovne:
```typst
#fei-assignment("includes/assignment.pdf", pages: 2)
```
kde prvý parameter je cesta k PDF súboru so zadaním a~parameter `pages`
špecifikuje počet strán, ktoré chceme vložiť.

=== Poďakovanie
Nepovinná, ale veľmi obľúbená časť práce.
Je umiestnené na samostatnej strane zväčša v~dolnej časti.
Jej obsah je ponechaný na autora.
Obsah poďakovania sa nachádza v~súbore
`includes/thanks.typ` a~do hlavného dokumentu sa vloží pomocou funkcie `fei-thanks`:
```typst
#fei-thanks[#include "includes/thanks.typ"]
```

=== Slovenský a anglický abstrakt

Definícia abstraktu vychádza z technickej normy STN ISO 214 Dokumentácia.
Abstrakty (referáty) pre publikácie a dokumentáciu @iso214.
Termín abstrakt je skrátené, presné vyjadrenie obsahu
bez pridanej interpretácie a kritiky.
Mal by poskytovať čo najviac informácií obsiahnutých v~dokumente.

Abstrakt si netreba zamieňať s termínmi anotácia,
extrakt alebo rezumé.
Anotácia je stručná poznámka, alebo vysvetlenie,
prípadne veľmi stručný opis dokumentu alebo jeho obsahu.
Extrakt predstavuje časti dokumentu vybratých
na reprezentáciu celku.
Rezumé obsahuje stručné zopakovanie významných prínosov
a~záverov v práci.
Nachádza sa zvyčajne na konci dokumentu
a~slúži na doplnenie orientácie čitateľa,
ktorý študoval predchádzajúci text.
Ak je práca napísaná v~anglickom jazyku,
musí obsahovať rezumé v~slovenčine.
V~slovenskej práci nemusí byť rezumé.

==== Účel a použitie abstraktov

- _„Dobre vypracovaný abstrakt umožní čitateľom identifikovať
  základný obsah dokumentu, rýchlo a presne stanoviť jeho
  relevanciu, a tak sa rozhodnúť, či potrebujú čítať celý
  dokument."_

- _„Čitatelia, pre ktorých predstavuje dokument len okrajový
  záujem, často získajú z~abstraktu dostatok informácií a nemusia
  čítať celý dokument."_

- _„Abstrakty sú často cenné aj pri automatickom vyhľadávaní
  v~plných textoch na získanie predbežných informácií a na
  informačný prieskum."_

#align(right)[(Citované z normy STN ISO 214 @iso214)]

Podľa metodického usmernenia Ministerstva školstva, vedy, výskumu a športu SR č. 56/2011 (čl. 1, ods. 1)
_„abstrakt obsahuje informáciu o cieľoch práce,
jej stručnom obsahu a~v~závere abstraktu
sa charakterizuje splnenie cieľa,
výsledky a~význam celej práce.
Súčasťou abstraktu je 3 -- 5 kľúčových slov.
Abstrakt sa píše súvisle ako jeden odsek a jeho rozsah je
spravidla 100 až 500 slov"_ @usmernenie562011.

Text slovenského a~anglického abstraktu sa nachádzajú
v~súboroch `abstractSK.typ` a~`abstractEN.typ` v~priečinku `includes`.

Do dokumentu sa vložia pomocou funkcie `abstract()` v~hlavnom súbore `main.typ`:
```typst
#abstract(
  [
    #include "includes/abstractSK.typ"
  ],
  lang: "sk",
)

#abstract(
  [
    #include "includes/abstractEN.typ"
  ],
  lang: "en",
)
```
Funkcia automaticky vypíše abstrakt s~príslušným jazykom
a~pod abstraktom zobrazí zoznam kľúčových slov podľa nastaveného jazyka.

=== Obsah a zoznamy

Obsah je povinný prehľad jednotlivých kapitol
a~častí práce s~uvedením nadpisov a~strán.
Začína na samostatnej stránke ako nová kapitola
s~nadpisom Obsah bez číslovania,
ktorý sa ale v~samotnom prehľade kapitol nezobrazí.

V~Typste zabezpečuje generovanie obsahu funkcia `fei-outline()`,
ktorá v~mieste použitia vloží automatický zoznam kapitol s~číslami strán.
Obsah sa vytvára automaticky na základe použitých nadpisov.
Na rozdiel od LaTeX-u nie je potrebné spúšťať kompiláciu viackrát.

V tejto šablóne sa v~hlavnom súbore `main.typ` používa:
```typst
#fei-outline()
```

==== Zoznam ilustrácií, obrázkov a tabuliek

Sú to nepovinné prehľady tzv. plávajúcich objektov.
V~Typste sa dajú vytvoriť pomocou funkcie `outline()` s~parameterom `target`,
ktorý špecifikuje typ objektu (obrázky alebo tabuľky).

Príklad pre zoznam obrázkov:
```typst
#outline(
  title: [Zoznam obrázkov],
  target: figure.where(kind: image),
)
```

Príklad pre zoznam tabuliek:
```typst
#outline(
  title: [Zoznam tabuliek],
  target: figure.where(kind: table),
)
```

Ak zoznamy v~práci nechceme, môžeme príslušné príkazy z~hlavného súboru
`main.typ` vymazať alebo ich označiť ako komentár.

==== Zoznam skratiek a značiek

V textových výstupoch vedecko-technických odborov sa používa
množstvo značiek a~skratiek najmä na označenie fyzikálnych
veličín v matematických vzťahoch,
ale aj zostručnenie textového prejavu najmä pri zložitých názvoch
vedeckých metód, zariadení alebo javov.
Sú to napríklad RTG (röntgenové žiarenie),
AFM (mikroskop atómových síl),
TEM (transmisný elektrónový mikroskop),
IR (infračervené žiarenie),
AC (obvod striedavého prúdu) a~mnoho iných.
Ak sa v práci objavia, musí ich autor pri ich prvom výskyte
jasne zadefinovať,
prípadne vysvetliť anglický preklad.
Rovnako to platí pre všetky použité fyzikálne veličiny.

Aj keď je tento zoznam nepovinná súčasť práce,
odporúčame ho zaradiť kvôli lepšej orientácii čitateľa.
Zoznam má podobu slovníka,
značky uvádzame v~abecednom poradí.

Šablóna používa balík `abbr` na automatizáciu práce so skratkami a~značkami v~texte.
Skratky sa definujú v~CSV súbore `includes/glossary.csv` a~do textu sa vložia
pomocou funkcie `abbr.show-rule` v~šablóne.

Skratky definujeme v~súbore `includes/glossary.csv` v~nasledujúcom formáte:
```
skratka, plný text
AI, Artificial Intelligence
STU, Slovenská technická univerzita
```

Zoznam skratiek a značiek sa automaticky vygeneruje v~hlavnom súbore `main.typ`
pomocou funkcie `fei-list-of-glossaries()`:

==== Manuálny zoznam fyzikálnych veličín a~matematických symbolov

Automatické riešenie pomocou CSV súboru úplne zlyháva pri práci s~veličinami,
ktorých zoznam predstavuje praktickú pomôcku najmä vo fyzikálnych a~matematických oblastiach.
Na označovanie veličín používame rôzne symboly a~ich modifikácie,
napríklad písmená gréckej abecedy ($alpha, omega, xi$),
symboly so šípkami v~prípade vektorov ($arrow(r), arrow(phi), arrow(i)$),
preškrtnuté h ($hbar$), zdvojené symboly ako $ZZ$,
prípadne aj niečo takéto: $aleph_0$, čo je hebrejské písmeno alef.

Pre takéto prípady je najlepšie použiť _ručný zoznam_ v~samostatnom súbore.
Vytvoríme súbor `includes/manual_glossaries.typ`

Zoznam si môžeme postupne vytvárať pri písaní a~udržiavať ho v~abecednom poradí.

Pri práci s~fyzikálnymi veličinami a~matematickými symbolmi sa odporúča
poznamenať ich definíciu pri prvom výskyte v~texte.
Prípadne si vytvoríme dodatočný zoznam veličín, ktorý umiestníme do dodatkov.

==== Zoznamy algoritmov a výpisov kódov programov

Zoznam výpisov kódov sa vytvorí pomocou funkcie `fei-outline-code()` v~hlavnom súbore `main.typ`:
```typst
#fei-outline-code()
```

Táto funkcia je špecifická pre informatické odbory a~automaticky zbiera všetky kódové výpisy
(figure s~kind: raw) a~vytvorí ich zoznam.

Ak v~práci nemáme výpisy kódov,
bude potrebné tento riadok z~hlavného súboru `main.typ` vymazať.
O~uvádzaní časti kódov a~zápisov algoritmov píšeme v kapitole @sec:listings.

== Hlavná textová časť

Samotný autorský obsah práce začína až tu.
Tradične text členíme na úvod, jadro a~záver,
pričom úvod a~záver sú samostatné kapitoly,
ktoré nečíslujeme a~je vhodné,
ak ich označíme nadpismi _Úvod_ a _Záver_.
Strednú časť -- jadro -- neoznačujeme.

=== Úvod

Prvá kapitola hlavnej časti práce má názov úvod, nečíslujeme ju.
Ide o~ucelený text v~rozsahu niekoľkých súvislých odsekov textu,
v~ktorých stručne a~výstižne charakterizujeme stav poznania
a~praxe v~danej oblasti,
oboznámime čitateľa s~cieľmi a~závermi práce.
Nosnou myšlienkou úvodu okrem uvedenia čitateľa do problematiky
je jasná motivácia autora a~jeho postoje,
ktoré viedli k~spracovaniu témy práce @GSM.

Nepísané pravidlo hovorí,
že úvod a~záver práce sa píšu až ako posledné.
Tento poznatok vyplýva z~praxe a~má dva dôvody:
1. na začiatku nemusí byť úplne zrejmé, čo všetko sa v~práci naozaj objaví;
2. úvod predstavuje samostatnú literárnu formu,
na ktorej sa neskúsený autor zasekne už na začiatku.
Aby sme sa tomu vyhli,
necháme si jeho napísanie až na záver,
keď už bude väčšina hlavného obsahu práce hotová.

Text úvodu sa nachádza v~súbore `includes/introduction.typ`
a~do hlavného dokumentu sa vloží pomocou funkcie `introduction`:
```typst
#introduction[#include "includes/introduction.typ"]
```

=== Jadro

Táto časť práce _nezačína_ nadpisom _Jadro_.
Obsah jadra členíme zvyčajne na niekoľko číslovaných
kapitol počínajúc číslom 1.
Prvá kapitola býva prehľad súčasného stavu problematiky,
ale môže mať aj iný názov,
napríklad _Teoretická časť,_ alebo rovno názov oblasti,
o~ktorej sa v nej bude písať
(trebárs _Metóda prenosových matíc_).

Pri písaní strednej časti práce nemusíme postupovať úplne
striktne podľa tohto návodu.
Treba však pamätať na to,
aby sme jasne oddelili poznatky,
ktoré pochádzajú od iných autorov,
a~sú súčasťou všeobecného prehľadu,
od poznatkov a~výsledkov samotnej práce autora.
Nemusia byť oddelené fyzicky v~rôznych odsekoch,
či kapitolách, z~textu však musí byť jasné,
ktoré výsledky sú originálne a~ktoré sú prebrané.
Odporúčaná štruktúra tejto časti je na
strane~<@sec:StrukturaPrace>.

Samotný obsah jadra sa nachádza v~súbore `includes/core.typ`.
Do hlavného dokumentu `main.typ` sa načíta pomocou funkcie `main-matter`:
```typst
#main-matter[#include "includes/core.typ"]
```

Ak je `core.typ` príliš obsiahly,
môžeme jednotlivé kapitoly uložiť do samostatných
súborov a~tie načítať do `core.typ`
pomocou príkazu `#include "includes/chapter1.typ"`.

==== Súčasný stav riešenej problematiky doma a~v~zahraničí

Podľa zvyklostí by malo približne 30% práce obsahovať prehľad
súčasného stavu a~poznatkov v~oblasti,
ktorej sa týka predkladaná práca.
Ide o~veľmi dôležitý aspekt,
ktorým študent preukáže,
že je schopný problematiku naštudovať,
porozumieť jej a~napísať o~nej súvislý text.
Dokáže na základe existujúcich poznatkov vysvetliť javy,
ktoré v~práci študuje.

Kľúčová činnosť pri príprave textu je štúdium prác publikovaných
u~nás a~v~zahraničí.
Nejde iba o~to, že autor píše myšlienky, ktoré sa kdesi dozvedel,
mal by tiež poznať ich primárne zdroje,
správne s~nimi pracovať a~citovať ich.
Dôležitý prínos študenta spočíva v~spájaní viacerých poznatkov
z~rôznych zdrojov do nového celku.

==== Cieľ práce

Bakalárska a diplomová práca má jasne uvedené ciele v zadaní práce. Nie je preto nutné uvádzať samostatnú kapitolu, kde budú ciele ešte raz vymenované. Je však žiadúce, ak sa zmienka o jednotlivých cieľoch v texte vyskytuje a poukazuje sa na ich splnenie, nesplnenie, prípadne ak hlavné ciele pozostávajú z čiastkových cieľov, treba ich jasne špecifikovať.

==== Metodika práce a metódy skúmania

V experimentálnych prácach býva v tejto časti podrobne zdokumentované prístrojové vybavenie, riadiaci a simulačný softvér, laboratórne podmienky a podobne. Metodické usmernenie @GSM odporúča nasledujúci obsah tejto časti práce: a) charakteristika objektu skúmania, b) pracovné postupy, c) spôsob získavania údajov a ich zdroje, d) použité metódy vyhodnotenia a interpretácie výsledkov, e) štatistické metódy.

==== Výsledky práce a diskusia

Študent zaujme k získaným výsledkom jasné postoje,
porovnáva ich s inými autormi, prípadne navrhuje ich ďalšie aplikácie.
Zhodnotí a~komentuje ich na základe štatistického spracovania dát (smerodajné odchýlky, priemery, regresie a podobne).
Odporúčame, aby táto časť tvorila 30 až 40 percent záverečnej práce.
Môžeme ju rozdeliť na dve samostatné podkapitoly: sumarizáciu výsledkov a~diskusiu formou eseje.

=== Záver

Záver práce predstavuje samostatnú nečíslovanú kapitolu
v~rozsahu niekoľkých odsekov alebo strán.
Obsahuje zhrnutie výsledkov vo vzťahu k~stanoveným cieľom~@GSM.
Rovnako, ako pri úvode, treba si dať
aj na kompozícii záveru zvlášť záležať.
Väčšina čitateľov si prečíta v~prvom rade úvod a~záver práce,
aby zistili, či im stojí za to pustiť sa do podrobnejšieho
štúdia celého textu.
Aj oponent vychádza najmä z dobre spracovaného záveru.

Jasne deklarujeme splnenia cieľov a naznačíme ďalšie možné smerovanie študovanej problematiky. Vyjadrujeme sa pozitívne. Ak sa nepodarilo úplne naplniť niektorú z~pôvodných predstáv, nerozpisujeme sa o tom.

Ako príklad použijeme nepríjemnú modelovú situáciu,
ktorá môže počas výskumu nastať.
Povedzme, že cieľ záverečnej práce bol odmerať
optické parametre tenkých $T i O_2$ vrstiev.#footnote[$T i O_2$ je chemická značka oxidu titaničitého,
  ktorý sa používa napríklad pri solárnych článkoch
  ako priehľadná vrchná elektróda.
  Ide totiž o~typ oxidu s~vlastnosťami polovodičov,
  čiže môže za určitých podmienok viesť elektrický prúd.
  Zároveň je pre viditeľné svetlo priehľadný,
  čo nebýva pri polovodičoch bežné.
  Optické a~elektrické vlastnosti vrstvy $T i O_2$
  často závisia od parametrov technologického procesu.]
Z~dôvodu havárie zariadenia sa nepodarilo takéto vzorky získať
a~v~skutočnosti sme mohli pracovať iba
s~tradičnými $S i O_2$ vrstvami.#footnote[Oxid kremičitý sa v~mikroelektronike používa
  ako nevodivá izolačná vrstva.
  Jeho materiálové vlastnosti sú veľmi dobre preskúmané
  a~všeobecne známe.
  S~jeho amorfnou formou sa v~každodennom živote bežne stretávame,
  je to obyčajné sklo.]
Vzniknutú situáciu zhodnotíme v~závere vecne a~pravdivo:

#block(
  inset: 1em,
  fill: rgb("#f5f5f5"),
)[
  #emph[Aj napriek poruche technologického zariadenia sme
    dokázali zabezpečiť náhradné vzorky a realizovať merania
    optických vlastností tenkých vrstiev termálneho
    #ch("SiO2").
    Poznatky, ktoré sme získali pri práci s~pokročilými
    experimentálnymi zariadeniami následne využijeme vo výskume
    materiálových vlastností #ch("TiO2") vrstiev.
    V~diskusii sme naznačili možné rozšírenie existujúcich
    metód na tento druh materiálu.]
]

Ak priznáme, že zariadenie sa pokazilo
a tým pádom sme nesplnili ciele,
stane sa záverečná práca neobhájiteľnou.
Nasledujúci príklad je ukážka takejto nevhodnej formulácie:

#block(
  inset: 1em,
  fill: rgb("#f5f5f5"),
)[
  #emph[Počas prípravy tenkých vrstiev došlo k neočakávanej
    poruche technologického zariadenia,
    ktorá znemožnila výrobu plánovaných vzoriek.
    Merania optických parametrov #ch("TIO2")
    sme preto nerealizovali.
    Veríme, že experimenty s~náhradnými vzorkami tenkých vrstiev
    termálneho #ch("SiO2") pomôžu v~budúcnosti
    aj pri výskume iných materiálov.]
]

Text obsahuje tri zápory, je pesimistický,
s~nejasným výhľadom do budúcnosti.
Cítiť z~neho sklamanie a~frustráciu zo vzniknutej situácie,
ktorá sa javí ako neriešiteľná.
Jednoznačne sme priznali nesplnenie cieľa.
Aj keď sme urobili úspešné náhradné merania,
z~textu to nie je zrejmé.
Záverečné tvrdenie o~možnosti využitia výsledkov
v~sebe navonok ukrýva istú nádej,
v~skutočnosti však iba potvrdzuje to,
že chceme mať toto fiasko čím skôr za sebou.

Pozor ale aj na prílišnú pozitivitu.
Tá môže, paradoxne, nedostatky ešte viac zvýrazniť.
Nasledujúca ukážka je síce optimistická,
avšak do textu práce taktiež nevhodná:

#block(
  inset: 1em,
  fill: rgb("#f5f5f5"),
)[
  #emph[Vďaka drobnej poruche technologického zariadenia sme
    mohli realizovať merania optických vlastností tenkých vrstiev
    termálneho #ch("SiO2") a~získať tak unikátne výsledky.
    Nesmierne bohaté skúsenosti s~najkvalitnejšími meracími
    aparatúrami využijeme aj v~nadväzujúcom výskume.
    Rozšírenie nadobudnutých kompetencií na iné materiály
    považujeme za najväčší prínos predkladanej práce.]
]

V tomto príklade vidieť prílišnú snahu zahladiť škody
a~vychvaľovať sa výsledkami,
ktoré v~skutočnosti nemajú zvláštny význam.
Je totiž málo pravdepodobné,
aby s~#ch("SiO2") vznikli unikátne výsledky.
Text obsahuje nevhodné absolútne kvantifikátory
(_nesmierne bohaté skúsenosti, najkvalitnejšie aparatúry,
najväčší prínos_);
bagatelizuje nehodu, dokonca jej ďakuje
(_vďaka drobnej poruche_),
čím na ňu zbytočne upozorňuje;
zámerne sa nezmieňuje o~pôvodných #ch("TiO2") vrstvách.
Nadužívaním cudzích slov (_kompetencie_)
autori zväčša maskujú rôzne nedostatky,
napríklad vlastnú neistotu.

Zapamätáme si, že vedecký text musí byť jasný, pravdivý a vecný.
Očistíme ho od akýchkoľvek citových výlevov v prvom rade tým,
že sa vyhýbame extrémnym kvantifikátorom. Nepoužívame ani tieto:
_všetci, nikdy, žiaden, každý jeden,_
pokiaľ nepíšeme matematické vety alebo logické výrazy.
Ak sa napríklad nepodarilo naprogramovať ani jeden fungujúci kód,
nenapíšeme,
že _žiaden program, ktorý sme sa snažili vytvoriť nefunguje_.
Povieme to miernejšie: _snaha o~vytvorenie funkčného
programu viedla k~menej presvedčivým výsledkom_.
Negatívnu skutočnosť formulujeme pozitívne.

Ani pozitívne prínosy zbytočne nepreceňujeme.
Necháme ich, nech sa chvália samé.
Namiesto prehnaného zdôrazňovania:
_Úžasné výsledky všetkých meraní sme dosiahli
vďaka perfektne pripraveným vzorkám_,
napíšeme vecne:
_Jednotlivé merania boli úspešné aj
vďaka kvalitným vzorkám._

Súbor so záverom v~priečinku `includes` má
názov `conclusion.typ`
a~do dokumentu sa dostane prostredníctvom funkcie `fei-conclusion`
v~hlavnom súbore projektu `main.typ`:
```typst
#fei-conclusion[#include "includes/conclusion.typ"]
```

== Zoznam použitej literatúry

Citované zdroje označujeme v texte číslom v hranatých zátvorkách.
Ide o poradové číslo uvedenia publikácií tak, ako sa postupne s nimi v texte pracuje.

Po kapitole _Záver_ nasleduje ďalšia nečíslovaná kapitola
s názvom _Literatúra_,
ktorá obsahuje číslovaný zoznam všetkých
citovaných literárnych zdrojov v spomínanom poradí.
Forma tohto zoznamu je pomerne komplikovaná a~podrobne
ju opisuje norma ISO 690: 2023 Dokumentácia -- Bibliografické odkazy -- Obsah, forma a~štruktúra @iso690.
V~Typste sa bibliografia vygeneruje automaticky z~BibTeX súboru `bibliography.bib`.

Bibliografiu vložíme v~hlavnom súbore `main.typ` nasledovne:
```typst
#bibliography("bibliography.bib")
```

Podrobne sa citáciám budeme venovať v kapitole @sec:citation.

=== Záverečná časť

Na záver práce uvádzame dodatky a prílohy.
Prílohy práce sú zväčša materiály,
ktoré majú odlišný formát voči samotnej práci.
Sú to napríklad pamäťové nosiče,
dátové súbory, veľkoformátové mapy, výkresy a podobne.
Každú prílohu treba jasne označiť, očíslovať a nazvať.
Zoznam príloh potom uvedieme v jednom z dodatkov.

Do tzv. dodatkov umiestňujeme informácie,
ktoré kvôli rozsahu nemôžu byť v hlavnom texte práce.
Sú to napríklad údajové listy k použitým prístrojom
a~zariadeniam, zdĺhavejšie matematické odvodenia,
rozsiahlejšie kódy programov, dokumentácia
k vytvoreným programom, definície neštandardných objektov,
ktoré v práci používame,
série rozsiahlych výsledkov alebo meraní
a ich grafy, fotografie a podobne.

Jednotlivé kapitoly v~dodatkoch číslujeme veľkými písmenami,
čísla podkapitol majú formu A.1, B.3.2, atď.
Na tento účel vytvoríme pre každý dodatok samostatný súbor v~priečinku `includes/`,
odporúčame názov súboru v~tvare `appendixA.typ` alebo podobne.
Každý dodatok je potom potrebné načítať v~hlavnom súbore `main.typ` nasledujúcim spôsobom:

```typst
#appendix([#include "includes/appendixA.typ"], [Názov dodatku])
```

Prvý parameter funkcie je obsah dodatku, druhý parameter je názov dodatku,
ktorý sa automaticky očísluje veľkým písmenom.

= Formát a jazyk <sec:formatLanguage>

== Formát dokumentu

Rozmery stránky, typy písma, veľkosti, riadkovanie,
medzery medzi odsekmi, formát nadpisov, obrázkov, tabuliek,
rovníc a ďalšie vizuálne parametre záverečnej práce
rešpektujú do maximálnej miery normu STN 01 6910: 2023
Pravidlá písania a úpravy písomností @stn016910.

=== Rozmery strany

Veľkosť bežnej textovej strany záverečnej práce je A4,
t.~j. 21 cm × 29,7 cm.
Pravý a ľavý okraj majú šírku 2,75 cm,
horný a dolný okraj majú výšku 3 cm.
Päta stránky, v ktorej sa nachádza číslo strany,
je od spodnej hrany stránky vzdialená o 1,25 cm.
Šírka textu je 15,5 cm, jeho výška 23,7 cm.
Horný a dolný okraj obálky sú z estetických
dôvodov zmenšené na 2 cm.

=== Písmo a riadkovanie

Základný font šablóny je normálny rez tzv. antikvového písma
s~veľkosťou 12 pt.
V~tejto šablóne je to New Computer Modern.
Vhodné sú aj iné fonty s~pätkami ako Times, Georgia, Palatino a~podobne.
Na obálke a~titulnom liste používame bezpätkový (grotesk) font Latin Modern.
Jednotlivé typy odsekov (nadpisy, poznámky a pod.)
majú jednotný typ písma,
odlišnosti vyjadrujeme rezom (polotučné písmo, kurzíva)
alebo veľkosťou.

Parameter `leading` v~šablóne má hodnotu 10,5 pt,
čo zabezpečuje vhodný odstup medzi riadkami textu.

=== Nadpisy

Šablóna záverečnej práce FEIstyle používa v~Typste rôzne úrovne nadpisov.
Nadpis najvyššej úrovne je `=` zodpovedajúci kapitole.
Podkapitoly sa definujú pomocou `==` a~`===`.
Číslovanie kapitol a~podkapitol je viacúrovňové typu X.Y.Z,
kde X je číslo kapitoly, Y je číslo podkapitoly a~Z je číslo časti podkapitoly.
Číslovanie vyšších úrovní nie je definované.
Tvar a~forma nadpisov zodpovedá norme STN ISO 2145: 1978 Dokumentácia.
Číslovanie oddielov a~pododdielov písaných dokumentov @iso2145.

Nová kapitola sa začína s~nadpisom prvej úrovne (`=`).
Typst automaticky preskakuje na novú stranu pri kapitole prvej úrovne
a~vysádza všetky plávajúce objekty (obrázky, tabuľky, výpisy kódu),
ktoré sa nepodarilo umiestniť na príslušné miesto v~texte.

== Jazyk a gramatika

Záverečná práca na FEI STU v Bratislave musí byť napísaná
buď po slovensky alebo po anglicky.
Ak je jazyk práce angličtina, musí po závere nasledovať
rezumé v slovenskom jazyku.

Záverečná práca univerzitného štúdia sa vyznačuje
vysokou jazykovou úrovňou.
Gramatické a štylistické chyby sú neprípustné.
Študent by mal tejto stránke diela venovať patričnú
pozornosť a podľa možností nechať rukopis prejsť
kvalifikovanou jazykovou kontrolou.
Najmä bakalárska práca predstavuje v živote väčšiny študentov
prvý rozsiahlejší autorský útvar,
ktorý má významný vplyv na jeho ďalší život a kariéru.

Aj keď väčšina textových editorov dokáže odhaľovať preklepy,
neporadí si s komplikovanejšou gramatikou a štylistikou.
Treba sa riadiť najmä pravidlami slovenského pravopisu,
slovníkmi slovenského jazyka a ďalšími zdrojmi,
ktoré možno nájsť na webových stránkach
Jazykovedného ústavu Ľudovíta Štúra SAV.#footnote[#link("https://www.juls.savba.sk/")[www.juls.savba.sk]]
Využiť môžeme aj jazykovu poradňu,
ktorú poskytuje ústav bezplatne a to buď telefonicky alebo
prostredníctvom emailovej komunikácie.
Cenným zdrojom informácií môže byť aj Jazyková poradňa
denníka SME v spolupráci
s Jazykovedným ústavom Ľudovíta Štúra SAV#footnote[#link("https://jazykovaporadna.sme.sk/")[jazykovaporadna.sme.sk]]
alebo online slovníky slovenského jazyka,#footnote[#link("https://slovnik.juls.savba.sk/")[slovnik.juls.savba.sk]]
prípadne národný jazykový korpus.#footnote[#link("https://korpus.sk/")[korpus.sk]]

Pri písaní práce dbáme najmä na pravopisné javy ako sú písanie
tvrdého a mäkkého y/i vo vybraných slovách,
v príponách a koncovkách pri skloňovaní
(pekný muž, ale pekní muži),
v číslovkách (rozprávali sme sa so siedmimi v poradí
-- skončili siedmi v poradí,
ale hrali sme sa so siedmymi deťmi -- detí bolo sedem), atď.
Rovnako dôležité je správne písanie rodov,
skloňovanie a časovanie.

Veľmi komplexná a dôležitá zložka gramatiky
je písanie čiarok v súvetiach.

Popri gramatike je podstatná aj štylistická tvorba viet,
ktorú musí študent univerzity zvládať na vysokej úrovni.

=== Delenie slov

Tzv. _textové procesory_ ako MS Word, LibreOffice a Apache OpenOffice
ponúkajú automatické delenie slov na konci riadka.
Systém na sadzbu textu LaTeX má túto funkciu automaticky zapnutú
a jej slovenská lokalizácia je veľmi kvalitne spracovaná.

Vo veľkej väčšine prípadov je delenie
v súlade s pravidlami jazyka.
Môžu sa vyskytnúť sporné okolnosti,
kedy počítač nerozdelí slovo správne.
Väčšinou máme možnosť do procesu zasiahnuť
a ručne kontrolovať delenie slov na miestach,
s ktorými si softvér nevie poradiť.
V~Typste sa automatické rozdelenie slov spravuje pomocou jazykových nastavení.
Napríklad slovo `predstave-nie` sa preferovane rozdelí v mieste prípony.

V každom prípade je žiadúce slová na konci riadka deliť
a túto možnosť nevypínať.
Prospieva to práci ako po technickej,
tak aj po estetickej stránke.
Odseky obsahujú menej dier,
textová oblasť stránky je vyplnená homogénnejšie,
čo prispieva k lepšej čitateľnosti.
V prípade, že používame zarovnávanie do bloku tak,
ako aj v tomto dokumente,
je prítomnosť dier v odseku značne rušivá.
Ak používame zarovnanie textu doľava,
nepoužívanie delenia slov má vplyv na vznik tzv. riek,
čo je náhle striedanie dlhých a krátkych riadkov.
Pravý okraj textu je nepekne zubatý.

Pravidlá rozdeľovania slov na konci riadka sú pomerne zložité.
Základné pravidlo, ktoré si pamätáme zo základnej školy,
je, že slová delíme na slabiky pred spoluhláskou alebo medzi
dvomi spoluhláskami.
Ak si nie sme istí, uprednostňujeme delenie v mieste,
kde sa ku koreňu slova pripájajú predpony alebo prípony,
prípadne v mieste spojenia slov v zloženom slove.

Pri slovách utvorených predponou alebo príponou
uprednostňujeme morfologické delenie
pred rozdelením koreňa slova.
Najskôr sa snažíme deliť slovo za predponou,
ak to nejde, skúsime to pred príponou.
Napríklad slovo _predstavenie_
delíme na slabiky takto: _pred-sta-ve-nie_.
Pri rozdeľovaní slov uprednostňujeme model
_pred-stavenie_, výnimočne aj _pred-stave-nie_.
V slove _výklenok_ sa uplatňuje pravidlo morfologického
delenia pred delením v mieste zhluku spoluhlások.
Sylabická stavba tohto slova je _vý-kle-nok_,
nie _výk-le-nok_,
pretože slovo pozostáva z troch častí: predpony _vý_,
koreňa _kle_ a prípony _nok_.
Mohli by sme namietať, že prípona je _ok_,
pomocou ktorej bolo vytvorené podstatné meno zo slovesa
klenúť alebo z prídavného mena klenutý,
kde identifikujeme koreň _klen_.
V skutočnosti je však príponou _-nok_.
Morfológia je pomerne komplexná problematika,
a nedokážeme tu obsiahnuť všetky jej detaily.
Väčšinou sa môžeme spoľahnúť na softvér,
že slová rozdelí správne.
V prípade pochybností využijeme externé pomôcky spomenuté
v úvode tejto kapitoly.

Slová spojené spojovníkom rozdeľujeme v mieste spojovníka tak,
že spojovník napíšeme na konci aj na začiatku riadka.
Slovo _vedecko-pedagogický_ môžeme rozdeliť takto:
_ve-dec-ko-pe-da-go-gic-ký_.
Ak delenie padne na miesto spojenia slov,
rozdelíme ho nasledujúcim spôsobom:

_vedecko-_
_-pedagogický_

V šablóne rieši tento problém príkaz
`languageattribute{slovak}{split}`,
ktorý je súčasťou jazykového balíka `babel`.

Nesprávne delenie slov sa v práci zvyčajne objaví
len zriedkavo a nemá vplyv na jej hodnotenie.
Netreba sa naň príliš sústrediť a robiť si starosti.
Celkový vzhľad práce viac naruší vypnutie delenia slov,
než občasná malá chyba.

=== Jednopísmenové predložky a spojky

Hovoríme o predložkách k, o, v, s, z,
ktoré by nemali ostať osamotené na konci riadka.
Do tejto kategórie patria aj spojky a, i.
Jednopísmenové slová pripájame k~nasledujúcemu slovu pomocou
tzv. _nedeliteľnej medzery_,
čo je špeciálny netlačiteľný znak.
V~kódovaní UTF-8 má číslo 00A0 (ASCII 160)
a~hovorí textovému procesoru,
že na tomto mieste nesmie byť za žiadnych okolností
koniec riadka.
V~Typste zapíšeme nedeliteľnú medzeru ako symbol vlnovka (`~`),
podobne ako v~LaTeX-u.
Napríklad slovné spojenie _v~priestore_ napíšeme takto:
`v~priestore`.
Typst automaticky počíta s~nedeliteľnými medzerami a~vkladá ich v~príslušných miestach,
ale pri potrebe ich môžeme aj ručne špecifikovať.

Existuje viacero medzier, ktoré sú tiež nedeliteľné a~majú pevnú šírku.
Najpoužívanejšia tzv. úzka medzera sa v~Typste vytvára pomocou `thin` alebo `\,` v~matematickom režime.
Takýto typ medzery používame pri zápise hodnôt fyzikálnych veličín
a~vkladáme ju medzi číslo a~jednotku. V~Typste: `5 thin upright("V")`.

== Štylistika

Niektorí oponenti vyčítajú študentom príliš dlhé súvetia,
iní zas príliš krátke.
Pravda je, že jednoduché vety pôsobia školácky,
zatiaľ čo dlhé súvetia sú často nezrozumiteľné a únavné.

V prvom rade sa snažíme nevrstviť podraďovacie súvetia.
Vo vete _Elektrostatické pole je fyzikálne pole,
ktoré tvoria elektrické náboje, ktoré sú v pokoji_
je dvakrát použitá spojka ktoré,
čo je síce prípustné, avšak nie príliš estetické.
Vetu môžeme opraviť takto:
_Elektrostatické pole je fyzikálne
pole tvorené elektrickými nábojmi, ktoré sú v pokoji._
Ak sa chceme vyhnúť trpnému rodu,
môžeme vetu preformulovať nasledujúcim spôsobom:
_Elektrostatické pole tvoria elektrické náboje,
ktoré sú v pokoji._
Vypadol síce pojem fyzikálne pole,
ale zmysel vety zostal nezmenený.

Správne a plynulo bude veta vyzerať aj v tomto tvare:
_Elektrostatické pole je fyzikálne pole,
ktoré tvoria elektrické náboje v pokoji._
V prípade potreby môžeme vetu napísať aj inak:
_Fyzikálne pole elektrických nábojov,
ktoré sú v pokoji, nazývame elektrostatické pole._

Obmieňame štruktúru po sebe nasledujúcich viet:
_Z výsledkov merania je zrejmé,
že predpoklad o zvyšovaní pohyblivosti nosičov náboja
s teplotou bol správny.
Na začiatku práce sme hovorili o tom,
že toto tvrdenie podporíme hodnovernými experimentálnymi dátami._
Obe súvetia sú podraďovacie so spojkou že.
Aby sme sa vyhli opakovaniu rovnakého typu viet,
môžeme prvú vetu prepísať:
_Výsledky merania potvrdili predpoklad o zvyšovaní
pohyblivosti nosičov náboja s rastúcou teplotou._
Druhú vetu ponecháme bez zmeny.

Veľmi osviežujúco pôsobí, ak medzi dlhé a kvetnaté súvetia
občas vložíme jednoduchú holú vetu.
Použijeme predchádzajúci príklad:
_Na začiatku práce sme hovorili o tom,
že predpoklad o zvyšovaní pohyblivosti nosičov náboja
s rastúcou teplotou podporíme hodnovernými
experimentálnymi dátami.
Merania ho potvrdili._
Tento malý trik je nečakane účinný a prispieva k lepšiemu
toku myšlienok.

Pozor, v texte pozostávajúcom z krátkych jednoduchých viet
je niekoľkoriadkové súvetie desivé:
_Pohyblivosť rastie s teplotou.
Hovorili sme o tom už na začiatku.
Tvrdenie ešte podporíme experimentom.
Ukazuje sa, že sme predpoklad o rastúcej pohyblivosti
nosičov náboja so zvyšujúcou sa teplotou,
pokiaľ berieme do úvahy výsledky meraní,
formulovali správne._

Aby bol písaný text zaujímavý a udržal čitateľov záujem,
používame stredne dlhé súvetia pozostávajúce maximálne
z dvoch až troch viet.
Občas text oživíme jednoduchou krátkou vetou.
Dávame si pri tom pozor,
aby táto činnosť nebola príliš schematická.

== Anglický jazyk

Šablóna FEIstyle podporuje slovenský a~anglický jazyk.
Pre prácu v~anglickom jazyku je potrebné túto skutočnosť nastaviť v~hlavnom súbore `main.typ`
ako parameter `language` funkcie `fei-thesis`:

```typst
#show: fei-thesis.with(language: "en")
```

Predvolená hodnota je `"sk"` pre slovenčinu.

Anglická práca musí obsahovať po závere rezumé v~slovenčine,
ktoré sa vloží pomocou funkcie `abstract` s~parametrom `lang: "sk"`.

Na jazykovú lokalizáciu sa v~Typste používa automatické nastavenie jazyka v~texte.
Ak sa v~práci písanej v~slovenčine nachádzajú výrazy v~angličtine,
môžeme ich jasne označiť pomocou kurzívy alebo ich uviesť v~úvodzovkách.
Napríklad pri zavádzaní skratky AI môžeme napísať,
že ide o~anglický výraz pre umelú inteligenciu _"Artificial Intelligence"_.

Ak nastavíme parameter `language: "en"` v~šablóne,
šablóna automaticky prepne celý dokument na anglický jazyk,
vrátane všetkých lokalizovaných textov (nadpisy, referencie atď.).

== Použitie umelej inteligencie <sec:utilizingAI>

Na optimalizáciu formulácie myšlienok môžeme využiť služby
umelej inteligencie (AI, z ang. _artificial intelligence_)
a tzv. veľkých jazykových modelov (LLM, z ang. _large language model_).
Umelá inteligencia dokáže kontrolovať rozsiahlejšie časti prác,
vyhľadáva chyby a navrhuje vhodnejšie
formulácie na základe pravidiel,
ktoré sme aplikovali v predchádzajúcom texte.
Neosvedčuje sa však pri kompozícii textov.
Neuspokojivé výsledky dosahujeme aj v prípadoch,
kedy necháme umelú inteligenciu preformulovať celé odseky.
Zanáša do nich chyby a nezmysly, ktoré tam pôvodne neboli.
Ťažko sa potom odhaľujú.
Tento jav poznáme ako tzv.
halucinácie a trpia nimi všetky nástroje AI,
vrátane najznámejšieho ChatGPT.

Napriek tomu predstavujú služby AI silný nástroj pri tvorbe pôvodného obsahu,
zvlášť užitočné sú tzv. generatívne umelé inteligencie (GAI),
ktoré dokážu vytvárať výstupy takmer na nerozoznanie od tvorby človeka.
Ich správna aplikácia nepochybne prispieva k vyššej jazykovej a obsahovej kvalite záverečných prác.
Treba však mať na pamäti, že záverečná práca má byť
pôvodné autorské dielo študenta a všetky časti,
ktoré nepochádzajú od autora musia byť riadne
zdokumentované a deklarované v zozname použitých zdrojov.
V žiadnom prípade sa neodporúča, aby
GAI formulovala pôvodné myšlienky
alebo súvislé časti práce.
Takéto konanie považujeme za nečestné podobne,
ako keby prácu písal niekto iný,
prípadne by boli celé odseky prebrané z iného zdroja bez korektného citovania (pozri kapitolu @sec:citation).

Používanie umelej inteligencie pri písaní záverečných prác
upravuje opatrenie rektora STU v Bratislave č. 1/2024-O,
ktoré budeme ďalej v texte uvádzať ako "opatrenie" @opatrenie12024.

=== Povolené činnosti umelej inteligencie bez potreby deklarácie

Podľa čl. V, ods. 2, písm. a) opatrenia môžu študenti používať GAI bez potreby deklarácie na tieto činnosti: kontrola gramatiky, oprava textu, tvorba osnovy, zhromažďovanie informácií a~použitie výpočtových metód a~softvérov, ktoré obsahujú prvky AI.

=== Deklarácia činnosti generatívnej umelej inteligencie

Čl. V, ods. 2, písmeno b) opatrenia obsahuje zoznam možností použitia GAI, ktoré je potrebné v práci deklarovať na konci po zozname literatúry.
Ide o nasledujúce činnosti: preklady medzi jazykmi, úpravy a reformulácie textu, tvorba zhrnutia a rešerší, citovanie odpovedí GAI, tvorba počítačových programov, tvorba grafického obsahu a obrázkov.

V závere práce, uvedieme za zoznamom literatúry časti textu vytvorené s~pomocou AI, spôsob ich využitia a použitý nástroj AI @opatrenie12024, čl. VI., ods. 2.

V~hlavnom súbore záverečnej práce `main.typ` sa vloží deklarácia používania AI
pomocou funkcie `fei-ai-declaration`:
```typst
#fei-ai-declaration[#include "includes/ai_declaration.typ"]
```
Deklarácia sa vloží za zoznam literatúry. Každý výskyt použitia nástrojov AI
zapíšeme ako položku do súboru `includes/ai_declaration.typ`.
Formát a~obsah jednotlivých záznamov je naznačený v~prílohe opatrenia číslo 1/2024-O.
Záznamy obsahujú tieto prvky:
- Názov spoločnosti (dátum), Názov nástroja, časť práce, účel použitia.

Predchádzajúci vzorec vygeneroval nástroj ChatGPT 4o od firmy
OpenAI dňa 2. 2. 2025 na základe analýzy spomínaného opatrenia.
V deklarácii použitia umelej inteligencie sa zapíšeme tento záznam:
- OpenAI (2025), ChatGPT 4o, časť @sec:utilizingAI, generovanie vzorca záznamu použitia AI.

Súčasná verzia šablóny FEIstyle nedisponuje nástrojmi na automatizáciu záznamov činnosti AI.
Preto ich treba zapisovať ručne do súboru `includes/ai_declaration.typ`.

= Špeciálne a netextové objekty

== Matematické rovnice

Systém na sadzbu textu TeX pôvodne vyvinul Donald Knuth.
Jeho motivácia bola poskytnúť producentom vedeckej tlače počítačový nástroj,
ktorý bude správne sádzať matematické rovnice.
Typst ako moderný nástroj má sadzbu rovníc v svojej DNA.
Autori textov z prírodovedeckej a technickej komunity siahajú po tomto nástroji
práve z~dôvodu bezkonkurenčnej práce s~rovnicami pri tvorbe vedeckého alebo akademického obsahu.

Matematické rovnice používame v tlačenom texte dvomi spôsobmi:
1. píšeme ich v~rámci textového odseku;
2. rovnicu vytlačíme zvlášť medzi dva textové odseky a~vtedy ju spravidla aj číslujeme, aby sme sa na ňu mohli ďalej odvolávať.

=== Rovnica v textovom riadku

Riešenie kvadratickej rovnice s koeficientami $a, b, c$
a~s~neznámou $x$ vypočítame pomocou známeho vzťahu
$x = frac(-b plus.minus sqrt(b^2 - 4a c), 2a)$.
Je to príklad rovnice zapísanej v~rámci textového odseku.
Ak tú istú rovnicu napíšeme do samostatného odseku, vyzerá trochu inak:

$ x = frac(-b plus.minus sqrt(b^2 - 4a c), 2a) $

#indent[Očividný rozdiel je vo veľkosti zlomku a~znaku odmocniny,
  môžeme si všimnúť aj malé rozdiely v~medzerách, vo vertikálnom zarovnávaní, atď.]

Vložené rovnice v~rámci textového riadku zapisujeme pomocou znaku dolára.
Matematický zápis ohraničíme znakmi dolára sprava aj zľava.
Napríklad zápis `$y = a x^2 + b x + c$` vytvorí rovnicu $y = a x^2 + b x + c$.

Označenia fyzikálnych veličín píšeme tiež ako vloženú rovnicu:
veľkosť sily $F$, hmotnosť $m$, čas $t$ a~podobne.
Všetky veličiny sme zapísali takto: `$F$`, `$m$`, `$t$`.

=== Zobrazená rovnica

Matematický text ohraničený dvomi znakmi dolára vytvorí zobrazenú rovnicu, ktorú vysádza do zvláštneho odseku zarovnaného na stred, napríklad:

$ y = a x^2 + b x + c $

Rovnicu s referenčným číslom vytvoríme tak, že zapíšeme rovnicu do bloku:

```
$ y = a x^2 + b x + c $ <eq:example>
```

=== Zásady matematickej sadzby

Pravidlá sadzby matematických, fyzikálnych veličín a~ich vzťahov sumarizuje medzinárodná norma u~nás známa pod označením STN ISO 80 000: 2022 Veličiny a~jednotky @iso800001.
Označenie fyzikálnych a~matematických veličín píšeme vždy šikmým rezom písma.
Čísla, názvy funkcií a~jednotky fyzikálnych veličín zapisujeme normálnym rezom.
Správny zápis elektrického napätia s veľkosťou 5,07 voltu vyzerá takto:
$ U = 5","07 thin upright("V") $ <eq:quantity>

kde $U$ je elektrické napätie.
Môžeme si všimnúť, že okolo znaku rovnosti sú medzery,
desatinná čiarka sa píše bez medzier.

TeX v~matematickom móde automaticky sádže veličiny kurzívou.
Ak chceme, aby bola jednotka V vzpriamená, použijeme v~matematickom móde funkciu `upright()`.
Medzery okolo znaku rovnosti sú taktiež automatické.

=== Príklad

Z Coulombovho zákona vyplýva, že pre vektor elektrostatickej sily $bold(F)_e$ medzi dvomi bodovými nábojmi platí nasledujúci vzťah:

$ bold(F)_e = frac(1, 4π ε_0) frac(q_1 q_2, r^2) frac(bold(r), r) $ <eq:coulomb>

kde $q_1$, $q_2$ sú veľkosti bodových nábojov,
$bold(r)$ je polohový vektor náboja $q_2$ vzhľadom na náboj $q_1$
a~$ε_0$ je elektrická konštanta.

Aby sme zhrnuli predchádzajúce pravidlá, detailnejšie opíšeme spôsob zápisu jednotlivých prvkov
v~rovnici @eq:coulomb.
Skalárne veličiny veľkosť náboja a~vzájomná vzdialenosť sú
napísané kurzívou,
vektorové veličiny sila a~polohový vektor sú polotučným rezom.
Všetky čísla (indexy a~násobok 4 v~menovateli)
píšeme normálnym rezom.
Konštanty $π$ a $ε_0$ sú podľa zvyklosti vysádzané šikmým rezom.

V~texte, ktorý nasleduje bezprostredne za rovnicou vysvetlíme
a~stručne opíšeme jednotlivé symboly.

==== Dôležité pravidlá písania rovníc

- Značky veličín píšeme šikmým rezom písma (kurzívou): $x$, $y$, $a$, $F$, $P$, $W$.

- Fyzikálne jednotky píšeme vzpriameným písmom: $a = 10 upright("cm")$.

- Čísla píšeme vzpriameným písmom: $1$; $2$; $3$; $1024$; $3,14$ a podobne.

- Skratky matematických funkcií píšeme vzpriameným písmom: $sin(α + β)$, $cos ω t$, $log_a x = frac(ln x, ln a)$, $e^(i π) = -1$.

- Označenia nemenných konštánt sú tiež vzpriamené písmená: $π$, $i$, $e$ -- tri základné matematické konštanty -- Ludolfovo číslo, komplexná jednotka a~Eulerovo číslo. Niektoré konštanty sa zo zvyku môžu písať kurzívou, napríklad $π$ alebo dielektrická konštanta $ε_0$. Komplexná jednotka je však vždy vzpriamená: $i^2 = -1$.

- Vzpriameným písmom píšeme v matematických vzťahoch aj všetky zátvorky.

- Sumačné indexy píšeme kurzívou: $p_N(x) = sum_(i=1)^N a_i x^i$. Symbol $i$ v tomto príklade predstavuje sumačný index, nie komplexnú jednotku.

- Vektory uvádzame buď polotučným šikmým rezom ($bold(a)$, $bold(b)$, $bold(F)$) alebo šikmým netučným rezom so šípkou nad symbolom: $vec(a)$, $vec(b)$, $vec(F)$. Treba si vybrať jeden spôsob a~ten používať v~celej práci.

- Označenia matíc a tenzorov zapisujeme polotučným šikmým rezom:
  $ bold(M) = mat(m_{11}, m_{12}; m_{21}, m_{22}) $
  Prvky matice $m_{i j}$ sú skalárne veličiny, preto sú to netučné šikmé písmená.

- Ak treba z nejakého dôvodu odlíšiť tenzor od bežnej matice, môžeme tenzory označiť dvomi čiarkami: $overline(overline(T))$.

- Značku úplného diferenciálu píšeme vzpriameným rezom: $upright(d) y$ je úplný diferenciál veličiny $y$.

- Derivácia dráhy podľa času: $v = frac(upright(d) s, upright(d) t)$. Veličiny $v$, $s$ a~$t$ sú stále písané kurzívou.

- Určitý integrál vyzerá takto: $ integral_a^b f(x) upright(d) x $

  V~integráli spravidla vkladáme pred diferenciál úzku medzeru.

// #[
//   #set par(first-line-indent: 0pt)
//   asdfasfd

// ]

// dalksdfi

== Obrázky

V akademickej oblasti prírodných a~technických vied sa v~záverečných prácach
objavujú v~pomerne veľkom počte aj netextové grafické objekty. Patria sem grafy, schémy, diagramy, fotografie,
prípadne iné dvojrozmerné vizualizácie obsahu.
Nehovoríme o~ozdobných grafických prvkoch,
tie do práce tohto typu nepatria.
Obsahové grafické prvky budeme spoločne nazývať slovom obrázok.
Obrázok môže byť súčasť textového odseku,
ale tejto možnosti sa vyhýbame,
ak to nie je úplne nevyhnutné.
Uprednostňujeme tzv. plávajúcu formu obrázkov,
teda objektov, ktoré sa nemusia nachádzať bezprostredne
na mieste v texte, kde sú spomenuté.
V zdrojovom kóde umiestňujeme príkazy na sadzbu obrázku za odsek,
v~ktorom sa o~ňom hovorí po prvýkrát.
Pod každým obrázkom je textové označenie,
začínajúce skratkou slova obrázok (Obr.) a~nasleduje
poradové číslo obrázku v práci.

Na obrázku @fig:measurement je znázornený proces správneho merania výšky dieťaťa.
Grafický objekt je súčasťou plávajúceho prostredia `figure`.
Samotnú grafiku pripravíme v externom editore,
exportujeme ju do niektorého z bežných formátov (JPG, PNG, PDF)
a~jej vloženie do finálneho PDF súboru
záverečnej práce zariadi makro `image()`.
Automatické číslovanie má na starosti príkaz `<caption>`,
ktorého argument je text pod obrázkom.

```typst
#figure(
  image("../assets/Measurement.png", width: 100%),
  caption: [Pravidelné meranie výšky dieťaťa],
) <fig:measurement>
```

#figure(
  image("../assets/Measurement.png", width: 100%),
  caption: [Pravidelné meranie výšky dieťaťa],
) <fig:measurement>

=== Umiestnenie obrázkov <sec:figPlacement>

Na obrázok sa v~texte odkazujeme prostredníctvom čísla.
Môžeme písať o~tom, že na obrázku 1 vidíme to a~to
alebo použijeme skratku -- obr. 1.
Slovo obrázok aj skratku píšeme v~odkaze v~texte
malým začiatočným písmenom, ak sa nachádza vo vnútri vety.
Na každý obrázok v~práci by mal existovať odkaz v~texte.

Umiestnenie obrázku v rámci dokumentu riadi pomerne
komplikovaný algoritmus, čo nie vždy vedie k uspokojivým výsledkom.
Polohu plávajúceho objektu môžeme čiastočne ovplyvniť
pomocou funkcie `figure()` v Typste.
Typst sa snaží automaticky umiestnať obrázky na rozumné miesto.
Obrázok sa zvyčajne umiestni na začiatok nasledujúcej strany, prípadne aj inam.
To nebýva žiaduce a žiaľ, nemáme príliš veľa možností, ako takýto výsledok ovplyvniť.
Pomôže zmena rozmerov obrázku, prípadne jeho premiestnenie inam v zdrojovom kóde.
Odporúča sa, aby sa prostredie obrázku nachádzalo mimo textového odseku, t. j. treba ho od okolitého textu oddeliť minimálne jedným prázdnym riadkom zhora aj zdola.

V Typste sa obrázky automaticky spravujú podľa dostupného priestoru
a možností optimalizácie rozloženia.
Jednotlivé parametre sa využívajú na kontrolu správania sa obrázka.
Napríklad nastavením `width: 100%` sa obrázok rozpína na celú šírku,
ako sa v~takýchto prípadoch zvykne robievať.

=== Označenie obrázku a text pod obrázkom

Text pod obrázkom pozostáva z~označenia obrázku a z~vysvetľujúceho obsahu.
Mal by sa nachádzať spolu s~obrázkom na tej istej strane.

Text je dostatočne opisný,
aby bol jasný obsah obrázku aj pri rýchlom prechádzaní
práce bez nutnosti detailného čítania hlavného textu.
Ak opis pod obrázkom pozostáva iba z~jednej vety,
prípadne ide o~heslo bez vetnej štruktúry,
nepíšeme zaň bodku.
V~prípade viacerých viet už bodku alebo príslušné interpunkčné
znamienka použijeme na konci každej vety,
aj poslednej.
V príklade na obrázku <@fig:measurement> je text bez bodky
a~to je správne.

=== Číslovanie a odkazy

Obrázky číslujeme podľa výskytu v práci od čísla 1.
Používame jednoúrovňové číslovanie,
teda obrázok 1, obrázok 2, atď.
V~Typste je automatické číslovanie obrázkov zabezpečené v definícii funkcie `figure()`.

Odvolávanie sa na číslo obrázku rieši identifikátor v ostrých zátvorkách.
Prvá časť `<fig:measurement>` je menovka obrázku.
Menovku volí autor textu, môže byť ľubovoľná, musí však začínať písmenom a nesmie obsahovať špeciálne znaky.
Tiež treba venovať pozornosť tomu, aby sa rovnaká menovka nevyskytla v~texte viackrát, pretože by došlo k jej preťaženiu a znefunkčneniu odkazov.

Z praktických dôvodov sa ustálila prax začínať menovku skratkou typu číslovanej položky: `fig` pre obrázok, `eq` pri rovniciach, `tab` ako menovka tabuľky, `sec` v~prípade nadpisu, atď.

== Grafy

Grafmi budeme nazývať zobrazenie vedeckých dát
najčastejšie vo forme dvojrozmerného grafu
závislosti dvoch alebo viacerých veličín.
Príklad takéhoto objektu je na obrázku @fig:Graph1.
Grafická reprezentácia vedeckých dát musí byť
v~prvom rade čitateľná, zreteľná a~jednoznačná.
Tomu treba prispôsobiť všetky zásady pri tvorbe grafov.

#figure(
  image("../assets/Graph1.pdf", width: 80%),
  caption: [Ukážka grafu vytvoreného v externom programe a vloženého ako PDF súbor.
    Použité písmo je Arial s veľkosťou približne 10 pt. Plné krúžky sú body merania a~prerušovaná čiara je kvadratický fit závislosti $s = a t^2 / 2$, pričom $a = (2,00 plus.minus 0,01) upright("m") upright("s")^(-2)$.],
) <fig:Graph1>

=== Formát súboru

Vektorové formáty SVG alebo PDF sú ideálna voľba pri exporte
z~grafických programov, napr. z~Excelu alebo Originu.
Ak takúto možnosť nemáme, treba grafy z externého softvéru
exportovať do bitmapového formátu, najlepšie PNG.
Stratový formát JPEG nie je na čiarovú grafiku vhodný.
Rozlíšenie bitmapového súboru by malo byť minimálne 600 dpi,
aby boli čiary ostré.
Znamená to, že ak predpokladáme veľkosť obrázku
10 cm × 7,5 cm,
musí mať aspoň 2 363 px × 1 772 px (pixelov).

=== Písmo a hrúbka čiar

Písmo v grafe nemusí byť nevyhnutne Computer Modern.
V~obrázkoch a~schémach sa často používa
tzv. bezserifové alebo groteskové písmo ako napr. Arial,
ktoré je lepšie čitateľné.
Veľkosť písma v~obrázkoch by nemala byť menšia než
10 pt,
čo je o~dva stupne menej ako základná veľkosť písma
v~dokumente.

Pozornosť treba venovať aj dostatočnej hrúbke čiar osí
a~grafického znázornenia dát,
aby boli viditeľné aj po vytlačení na bežnej tlačiarni.

=== Prvky grafu

Formálne prvky grafu sú osi s~dielikmi a~číslami,
názvy osí s~uvedením veličín, násobkov a~jednotiek,
mriežka a~legenda.
Medzi obsahové prvky zaraďujeme znázornené hodnoty vo forme
bodov alebo čiar.
Graf môže obsahovať aj názov grafu
a~doplňujúce texty,
prípadne ďalšie grafické prvky na zvýraznenie niektorých bodov,
oblastí a~podobne.

Bežný graf pozostáva zväčša z~dvoch navzájom kolmých číselných
osí – z~ľavej zvislej a~spodnej vodorovnej,
ktoré sa pretínajú v~ľavom dolnom rohu.
Na spodnej osi sa nachádzajú hodnoty nezávislej veličiny,
ľavá zvislá os obsahuje hodnoty závislej veličiny.
Rozsahy osí volíme tak,
aby korešpondovali s~intervalmi zobrazovaných hodnôt,
prípadne aby znázorňovali javy,
ktoré majú byť z grafu zrejmé.
Osi sa môžu pretínať aj v inom než nulovom bode.

=== Označenie osí

Osi musia byť riadne označené názvom alebo značkou veličiny,
jej jednotkou a~násobkom.
Nedodržanie tohto pravidla sa považuje za závažný nedostatok
a~autor musí mať na takýto krok obhájiteľný dôvod.
Jednotku spolu s~násobkom uzatvárame kvôli jednoznačnosti
do okrúhlych zátvoriek.
Hranaté zátvorky sa v knižnej tlači na tento účel nepoužívajú.

Os musí byť jasne rozdelená dielikmi,
ktoré sú kolmé na os a~predstavujú okrúhle hodnoty
zobrazovanej veličiny.
V blízkosti hlavných dielikov sa nachádzajú čísla prislúchajúce
hodnote dieliku.
Táto hodnota sa potom násobí s údajom v~zátvorke
v~opise osi a~spolu tvoria hodnoty zobrazenej fyzikálnej
veličiny aj s~jednotkou.

=== Viacero grafov v jednom obrázku

Priebehy dvoch a~viac nezávislých veličín môžeme nakresliť
do spoločných osí alebo použijeme pravú nezávislú zvislú os.
V~špeciálnych prípadoch môžeme využiť aj hornú vodorovnú os.
Ak chceme v~jednom obrázku zobraziť viacero grafov,
musí byť príslušnosť jednotlivých bodov a~čiar k~osiam jasná
z~legendy.
Legendu možno zahrnúť aj do textu pod obrázkom.

Graf znázorňujúci experimentálne hodnoty fyzikálnych veličín
zvykne byť uzavretý zhora aj sprava tak,
ako na obrázku <@fig:Graph1>.
Dve prekrížené otvorené osi sa používajú zväčša
v~prípade teoretického nákresu matematickej funkcie $y = f(x)$.

== Tabuľky

Sumarizácia dát vo forme tabuliek prispieva
k~sprehľadneniu obsahu, zjednodušuje text
a~umožňuje autorovi zamerať sa pri formulácii myšlienok na
obsahovú stránku práce.
Tabuľka, podobne ako obrázok, patrí medzi plávajúce objekty
a preto nemusí byť umiestnená priamo na mieste v dokumente,
kde sa o nej zmieňuje text.
Zvyčajne ju umiestňujeme za odsek s~prvou zmienkou,
ale často býva aj súčasťou prílohy dokumentu,
najmä ak je rozsiahlejšia.

Zameriame sa teraz iba na tabuľky s~výsledkami meraní,
ktoré sa v~záverečných prácach vyskytujú najčastejšie.

Tabuľku označujeme slovom Tabuľka,
za ktorým nasleduje poradové číslo tabuľky podľa výskytu
v~texte.
Za číslom môže nasledovať dvojbodka a~text s~opisom obsahu
tabuľky.
V~prípade, že označenie neobsahuje opisný text,
dvojbodku vynecháme.
Opisný text nekončí bodkou,
ani iným interpunkčným znamienkom,
pokiaľ ide iba o názov alebo jednu oznamovaciu vetu.
Celý odsek s~označením, číslom a~opisom umiestňujeme
nad tabuľku (pozri napríklad tabuľku~<@tab:template>).

#figure(
  table(
    columns: (auto, auto, auto, auto, auto),
    align: (left, right, right, right, right),
    stroke: none,
    table.hline(),
    table.header([*názov riadka*], [*stĺpec 1*], [*stĺpec 2*], [*stĺpec 3*], [*stĺpec 4*]),
    table.hline(),
    [prvý riadok], [hodnota 1], [hodnota 2], [hodnota 3], [hodnota 4],
    [druhý riadok], [hodnota 5], [hodnota 6], [hodnota 7], [hodnota 8],
    [tretí riadok], [hodnota 9], [hodnota 10], [hodnota 11], [hodnota 12],
    table.hline(),
  ),
  caption: [Vzorová tabuľka],
) <tab:template>

Na tabuľky sa odvolávame pomocou ich čísla použitím dvojice makier
`<tab:template>` a~`@tab:template` .
Spôsob odkazovania je podobný ako v prípade obrázkov,
o~ktorom sme podrobne hovorili v časti @sec:figPlacement.

=== Vzhľad tabuľky

Jednoduchá tabuľka obsahuje hlavičku a~niekoľko
údajových riadkov.
Vzhľad tabuľky je otázka estetických preferencií autora.
Príliš veľa grafických prvkov znižuje obsahovú hodnotu a čitateľnosť tabuľky.
Formát, ktorý sme vybrali je inšpirovaný trendmi
v~knižnej sadzbe.
Tabuľka je zhora a~zdola ohraničená vodorovnými čiarami
`table.hline()` v~Typste.
Podobne je čiarou `table.hline()` oddelená hlavička tabuľky
a~prípadne aj päta, ak ju použijeme.
Zvislé čiary sa používajú iba vo výnimočných prípadoch,
napríklad ak je tabuľka rozdelená na
dve evidentne oddelené časti.
Prípadne môžeme čiarou oddeliť prvý stĺpec s~opisom označenia riadka (tabuľka @tab:LED).
Jednotlivé riadky s~údajmi neoddeľujeme.
Tabuľka pôsobí harmonicky,
ak je text v~prvom stĺpci zarovnaný doľava
a~v~poslednom stĺpci doprava.

Prvý riadok môže byť vysádzaný polotučným
rezom (bold),
ak obsahuje tzv. hlavičku, teda názvy stĺpcov alebo názvy
a~jednotky veličín, ktorých hodnoty sú v~konkrétnom stĺpci.
Označenie veličín symbolom ($U$, $I$, $R$, $P$, a~pod.)
nepíšeme v~hlavičke tučným písmom,
aby sme dodržali pravidlo o~tom,
že veličiny by mali byť v~celom dokumente označené symbolom
rovnakého tvaru a typu.

#figure(
  table(
    columns: (auto, auto, auto, auto, auto),
    align: (left, right, right, right, right),
    stroke: none,
    table.hline(),
    table.vline(x: 1, start: 0),
    table.header(
      [*dióda*],
      [$λ_upright(m)\,(upright("nm"))$],
      [*FWHM (nm)*],
      [*žiarivý výkon* $(10^(-5)\,upright("W"))$],
      [*farba*],
    ),
    table.hline(),
    [LED 1], [$450 plus.minus 5$], [$20 plus.minus 2$], [$3 plus.minus 1$], [modrá],
    [LED 2], [$525 plus.minus 5$], [$25 plus.minus 3$], [$50 plus.minus 4$], [zelená],
    [LED 3], [$615 plus.minus 5$], [$15 plus.minus 1$], [$2 plus.minus 1$], [oranžová],
    [LED 4], [$630 plus.minus 5$], [$20 plus.minus 2$], [$5 plus.minus 1$], [červená],
    table.hline(),
  ),
  caption: [Tabuľka parametrov štyroch diód LED.
    FWHM predstavuje šírku píku v~polovici intenzity
    spektrálneho maxima (_Full-Width-Half-Maximum_) pri vlnovej dĺžke~$λ_upright(m)$.],
) <tab:LED>

=== Obsah tabuľky

Tabuľka s nameranými hodnotami obsahuje v~prvom riadku označenie
veličín a~to buď slovom alebo symbolom.
Za veličinou nasleduje jednotka v~okrúhlej zátvorke.
Hranaté zátvorky na tento účel nepoužívame.
Bezrozmerné relatívne veličiny uvádzame s~jednotkou `a. u.`.
Ide o zaužívanú formu v~medzinárodnej vedeckej komunite na pomenovanie tzv. príslušnej jednotky (_arbitrary unit_).
Takto označujeme aj osi grafov rôznych relatívnych veličín.

Pred jednotkou môže byť označenie násobku
a~dielu a~to ako v~symbolickej forme (`kA`, `nm`, `MW`),
tak aj vo forme dekadického exponentu ($10^3$, $10^(-9)$, $10^6$).
Vyhýbame sa zápisom v~tvare `1E-3` alebo `10-3`,
pretože sú mätúce.
Text hlavičky vlnová dĺžka ($10^(-7)$\,m) znamená,
že hodnoty v~celom stĺpci predstavujú veličinu vlnová dĺžka
a~sú uvedené v~jednotkách $10^(-7)$ metra.

Neistoty a~odchýlky zapisujeme k~hlavnej hodnote pomocou
znaku $plus.minus$ alebo do zvláštneho stĺpca,
ktorý príslušne označíme.
Ďalšie spôsoby zápisu neistôt uvádza príslušná norma (napr. STN 01 6910: 2022 @stn016910).

== Výpisy kódov programu a algoritmy <sec:listings>

Ak je súčasť cieľov práce tvorba softvéru, prípadne analýza programátorských riešení,
je žiaduce uvádzať časti kódov vo forme krátkych výpisov (angl. _listing_).
Existuje niekoľko balíčkov, ktoré umožňujú zahrnúť časti kódov do textu práce.
Šablóna FEIstyle používa balík na zobrazovanie kódu.
Prostredie na vloženie kódu vytvorí blok kódu s~menovkou a~číslom výpisu.
Makro na vytvorenie zoznamu všetkých výpisov na začiatku dokumentu,
ktorý nie je povinnou súčasťou práce,
býva však dobrým zvykom uvádzať ho najmä v~informatických študijných programoch.

Ukážka kódu je vo výpise~@lst:main-c.
// V dodatku @att:listings nájdeme príklad výpisu obsahu externého textového súboru.
Ďalšie podrobnosti možno nájsť v~dokumentácii k~balíčkom#footnote[#link("https://ctan.org/pkg/listings")[ctan.org/pkg/listings]]
alebo v~tutoriáli služby Overleaf#footnote[#link("https://www.overleaf.com/learn/latex/Code_listing")[www.overleaf.com/learn/latex/Code_listing]].
#figure(
  ```c
  /* Hello World program */

  #include<stdio.h>

  struct cpu_info {
      long unsigned utime, ntime, stime, itime;
      long unsigned iowtime, irqtime, sirqtime;
  };

  main()
  {
      printf("Hello World");
  }
  ```,
  caption: [Ukážka výpisu kódu programu],
)<lst:main-c>

=== Algoritmy

Dvojica balíkov#footnote[#link("https://ctan.org/pkg/algorithms")[ctan.org/pkg/algorithms]]
na zápis algoritmizácie pomocou pseudokódov
uľahčuje formálny opis algoritmov.
Tieto nástroje sa uplatňujú najmä v prípade teoretických prác v~oblasti informatiky a~softvérového inžinierstva.
Šablóna FEIstyle načítava balíky automaticky a~tiež umožňuje vytvorenie zoznamu všetkých algoritmov
na začiatku záverečnej práce.
Príkaz možno vynechať alebo označiť riadok ako poznámku, zoznam sa tak nevytvorí.
// Príklad algoritmu je uvedený v dodatku @att:algorithms.

Ďalšie podrobnosti získame z~tutoriálov#footnote[#link("https://www.overleaf.com/learn/latex/Algorithms")[www.overleaf.com/learn/latex/Algorithms]]
alebo z~dokumentácie k~jednotlivým balíčkom.

= Citovanie externých zdrojov <sec:citation>

V~súvislosti s~preberaním časti obsahu iných diel rozoznávame dva pojmy. Sú to citát a~citácia.

Citát je doslovná reprodukcia prevzatého textu, ktorý môžeme v~práci použiť dvomi spôsobmi.
Buď ako súčasť odseku textu, alebo celý citovaný text vysádžeme v~samostatnom odseku.
V oboch prípadoch je zvykom citovaný text uzavrieť do úvodzoviek a~zvýrazniť šikmým rezom písma.
Za citovaným textom uvedieme meno autora, prípadne názov diela, rok a nasleduje číslo bibliografického
zdroja v~hranatých zátvorkách uvádzajúce poradie v~zozname použitej literatúry v~závere práce.

Na citovanie v rámci odseku možno využiť správne slovenské úvodzovky a `#emph` pre zvýraznenie textu.

Samostatne vysádzaný citát môžeme umiestniť do samostatného odseku so zvýraznením.

Citácia je nepriamo prebraná a~prerozprávaná časť citovanej práce.
Môže to byť vedecká myšlienka, odkaz na výsledky výskumu, dôležitý poznatok, matematický vzťah a~podobne.
Schopnosť študenta pracovať s~literatúrou a~s~externými zdrojmi je dôležitý moment pri hodnotení spôsobilosti uchádzača
o~vysokoškolský titul.
Tomuto aspektu práce treba preto venovať patričnú pozornosť.

== Odkazy na citované diela

Vo vedecko-technických oblastiach, do ktorých patria aj študijné programy na našej fakulte, je zvykom používať numerický systém citovania.
Jednotlivé zdroje sú očíslované podľa poradia výskytu v texte, pričom číslo zdroja uvádzame v hranatých zátvorkách.
Citovanie sa riadi technickou normou STN ISO 690: 2022 Informácie a~dokumentácia: Návod na tvorbu bibliografických odkazov na informačné pramene a~ich citovanie.

Systém Typst umožňuje pracovať s citáciami prostredníctvom bibliografických databáz. Základom je externý databázový súbor `bibliography.bib`,
ktorý sa nachádza v hlavnom priečinku projektu záverečnej práce.
Súbor obsahuje bibliografické záznamy citovaných diel v špecifickom formáte.
Každý záznam začína jedinečným identifikátorom, ktorý zvyčajne volíme tak, aby sme si ho jednoducho pamätali.
Ak totiž v texte chceme dielo citovať, napíšeme `@identifikator` a v~práci sa automaticky objaví poradové číslo citovaného diela v hranatej zátvorke.

Pri práci s~bibliografiou odporúčame spustiť externý program na spracovanie bibliografických zdrojov
po prvej kompilácii a~potom skompilovať dokument ešte dvakrát.
Posledná kompilácia zabezpečí správne čísla strán v obsahu.

== Bibliografické záznamy

V zozname použitej literatúry v~závere práce sa nachádzajú podrobné záznamy použitých zdrojov.
Sú to najmä mená autorov, názov článku alebo číslo kapitoly knihy, názov časopisu alebo knihy,
vydavateľ, rok vydania, strana, na ktorej sa nachádza citovaný článok a podobne.
V~prípade webových stránok je potrebné uviesť internetovú adresu a~dátum, kedy sme informáciu zo stránky čerpali.
Dôležité je, aby boli informácie na základe týchto detailov ľahko a jednoznačne dohľadateľné.

Formátujeme použitú literatúru podľa štýlu iso-numeric, ktorý do veľkej miery rešpektuje
doteraz zaužívané zvyklosti a~je navrhnutý tak, aby spĺňal odporúčania normy aj v~slovenskom jazyku.

=== Príklad záznamu v~databázovom súbore .bib <sec:citExample>

Súbor `bibliography.bib` je textový súbor, ktorý musí mať predpísanú štruktúru.
Môžeme ho vytvoriť ručne alebo použiť systémy na správu publikácií a~citácií ako sú JabRef, Mendeley, Zotero a~podobne.

Bibliografický záznam pre článok:

```
@article{Steinerova2000Principy,
  author  = {J. Steinerová},
  journal = {Pedagogická revue},
  title   = {Princípy formovania vzdelania v informačnej vede},
  year    = {2000},
  number  = {3},
  pages   = {8--16},
  volume  = {2},
}
```

Každý záznam začína symbolom `@` a nasleduje typ publikácie.
Okrem článku (`article`) to môže byť aj kniha (`book`), príspevok v~zborníku konferencie (`inproceedings`),
webová stránka (`online`), správa (`techreport`), všeobecný záznam (`misc`) a~mnohé iné.

Prvý povinný údaj je jedinečný identifikátor, ktorý je ľubovoľný.
Odporúča sa však aby obsahoval priezvisko prvého autora, rok vydania a~prvé slovo názvu.

Jednotlivé položky databázového záznamu sú oddelené čiarkou, za posledným poľom už čiarka nie je.

=== Prvky bibliografického záznamu

Zoznam použitej literatúry obsahuje informácie o~jednotlivých zdrojoch.
Je potrebné mať na pamäti, aby záznamy boli jasné, stručné a~jednoznačne identifikovateľné.
Bežne zorientovaný čitateľ práce by mal byť schopný identifikovať jednotlivé diela.
Prípadný záujemca o~detailné štúdium problematiky by si mal vedieť na základe záznamu vyhľadať citovanú publikáciu
buď na internete alebo v~knižnici.

Uvedieme niekoľko jednoduchých príkladov bežného spôsobu citovania.

==== Mená tvorcov

V zozname literatúry majú formu: PRIEZVISKO, Meno alebo PRIEZVISKO, M. a~navzájom sú oddelené bodkočiarkou.
Za zoznamom autorov nasleduje bodka.

V `.bib` súbore:
```
author = {Meno1 Priezvisko1 and Meno2 Priezvisko2}
```

Autorov zapisujeme ako `Meno Priezvisko` a~oddeľujeme ich kľúčovým slovom `and`.

==== Názov

Názov článku píšeme normálnym písmom.
Názov nosného informačného zdroja (kniha, časopis, zborník) píšeme kurzívou.

V `.bib` súbore:
```
title = {}
booktitle = {}
```

==== Dátum

Pri každej publikácii musí byť uvedený aspoň rok vydania vo formáte YYYY.
V~prípade online zdrojov treba uvádzať aj presný dátum, kedy sme zdroj použili.
Formát je odporúčaný ako `[cit. YYYY-MM-DD]`.
Napríklad `[cit. 2023-05-14]` znamená 14. mája 2023.
Ide o~medzinárodne akceptovaný a~zrozumiteľný tvar zápisu dátumu.

V `.bib` súbore:
```
year = {2024}
date = {2024-12-31}
```

==== Dostupnosť

Uvádzame buď úplnú webovú adresu alebo DOI číslo. Nepíšeme oba údaje, preferujeme DOI.

V `.bib` súbore:
```
url = {}
doi = {}
```

==== Ročník, zväzok a~číslo časopisu

Vedecké periodiká vychádzajú v~zväzkoch (_volume_).
Zväzok a~číslo zapisujeme buď pomocou skratiek vol. a~iss., alebo preferujeme zaužívanú skrátenú formu *15*(8).

V `.bib` súbore:
```
volume = {}
number = {}
```

== Článok v~odbornom periodiku

Záznam musí obsahovať mená autorov, názov článku, názov časopisu, dátum alebo iba rok vydania,
ročník alebo zväzok a~číslo vo zväzku, číslo prvej strany.

==== Príklady

```
@article{Steinerova2000Principy,
  author  = {J. Steinerová},
  journal = {Pedagogická revue},
  title   = {Princípy formovania vzdelania v informačnej vede},
  year    = {2000},
  number  = {3},
  pages   = {8--16},
  volume  = {2},
}

@article{Benacka2009Abetter,
  author  = {Ján Benačka and others},
  title   = {A better cosine approximate solution to pendulum equation},
  journal = {International Journal of Mathematical Education in Science
             and Technology},
  volume  = {40},
  number  = {2},
  pages   = {307--308},
  year    = {2009},
  doi     = {10.1080/00207390802419594},
}
```

== Monografia a~kniha

TVORCOVIA. _Názov knihy._ Mesto: Vydavateľ, Rok vydania. ISBN.

==== Príklady

```
@book{Obert2006Navraty,
  author    = {Viliam Obert},
  publisher = {Univerzita Konštantína Filozofa},
  title     = {Návraty a odkazy},
  year      = {2006},
  address   = {Nitra},
  isbn      = {80-8094-046-0},
}

@book{Timko2004Geneticky,
  author    = {Jozef Timko and Peter Siekel and Ján Turňa},
  publisher = {Veda},
  title     = {Geneticky modifikované organizmy},
  year      = {2004},
  isbn      = {80-224-0834-4},
}
```

== Záverečná a~vedecko-kvalifikačná práca

AUTOR. _Názov práce._ Mesto, Rok vypracovania. Typ práce. Inštitúcia.

==== Príklady

```
@thesis{Mikulasikova1999Didakticke,
  author  = {M. Mikulášiková},
  title   = {Didaktické pomôcky pre praktickú výučbu na hodinách
             výtvarnej výchovy},
  address = {Nitra},
  year    = {1999},
  type    = {Diplomová práca},
  school  = {Univerzita Konštantína Filozofa},
}

@report{Baumgarntner1998Ochrana,
  author      = {J. Baumgartner and others},
  institution = {VÚŽV},
  title       = {Ochrana a udržiavanie genofondu zvierat},
  address     = {Nitra},
  year        = {1998},
  type        = {Výskumná správa},
}
```

== Príspevok v~zborníku konferencie

Ak citujeme príspevok z~neperiodického zborníka, uvedieme za názvom príspevku kľúčové slovo In:,
po ktorom nasleduje zoznam editorov zborníka a~názov zborníka:

TVORCOVIA. Názov príspevku. In: EDITORI (ed.). _Názov zborníka._ Mesto: Vydavateľ, Rok vydania, zväzok. ISBN. ISSN.

==== Príklady

```
@InProceedings{Zemanek2001TheMachines,
  author    = {P. Zemánek},
  booktitle = {9th International Conference: proceedings.
               Fruit Growing and viticulture},
  title     = {The machines for green works in vineyards and their
               economical evaluation},
  volume    = {2},
  year      = {2001},
  pages     = {262--268},
  publisher = {Mendel University of Agriculture and Forestry},
  address   = {Lednice},
  isbn      = {80-7157-524-0},
}

@InProceedings{ChlpikSpectroscopic2024,
  author    = {Chlpík, Juraj and Kurtulík, Matej and Kotorová, Soňa},
  date      = {2024-01},
  title     = {Spectroscopic ellipsometry of Au nanoparticles layers},
  editor    = {Jozef Sitek and Ján Vajda},
  doi       = {10.1063/5.0187526},
  booktitle = {AIP Conference Proceedings},
  volume    = {3054},
}
```

== Webová stránka, sociálna sieť, video

Pri multimediálnom online obsahu často nepoznáme autora, prípadne je komplikované zistiť názov webovej stránky.
Snažíme sa zahrnúť čo najviac jednoznačných informácií, najmä webovú adresu, dátum publikovania a~dátum citovania.

TVORCOVIA. _Názov obsahu_ [online]. Platforma, dátum publikovania [cit. dátum citovania]. Dostupnosť.

==== Príklady

```
@online{Valko2024M31,
  author       = {Pavol Valko},
  title        = {M31, M32 a jeden Starlink k tomu},
  howpublished = {online},
  date         = {2024-08-30},
  url          = {https://www.facebook.com/share/p/S93xZoz9RbnhdQ7M},
  urldate      = {2024-09-06},
  publisher    = {Facebook},
}

@online{WhyLenses2017,
  title        = {Why lenses can't make perfect images},
  howpublished = {online},
  date         = {2017-10-18},
  url          = {https://youtu.be/DDoryfCXxPI?si=hC5Kuuf4p3OxOOsm},
  urldate      = {2024-08-25},
  publisher    = {Youtube},
}
```

== Ako citovať technické normy

K~normám nemusíme uvádzať autorov, ak ide o~slovenskú normu STN.
Dôležité je číslo normy a~rok vydania.

_Číslo normy. Názov: Podnázov._ Mesto: Vydavateľ. Rok vydania.

==== Príklad

```
@report{iso690,
  title     = {STN ISO 690: 2022. Informácie a dokumentácia},
  subtitle  = {Návod na tvorbu bibliografických odkazov},
  address   = {Bratislava},
  publisher = {Slovenský ústav technickej normalizácie},
  year      = {2022},
}
```


