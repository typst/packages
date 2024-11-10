# Quick Minutes

With Quick Minutes you can record any meeting event by just typing it out. No function calls needed!

## Usage

### Import & Initialisation
```typ
#import "@preview/quick-minutes:1.2.0": *

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
|| present | List with names of people present at the meeting | `()` | list
|| chairperson | Name of the person chairing the meeting<br>Can be a `list` of people | `none` | `string`, `list(string)`
|| secretary | Name of the person taking minutes<br>Can be a `list` of people | `none` | `string`, `list(string)`
| optional |
||
|| awareness | Name of the person responsible for awareness<br>Can be a `list` of people | `none` | `string`, `list(string)`
|| translation | Name of the person responsible for translating<br>Can be a `list` of people | `none` | `string`, `list(string)`
|| cosigner | Position of the Person signing the protocol, should they differ from the chairperson | `none` | `string`
|| cosigner-name | Name of the person signing the protocol, should they differ from the chairperson | `none` | `string`
| customisation |
||
|| logo | Logo of the body holding the meeting | `none` | `image`
|| custom-header | Custom Header<br><br>Arguments:<br>(date, body-name, event-name, translate)<br><br>Set to `none` for empty header | `auto` | `function(content, content, content, function(string, ..string))`, `auto`
|| custom-footer | Custom Footer<br><br>Arguments:<br>(current-page, page-count, translate)<br><br>Set to `none` for empty footer<br><br>Is called inside of `context` | `auto` | `function(int, int, function(string, ..string))`, `auto`
|| custom-background | Custom Background<br><br>Arguments:<br>(hole-mark)<br><br>Set to `none` for empty background | `auto` | `function(bool)`, `auto`
|| custom-head-section | Custom Head Section<br><br>Arguments:<br>(chairperson, secretary, awareness, translation, present, present-count, start-time, end-time, translate, four-digits-to-time)<br><br>Set to `none` for empty head section<br><br>Handle start-time & end-time like this:<br><pre>let start-time = start-time.final()<br>if (start-time != none) [\*#translate("START")\*: #four-digits-to-time(start-time)\ ] | `auto` | `function(content, content, content/none, content/none, content, int/none, state, state, function(string, ..string), function(string))`, `auto`
|| custom-name-format | Formatting of names in the document | <pre>(first-name, last-name, numbered) => [<br>&nbsp;#if (numbered) [#first-name #last-name] else [<br>&nbsp;&nbsp;#if (last-name != none) [#last-name, ]#first-name]<br>]</pre> | `function(string)`
|| custom-name-style | Style of names in the document | <pre>(name) => [name] | `function(string)`
|| item-numbering | Numbering of items. Reverts to `DEFAULT_ITEM_NUMBERING` if `none`.  | `none` | `function(..int)`
|| time-format | Datetime format `string` for times taken. Reverts to `DEFAULT_TIME_FORMAT` if `none`. | `none` | `string`
|| date-format | Datetime format `string` for the date of the event. Reverts to `DEFAULT_DATE_FORMAT` if `none`.| `none` | `string`
|| timestamp-margin | Size of gutter between timestamps and text | `10pt` | `length`<br>(static (pt, cm ...) recommended)
|| line-numbering | `none` for no line numbering, `int` for every xth line numbered | `5` | `int`
|| fancy-decisions | Draws a diagram underneath decisions | `false` | `bool`
|| fancy-dialogue | Splits dialogue up into paragraphs | `false` | `bool`
|| hole-mark | Draws a mark for the alignment of a hole punch | `true` | `bool`
|| separator-lines | Draws lines next to the titles | `true` | `bool`
|| signing | Do people have to sign this document? | `true` | `bool`
|| title-page | Should the actual protocol start after a `pagebreak`? | `false` | `bool`
|| number-present | Should the number of people present be shown? | `false` | `bool`
|| show-arrival-time | Should the time of arrival be schown in the list of people present? | `true` | `bool`
|| locale | language of the document | `"en"`| `string`
|| translation-overrides | [Translation](lang.json) Overrides | `(:)` | dictionary
|| custom-royalty-connectors | Additional `list` of surname beginnings like "von".<br>Already recognises "von", "von der" & "de" | `()` | `list`
| debug | 
||
|| display-all-warnings | Shows all warnings directly beneath their occurence | `false` | `bool`
|| hide-warnings | Hides all warnings | `false` | `bool`
|| warning-color | Color warnings are displayed in | `red` | `color`
|| enable-help-text | Should a help/debug text with state info be shown? | `false` | `bool`

### Commands

| name | format | description |
|---|---|---|
Join | <pre>+(\<time>/)?\<name><br>++(\<time>/)?\<name> | Marks the arrival of someone<br>+: Come back from pause etc.<br>++: Arrive at event<br><br>_Time is optional_
Leave | <pre>-(\<time>/)?\<name><br>--(\<time>/)?\<name> | Marks the departure of someone.<br>-: Leave into pause etc.<br>--: Leave event<br><br>_Time is optional_
Time | <pre>\<time>/\<text> | Time the following text
Mark Name | <pre>/\<name> | Marks following name
Vote | <pre>!(\<time>/)?\<text>/\<vote>/\<vote>... | Vote on something (described in text)<br><br>/\<vote> can be repeated as many times as needed (min. 2)<br>3 unnamed & uncolored votes will result in a "For" (green), "Against" (red), "Abstain" (blue) vote<br><br>If you want to use `/` inside of a label or the text, you can use `-/` to escape into a normal `/`<br><br>_Time is optional_
Dialogue | <pre>\<name>: \<text> | Marks that someone is speaking<br><br>Can be escaped with a `-` (`<name>-:`) to avoid restructuring
End | <pre>/\<time> | End of the meeting.<br><br>Replace \<time> with `"end"` if you dont want to set a time |

### Formats

| name | format | example |
|---|---|---|
\<vote> | <pre>\<label>(\|\<color>)?\<count> | `First Party\|green42`<br>`Third choice22`
\<time> | 1-4 numbers | `1312` -> 01:12 pm<br>`650` -> 06:50 pm<br>`21`-> last timed hour:21 (pm/am)<br>`4`-> last timed hour:04 (pm/am)
\<name> | Name in various formats | `Last Name, First Name`<br>`First Name Last Name`<br>`First Name`<br>`Last Name`<br>`First Name L`<br>`F Last Name`<br>`FL`<br><br>Last name can also start with a royalty connector like "de" or "von"<br><br>`Name 1`,`Name 2` will render with the number after the name, but the number is handled as a last name.<br><br>If you just want your name formatted by `custom-name-style` you can escape the restructuring process with a `-` (`/-<name>`).