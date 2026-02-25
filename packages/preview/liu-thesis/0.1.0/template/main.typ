#import "@preview/liu-thesis:0.1.0": student-thesis

#show: student-thesis.with(
  title: (
    swedish: "En himla bra svensk titel",
    english: "A very very long title",
  ),
  subtitle: (
    swedish: none,
    english: "with a subtitle",
  ),
  author: "Författaren",
  examiner: "Min examinator",
  supervisor: "Min handledare",
  subject: "Datateknik",
  department: (
    swedish: "Institutionen för datavetenskap",
    english: "Department of Computer and Information Science",
  ),
  department-short: "IDA",
  publication-year: "2017",
  thesis-number: "001",
  language: "swedish",
  level: "msc",
  faculty: "lith",
  abstract: [
    Här skriver du en kort sammanfattning av ditt arbete.

    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque
    in massa suscipit, congue massa in, pharetra lacus. Donec nec felis
    tempor, suscipit metus molestie, consectetur orci. Pellentesque
    habitant morbi tristique senectus et netus et malesuada fames ac
    turpis egestas. Curabitur fermentum, augue non ullamcorper tempus, ex
    urna suscipit lorem, eu consectetur ligula orci quis ex.

    Nulla lobortis enim ac magna rhoncus, nec condimentum erat aliquam.
    Nullam laoreet interdum lacus, ac rutrum eros dictum vel. Cras lobortis
    egestas lectus, id varius turpis rhoncus et. Nam vitae auctor ligula,
    et fermentum turpis. Morbi neque tellus, dignissim a cursus sed, tempus
    eu sapien. Morbi volutpat convallis mauris, a euismod dui egestas sit
    amet.

    Vestibulum posuere nibh ut iaculis semper. Ut diam justo, interdum quis
    felis ac, posuere fermentum ex. Fusce tincidunt vel nunc non semper.
    Sed ultrices suscipit dui, vel lacinia lorem euismod quis. Etiam
    pellentesque vitae sem eu bibendum.
  ],
  acknowledgments: [
    Skriv dina tack här.
  ],
  bibliography: bibliography("references.bib", title: none),
)

#set math.equation(numbering: "(1)")

= Inledning <cha:introduction>

Inledningen ska delas in i följande avsnitt.

== Motivation

@scigen

Här beskrivs det studerade problemet ur ett generellt perspektiv och
sätts i ett sammanhang som gör det tydligt att det är intressant och
värt att studera. Syftet är att göra läsaren intresserad av arbetet
och skapa en vilja att fortsätta läsa.

== Syfte

Vad är det underliggande syftet med examensarbetet?

== Forskningsfrågor <sec:research-questions>

Här beskrivs forskningsfrågorna. Formulera dessa som explicita frågor,
avslutade med frågetecken. En rapport innehåller vanligtvis flera olika
forskningsfrågor som är tematiskt sammankopplade. Det brukar vara 2--4
frågor totalt.

Exempel på vanliga typer av forskningsfrågor (förenklade och
generaliserade):

+ Hur påverkar teknik X möjligheten att uppnå effekt Y?

+ Hur kan ett system (eller en lösning) för X realiseras så att
  effekt Y uppnås?

+ Vilka är alternativen för att uppnå X, och vilket alternativ ger
  bäst effekt med hänsyn till Y och Z?

Observera att en mycket specifik forskningsfråga nästan alltid leder
till en bättre uppsats än en generell forskningsfråga. Det bästa sättet
att uppnå en riktigt bra och specifik forskningsfråga är att genomföra
en grundlig litteraturgenomgång och bekanta sig med relaterad forskning.
Det leder till idéer och terminologi som gör det möjligt att uttrycka
sig med precision och även ha något värdefullt att säga i
diskussionskapitlet. I slutändan lönar det sig vanligtvis att lägga
extra tid i början på litteraturgenomgången.

== Avgränsningar

Här beskrivs de viktigaste avgränsningarna. Till exempel kan det handla
om att studien har fokuserats på en specifik tillämpningsdomän eller
målgrupp. I normalfallet behöver avgränsningarna inte motiveras.


= Teori <cha:theory>

Huvudsyftet med detta kapitel är att göra det uppenbart för läsaren att
rapportens författare har ansträngt sig för att läsa in sig på relaterad
forskning och annan information av relevans för forskningsfrågorna. Det
handlar om förtroende: kan jag som läsare lita på vad författarna säger?
Om det är uppenbart att författarna kan ämnesområdet väl och tydligt
presenterar sina lärdomar, höjer det den upplevda kvaliteten på hela
rapporten.

Efter att ha läst teorikapitlet ska det vara uppenbart för läsaren att
forskningsfrågorna är både väl formulerade och relevanta.

Kapitlet ska vara strukturerat tematiskt, inte per författare. Ett bra
tillvägagångssätt för att göra en litteraturöversikt är att använda
_Google Scholar_ (som även har den användbara funktionen _Citera_). Genom
att iterera mellan att söka artiklar och läsa sammanfattningar för att
hitta nya termer som vägleder vidare sökningar, kan man relativt enkelt
hitta bra och relevant information, som till exempel @test.

Har man hittat en relevant artikel kan man använda funktionen för att
visa andra artiklar som har citerat just den artikeln, samt gå igenom
artikelns egen referenslista @scigen. Bland dessa kan man ofta hitta
andra intressanta artiklar och därmed komma vidare.

En formel kan presenteras som en del av texten @knuth1997. Till exempel
beskriver @eq:example det välkända kvadratiska uttrycket:

$ f(x) = a x^2 + b x + c $ <eq:example>

@tab:comparison visar en jämförelse av olika metoder som diskuteras i
litteraturen.

