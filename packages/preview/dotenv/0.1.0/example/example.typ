#import "../dotenv.typ": *

#let env = env_load("/.env")

#let env_example = env_load("/example/.env.example")

```typ
#import "@preview/dotenv.typ": env_load

#let env = env_load("/.env")

#let env_example = env_load("/example/.env.example")
```

Load the environment variable `FOO_IN_ROOT` from the `.env` file in the root of the project: #env.FOO_IN_ROOT

Below is the content of the `/.env` file:

```ini
# /.env

# This is a comment
FOO_IN_ROOT= bar # this is also a comment
```

It will be loaded as:

#env

Load the environment variable `FOO_IN_EXAMPLE` from the `.env.example` file of the project: #env_example.FOO_IN_EXAMPLE

Below is the content of the `.env.example` file:

```ini
# .env.example

# This is a comment
FOO_IN_EXAMPLE=baz # this is also a comment
```

It will be loaded as:

#env_example
