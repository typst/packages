import asyncdispatch, asynchttpserver, zippy

let server = newAsyncHttpServer()

proc cb(req: Request) {.async.} =
  if req.headers.hasKey("Accept-Encoding") and
    req.headers["Accept-Encoding"].contains("gzip"):
    # This client supports gzip, send compressed response
    let headers = newHttpHeaders([("Content-Encoding", "gzip")])
    await req.respond(
      Http200,
      compress("gzip'ed response body", BestSpeed, dfGzip),
      headers
    )
  else:
    await req.respond(Http200, "uncompressed response body")

waitFor server.serve(Port(8080), cb)
