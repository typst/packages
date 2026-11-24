#import "@preview/pg-thesis-unofficial:0.1.0": ang

= Dokument elektroniczny <chap:DokumentElektroniczny>
Dokument, najogólniej, to nośnik zrozumiałej dla~człowieka treści, zwanej potocznie informacją. Stanowi naturalny, utrwalony przez~wieki interfejs dla~człowieka oraz powszechny środek komunikacji międzyludzkiej. Jako dokument mogą być rozumiane wszelkie środki przekazu informacji, od~tradycyjnych dokumentów tekstowo-obrazkowych, odbieranych za~pośrednictwem wzroku, po~coraz bardziej powszechne dokumenty multimedialne, szczególnie dźwiękowe, ale też odbierane poprzez dotyk (np. napisane alfabetem Braille'a) bądź nawet przez~węch#footnote[Popularny był kiedyś zwyczaj perfumowania listów, co~pozwalało identyfikować jego nadawcę.].

#sym.dots

== Notacje reprezentacji informacji <sec:NotacjeReprezentacjiInformacji>

_Format dokumentu}_ jako ustalony standard zapisu informacji definiujący jego strukturę i~zawartość, jest jedną z~głównych cech rozróżniających dokumenty @techterms. Istnieje wiele przyczyn występowania różnych formatów. Najczęściej są to względy komercyjne, tj. wspieranie pewnych formatów przez~firmy informatyczne lub uzależnienie rodzaju zapisu danych od~określonego oprogramowania dostępnego na~rynku. Często w~wyborze formatu istotną rolę pełni jego łatwość użycia, siła wyrazu, uniwersalność, sposób kompresji oraz zrozumiałość dla~użytkowników. Formaty można, w~ogólności, podzielić na~otwarte, gdy opis standardu jest powszechnie dostępny oraz zamknięte, gdy szczegóły standardu znane są tylko producentowi.

_Typ dokumentu_ jest pojęciem niezwiązanym bezpośrednio z~technicznym opisem struktury dokumentu. Jest to pewna nazwa nadana konkretnym rodzajom dokumentów w~celu powiązania ich z~aplikacjami, które mogą je prawidłowo odczytać @techterms. Ze względu na~to, że istnieje bardzo wiele typów dokumentów, ich właściwa identyfikacja jest kluczowa w~przypadku konieczności przenoszenia dokumentów między różnymi urządzeniami. W~takiej sytuacji pomocne są ogólnodostępne repozytoria, które zapewniają jednolity opis typów dokumentów dla~wielu ich odbiorców.

=== Repozytorium typów dokumentów <sec:RepozytoriumTypowDokumentow>

Dominującym obecnie mechanizmem wymiany dokumentów różnych typów jest poczta elektroniczna. Dokument przesyłany jako wiadomość elektroniczna (email) może zawierać w~sobie dokumenty dowolnego typu w~postaci zarówno treści wiadomości jak i~załączników. Mimo że wiadomość elektroniczna jest przekształcana na~ciąg znaków możliwych do~przesłania przez~protokoły pocztowe @SMTP_RFC, agenty pocztowe są w~stanie odebrać i~odpowiednio odtworzyć zawartość wiadomości. Jest to możliwe dzięki standardowi MIME #ang[Multipurpose Internet Mail Extensions] @mime-format, powszechnie stosowanemu przy przesyłaniu poczty elektronicznej.

#sym.dots

=== Notacje dokumentów a~praca grupowa <sec:notacjaAPracaGrupowa>

Z jednej strony postać cyfrowa ułatwia przekazywanie dokumentów, z~drugiej różnorodność notacji ogranicza możliwości ich prawidłowego odczytu i~edycji.
Typy zawartości MIME wspierają pracę grupową opartą na~dokumencie i~pozwalają zidentyfikować typ niemal każdego dokumentu napisanego przez~człowieka, co~umożliwia jego przesyłanie z~wykorzystaniem protokołów poczty elektronicznej oraz powiązanie go z~odpowiednią aplikacją. Nie rozwiązuje to jednak dwóch problemów związanych z~przekazywaniem dokumentów. Oba dotyczą właściwego wyboru aplikacji do~odpowiedniego przetwarzania nietekstowych zawartości:

