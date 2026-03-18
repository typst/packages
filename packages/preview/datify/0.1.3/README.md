# Datify

Datify is a simple date package that allows users to format dates in new ways and addresses the issue of lacking date formats in different languages.

## Installation

To include this package in your Typst project, add the following to your project file:

```typst
#import "@preview/datify:0.1.3": day-name, month-name, custom-date-format
```

## Reference

### `day-name`

Returns the name of the weekday.

#### Example

```typst
#import "@preview/datify:0.1.3": day-name

#day-name(2)
#day-name(1,"fr",true)
```

Output:

```
tuesday
Lundi
```

#### Parameters

```typst
day-name(weekday: int or str, lang: str, upper: boolean) --> str
```

| Parameter | Description                                            | Default |
|-----------|--------------------------------------------------------|---------|
| weekday*  | The weekday as an integer (1-7) or a string ("1"-"7"). | none    |
| lang      | An ISO 639-1 code representing the language.           | en      |
| upper     | A boolean that sets the first letter to be uppercase.  | false   |

\* required

### `month-name`

Returns the name of the month.

#### Example

```typst
#import "@preview/datify:0.1.3": month-name

#month-name(2)
#month-name(1, "fr", true)
```

Output:

```
february
Janvier
```

#### Parameters

```typst
month-name(month: int or str, lang: str = 'en', upper: bool = false) -> str
```

| Parameter | Description                                            | Default |
|-----------|--------------------------------------------------------|---------|
| month*    | The month as an integer (1-12) or a string ("1"-"12"). | none    |
| lang      | An ISO 639-1 code representing the language.           | en      |
| upper     | A boolean that sets the first letter to be uppercase.  | false   |

\* required

### `custom-date-format`

Formats a given date according to a specified format and language.

#### Example

```typst
#import "@preview/datify:0.1.3": custom-date-format

#let my-date = datetime(year: 2024, month: 8, day: 4)
#custom-date-format(my-date, "MMMM DDth, YYYY")
```

Output:

```
August 04th, 2024
```

#### Parameters

```typst
custom-date-format(date: datetime, format: str, lang: str = 'en') -> str
```

| Parameter | Description                                    | Default |
|-----------|------------------------------------------------|---------|
| date*     | A datetime object representing the date.       | none    |
| format*   | A string representing the desired date format. | none    |
| lang      | An ISO 639-1 code representing the language.   | en      |

\* required

#### Format Types

Below is a table of all possible format types that can be used in the format string:

| Format | Description                            | Example       |
|--------|----------------------------------------|---------------|
| `DD`   | Day of the month, 2 digits             | 05            |
| `day`  | Full name of the day                   | tuesday       |
| `Day`  | Capitalized full name of the day       | Tuesday       |
| `DAY`  | Uppercase full name of the day         | TUESDAY       |
| `MMMM` | Capitalized full name of the month     | May           |
| `MMM`  | Short name of the month (first 3 chars)| May           |
| `MM`   | Month number, 2 digits                 | 05            |
| `month`| Full name of the month                 | may           |
| `Month`| Capitalized full name of the month     | May           |
| `MONTH`| Uppercase full name of the month       | MAY           |
| `YYYY` | 4-digit year                           | 2023          |
| `YY`   | Last 2 digits of the year              | 23            |


## Examples

Here are some examples demonstrating the usage of the functions provided by the Datify package:

```typst
#let my-date = datetime(year: 2024, month: 12, day: 25)

#custom-date-format(my-date, "DD-MM-YYYY")  // Output: 25-12-2024
#custom-date-format(my-date, "Day, DD Month YYYY", "fr")  // Output: Mercredi, 25 Décembre 2024
#custom-date-format(my-date, "day, DD de month de YYYY", "es") // Output: miércoles, 25 de diciembre de 2024
#custom-date-format(my-date, "day, DD de month de YYYY", "pt") // Output: terça-feira, 25 de dezembro de 2024

#day-name(4)  // Output: thursday

#month-name(12)  // Output: december
```

## Supported language

