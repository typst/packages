# October

This template generates a monthly calendar, designed to be printed in landscape.

## Usage

The calendar function accepts one parameter for the year, which should be formatted as an integer.

```typst
#show: calendar.with(
  year: 2025
)
```

Otherwise, the current year can be passed in with `datetime.today().year()`.

```typst
#show: calendar.with(
  year: datetime.today().year()
)
```

When printed on A4 paper there isn't much space for writing in each day box, the calendar is more suited to blocking out days with a highlighter.
For example, to mark days of rest in a variable pattern of work shifts.

## License

[MIT No Attribution](https://github.com/extua/october/blob/main/LICENSE) © Pierre Marshall.