+ szczegóły odtworzenia otrzymanej zawartości opisanej znanym typem MIME mogą wymagać wcześniejszych uzgodnień z~nadawcą wiadomości,
+ niestandardowa zawartość wiadomości może wymagać od~odbiorcy komunikatu odnalezienia i~zainstalowania odpowiedniej aplikacji.
<mark:problemyZawartosci>

Sytuacja 1. zazwyczaj nie~ma miejsca, gdy praca nad~dokumentem odbywa się w~grupie, która posiada takie samo oprogramowanie do~edycji zawartości danego typu (tego samego producenta i~tej samej wersji). Jednak jest to sytuacja rzadka w~realiach organizacji wirtualnych, których członkowie znajdują się w~terytorialnym rozproszeniu, zmieniają swoje lokalizacje i~urządzenia, na~których pracują (wykonują, przykładowo, część pracy w~biurze a~część w~domu).

#sym.dots

=== Klasyfikacja typów dokumentów
<sec:KlasyfikacjaTypowDokumentow>

Typy dokumentów można sklasyfikować w~sposób przedstawiony na~rysunku @fig:docFormatsPL[]. Podział ten dotyczy możliwości przetwarzania zawartości dokumentów przez~urządzenia elektroniczne. Ogólnie, segreguje dokumenty począwszy od~zrozumiałych tylko przez~ludzi do~zrozumiałych jednocześnie przez~ludzi i~urządzenia elektroniczne#footnote[Zrozumiałość, w~tym przypadku, polega na~możliwości automatycznej analizy treści przez~program komputerowy.].

#figure(
  scale(
    88%,
    reflow: true,
  )[#image("../assets/images/doc-formats-pl.svg")],
  caption: [Klasyfikacja typów dokumentów],
)<fig:docFormatsPL>

==== Dokumenty analogowe i~cyfrowe <sec:DokumentyAnalogoweICyfrowe>

Dokumenty można podzielić ze~względu na~nośnik na~dwie główne grupy: analogowe i~cyfrowe. Jako _dokumenty analogowe_ określone zostały wszystkie dokumenty będące w~formie niezdygitalizowanej, czego przykładem są dokumenty papierowe (drukowane lub pisane odręcznie). Mogą to być także dowolne zasoby informacji, takie jak płyty winylowe, zielniki, albumy ze~zdjęciami itp. obiekty informacyjne. Wiele organizacji, np. sądowniczych, wymaga obecności dokumentów analogowych ze~względów formalnych, prawnych lub dlatego, że niosą one poza treścią dodatkowe informacje. Występuje również wiele historycznych dokumentów analogowych, istotnych dla~różnych organizacji. Stąd zasadność umieszczenia dokumentów analogowych w~klasyfikacji typów dokumentów.

Gdy dany dokument analogowy zostanie przetworzony na~zrozumiałą dla~urządzenia elektronicznego postać numeryczną, wówczas możemy mówić o~_dokumencie cyfrowym_. Są także dokumenty cyfrowe typu "born electronic", które powstały w~środowisku komputerowym od~razu jako cyfrowe i~nie mają swoich analogowych poprzedników.

Istnieje wiele formatów dokumentów cyfrowych, które mają różne możliwości i~zastosowania. Zasadniczo można podzielić je odnośnie reprezentacji na~dwie klasy: binarne i~tekstowe, gdzie te pierwsze są nieprzetworzonym zapisem dokumentu analogowego w~postaci zestawu próbek informacji, np. pikseli, zaś te drugie są pewnym zestawem rozpoznawalnych symboli, które mogą mieć różną złożoność i~strukturę.

==== Dokumenty binarne <sec:DokumentyBinarne>

