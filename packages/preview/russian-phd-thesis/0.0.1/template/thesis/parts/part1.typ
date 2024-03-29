#import "../template.typ": *
#part_count.step() // Обновление счетчика разделов 
= Оформление различных элементов <ch1>

== Форматирование текста <ch1:sec1>

Тип и размер шрифта задан в файле `common\style.typ`
Мы можем сделать *жирный текст* и _курсив_. 

== Ссылки <ch1:sec2>
Сошлёмся на библиографию. Одна ссылка: @Sokolov[с.~54];@Gaidaenko[с.~36];.
Две ссылки: @Sokolov @Gaidaenko. Ссылка на собственные работы:
@vakbib1 @confbib2. Много ссылок:
@Lermontov @Management @Borozda @Marketing @Constitution @FamilyCode @Gost.7.0.53 @Razumovski @Lagkueva @Pokrovski @Methodology @Berestova @Kriger
. И~ещё немного
ссылок:~@Article @Book @Booklet @Conference @Inbook @Incollection @Manual @Mastersthesis @Misc @Phdthesis @Proceedings @Techreport @Unpublished
 @medvedev2006jelektronnye @CEAT:CEAT581#cite(label("doi:10.1080/01932691.2010.513279")); @Gosele1999161 @Li2007StressAnalysis @Shoji199895 @test:eisner-sample @test:eisner-sample-shorted @AB_patent_Pomerantz_1968 @iofis_patent1960
.

Сошлёмся на разделы: @ch1, @ch2:sec1, @ch1:sec2.

Сошлёмся на приложения: @app:A, @app:B.

Сошлёмся на формулу: @eq:equation1.

Сошлёмся на изображение: @fig:typst. 

Сошлемся на определение при помощи пакета *Glossarium*: @typst. Подробнее про пакет *Glossarium* можно почитать здесь https://github.com/ENIB-Community/glossarium. Все определения задаются в файле `common\glossary.typ`. 

Также можно вставлять сокращения @si, @ацп и ссылки на символы: @pi. 

А также ссылку на символы в уравнении: 

$ #gls("pi") $

И при повторном использовании: @si, @ацп. 

== Формулы <ch1:sec3>

=== Нумерованные одиночные формулы <ch1:sec3:sub1>

Вот так может выглядеть формула, которую необходимо вставить в~строку по~тексту: $x approx sin x$ при $x -> 0$.

А вот так выглядит нумерованная отдельностоящая формула c подстрочными и надстрочными индексами:

$ (x_1+x_2)^2 = x_1^2 + 2 x_1 x_2 + x_2^2 $ <eq:equation1>

Формула с неопределенным интегралом:

$ integral f(alpha+x)= sum beta $

Подробнее можно прочитать здесь: https://typst.app/docs/reference/math/equation 