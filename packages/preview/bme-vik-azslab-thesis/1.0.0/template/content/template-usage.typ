#import "@preview/bme-vik-azslab-thesis:1.0.0": *
#import "@preview/colorful-boxes:1.4.3": colorbox

#import "helpers/huorion.typ": *

// ----------------------------------------------------------------------------
= A Typst sablon használata
// ----------------------------------------------------------------------------

Ebben a fejezetben bemutatásra kerül a sablon használata. Itt kifejezetten csak ezen specifikus részeket, illetve egy ilyen munka vonatkozásában használandó Typst elemeket tárgyalunk, általános szintaktikai elemeket és megoldásokat nem.

#colorbox(
  title: "Figyelem!",
  color: "red",
  radius: 5pt,
  width: auto,
)[
  A Typst használata során egyes tervezői döntések furcsának tűnhetnek, azonban aki ismeri a LaTeX működését, értheti, hogy a fejlesztők miért adott módon implementáltak valamit -- nem egyszerű mesterség a betűszedés. Továbbá a rendszer kialakítása során az angol nyelv és tipográfia élvezett elsőbbséget -- ennek leprogramozása is jóval egyszerűbb a világ nyelveinek döntő többségénél --, emiatt a magyar nyelvi és tipográfiai lehetőségek igen korlátozottak.

  A fenti két ok miatt számos funkciót csak nyakatekerten lehet megoldani, ezért ha valami furcsa megoldás alkalmazására kerül sor, azt az alábbi piros színű dobozban jelezzük.

  Továbbá: a legnagyobb jó szándék mellett sem lehet mindent Typst csomagokkal megoldani, a legjobb mindig, ha egy alapvető dolgot natívan támogat a rendszer, ezért bátorítok minden olvasót, amennyiben kedve és indíttatása van, segítse a rendszer fejlesztését.
]

A sablont az online felületen a _“Start from template”_ gomb megnyomásával lehet elkezdeni használni. Amennyiben lokálisan kívánjuk használni, úgy a parancssorból a

```bash
typst init @preview/bme-vik-thesis-template
``` parancs kiadásával lehet létrehozni a mappát, benne a szükséges sablon fájlokkal, továbbá ezzel a példadokumentummal. Ezen felül akár a _Github_ repository klónozásával is hozzá lehet jutni a sablonhoz és a példadokumentumhoz, például HTTP-n:

```git
git clone https://github.com/afranko/bme-vik-thesis-template.git
```

// ----------------------------------------------------------------------------
== Címkék és hivatkozások
// ----------------------------------------------------------------------------

Egy Typst-dokumentumban címkéket rendelhetünk ábrákhoz, táblázatokhoz, listákhoz, képletekhez, fejezetekhez. Ezekre a dokumentum bármely részében hivatkozhatunk a hivatkozások automatikusan feloldásra kerülnek. Címkézni az alábbi módon lehet: `<cimke>`, míg hivatkozni a következőképpen: `@cimke`. Erről bővebben #link("https://typst.app/docs/reference/model/ref/")[itt] olvashatunk.

Célszerű az egyes címkéket szemantikával ellátni, tehát jelölni, hogy egy adott címke milyen funkciót lát el. Például a `<chap:cimke>` és `<sec:cimke>` ebben a dokumentumban a fejezeteket és alfejezeteket jelölő címkék. Technikailag létre tudnánk hozni egy burkoló függvényt, hogy külön címkézzük a fejezeteket és alfejezeteket, de jelen dokumentum szerzője ezt nem javasolja, mivel szembemegy a Typst alapvető szellemiségével és pont az egyszerűségen csorbát ejt. Ugyanezt az elnevezési konvenciót alkalmazhatjuk ábrák, táblázatok és kódlisták esetén is: `<fig:cimke>`, `<tab:cimke>` és `<lst:cimke>`. A Typst mindig tudja az adott `#figure` hívásról, hogy épp ábra, táblázat vagy kódrészlet: a fenti konvenció a szerzőnek segít, nem a szoftvernek.

A címkék használatának előnye, hogy a formát és a tartalmat szétválasztja, tehát ha kézzel írnánk be, hogy X. ábra, akkor egy új ábra betoldásával az ábraszámozás megváltozhat és azt nekünk kell kézzel frissíteni. Ezen a módon viszont, ha a hivatkozás mindig a megfelelő módon jelenik meg, így nem kell kézzel módosítani a későbbiekben.