Dokumenty binarne będące przeniesieniem dokumentów analogowych (papierowych) do~środowiska komputerowego są reprezentowane jako zestaw pikseli o~określonych cechach. Przykładowe formaty takiego zapisu to JPG, BMP czy TIFF.
Treść tego typu dokumentów jest w~praktyce trudna do~rozpoznania przez~komputer ze~względu na~obecność szumów obniżających jego czytelność.
Jednak taki dokument ma także zalety: może być przechowywany w~pamięci komputera i~przesyłany przez~sieć, a~po~wyrenderowaniu na~ekran lub wydruku na~papierze może być przez~człowieka traktowany jak oryginał. Nawet takie artefakty, jak plamy, zagniecenia czy tekstura papieru mogą nieść ważną informację dla~jego użytkownika.

Ogólnie, analiza treści dokumentów w~postaci binarnej wymaga wsparcia zewnętrznej aplikacji i~jest związana z~cyfrowym przetwarzaniem obrazów. Jest to problem złożony i~wciąż otwarty, rozwiązywany na~wiele sposobów metodami sztucznej inteligencji. Metody te są coraz bardziej skuteczne, jednakże nie~pozbawione błędów -- zwłaszcza w~przypadku tekstów odręcznych lub mocno zaszumionych @OCRReview@Handwritting:2011. Dużo lepiej wygląda natomiast kwestia wizualizacji dokumentów binarnych i~wiąże się po~prostu z~wyświetleniem pikseli. Oczywiście, pojawiają się tu problemy rozdzielczości, kompresji czy częstości próbkowania sygnału, ale są to kwestie obecnie dość dobrze rozwiązywane, ze~względu na~coraz lepsze możliwości sprzętu.

==== Dokumenty tekstowe <sec:DokumentyTekstowe>

Dokumenty tekstowe zawierają wyłącznie ciągi symboli rozpoznawalne bezpośrednio przez~komputer i~człowieka. Ich podział uzależniony jest od~możliwości przetwarzania zawartych w~nich informacji. Można wyróżnić dokumenty parsowalne i~nieparsowalne.

_Nieparsowalne_ dokumenty tekstowe zawierają strumień znaków wyrażony w~języku naturalnym, np. bezpośredni zapis rozmowy telefonicznej w~formie stenogramu lub tekstu. Taka zawartość dokumentu jest oznaczona przez~typ MIME: `text/plain`. Jedynym sposobem automatycznego wydobywania potrzebnych informacji z~takiego dokumentu jest użycie narzędzi do~przetwarzaniu języka naturalnego. Wizualizacja zaś przebiega na~zasadzie kopiowania i~wyświetlania strumienia tekstowego i~jest całkowicie zależna od~sposobu prezentowania go przez~odpowiedni program do~tego służący.

Grupą dokumentów znacznie łatwiej przetwarzanych przez~komputer są dokumenty _parsowalne_, zwane również _dokumentami elektronicznymi_. Są to dokumenty posiadające oprócz treści, także strukturę, która jest zrozumiała zarówno przez~człowieka jak i~przez komputer. W~celu zdefiniowania dokumentu elektronicznego można więc użyć następującej równości:

#align(center)[
  _dokument elektroniczny = struktura + zawartość._
]

Ze względu na~składnię, dokumenty elektroniczne można podzielić na: znakowane i~formalne. _Formalne_ dokumenty elektroniczne zawierają kod źródłowy programów komputerowych, a~ich gramatyka i~składnia są ściśle sprecyzowane. W~wiadomościach MIME są identyfikowane przez~odpowiednie podtypy, przykładowo `text/x-java` dla~parsowalnego formalnego kodu źródłowego w~języku Java. Wydobywanie treści odbywa się poprzez rozbiór dokumentu przez~odpowiednie analizatory składni (parsery) i~jest w~pełni skuteczne (np. narzędzie do~generowania dokumentacji Javadoc @JAVADOC). Dobrze zdefiniowana gramatyka określa jednoznacznie elementy składni: zmienne, deklaracje typów, instrukcje itp. Wyświetlanie dokumentów formalnych odbywa się również przez~analizę składni i~jest dokonywane przez~narzędzia służące do~prezentacji kodu źródłowego, np. edytory posiadające wsparcie dla~danego języka i~umożliwiające automatyczne formatowanie wydruku #ang[pretty printing].

