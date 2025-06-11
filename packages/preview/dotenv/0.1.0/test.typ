
#import "lib.typ": parse-env as _parse-env

#let parse-env(body) = if type(body) == content {
  _parse-env(body.text)
} else {
  _parse-env(body)
}

#let it = parse-env(```env
BASIC=basic

# previous line intentionally left blank
AFTER_LINE=after_line
EMPTY=
EMPTY_SINGLE_QUOTES=''
EMPTY_DOUBLE_QUOTES=""
EMPTY_BACKTICKS=``
SINGLE_QUOTES='single_quotes'
SINGLE_QUOTES_SPACED='    single quotes    '
DOUBLE_QUOTES="double_quotes"
DOUBLE_QUOTES_SPACED="    double quotes    "
DOUBLE_QUOTES_INSIDE_SINGLE='double "quotes" work inside single quotes'
DOUBLE_QUOTES_WITH_NO_SPACE_BRACKET="{ port: $MONGOLAB_PORT}"
SINGLE_QUOTES_INSIDE_DOUBLE="single 'quotes' work inside double quotes"
BACKTICKS_INSIDE_SINGLE='`backticks` work inside single quotes'
BACKTICKS_INSIDE_DOUBLE="`backticks` work inside double quotes"
BACKTICKS=`backticks`
BACKTICKS_SPACED=`    backticks    `
DOUBLE_QUOTES_INSIDE_BACKTICKS=`double "quotes" work inside backticks`
SINGLE_QUOTES_INSIDE_BACKTICKS=`single 'quotes' work inside backticks`
DOUBLE_AND_SINGLE_QUOTES_INSIDE_BACKTICKS=`double "quotes" and single 'quotes' work inside backticks`
EXPAND_NEWLINES="expand\nnew\nlines"
DONT_EXPAND_UNQUOTED=dontexpand\nnewlines
DONT_EXPAND_SQUOTED='dontexpand\nnewlines'
# COMMENTS=work
INLINE_COMMENTS=inline comments # work #very #well
INLINE_COMMENTS_SINGLE_QUOTES='inline comments outside of #singlequotes' # work
INLINE_COMMENTS_DOUBLE_QUOTES="inline comments outside of #doublequotes" # work
INLINE_COMMENTS_BACKTICKS=`inline comments outside of #backticks` # work
INLINE_COMMENTS_SPACE=inline comments start with a#number sign. no space required.
EQUAL_SIGNS=equals==
RETAIN_INNER_QUOTES={"foo": "bar"}
RETAIN_INNER_QUOTES_AS_STRING='{"foo": "bar"}'
RETAIN_INNER_QUOTES_AS_BACKTICKS=`{"foo": "bar's"}`
TRIM_SPACE_FROM_UNQUOTED=    some spaced out string
USERNAME=therealnerdybeast@example.tld
    SPACED_KEY = parsed```)

#assert.eq(
  it,
  (
    BASIC: "basic",
    AFTER_LINE: "after_line",
    EMPTY: "",
    EMPTY_SINGLE_QUOTES: "",
    EMPTY_DOUBLE_QUOTES: "",
    EMPTY_BACKTICKS: "",
    SINGLE_QUOTES: "single_quotes",
    SINGLE_QUOTES_SPACED: "    single quotes    ",
    DOUBLE_QUOTES: "double_quotes",
    DOUBLE_QUOTES_SPACED: "    double quotes    ",
    DOUBLE_QUOTES_INSIDE_SINGLE: "double \"quotes\" work inside single quotes",
    DOUBLE_QUOTES_WITH_NO_SPACE_BRACKET: "{ port: $MONGOLAB_PORT}",
    SINGLE_QUOTES_INSIDE_DOUBLE: "single 'quotes' work inside double quotes",
    BACKTICKS_INSIDE_SINGLE: "`backticks` work inside single quotes",
    BACKTICKS_INSIDE_DOUBLE: "`backticks` work inside double quotes",
    BACKTICKS: "backticks",
    BACKTICKS_SPACED: "    backticks    ",
    DOUBLE_QUOTES_INSIDE_BACKTICKS: "double \"quotes\" work inside backticks",
    SINGLE_QUOTES_INSIDE_BACKTICKS: "single 'quotes' work inside backticks",
    DOUBLE_AND_SINGLE_QUOTES_INSIDE_BACKTICKS: "double \"quotes\" and single 'quotes' work inside backticks",
    EXPAND_NEWLINES: "expand\nnew\nlines",
    DONT_EXPAND_UNQUOTED: "dontexpand\\nnewlines",
    DONT_EXPAND_SQUOTED: "dontexpand\\nnewlines",
    INLINE_COMMENTS: "inline comments",
    INLINE_COMMENTS_SINGLE_QUOTES: "inline comments outside of #singlequotes",
    INLINE_COMMENTS_DOUBLE_QUOTES: "inline comments outside of #doublequotes",
    INLINE_COMMENTS_BACKTICKS: "inline comments outside of #backticks",
    INLINE_COMMENTS_SPACE: "inline comments start with a",
    EQUAL_SIGNS: "equals==",
    RETAIN_INNER_QUOTES: "{\"foo\": \"bar\"}",
    RETAIN_INNER_QUOTES_AS_STRING: "{\"foo\": \"bar\"}",
    RETAIN_INNER_QUOTES_AS_BACKTICKS: "{\"foo\": \"bar's\"}",
    TRIM_SPACE_FROM_UNQUOTED: "some spaced out string",
    USERNAME: "therealnerdybeast@example.tld",
    SPACED_KEY: "parsed",
  ),
)

#assert(it.at("COMMENTS", default: none) == none, message: "ignores commented lines")

#let expected-payload = (
  SERVER: "localhost",
  PASSWORD: "password",
  DB: "tests",
)

#assert.eq(
  parse-env("SERVER=localhost\rPASSWORD=password\rDB=tests\r"),
  expected-payload,
  message: "can parse (\\r) line endings",
)
#assert.eq(
  parse-env("SERVER=localhost\nPASSWORD=password\nDB=tests\n"),
  expected-payload,
  message: "can parse (\\n) line endings",
)
#assert.eq(
  parse-env("SERVER=localhost\r\nPASSWORD=password\r\nDB=tests\r\n"),
  expected-payload,
  message: "can parse (\\r\\n) line endings",
)


#let it = parse-env(```env
BASIC=basic