#colorbox(
  title: "Figyelem!",
  color: "red",
  radius: 5pt,
  width: auto,
)[
  A Typst alapvetően például egy `@fig:cimke` hivatkozásnál azt írja ki, hogy `Figure X`. A legtöbb nyelven ez folyékonyan beleillik a mondatba, magyarul viszont `X. ábra` a helyes. Erre a Typst jelenleg nem ad beállítási lehetőséget, de megoldható. A probléma viszont, hogy egy tipikus hivatkozás így néz ki: "Az 5. ábrán látható". Emiatt a névelő a sorszám függvénye, továbbá esetenként (de nem mindig) toldalékolni kell a szót. Ugyan a #link("https://typst.app/universe/package/pannotyp/")[pannotyp] csomag részben megoldja ezeket a problémákat, de nem teljes körűen, ráadásul erősen inkompatibilis minden saját változtatással.

  A fentiek miatt ebben a sablonban *mindig csak a sorszám* kerül hivatkozásra, a könnyebb toldalékolhatóság miatt. Továbbá a sablon biztosítja az `aref` és `Aref` függvényeket, melyek használatával a megfelelő névelő dinamikusan előállítható. Például a `= Typst-eszközök <chap:typst-tools>` módon létrehozott fejezetre az alábbi módon hivatkozhatunk: `#Aref(<chap:typst-tools>) fejezetben olvashatunk a szerkesztéshez használható eszközökről.`, amely az alábbi módon jelenik meg: #Aref(<chap:typst-tools>)~fejezetben olvashatunk a szerkesztéshez használható eszközökről. Sajnos így az egyszerű címkehivatkozás nem használható, de az eredeti funkcionalitás megmarad.
]

#text()[
  #show link: it => {
    if it == none { return it }
    box(stroke: 1pt + red, outset: (bottom: 1.5pt, rest: .5pt), it)
  }
A fenti hivatkozásokon túl természetesen webhivatkozásokat is tehetünk a dokumentumba. Az url-ek automatikusan hivatkozásként jelennek meg: https://www.vik.bme.hu. Emellett lehetőség van a `#link` parancs használatára is. A `#link("https://watchbutdonotlearn.github.io")[Ne kattints rá!]` az alábbi formában jelenik meg: #link("https://watchbutdonotlearn.github.io")[Ne kattints rá!]

Az összes említett hivatkozástípus aktív a legtöbb PDF-nézegetőben, rájuk kattintva a dokumentum megfelelő oldalára ugrik a PDF-néző vagy a megfelelő linket megnyitja az alapértelmezett böngészővel. A Typst a kimeneti PDF-dokumentumba könyvjelzőket is készít a tartalomjegyzékből. Ez egy szintén aktív tartalomjegyzék, amelynek elemeire kattintva a nézegető behozza a kiválasztott fejezetet. A hivatkozások (`link` vagy kizárólag `ref`) testreszabhatók dokumentumszinten -- vagy az itteni példa szerint akár lokálisan is.
]

// ----------------------------------------------------------------------------
== Ábrák és táblázatok
// ----------------------------------------------------------------------------

Használjunk vektorgrafikus ábrákat, ha van rá módunk. A Typst a legtöbb vektorgrafikus formátumot (SVG, PDF) tudja kezelni, ellenben EPS-t nem, azt először konvertálni szükséges. Ha vektorgrafikus formában nem áll rendelkezésünkre az ábra, akkor a  veszteségmentes PNG, valamint a veszteséges JPEG formátumban érdemes elmenteni.  Figyeljünk arra, hogy ilyenkor a képek felbontása elég nagy legyen ahhoz, hogy nyomtatásban is megfelelő minőséget nyújtson (legalább 300 dpi javasolt). A dokumentumban felhasznált képfájlokat a dokumentum forrása mellett érdemes tartani, archiválni, mivel ezek hiányában a dokumentum nem fordul újra. Ha lehet, a vektorgrafikus képeket vektorgrafikus formátumban is érdemes elmenteni az újrafelhasználhatóság (az átszerkeszthetőség) érdekében.

#colorbox(
  title: "Figyelem!",
  color: "red",
  radius: 5pt,
  width: auto,
)[
  Sajnos a Typst egyik nagy hiányossága a fejlett ábraelhelyezés, amit a LaTeX parádésan művel. Emiatt minden ábra pont ott jelenik meg, ahol a forráskódban szerepel. Amennyiben lebegtetni (float) szeretnénk egy ábrát azt, kézzel kell megtennünk. Ez természetsen igaz a kódrészletekre és a táblázatokra is.
]

Kapcsolási rajzok legtöbbször kimásolhatók egy vektorgrafikus programba (pl. Inkscape) és onnan nagyobb felbontással raszterizálva kimenthatők PNG formátumban. Ugyanakkor kiváló ábrák készíthetők ingyenes szoftverekkel is, mint a _draw.io_ vagy a Typst rajzoló csomagja: a #link("https://typst.app/universe/package/cetz/")[_cetz_].