Dokumenty _znakowane_ zawierają w~swojej treści fragmenty opisane odpowiednimi znacznikami. Znaczniki te organizują zawartość dokumentu, służąc jego prezentacji lub nadając mu strukturę logiczną. Gdy znaczniki wprowadzane są w~celu zarządzania wyglądem dokumentu, tak jak w~dokumentach HTML, wówczas ich wizualizacja jest bardzo prosta i~przebiega "w locie" (jest interpretowana w~trakcie czytania dokumentu przez~odpowiednią aplikację). Wydobywanie treści zaś odbywa się poprzez transformację -- jest trudniejsze i~mniej jednoznaczne niż w~przypadku dokumentów posiadających strukturę logiczną, jak np. XML. W~dokumentach ze~strukturą logiczną znaczniki wprowadzane są w~celu opisania zawartości, a~nie wyglądu dokumentu, toteż wydobywanie treści odbywa się poprzez wyszukanie odpowiednich znaczników, co~jest jednoznaczne i~natychmiastowe. Wizualizacja wymaga zaś transformacji dokumentu do~oczekiwanego formatu, np. w~XML żądany wygląd można uzyskać za~pomocą tzw. obiektów formatujących #ang[formatting object], np. XSL-FO @XSL-FO.

Zaprezentowana klasyfikacja typów dokumentów ukazuje różnorodność notacji informacji, a~co za~tym idzie złożoność problemu automatycznej analizy zawartości. Użytkownik w~swojej pracy spotyka się z~wieloma typami dokumentów, co~nierzadko sprawia mu problemy i~prowadzi do~przedłużania się pracy z~danym dokumentem. Zmienność istniejących formatów i~pojawianie się nowych rodzi problemy związane z~prawidłową identyfikacją i~przetwarzaniem zawartości. Dlatego rozwój dokumentów powinien iść w~kierunku ich kompatybilności oraz wsparcia użytkowników w~pracy grupowej z~różnorodną zawartością.

== Rozwój dokumentów elektronicznych <sec:RozwójDokumentówElektronicznych>

Powszechność wymienionych wcześniej problemów potencjalnej niekompatybilności znanej zawartości lub prawidłowego odtworzenia nieznanej zawartości nasuwa pytanie, czy jest możliwe stworzenie agenta zdolnego do~analizy treści dokumentu w~celu wsparcia użytkownika w~pracy nad~tym dokumentem. Rozwój dokumentów elektronicznych potwierdza potrzebę dostosowania ich struktury wewnętrznej do~analizy zawartości i~wspierania pracy grupowej.
Użytkownicy oczekują od~dokumentów już nie~tylko możliwości wygodnego przeglądania treści, ale też tego, by dokument zachowywał wszystkie zalety dokumentów w~formie papierowej oraz oferował dodatkowe funkcje, w~tym szczególnie wspierał pracę grupową, aktywnie zabezpieczał dostęp użytkowników do~określonych fragmentów dokumentu, personalizował sposób wykorzystania zawartości, np. poprzez wyświetlanie jej w~języku użytkownika, dawał możliwości nanoszenia przypisów, wprowadzania odsyłaczy, itd. Pojawiające się rozwiązania dają możliwość łączenia różnorodnych typów dokumentów w~ramach jednej struktury oraz zmieniają rolę dokumentów w~procesie ich przetwarzania ze~statycznej w~aktywną.

Rozwój dokumentów przyczynił się do~powstania dziedziny informatyki zwanej _inżynierią dokumentu_ #ang[document engineering] @doc_centric2@doc_centric.

#sym.dots

