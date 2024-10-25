# Quick Minutes

With Quick Minutes you can record any event by just typing events out. No function calls needed!

## Usage

### Import & Initialisation
```
#import "@preview/quick-minutes:1.0.0": *

#show: minutes.with(
  chairperson: "Name 1",
  secretary: "Name 2",
  date: auto,
  body-name: "Organisation",
  event-name: "Event",
  present: (
    "Name 1",
    "Name 2",
    "Name 3",
    "Name 4",
  )
)

...

```

[Commands](#commands)\
[Formats](#formats)

### Parameters

| | name | explaination | default | type |
|---|---|---|---|---|
| required |
||
|| body-name | Name of the body holding the recorded meeting | `none` | `string`
|| event-name | Name of the meeting | `none` | `string`
|| date | Date of the meeting (`auto` for current date, datetime for formatted date) | `none` | `string, auto, datetime`
|| present | list with names of people present at the meeting | `()` | list
|| chairperson | Name of the person chairing the meeting | `none` | `string`
|| secretary | Name of the person taking minutes | `none` | `string`
| optional |
|| awareness | Name of the person responsible for awareness | `none` | `string`
|| translation | Name of the person responsible for translating | `none` | `string`
|| cosigner | Position of the Person signing the protocoll, should they differ from the chairperson. Aditionally to the secretary. | `none` | `string`
|| cosigner-name | Name of the person signing the protocoll, should they differ from the chairperson. Aditionally to the secretary. | `none` | `string`
| customization |
|| custom-name-format | Format of names in the document | `(name) => [#name]` | `function(string)`
|| item-numbering | Numbering of items. Reverts to `DEFAULT_ITEM_NUMBERING` if `none`.  | `none` | `funtion(..int)`
|| time-format | Datetime format `string` for times taken. Reverts to `DEFAULT_TIME_FORMAT` if `none`. | `none` | `string`
|| date-format | Datetime format `string` for the date of the event. Reverts to `DEFAULT_DATE_FORMAT` if `none`.| `none` | `string`
|| timestamp-margin | Size of gutter between timestamps and text | `10pt` | `length` (pt or cm recommended)
|| line-numbering | `none` for no line numbering, number for every xth line numbered | `5` | `int`
|| fancy-decisions | Draws a diagram underneath decisions | `false` | `bool`
|| fancy-dialogue | Splits dialogue up into paragraphs | `false` | `bool`
|| hole-mark | Mark for the alignment of a hole punch | `true` | `bool`
|| separator-lines | Lines next to the titles | `true` | `bool`
|| signing | Do people have to sign this document | `true` | `bool`
|| title-page | Should the actual protocol start after a `pagebreak` | `false` | `bool`
|| number-present | Should the number of people present be shown | `false` | `bool`
|| show-arrival-time | Should the time of arrival be schown in the list of people present | `true` | `bool`
|| locale | language of the document | `"en"`| `string`
|| translation-overrides | [Translation](lang.json) Overrides | `(:)` | dictionary
|| custom-royalty-connectors | Custom list of surname beginnings like "von" | `()` | `list`
| debug | 
|| display-all-warnings | Shows all warnings directly beneath their occurence | `false` | `bool`
|| hide-warnings | Hide all warnings | `false` | `bool`
|| warning-color | Color warnings are displayed in | `red` | `color`
|| enable-help-text | Should a help/debug text with state info be shown | `false` | `bool`

### Commands

| name | format | description |
|---|---|---|
Join | +\<time>/\<name><br>++\<time>/\<name> | Marks the arrival of someone<br>+: Come back from pause etc.<br>++: Arrive at event.
Leave | -\<time>/\<name><br>--\<time>/\<name> | Marks the departure of someone.<br>-: Leave into pause etc.<br>--: Leave event.
Time | \<time>/\<text> | Time the following text
Mark Name | /\<name> | Marks following name
Vote | !\<time>/\<text>/\<vote>/\<vote>... | Vote on something (described in text).<br><br>/\<vote> can be repeated as many times as needed (min. 2)<br>3 unnamed & uncolored votes will result in a "For" (green), "Against" (red), "Abstain" (blue) vote

### Formats

| name | format | example |
|---|---|---|
\<vote> | \<label>\|(\<color>)?\<count> | `First Party\|green42`<br>`Third choice\|red22`
\<time> | 1-4 numbers (can contain ":" and " ") | `1312` -> 01:12 pm<br>`650` -> 06:50 pm<br>`21`-> last timed hour:21 (pm/am)<br>`4`-> last timed hour:04 (pm/am)
\<name> | Name in varios formats | `Last Name, First Name`<br>`First Name Last Name`<br>`First Name`<br>`Last Name`<br>`First Name L`<br>`F Last Name`<br>`FL`<br><br>Last name can also start with a royalty connector like "de" or "von"<br><br>`Name 1`,`Name 2` will render with the number after the name but the number is handled as a last name.