Amennyiben valamilyen vizualizációs szoftvert (Matlab, Octave, GNUPlot, stb.) vagy könyvtárat használunk (MatPlotLib, GGPlot, Plotly, Seaborn, stb.), a következő lehetőségeink vannak:

- Képernyőlopás (_screenshot_) is elfogadható minőségű lehet a dokumentumban, de általában jobb felbontást is el lehet érni más módszerrel.
- A Matlab ábrát a `File/Save As` opcióval lementhetjük PNG formátumban (ugyanaz itt is érvényes, mint korábban, ezért nem javasoljuk).
- A Matlab ábrát a `Copy figure` opcióval kimásolhatjuk egy vektorgrafikus programba is és onnan nagyobb felbontással raszterizálva kimenthatjük PNG formátumban (nem javasolt).
- *Javasolt megoldás*: az ábrát a `File/Save As` opcióval PDF _vektorgrafikus_ formátumban elmentjük, vagy ha az adott szoftver csak EPS-be tud menteni, akkor PDF-be konvertálva beillesztjük a dolgozatba.
- Természetesen a fenti megoldás általánosítható: az R és Python megjelenítő csomagok ezt támogatják, így egy `fig.savefig("abra_1.pdf")` vagy `ggsave("abra_2.pdf")` hívással egyből vektorgrafikus formátumba menthetjük az ábrát.

Ezek után a PDF-ábrát ugyanúgy lehet a dokumentumba beilleszteni, mint a PNG-t vagy a JPEG-et. A megoldás előnye, hogy a lefordított dokumentumban is vektorgrafikusan tárolódik az ábra, így a mérete jóval kisebb, mintha raszterizáltuk volna beillesztés előtt. Ez a módszer minden -- az EPS formátumot ismerő -- vektorgrafikus program (pl. Inkscape) esetén is használható. Képbeillesztésre mutat példát #aref(<fig:vscode-appendix>)~ábra.

Fontos kiemelni, hogy minden egyes számozott ábra (táblázat és kódrészlet) hivatkozva kell legyen a folyószövegben!

A táblázatok használatára #aref(<tab:tabular-example>)~táblázat mutat példát. A táblázatok formázási lehetőségeit a `table` parancs dokumentációjában találjuk: #link("https://typst.app/docs/reference/model/table/")[itt].

#figure(caption: "Az órajel-generátor chip órajel-kimenetei.")[
  #table(
    columns: (auto, auto, auto),
    align: (left, center, center),
    inset: (x: 0.6em, y: 0.45em),
    stroke: none,

    table.hline(stroke: 1pt),

    [*Órajel*],
    [*Frekvencia*],
    [*Cél pin*],

    table.hline(stroke: 0.6pt),

    [CLKA], [100 MHz], [FPGA CLK0],
    [CLKB], [48 MHz],  [FPGA CLK1],
    [CLKC], [20 MHz],  [Processzor],
    [CLKD], [25 MHz],  [Ethernet chip],
    [CLKE], [72 MHz],  [FPGA CLK2],
    [XBUF], [20 MHz],  [FPGA CLK3],

    table.hline(stroke: 1pt),
  )
] <tab:tabular-example>

// ---------------------------------------------------------------------------
== Felsorolások és listák
// ---------------------------------------------------------------------------

Számozatlan felsorolásra mutat példát a jelenlegi bekezdés:

- _első bajusz:_ ide lehetne írni az első elem kifejését,
- _második bajusz:_ ide lehetne írni a második elem kifejését,
- _ez meg egy szakáll:_ ide lehetne írni a harmadik elem kifejését.


Számozott felsorolást is készíthetünk az alábbi módon:

1. _első bajusz:_ ide lehetne írni az első elem kifejését, és ez a kifejtés így néz ki, ha több sorosra sikeredik,
2. _második bajusz:_ ide lehetne írni a második elem kifejését,
3. _ez meg egy szakáll:_ ide lehetne írni a harmadik elem kifejését.

A felsorolásokban sorok végén vessző, az utolsó sor végén pedig pont a szokásos írásjel. Ez alól kivételt képezhet, ha az egyes elemek több teljes mondatot tartalmaznak.

Kódrészletekben a dolgozat szövegétől elkülönítendő kódrészleteket, programsorokat, pszeudokódokat jeleníthetünk meg akár csak #aref(<example-code>) kódrészletben.
#figure(caption: "Példa kódrészlet a sablon forráskódjából")[
  ```typst
  #let front-matter(body) = {
    counter(page).update(0)
    set page(numbering: "i")
    body
  }
  ```
] <example-code>