# previous line intentionally left blank
AFTER_LINE=after_line
EMPTY=
SINGLE_QUOTES='single_quotes'
SINGLE_QUOTES_SPACED='    single quotes    '
DOUBLE_QUOTES="double_quotes"
DOUBLE_QUOTES_SPACED="    double quotes    "
EXPAND_NEWLINES="expand\nnew\nlines"
DONT_EXPAND_UNQUOTED=dontexpand\nnewlines
DONT_EXPAND_SQUOTED='dontexpand\nnewlines'
# COMMENTS=work
EQUAL_SIGNS=equals==
RETAIN_INNER_QUOTES={"foo": "bar"}

RETAIN_INNER_QUOTES_AS_STRING='{"foo": "bar"}'
TRIM_SPACE_FROM_UNQUOTED=    some spaced out string
USERNAME=therealnerdybeast@example.tld
    SPACED_KEY = parsed

MULTI_DOUBLE_QUOTED="THIS
IS
A
MULTILINE
STRING"

MULTI_SINGLE_QUOTED='THIS
IS
A
MULTILINE
STRING'

MULTI_BACKTICKED=`THIS
IS
A
"MULTILINE'S"
STRING`

MULTI_PEM_DOUBLE_QUOTED="-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnNl1tL3QjKp3DZWM0T3u
LgGJQwu9WqyzHKZ6WIA5T+7zPjO1L8l3S8k8YzBrfH4mqWOD1GBI8Yjq2L1ac3Y/
bTdfHN8CmQr2iDJC0C6zY8YV93oZB3x0zC/LPbRYpF8f6OqX1lZj5vo2zJZy4fI/
kKcI5jHYc8VJq+KCuRZrvn+3V+KuL9tF9v8ZgjF2PZbU+LsCy5Yqg1M8f5Jp5f6V
u4QuUoobAgMBAAE=
-----END PUBLIC KEY-----"```)

#assert.eq(
  it,
  (
    BASIC: "basic",
    AFTER_LINE: "after_line",
    EMPTY: "",
    SINGLE_QUOTES: "single_quotes",
    SINGLE_QUOTES_SPACED: "    single quotes    ",
    DOUBLE_QUOTES: "double_quotes",
    DOUBLE_QUOTES_SPACED: "    double quotes    ",
    EXPAND_NEWLINES: "expand\nnew\nlines",
    DONT_EXPAND_UNQUOTED: "dontexpand\\nnewlines",
    DONT_EXPAND_SQUOTED: "dontexpand\\nnewlines",
    EQUAL_SIGNS: "equals==",
    RETAIN_INNER_QUOTES: "{\"foo\": \"bar\"}",
    RETAIN_INNER_QUOTES_AS_STRING: "{\"foo\": \"bar\"}",
    TRIM_SPACE_FROM_UNQUOTED: "some spaced out string",
    USERNAME: "therealnerdybeast@example.tld",
    SPACED_KEY: "parsed",
    MULTI_DOUBLE_QUOTED: "THIS\nIS\nA\nMULTILINE\nSTRING",
    MULTI_SINGLE_QUOTED: "THIS\nIS\nA\nMULTILINE\nSTRING",
    MULTI_BACKTICKED: "THIS\nIS\nA\n\"MULTILINE'S\"\nSTRING",
    MULTI_PEM_DOUBLE_QUOTED: "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnNl1tL3QjKp3DZWM0T3u\nLgGJQwu9WqyzHKZ6WIA5T+7zPjO1L8l3S8k8YzBrfH4mqWOD1GBI8Yjq2L1ac3Y/\nbTdfHN8CmQr2iDJC0C6zY8YV93oZB3x0zC/LPbRYpF8f6OqX1lZj5vo2zJZy4fI/\nkKcI5jHYc8VJq+KCuRZrvn+3V+KuL9tF9v8ZgjF2PZbU+LsCy5Yqg1M8f5Jp5f6V\nu4QuUoobAgMBAAE=\n-----END PUBLIC KEY-----",
  ),
)


#assert.eq(parse-env(read("examples/.env")), ("KEY": "VALUE"))

#let files = ("examples/.env", "examples/.env.local")
#assert.eq(
  files.map(it => parse-env(read(it))).sum(),
  (KEY: "VALUE2", MORE_KEY: "VALUE3"),
)
