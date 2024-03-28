# Development Notes

If you add some content below a level 1 heading, 
then using

```
set page(
    header: locate(
      loc => {
        // Search for previous chapters starting from the current location
        let previous-chapter-elements = query(selector(heading.where(level: 1)).before(loc), loc)

        // ...
      }
    )
)
```

to find previous chapters before the current location will not include the current chapter, which is usually what you want.

However, if you have nothing below a level 1 heading, for example:

```
= My Chapter

= Another Chapter

#lorem(100)
```

then when searching for previous chapters at the page where "My Chapter" starts will include "My Chapter" itself.