// ---------------------------------------------------------------------------
== Képletek
// ---------------------------------------------------------------------------

Ha egy formula nem túlságosan hosszú, és nem akarjuk hivatkozni a szövegből, mint például a $e^(i pi)+1=0$ képlet, _szövegközi képletként_ szokás leírni. Csak hogy másik példát is lássunk, az $U_i= -dif Phi\/dif t$ Faraday-törvény a $"rot" E=- (dif B)/(dif t)$ differenciális alakban adott Maxwell-egyenlet felületre vett integráljából vezethető le. Látható, hogy a Typst-fordító a sorközöket betartja, így a szöveg szedése esztétikus marad szövegközi képletek használata esetén is. A Typst a `/` szimbólumot alapvetően közönséges törtalakként értelmezi, tehát ha szövegközben kifejezetten meg szeretnénk őrizni az egysoros formát, akkor `\/` alakban kell írni.

Képletek esetén az általános konvenció, hogy a kisbetűk skalárt, a kis félkövér betűk ($mathbf(v)$) oszlopvektort -- és ennek megfelelően $mathbf(v)^T$ sorvektort -- a kapitális félkövér betűk ($mathbf(A)$) mátrixot jelölnek. Ha ettől el szeretnénk térni, akkor az alkalmazni kívánt jelölésmódot célszerű külön alfejezetben definiálni. A Typst erre az igen gyakori jelölésre -- egyelőre -- nem ad egyszerűsítést, ezért a sablonban található `mathbf` függvényt kell használni: `$mathbf(v)$`.

Ennek megfelelően, amennyiben $mathbf(y)$ jelöli a mérések vektorát, $mathbf(theta.alt)$ a paraméterek vektorát és $hat(mathbf(y)) = mathbf(X) theta.alt $ a paraméterekben lineáris modellt, akkor a _Least-Squares_ értelemben optimális paraméterbecslő $hat(mathbf(theta.alt))_("LS") = mathbf(X)^T mathbf(X)^(-1)mathbf(X)^T mathbf(y)$ lesz.

Emellett kiemelt, sorszámozott képleteket is megadhatunk. Célszerűen a számozott képletekre hivatkozni kell a szövegben, amennyiben csak levezetés végett vagy egyéb célból jelenik meg, úgy nem kell számozni. Amennyiben számozottá szeretnénk tenni, használjuk a sablon `eq` függvényét: `#eq($ a+b=c $)`, ahogy #aref(<eq:linear>) egyenletben is tettük.
#eq($
dot(mathbf(x)) &= mathbf(A)mathbf(x)+mathbf(B)mathbf(u),\
mathbf(y) &= mathbf(C)mathbf(x) 
$) <eq:linear>
ahol $mathbf(x)$ az állapotvektor, $mathbf(y)$ a mérések vektora és $mathbf(A)$, $mathbf(B)$ és $mathbf(C)$ a rendszert leíró paramétermátrixok.

#colorbox(
  title: "Figyelem!",
  color: "red",
  radius: 5pt,
  width: auto,
)[
  A Typst a matematika módot egységesen kezeli, így a sorszámozást -- vagy annak elhagyását -- kézzel kell végezni. Ebben a sablonban alapvetően nem számozottak a képletek, tehát alapvetően az `#equation()` parancs használatával tudnánk explicit számozást megadni. Ezt megkönnyítendő ez a sablon definiál egy `#eq()` parancsot, melyben nem kell beállítani semmit, csak körbevonni vele az egyenletünket és az a megfelelő módon beszámozza. Mivel a sablon a kari számozási konvenciót alkalmazza, ezért minden esetben ezt használjuk számozott egyenletekhez, ne adjunk meg kézzel számozást!
]

Figyeljük meg, hogy a két egyenletben az egyenlőségjelek egymáshoz igazítva jelennek meg, mivel az egyenlőségjeleket egymáshoz igazítottuk a következő módon: `&=`. Amennyiben csak szimplán matematikai módba váltunk, a képletek számozatlanok maradnak:
$
  dot(mathbf(x)) &= mathbf(A)mathbf(x)+mathbf(B)mathbf(u),\
  mathbf(y) &= mathbf(C)mathbf(x) 
$
Mátrixok felírására az $mathbf(A)mathbf(x)=mathbf(b)$ inhomogén lineáris egyenlet részletes kifejtésével mutatunk példát:
#eq($ mat(
  a_(11), a_(12), ..., a_(1n);
  a_(21), a_(22), ..., a_(2n);
  a_(11), a_(12), ..., a_(1n);
  a_(m 1), a_(m 2), ..., a_(m n);
) vec(x_1, x_2, ..., x_n) = vec(b_1,b_2,...,b_n)$)

