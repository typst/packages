This template generates a monthly calendar, designed to be printed in landscape.

The calendar function accepts one parameter for the year, which should be formatted as an integer. 
Otherwise, the current year can be passed in with `datetime.today().year()`.

```typst
 #show: calendar.with(
  year: datetime.today().year()
)
```

There isn't much space for writing in each day box, it's more suited to blocking out days with a highlighter.
For example, to mark out free days in a variable schedule of work shifts.
