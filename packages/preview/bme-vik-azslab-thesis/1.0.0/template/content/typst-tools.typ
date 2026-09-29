#import "@preview/bme-vik-azslab-thesis:1.0.0": *
// ---------------------------------------------------------------------------
= Typst-eszközök <chap:typst-tools>
// ---------------------------------------------------------------------------

Az alábbi leírás a Typst lehetőségeinek csak egy kis részét mutatja be azon felhasználók számára, akik nem szeretnének a számítógép-kezelés rögös útjára lépni, és egy kész recepetet kívánnak követni. Mindazok, akik a megfelelő technikai képzettséggel rendelkeznek látogassanak el a hivatalos weboldalra -- https://typst.app --, ahol választ kapnak az összes olyan kérdésre, amelyet itt most csak felületesen vizsgálunk. Tételesen:

- Mi a Typst?
- Hogyan lehet Typst nyelven dokumentumot írni?
- Milyen szoftverben tudok Typst nyelvű dokumentumot írni?
- Hogyan kell egy Typst nyelvű dokumentumot lefordítani? 
- Milyen lehetőségeim vannak a Typst lokális telepítésére?

== Mi a Typst?

A Typst egy modern dokumentumszerkesztő rendszer, amelyet tudományos dolgozatok, szakdolgozatok, könyvek és egyéb összetett dokumentumok készítésére fejlesztettek ki. Működési elve hasonló a LaTeX-éhez: a felhasználó nem egy grafikus felületen szerkeszti a dokumentumot, hanem egy egyszerű jelölőnyelven írja le annak szerkezetét és tartalmát, amelyből a rendszer automatikusan állítja elő a végleges PDF-et. A Typst azonban a LaTeX-nél modernebb szemléletet követ. Szintaxisa letisztultabb és könnyebben olvasható, a felszínen több elemében a Markdown jelölőnyelvre emlékeztet, ezért a kezdő felhasználók számára is könnyebben elsajátítható, miközben a haladó felhasználók számára is biztosítja a nagyfokú testreszabhatóságot.

A Typst egyik legnagyobb előnye a gyors fordítási sebesség és az azonnali előnézet, amely jelentősen megkönnyíti a dokumentum szerkesztését. Emellett beépített támogatást nyújt számos gyakori funkcióhoz, például a tartalomjegyzék, az ábrák és táblázatok jegyzéke, a hivatkozások vagy a matematikai képletek kezeléséhez. A rendszer jól támogatja az újrafelhasználható sablonok készítését is, így egy intézmény vagy szervezet egységes arculatú dokumentumokat készíthet anélkül, hogy a felhasználóknak a formázással kellene foglalkozniuk -- ezért vagy te is itt. Ezeknek a tulajdonságoknak köszönhetően a Typst napjaink egyik legígéretesebb alternatívája a hagyományos WYSIWYG (What You See Is What You Get) dokumentumszerkesztő rendszereknek, mint amilyen a Microsoft Word. Mindemellett kötelességem megjegyezni, hogy a Typst még egy fiatal rendszer, tehát minden előnye ellenére vannak kiforratlan részei, ez remélhetőleg idővel változni fog.

== A Typst nyelv alapjai

Ahhoz, hogy el tudjunk kezdni írni egy Typst nyelvű dokumentumot, csupán néhány szabályt kell ismernünk. Alapvetően az egyszerű szöveg abban a formában jelenik meg ahogy leírjuk#footnote[Legalábbis ameddig Markup módban vagyunk.], továbbá a szöveg funkcióját tudjuk speciális karakterekkel módosítani.

Ha `=` karakterrel (és szóközzel) kezdünk egy sort, akkor az új fejezetet jelöl. #Aref(<lst:simple-code>)~kódrészletben például a fejezet neve *Bevezetés* lesz. Amennyiben `==` karakterrel kezdjük a sort, úgy az alfejezetet fog jelenteni.

Felsorolást könnyedén hozhatunk létre `-` karakter alkalmazásával, ahogy a lenti példán is látszik. Ugyanígy számozott listát létre tudunk hozni `+` karakterrel vagy akár a számok megadásával `1.`, `2.` és így tovább.

A jelölőnyelven túl parancsokat#footnote[Pontosabban függvényeket] is használhatunk, például a `#figure` parancs egy számozott ábrát fog létrehozni a paraméterként (zárójelek között) átadott képből.

#figure(caption: "Typst forráskód egy egyszerű példa dokumentumhoz")[
```typst
= Bevezetés

Ez egy egyszerű Typst dokumentum.

== Felsorolás

- Első elem
- Második elem
- Harmadik elem

#figure(image("foto.jpg"))

#pagebreak()

= Következő fejezet

```
] <lst:simple-code>

További információk a https://typst.app/docs/tutorial/writing-in-typst/ oldalon érhetők el. Körülbelül 3 perc hosszú olvasmány, és ez után már akár bele is vághatunk a dokumentumírásba.

// ---------------------------------------------------------------------------
== A szerkesztéshez használatos eszközök
// ---------------------------------------------------------------------------