A matematikai mód minden szimbólumának és képességének a bemutatására természetesen itt nincs lehetőség, de a Typst hivatalos oldalán találhatunk egy #link("https://typst.app/docs/reference/symbols/")[szimbolóumkeresőt], amely megkönnyíti a használatot. Továbbá hasznos lehet a `physica` csomag használata, mely #link("https://typst.app/universe/package/physica/")[itt] érhető el. Ennek a csomagnak a használatával lehetséges, hogy ebben a dokumentumban a `mathbf(a)^T` valódi transzponált jellel jelenik meg: $mathbf(a)^T$.

// ---------------------------------------------------------------------------
== Irodalmi hivatkozások <sec:citations>
// ---------------------------------------------------------------------------

Egy Typst dokumentumban az irodalmi hivatkozások módja eléggé korlátozott annak érdekében, hogy egységes és jól kezelhető legyen. Minden esetben a `bibliography` hívást kell alkalmazni. Elvileg lehetőség van forráskód szinten is megadni a hivatkozni kívánt forrásokat, de ez egy idő után átláthatatlanná teszi a kezelését, ezért semmiképpse javasoljuk.

A Typst a hivatkozások kezelésére a LaTeX egyik továbbfejlesztett módszerét vette át, tehát egy akár meglévő irodalomjegyzéket is felhasználhatunk a dokumentumhoz. A Typst két formátumot támogat a BibLaTeX `.bib` forrásfájljait, illetve a viszonylag új *Hayagriva-féle* `.yml` formátumot. Alapvetően az első megoldás használata a könnyebb, hiszen a legtöbb szakirodalmi folyóirat vagy könyvtár automatikusan generál exportálható `.bib` hivatkozást az adott forráshoz. A második megoldás ellenben kifejezetten Typsthoz készült, viszont az említett forráskönyvtárak -- egyelőre -- többnyire nem generálják a hivatkozást automatikusan Hayagriva `yml`-be.

A fenti megoldás használatával a forráskezelés professzionálissá válik: nem kell külön rendezni és formázni a hivatkozásokat, csupán összegyűjteni őket a megfelelő forrásfájlba, majd névvel hivatkozni őket a dokumentumban. Az egyes forrásmunkákra a szövegből  a `@` operátorral tudunk hivatkozni, így #aref(<lst:bib>)~kódrészlet esetén a hivatkozások rendre `@Wettl04`, `@Candy86`, `@Lee87`, `@KissPhD`, `@Schreier00`, `@Mkrtychev:1997` és `@DipPortal`. Az egyes forrásmunkák sorszáma az irodalomjegyzék bővítésekor változhat. Amennyiben az aktuális számhoz illeszkedő névelőt szeretnénk használni, használjuk az `aref` parancsot a korábbiakban megszokott módon.

BibTeX esetén a forrásmunkákat típus szerinti kulcsszó vezeti be (`@book` könyv, `@inproceedings` konferenciakiadványban megjelent cikk, `@article` folyóiratban megjelent cikk, `@techreport` valamelyik egyetem gondozásában megjelent műszaki tanulmány, `@manual` műszaki dokumentáció esetén stb.). Nemcsak a megjelenés stílusa, de a kötelezően megadandó mezők is típusról-típusra változnak. 

#colorbox(
  title: "Figyelem!",
  color: "red",
  radius: 5pt,
  width: auto,
)[
  Egy jól használható referencia a http://en.wikipedia.org/wiki/BibTeX oldalon található. Viszont érdemes figyelni, mert nem minden mező szerepel a szabványban, amit a BibTeX alkalmaz, ezért némelyik nem biztos, hogy ténylegesen szerepelni fog. Például: `howpublished` mező a `misc` típusnál. Ezt érdemes ellenőrizni
]


