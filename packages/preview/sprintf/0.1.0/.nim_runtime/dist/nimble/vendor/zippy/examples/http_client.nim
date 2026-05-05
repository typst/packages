import httpclient, strformat, zippy

let client = newHttpClient()
client.headers = newHttpHeaders({"Accept-Encoding": "gzip"})

let
  response = client.request("http://www.google.com")
  compressed = response.body
  uncompressed = uncompress(response.body)

echo &"compressed size: {compressed.len} uncompressed size: {uncompressed.len}"