A sablon szerkesztéséhez számos ingyenesen elérhető eszköz található. Az első és legegyszerűbb a https://typst.app online felülete, amely tartalmazza a Typst keretrendszeret is, tehát _out-of-the-box_ megoldást kínál azoknak, akik nem szeretnének bajlódni a dokumentumszerkesztéssel. Fontos megjegyezni, hogy ez több csomagban érhető el, és az ingyenes változat korlátozásokkal terhelt. A fenti eszköz párja az -- előbbitől független fejlesztésű -- #link("https://typstify.com")[Typstify], amely egy asztali alkalmazás Linux, Windows és Mac operációs rendszerekre, ez látható #aref(<fig:typstify>)~ábrán is. Ez kifejezetten Typst dokumentumok szerkesztésére való, akár csak az online eszköz, viszont ez esetben a fájlok a saját eszközünkön tárolódnak, továbbá a környezet beállítása is a felhasználó felelőssége -- cserébe korlátozások nélkül használható.

#figure(image("../figures/typstify.webp"), caption: "A Typstify szövegszerkesztő program és a live preview nézet") <fig:typstify>

Jelen sablon szerzője a Microsoft Visual Studio Code termékét ajánlja a #link("https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist")[Tinymist] plugin alkalmazásával -- ezt mutatja #aref(<fig:vscode>)~ábra --, de bármilyen kódszerkesztő alkalmazás használható. Célszerű olyat választani, amellyel már van tapasztalatunk, így sok időt meg spórolhatunk.

#figure(image("../figures/vs_code_tinymist.png"), caption: "A Microsoft Visual Studio Code szövegszerkesztő programban az alábbi sablon és a hozzá tartozó előnézet") <fig:vscode>

Fontos, hogy ezen szoftverek egyike sem tartalmaz beépített helyesírás-ellenőrzést, arról a felhasználónak kell gondoskodni. Az online Typst editorban célszerűen alkalmazható egy böngészőben futó, tetszőleges helyesírás-ellenőrző. VSCode-ban a Code Spell Checker plugin és a külön telepítendő "Hungarian" szótár lehet segítségünkre -- ez utóbbi a sablon készítésekor meglehetősen korlátozott képességű (`1.0.5`). Ezek azonban -- egyelőre -- nyelvtani hibákat nem vesznek észre, csak elgépeléseket, így a kész munkát célszerű egy külső helyesírás ellenőrzővel is átnézetni.

// ---------------------------------------------------------------------------
== A Typst telepítése és a dokumentum lefordítása
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
=== Telepítés Windows operációs rendszeren
// ---------------------------------------------------------------------------
A fent felsorolt szoftverek csupán a szöveg (forrás) szerkesztésére alkalmasak, ahhoz hogy a forrásból egy tényleges dokumentum készüljön, le kell azt fordítani. Ehhez szükségünk van a Typst szoftvercsomagra, mely többek között a Typst fordítót is tartalmazza. A hivatalos weboldalon számos telepítési lehetőség közül választhatunk. Valószínűleg Windows felhasználóknak a legkomfortosabb változat a futtatható telepítő (`.exe`) használata. Telepítés után a `PATH` környezeti változóba fel kell venni a telepítés helyét, hogy bárhonnan elérhető legyen a `typst` parancs. Ez utóbbiről #link("https://stackoverflow.com/questions/9546324/adding-a-directory-to-the-path-environment-variable-in-windows")[ITT] lehet olvasni.

// ---------------------------------------------------------------------------
=== Telepítés normális operációs rendszeren
// ---------------------------------------------------------------------------
Linux disztribúciókon is számos különböző telepítési út áll rendelkezésünkre, a legkézenfekvőbb a disztribúció saját csomagkezelőjét használni, amennyiben a csomag létezik. Ez egyelőre csak bizonyos disztribúcióknál érhető el. A sokak körében népszerű Ubuntun például `snap`-en keresztül lehet telepíteni, az `apt` csomagkezelőn keresztül nem. Természetesen fordíthatjuk forrásból is vagy használhatunk Docker image-t. Erről bővebben a hivatalos oldalon lehet olvasni: https://typst.app/open-source/#download

Amennyiben nem csomagkezelőn keresztül telepítettük, úgy az elérési útvonalat hozzá kell adni a `PATH` környezeti változóba. Ez utóbbiről #link("https://stackoverflow.com/questions/14637979/how-to-permanently-set-path-on-linux-unix")[ITT] lehet olvasni.


// ----------------------------------------------------------------------------
=== A dokumentum lefordítása
// ----------------------------------------------------------------------------

Amennyiben nem használjuk a fenti szerkesztők beépített fordítási funkcióját, úgy mi magunk is lefordíthatjuk a sablont, közvetlenül. Ehhez az alábbi parancsot kell kiadni a projektmappában vagy a letöltött sablon `template` könyvtárában:
```sh
typst compile thesis.typ
```
Ekkor létre fog jönni a kívánt `.pdf` fájl. Továbbá, igen hasznos a következő parancs:
```sh
typst watch thesis.typ
```
Ez esetben a fájl azonnal újrafordul minden egyes alkalommal, amikor a forrásfájl megváltozik.

Bár ezek a parancsok és a Typst rendszer ismerete nagyon hasznos tud lenni, a munkafolyamat szempontjából célszerűbb nem parancsosorból fordítani, hanem a szerkesztőprogramon keresztül -- amely természetesen ugyanúgy a `typst` parancsot hívja.

Egyéb teendőnk nincs a dokumentum lefordítása végett, ugyanis a Typst tartalmaz minden komponenst, amely ehhez szükséges, leszámítva a használt Typst csomagokat, azonban az első fordítás alkalmával ezeket automatikusan letölti.
