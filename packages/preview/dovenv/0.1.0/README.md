# dovenv

dovenv (dove-env) is a zero-dependency module that smoothly loads environment variables from a `.env` file. It uses implementation and passes tests obtained from [dotenv.](https://github.com/motdotla/dotenv)

## Examples

```typ
#import "@preview/dovenv:0.1.0": parse-env

// From single files
#assert.eq(parse-env(read(".env")), ("KEY": "VALUE"))

// From multiple files
#assert.eq(
  (".env", ".env.local").map(it => parse-env(read(it))).sum(),
  (KEY: "VALUE2", MORE_KEY: "VALUE3"),
)

```

## License

This project is licensed under the Apache License 2.0.