| ISO 639-1 code | Status       |
|----------------|--------------|
| aa             | ❌           |
| ab             | ❌           |
| ae             | ❌           |
| af             | ❌           |
| ak             | ❌           |
| am             | ❌           |
| an             | ❌           |
| ar             | ❌           |
| as             | ❌           |
| av             | ❌           |
| ay             | ❌           |
| az             | ❌           |
| ba             | ❌           |
| be             | ❌           |
| bg             | ❌           |
| bh             | ❌           |
| bi             | ❌           |
| bm             | ❌           |
| bn             | ❌           |
| bo             | ❌           |
| br             | ❌           |
| bs             | ❌           |
| ca             | ❌           |
| ce             | ❌           |
| ch             | ❌           |
| co             | ❌           |
| cr             | ❌           |
| cs             | ❌           |
| cu             | ❌           |
| cv             | ❌           |
| cy             | ❌           |
| da             | ❌           |
| de             | ✅           |
| dv             | ❌           |
| dz             | ❌           |
| ee             | ❌           |
| el             | ❌           |
| en             | ✅           |
| eo             | ❌           |
| es             | ✅           |
| et             | ❌           |
| eu             | ❌           |
| fa             | ❌           |
| ff             | ❌           |
| fi             | ❌           |
| fj             | ❌           |
| fo             | ❌           |
| fr             | ✅           |
| fy             | ❌           |
| ga             | ❌           |
| gd             | ❌           |
| gl             | ❌           |
| gn             | ❌           |
| gu             | ❌           |
| gv             | ❌           |
| ha             | ❌           |
| he             | ❌           |
| hi             | ❌           |
| ho             | ❌           |
| hr             | ❌           |
| ht             | ❌           |
| hu             | ❌           |
| hy             | ❌           |
| hz             | ❌           |
| ia             | ❌           |
| id             | ❌           |
| ie             | ❌           |
| ig             | ❌           |
| ii             | ❌           |
| ik             | ❌           |
| io             | ❌           |
| is             | ❌           |
| it             | ❌           |
| iu             | ❌           |
| ja             | ❌           |
| jv             | ❌           |
| ka             | ❌           |
| kg             | ❌           |
| ki             | ❌           |
| kj             | ❌           |
| kk             | ❌           |
| kl             | ❌           |
| km             | ❌           |
| kn             | ❌           |
| ko             | ❌           |
| kr             | ❌           |
| ks             | ❌           |
| ku             | ❌           |
| kv             | ❌           |
| kw             | ❌           |
| ky             | ❌           |
| la             | ❌           |
| lb             | ❌           |
| lg             | ❌           |
| li             | ❌           |
| ln             | ❌           |
| lo             | ❌           |
| lt             | ❌           |
| lu             | ❌           |
| lv             | ❌           |
| mg             | ❌           |
| mh             | ❌           |
| mi             | ❌           |
| mk             | ❌           |
| ml             | ❌           |
| mn             | ❌           |
| mr             | ❌           |
| ms             | ❌           |
| mt             | ❌           |
| my             | ❌           |
| na             | ❌           |
| nb             | ❌           |
| nd             | ❌           |
| ne             | ❌           |
| ng             | ❌           |
| nl             | ❌           |
| nn             | ❌           |
| no             | ❌           |
| nr             | ❌           |
| nv             | ❌           |
| ny             | ❌           |
| oc             | ❌           |
| oj             | ❌           |
| om             | ❌           |
| or             | ❌           |
| os             | ❌           |
| pa             | ❌           |
| pi             | ❌           |
| pl             | ❌           |
| ps             | ❌           |
| pt             | ✅           |
| qu             | ❌           |
| rm             | ❌           |
| rn             | ❌           |
| ro             | ❌           |
| ru             | ❌           |
| rw             | ❌           |
| sa             | ❌           |
| sc             | ❌           |
| sd             | ❌           |
| se             | ❌           |
| sg             | ❌           |
| si             | ❌           |
| sk             | ❌           |
| sl             | ❌           |
| sm             | ❌           |
| sn             | ❌           |
| so             | ❌           |
| sq             | ❌           |
| sr             | ❌           |
| ss             | ❌           |
| st             | ❌           |
| su             | ❌           |
| sv             | ❌           |
| sw             | ❌           |
| ta             | ❌           |
| te             | ❌           |
| tg             | ❌           |
| th             | ❌           |
| ti             | ❌           |
| tk             | ❌           |
| tl             | ❌           |
| tn             | ❌           |
| to             | ❌           |
| tr             | ❌           |
| ts             | ❌           |
| tt             | ❌           |
| tw             | ❌           |
| ty             | ❌           |
| ug             | ❌           |
| uk             | ❌           |
| ur             | ❌           |
| uz             | ❌           |
| ve             | ❌           |
| vi             | ❌           |
| vo             | ❌           |
| wa             | ❌           |
| wo             | ❌           |
| xh             | ❌           |
| yi             | ❌           |
| yo             | ❌           |
| za             | ❌           |
| zh             | ❌           |
| zu             | ❌           |

## Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue if you encounter any problems.

## License

This project is licensed under the MIT License.

## Planned
- Adding support for more language
- Adding set and get method to set default language for a whole document
- Adding new methods