#figure(
  table(
    columns: 3,
    table.header[*Metod*][*Fördel*][*Nackdel*],
    [Metod A], [Snabb], [Låg precision],
    [Metod B], [Hög precision], [Långsam],
    [Metod C], [Balanserad], [Komplex implementation],
  ),
  caption: [Jämförelse av metoder i litteraturen.],
) <tab:comparison>

Detta kapitel kallas antingen _Teori_, _Relaterat arbete_ eller
_Relaterad forskning_. Kontrollera med din handledare.


= Metod <cha:method>

I detta kapitel beskrivs metoden på ett sätt som visar hur arbetet
faktiskt genomfördes. Beskrivningen ska vara precis och genomtänkt.
Tänk på den vetenskapliga termen _replikerbarhet_. Replikerbarhet
innebär att någon som läser en vetenskaplig rapport ska kunna följa
metodbeskrivningen och sedan genomföra samma studie och kontrollera
om resultaten som erhålls är liknande. Att uppnå replikerbarhet är
inte alltid relevant, men precision och tydlighet är det @smith2020.

Ibland delas arbetet upp i olika delar. I sådana fall rekommenderas
att metodkapitlet struktureras med lämpliga underrubriker, till
exempel:

- Förstudie
- Implementering
- Utvärdering

En metodisk process kan beskrivas steg för steg:

+ Definiera problemet och formulera hypoteser.
+ Välj lämpliga datakällor och verktyg.
+ Samla in och förbehandla data.
+ Genomför analysen enligt vald metod.
+ Validera resultaten mot kända referensvärden.

Om implementeringsdetaljer är relevanta kan pseudokod eller
kodexempel inkluderas för att förtydliga:

```python
def process_data(raw_data):
    """Förbehandla rå data för analys."""
    cleaned = remove_outliers(raw_data)
    normalized = normalize(cleaned)
    return normalized
```


= Resultat <cha:results>

Detta kapitel presenterar resultaten. Observera att resultaten
presenteras sakligt, med strävan efter objektivitet så långt det är
möjligt. Resultaten ska inte analyseras, diskuteras eller utvärderas.
Det lämnas till diskussionskapitlet.

Om metodkapitlet (@cha:method) har delats in i underrubriker som
förstudie, implementering och utvärdering, bör resultatkapitlet ha
samma underrubriker. Det ger en tydlig struktur och gör kapitlet
lättare att skriva.

Om resultat presenteras från en process (t.ex. en
implementeringsprocess) ska de viktigaste besluten under processen
presenteras och motiveras tydligt. Normalt har alternativa ansatser
redan beskrivits i teorikapitlet, vilket gör det möjligt att hänvisa
dit som en del av motiveringen.

@tab:results sammanfattar de viktigaste mätresultaten.

#figure(
  table(
    columns: 4,
    table.header[*Konfiguration*][*Precision*][*Recall*][*F1-poäng*],
    [Baslinje], [0.72], [0.68], [0.70],
    [Metod A], [0.81], [0.79], [0.80],
    [Metod B], [0.85], [0.74], [0.79],
    [Metod C], [0.83], [0.82], [0.82],
  ),
  caption: [Resultat för de olika konfigurationerna.],
) <tab:results>


= Diskussion <cha:discussion>

Detta kapitel innehåller följande underrubriker.

== Resultat

Finns det något i resultaten som sticker ut och behöver analyseras och
kommenteras? Hur förhåller sig resultaten till materialet i
teorikapitlet (@cha:theory)? Vad säger teorin om betydelsen av
resultaten? Till exempel, vad innebär det att ett visst system fick ett
visst numeriskt värde i en utvärdering --- hur bra eller dåligt är det?
Finns det något i resultaten som är oväntat baserat på
litteraturgenomgången, eller är allt som man teoretiskt kunde förvänta
sig?

== Metod

Här diskuteras och kritiseras den tillämpade metoden. Att inta en
självkritisk hållning till den använda metoden är en viktig del av det
vetenskapliga förhållningssättet.

En studie är sällan perfekt. Det finns nästan alltid saker man kunde ha
gjort annorlunda om studien kunde upprepas eller med extra resurser. Gå
igenom de viktigaste begränsningarna med metoden och diskutera
potentiella konsekvenser för resultaten. Koppla tillbaka till
metodteorin som presenterades i teorikapitlet.#footnote[Reliabilitet
avser huruvida man kan förvänta sig att få samma resultat om en studie
upprepas med samma metod. Validitet handlar, något förenklat, om
huruvida en genomförd mätning faktiskt mäter det man tror att den mäter.]

Metoddiskussionen ska även innehålla ett stycke om källkritik. Här
beskrivs författarnas syn på användningen och urvalet av källor.

== Arbetet i ett vidare sammanhang

Det ska finnas ett avsnitt som diskuterar etiska och samhälleliga
aspekter relaterade till arbetet. Detta är viktigt för att författarna
ska kunna visa professionell mognad och även för att uppfylla
utbildningsmålen. Om arbetet av någon anledning helt saknar koppling
till etiska eller samhälleliga aspekter ska detta uttryckligen anges
och motiveras i avsnittet Avgränsningar i inledningskapitlet.


= Slutsats

Detta kapitel innehåller en sammanfattning av syftet och
forskningsfrågorna (se @sec:research-questions). I vilken utsträckning
har syftet uppnåtts och vilka är svaren på forskningsfrågorna?

Konsekvenserna för målgruppen (och möjligen för forskare och
praktiker) ska också beskrivas. Det bör finnas ett avsnitt om framtida
arbete där idéer för fortsatt arbete beskrivs. Om slutsatskapitlet
innehåller ett sådant avsnitt ska idéerna vara konkreta och genomtänkta.
