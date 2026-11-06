#import "../badgery.typ": ui-action, menu, badge-gray, badge-red, badge-yellow, badge-green, badge-blue, badge-purple



= Badgery

This package defines some colourful badges and boxes around text that represent user interface actions such as a click or following a menu.

== Badges

```typ
#badge-gray("Gray badge"),
#badge-red("Red badge"),
#badge-yellow("Yellow badge"),
#badge-green("Green badge"),
#badge-blue("Blue badge"),
#badge-purple("Purple badge")
```


#stack(
  dir: ttb,
  spacing: 5pt,
  badge-gray("Gray badge"),
  badge-red("Red badge"),
  badge-yellow("Yellow badge"),
  badge-green("Green badge"),
  badge-blue("Blue badge"),
  badge-purple("Purple badge")
)

== User interface actions

This is a user interface action (ie. a click):

```typ
#ui-action("Click X")
```

#ui-action("Click X")

This is an action to follow a user interface menu (2 steps):

```typ
#menu(("File", "New File..."))
```

#menu(("File", "New File..."))

This is a menu action with multiple steps:

```typ
#menu(("Menu", "Sub-menu", "Sub-sub menu", "Action"))
```

#menu(("Menu", "Sub-menu", "Sub-sub menu", "Action"))