=== Warstwowe dokumenty wielopostaciowe <sec:WarstwoweDokumentyWielopostaciowe>
Jednym z~pomysłów pozwalających na~łączenie różnych typów zawartości w~ramach jednej struktury oraz zarządzania poszczególnymi częściami dokumentu jest model dokumentu warstwowego zaproponowany przez~Phelpsa i~Wilensky'ego w~@Phelps96@Phelps98_tech_rep i~stanowiący punkt wyjściowy dla~moich badań nad~rozwojem dokumentów elektronicznych @KKTI06_moja@TECHNICON06_moja. Pozwala on stworzyć jeden dokument składający się z~kilku warstw o~różnej zawartości. Warstwy, dzięki odpowiednim znacznikom, tworzą zazwyczaj strukturę drzewa -- można je dowolnie ukrywać i~uwidaczniać, czyniąc ich treść opcjonalną. Taka struktura umożliwia nanoszenie przypisów, podkreśleń czy adnotacji, podobnie jak w~dokumentach papierowych. Umieszczane są one w~innych warstwach niż oryginalny dokument bazowy, co~pozwala chronić jego treść a~także ustalać politykę dostępu do~naniesionych treści. Innym przykładem zastosowania warstw jest możliwość „nałożenia” tłumaczenia na~istniejący już dokument zamiast tworzyć nowy dokument w~innym języku. Warstwy umożliwiają również bardziej zaawansowane współdzielenie dokumentów. Użytkownicy mogą ustalać prawa dostępu do~poszczególnych części dokumentu, np. zabezpieczać je hasłem. Pozwalają także na~tworzenie dokumentów rozproszonych, którego poszczególne warstwy znajdują się na~różnych urządzeniach elektronicznych i~są wyświetlane jako całość przez~odpowiednio do~tego przystosowaną aplikację.

Format PDF #ang[Portable Document Format] jest pierwszym formatem dokumentów, w~którym warstwowość została wprowadzona jako obowiązujący standard i~jest rozwijana na~dużą skalę. Począwszy od~wersji PDF 1.5 @PDFRef został wprowadzony mechanizm opcjonalnej zawartości #ang[optional content] i~dotyczy sekcji zawartości dokumentu, która może być dowolnie uwidaczniana i~ukrywana przez~autora dokumentu lub jego użytkownika. Sprawiło to, iż warstwy dokumentu stały się jeszcze bardziej praktyczne, gdyż istnieje możliwość dowolnej ich prezentacji, zarządzania pojedynczymi warstwami, podwarstwami a~także grupami warstw. Opcjonalna zawartość pozwala na~tworzenie warstw treści, rysunków, a~także wielojęzycznych dokumentów. Zawartość warstw jest łączona w~grupy OCG #ang[optional content group], które są podstawową strukturą używaną do~sterowania widocznością składowych dokumentu. Reprezentują one pewne kolekcje elementów, które mogą być dynamicznie ukrywane bądź uwidaczniane przez~użytkownika. Elementy należące do~danej grupy mogą się znajdować w~różnych miejscach dokumentu i~należeć do~różnych strumieni zawartości. Grupie przypisywany jest stan ON (włączona) lub OFF (wyłączona). W~podstawowym przypadku zawartość należąca do~jednej grupy jest widoczna, gdy stan jest ON i~niewidoczna, gdy jest OFF, ale w~bardziej złożonych przypadkach zawartość może należeć do~kilku grup o~wykluczających się stanach. Wówczas można ustalić pewną taktykę widoczności, dla~zawartości należącej do~konkretnego zgrupowania danych. Przykładowo:

```
<</Type /OCMD                  %grupowanie danych w OCMD
/OCGs[12 0 R 13 0 R 14 0 R]    %słownik składa się z trzech grup
                               %opcjonalnej zawartości
/P /AllOn                      %stan P zostaje ustalony na AllOn, co
>>                             %oznacza, że zawartość jest widoczna,
                               %jeśli stany każdej z trzech grup są ON,
                               %w przeciwnym przypadku jest ukryta
```