#figure(caption: "Példa szöveges irodalomjegyzék használatára -- BibTeX esetén")[
```bib
@book{Wettl04,
  author    = {Ferenc Wettl and Gyula Mayer and Péter Szabó},
  publisher = {Panem Könyvkiadó},
  title     = {\LaTeX~kézikönyv},
  year      = {2004},
}

@article{Candy86,
  author       = {James C. Candy},
  journaltitle = {{IEEE} Trans.\ on Communications},
  month        = {01},
  note         = {\doi{10.1109/TCOM.1986.1096432}},
  number       = {1},
  pages        = {72--76},
  title        = {Decimation for Sigma Delta Modulation},
  volume       = {34},
  year         = {1986},
}

@inproceedings{Lee87,
  author    = {Wai L. Lee and Charles G. Sodini},
  booktitle = {Proc.\ of the IEEE International Symposium on Circuits and Systems},
  location  = {Philadelphia, PA, USA},
  month     = {05~4--7},
  pages     = {459--462},
  title     = {A Topology for Higher Order Interpolative Coders},
  vol       = {2},
  year      = {1987},
}

@thesis{KissPhD,
  author      = {Peter Kiss},
  institution = {Technical University of Timi\c{s}oara, Romania},
  month       = {04},
  title       = {Adaptive Digital Compensation of Analog Circuit Imperfections for Cascaded Delta-Sigma Analog-to-Digital Converters},
  type        = {phdthesis},
  year        = {2000},
}

@manual{Schreier00,
  author       = {Richard Schreier},
  month        = {01},
  note         = {\url{http://www.mathworks.com/matlabcentral/fileexchange/}},
  organization = {Oregon State University},
  title        = {The Delta-Sigma Toolbox v5.2},
  year         = {2000},
}

@misc{DipPortal,
  author       = {{Budapesti Műszaki és Gazdaságtudományi Egyetem Villamosmérnöki és Informatikai Kar}},
  howpublished = {\url{http://diplomaterv.vik.bme.hu/}},
  title        = {Diplomaterv portál (2011. február 26.)},
}

@incollection{Mkrtychev:1997,
  author    = {Mkrtychev, Alexey},
  booktitle = {Logical Foundations of Computer Science},
  doi       = {10.1007/3-540-63045-7_27},
  editor    = {Adian, Sergei and Nerode, Anil},
  isbn      = {978-3-540-63045-6},
  pages     = {266-275},
  publisher = {Springer Berlin Heidelberg},
  series    = {Lecture Notes in Computer Science},
  title     = {Models for the logic of proofs},
  url       = {http://dx.doi.org/10.1007/3-540-63045-7_27},
  volume    = {1234},
  year      = {1997},
}
```
] <lst:bib>

Az irodalomjegyzékben alapértelmezésben csak azok a forrásmunkák jelennek meg, amelyekre található hivatkozás a szövegben, és ez így alapvetően helyes is, hiszen olyan forrásmunkákat nem illik az irodalomjegyzékbe írni, amelyekre nincs hivatkozás.

Hogy a szövegbe ágyazott hivatkozások kinézetét demonstráljuk, itt most sorban meghivatkozzuk a @Wettl04, @Candy86, @Lee87, @KissPhD, @Schreier00 és  @Mkrtychev:1997#footnote[Informatikai témában gyakran hivatkozunk cikkeket a Springer LNCS valamely kötetéből, ez a hivatkozás erre mutat egy helyes példát.] forrásmunkát, valamint @DipPortal weboldalt.

