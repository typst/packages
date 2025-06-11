# dotenv-typ

dotenv-typ is a zero-dependency module that loads environment variables from a `.env` file. It uses implementation and passes tests obtained from [dotenv.](https://github.com/motdotla/dotenv)

## Examples

```typ
#import "@preview/dotenv:0.1.0": parse-env
#assert.eq(parse-env(read("/.env")), ("KEY": "VALUE"))
```

## License

This project is licensed under the Apache License 2.0.