Phelps i~Wilensky @Phelps96@Phelps98_tech_rep rozszerzają model warstwowy dodatkowo o~funkcjonalność, proponując model _dokumentu wielopostaciowego_ (MVD, ang._ multivalent document_). Dokument składa się z~rozproszonej zawartości i~dynamicznych programów, zwanych odpowiednio _warstwami_ #ang[layers] i~_zachowaniami_ #ang[behaviors]. Warstwy, jak opisano wyżej, dają możliwość włączenia różnych typów zawartości w~strukturę jednego dokumentu. Mogą być też dodawane później do~utworzonego już dokumentu. Warstwy odzwierciedlają semantykę zawartości, i~nie wynikają z~lokalizacji w~dokumencie -- można powiedzieć, są to _warstwy semantyczne_.

#sym.dots

=== Dokumenty aktywne <sec:DokumentyAktywne>

Dodanie funkcjonalności do~dokumentu zmienia jego rolę w~procesie przetwarzania z~pasywnej na~aktywną. Możliwość wykorzystania dowolnego języka programowania do~specyfikacji zachowań dokumentu, czyni jego funkcjonalność otwartą i~potencjalnie nieograniczoną. Stąd można zdefiniować _dokument aktywny_ jako dokument elektroniczny zawierający wbudowany w~niego zbiór usług, definiujący jego funkcjonalność @Ciancarini2002, zatem:

#align(center)[
  _dokument aktywny = struktura + zawartość + funkcjonalność_
]

Pierwsza koncepcja w~pełni aktywnych dokumentów elektronicznych zdolnych do~samodzielnego działania niezależnie od~aktualnej lokalizacji #ang[placeless documents] została zaproponowana przez~Dourish i~in. @Dourish2000@Dourish2003. Model ten wykorzystuje możliwość wbudowywania funkcjonalności w~dokument w~celu zarządzania jego zawartością. Głównym założeniem autorów było odejście od~standardowej hierarchicznej struktury i~ścisłej kategoryzacji dokumentów w~katalogach systemów operacyjnych, systemach mailowych czy na~stronach internetowych. Tradycyjnie bowiem umieszcza się dokument w~konkretnym katalogu znajdującym się w~pewnej statycznej hierarchii katalogów. Odszukanie takiego dokumentu może być utrudnione, zwłaszcza gdy zapisywany był zgodnie z~innym kryterium niż później odszukiwany lub jeśli ma być odszukany przez~inną osobę, która zupełnie tego kryterium nie~znała. Autorzy zauważyli, że katalogi plików nie~tylko zapewniają organizację dokumentów (grupowanie, lokalizację), ale także służą do~zarządzania nimi, np. tworzenia archiwów czy umożliwiania zdalnego dostępu. Aby skuteczniej zarządzać dokumentami zaproponowali więc odejście od~tradycyjnej hierarchii katalogów poprzez wprowadzenie własności #ang[properties] dokumentów, które pozwolą uniezależniać dokumenty od~ich lokalizacji i~dostosowywać je dynamicznie do~kontekstu użycia.

#sym.dots

=== Dokumenty jako agenty <sec:DokumentyAgentowe>
Własności "wykonawcze" dokumentów _Placeless documents_ są uruchamiane po~zainicjowaniu akcji na~dokumencie traktowanym jako obiekt. Takie dokumenty można nazwać _dokumentami reaktywnymi_ #ang[reactive documents], gdyż reagują samodzielnie na~każdą próbę dostępu do~nich. Alternatywą są _dokumenty proaktywne_ #ang[proactive documents], które posiadają pewną autonomię i~same potrafią się uaktywnić lub dostosować do~środowiska, w~którym się aktualnie znajdują -- mają cechy autonomicznego programu komputerowego zwanego agentem #ang[software agent]. Tą klasę dokumentów będę nazywać _dokumentami-agentami_ #ang[document agents], by podkreślić ich dwojaką naturę: klasycznie rozumianych dokumentów elektronicznych oraz agentów @Ciancarini2002.

W @Satoh2001 została przedstawiona koncepcja dokumentów w~postaci mobilnych agentów

#sym.dots