Irodalomhivatkozásokat célszerű először olyan szolgáltatásokban keresni, ahol jó minőségű bejegyzések találhatók (pl. ACM Digital Library,#footnote[https://dl.acm.org/] DBLP,#footnote[http://dblp.uni-trier.de/] IEEE Xplore,#footnote[http://ieeexplore.ieee.org/] SpringerLink#footnote[https://link.springer.com/]) és csak ezek után használni kevésbé válogatott forrásokat (pl. Google Scholar#footnote[http://scholar.google.com/]).

// ---------------------------------------------------------------------------
== A dolgozat szerkezete és a forrásfájlok
// ---------------------------------------------------------------------------

A diplomatervsablon alapvetően két részből áll: az egyik a formázást, alapvető beállításokat és eszköztárat kínáló sablon, a másik pedig a tartalmi részeket felölelő példa dokumentum. Előbbi egy csomag, melynek a `lib.typ` a belépési pontja -- ideális esetben ezt nem kell/szabad módosítani. Utóbbi egy általános dokumentum, melynek belépési pontja a `thesis.typ`, ezt kell módosítani, hisz a tartalmi elemek itt találhatók.

A diplomatervsablon (a kari irányelvek szerint) az alábbi fő fejezetekből áll:

	1. 1 oldalas _tájékoztató_ a szakdolgozat/diplomaterv szerkezetéről (`guideline.typ`), *ami a végső dolgozatból törlendő*,
	2. _feladatkiírás_ `project.typ`, a dolgozat nyomtatott verziójában *ennek a helyére kerül* a tanszék által kiadott, a tanszékvezető által aláírt feladatkiírás, *a dolgozat elektronikus verziójába pedig a feladatkiírás egyáltalán ne kerüljön bele*, azt külön tölti fel a tanszék a diplomaterv-honlapra,
	3. _címoldal_,
	4. _tartalomjegyzék_,
	5. a diplomatervező/szakdolgozó #text(style: "italic")[nyilatkozat]a az önálló munkáról
	6. 1-2 oldalas tartalmi _összefoglaló_ magyarul és angolul, illetve elkészíthető még további nyelveken is (`abstract.typ`),
	7. _bevezetés_: a feladat értelmezése, a tervezés célja, a feladat indokoltsága, a diplomaterv felépítésének rövid összefoglalása (`introduction.typ`),
	8. sorszámmal ellátott _fejezetek_: a feladatkiírás pontosítása és részletes elemzése, előzmények (irodalomkutatás, hasonló alkotások), az ezekből levonható következtetések, a tervezés részletes leírása, a döntési lehetőségek értékelése és a választott megoldások indoklása, a megtervezett műszaki alkotás értékelése, kritikai elemzése, továbbfejlesztési lehetőségek,
	9. esetleges #text(style: "italic")[köszönetnyilvánítás]ok (`acknowledgement.typ`),
	10. részletes és pontos _irodalomjegyzék_ (ez a sablon esetében automatikusan generálódik a `thesis.typ` fájlban elhelyezett `#bibliography()` utasítás hatására, #aref(<sec:citations>) fejezetben leírtak szerint),
	11. _függelékek_ (`appendices.tex`).

A sablonban a fejezetek a `thesis.typ` fájlba vannak beillesztve `#include` utasítások segítségével. A sablon a fejezetek számára nem tesz megkötést, azonban explicit utasításokkal jelezni kell a dokumentum egyes részeit a megfelelő számozások, stílusok és hivatkozások előállítása végett.

A `#show: front-matter` rule-t mindig a sablon inicializálása, tehát a `#show: thesis.with(...)` rule után kell hívni. Ekkor helyezhető el a tetszőleges számú és nyelvű kivonat a sablonban. Fontos, hogy ezeket explicit `#heading(numbering: none)[Kivonat]` módon kell létrehozni.

A `#show: main-matter` rule-t mindig a kivonati rész után kell helyezni. Ezután tetszőleges számú *számozott fejezet* illeszthető a dokumentumba, ahol az egyes stílusjegyek a kari irányelveket, illetve szokásrendet követik.

A `#show: back-matter` rule-t a számozott fejezetek után kell elhelyezni, ekkor tetszőleges számozatlan fejezet elhelyezhető. Például: köszönetnyilvánítás, `#show: list-of-figures` és `#show: list-of-tables` rule-ok alkalmazásával rendre ábra- és táblázatjegyzék, továbbá tetszőleges számú irodalomjegyzék a `#bibliography` parancs alkalmazásával -- ez utóbbi beépített Typst parancs, #link("https://typst.app/docs/reference/model/bibliography/")[itt] lehet róla olvasni. Jellemzően egy irodalomjegyzék elég, de időnként a szerzőnek az önhivatkozásokat külön kell kezelnie, például doktori disszertációk esetében.

A `#show: appendix` rule alkalmazása után már csak a függelék fejezet csatolható tetszőleges számú _alfejezettel_.

Végül a dokumentum zárásaként a a mesterséges intelligencia használatáról szóló nyilatkozatot kell kitölteni. Ehhez a `#show: genai-declaration.with()` rule alkalmazására van szükség, ahol argumentumként *meg kell adni*, hogy a szerző használt-e mesterséges intelligenciát a dolgozat készítéséhez: `true` vagy `false` opcióval. Előbbi válasz esetén pedig a sablonban található táblázatot kell kitölteni a megfelelő módon, továbbá a megfelelő függvények hívásával. Ha egy adott promptot meg szeretnénk adni, akkor az adott sor hívásába kell ezt elhelyeznünk `gen-ai-prompt(text: "Ez a prompt!")` módon, ahogy `gen-ai-all-text` hívás esetén is. A teljes százalékos hozzájárulást számszerűen kell megadni: `gen-ai-all-percentage(percentage: 75)`.

Ennek a dokumentumnak a forrásfájlja adja a legkézenfekvőbb bevezetést a sablon használatába, ezért érdemes tanulmányozni. 

// ---------------------------------------------------------------------------
== Alapadatok megadása
// ---------------------------------------------------------------------------

A diplomaterv alapadatait (cím, szerző, konzulens, konzulens titulusa) a `thesis.typ` fájlban lehet megadni, a sablon hívása során a `thesis.with()` paranccsal. Az alkalmazható paraméterek a következők:

- `authors`: Egy vagy több szerző neve sztring vagy tömb formátumban: `"egy"` vagy `("elso", "masodik")`.
- `department`: A tanszék neve sztringként megadva -- alapértelmezett opció a TMIT
- `font-size`: A dokumentum betűmérete `length` típusként. Az alábbi opciók támogatottak: `10pt`, `11pt`, `12pt`.
- `industrial-advisors`: Ipari konzulens(ek) nevei, sztring vagy tömb formátumban.
- `lang`: A dokumentum nyelve. Jelenleg a `hu` és `en` támogatott, előbbi az alapértelmezett.
- `leading`: Az alkalmazott sorköz mérete sztringként. Jelenleg támogatott értékek: `"normal"` (0.65-ös, alapértelmezett), `"simple"` (feles), `"double"` (egyszeres).
- `physical`: Boolean érték, mely ha `true`, akkor fizikai nyomtatáshoz megfelelően állítja a margókat. Ízlés szerint két vagy egyoldalas nyomtatás/fűzés is lehetséges. `false` esetén minden margó egyforma -- ideális digitális verziókhoz.
- `supervising-type`: A témavezetés jellege, két támogatott értékkel: `"advisor"`, ekkor a címlapon a _konzulens_ szó jelenik meg (alapértelmezett), továbbá `"supervisor"`, ekkor pedig a _témavezető_ szó.
- `supervisors`: A konzulens(ek)/témavezető(k) neve sztringként vagy tömbként.
- `thesis-type`: A dolgozat jellege, ami a címlapon is megjelenik. A támogatott értékek: `bsc` (alapértelmezett), `msc`, `phd`, `tdk`.
- `title`: A dolgozat címe sztringként.

// ---------------------------------------------------------------------------
== Új fejezet írása
// ---------------------------------------------------------------------------
A főfejezetek külön a `content` könyvtárban foglalnak helyet. A sablonhoz 3 fejezet készült. További főfejezeteket úgy hozhatunk létre, ha új Typst~fájlt készítünk a fejezet számára, és a `thesis.typ` fájlban, az `#include()` utasítások argumentumába felvesszük az új `.typ` fájl nevét.

#colorbox(
  title: "Figyelem!",
  color: "red",
  radius: 5pt,
  width: auto,
)[
  Mivel a Typst nem fordítja össze a forrásfájlokat, így egy adott csomagot mindig a használat helyén kell beimportálni, ha annak egy függvényét/változóját kívánjuk elérni (ez természetesen rule-okra nem vonatkozik). Emiatt a sablon által nyújtott függvények hívásához, *az adott fájlban mindig be kell importálni a sablont*! Tipikusan ilyen függvény az `aref`, `mathbf` és #aref(<sec:defs>)~fejezetben bemutatott definíciók és tételek.
]

// ---------------------------------------------------------------------------
== Definíciók, tételek, példák <sec:defs>
// ---------------------------------------------------------------------------

Az alábbiakban matematikai definíciók és tételek létrehozását mutatjuk be. Alapvetően a Typst nem támogatja ezeket a környezeteket, csak csomagokon keresztül. Ez a sablon a #link("https://typst.app/universe/package/theorion/")[theorion] csomagot használja, ahhoz előgyártott beálltásokat tartalmaz, így a hivatkozások az ábráknál is megszokott módon működnek: #aref(<def:fluxus>)~definíció például a fluxuskondenzátor térerősségét definiálja.

#colorbox(
  title: "Figyelem!",
  color: "red",
  radius: 5pt,
  width: auto,
)[
  A `theorion` alapvetően többnyelvű csomag, de magyart nem tartalmaz, illetve az egyedi számozásokat nehézkesen kezeli (egyelőre, akárcsak a Typst), ezért a sablon a lehető legegyszerűbben hidalja át ezt a problémát.

  A magyar `theorion` (huorion) a `content/helpers` mappában található, innen kell beimportálni -- akár csak a jelen fájlban. Alapesetben nem kell változtatni semmit, tehát csak használni a `theorion` által adott parancsokat, viszont lehet módosítani például a megjelenést, úgy ahogy a csomag útmutatója azt leírja.
]

A sablon egyelőre a definíció, tétel, bizonyítás, lemma és példa környezeteket ismeri "magyarul": `#definition`, `#theorem`, `#proof`, `#lemma` és `#example`.



#definition(title: "Fluxuskondenzátor térerőssége")[
  #lorem(45)
] <def:fluxus>

#example[
  #lorem(30)
]

#theorem[Hollósi tétele][#lorem(33) Vagy valami hasonló, mittomén.
]

#proof[
  #lorem(65)
  $
  a^2 + b^2 = c^2
  $
  #lorem(75)
]