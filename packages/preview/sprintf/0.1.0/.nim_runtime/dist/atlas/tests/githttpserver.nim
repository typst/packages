
import asynchttpserver, asyncdispatch
import os, strutils, mimetypes, httpclient
import basic/context

var
  searchDirs: seq[string]
  c = Reporter()

proc findDir(org, repo, files: string): string =
  {.cast(gcsafe).}:
    # search for org matches first
    for dir in searchDirs:
      result = dir / org / repo / files
      # infoNow "searching: ", result
      if fileExists(result):
        return
    # otherwise try without org in the searchdir
    for dir in searchDirs:
      result = dir / repo / files
      # infoNow "searching: ", result
      if fileExists(result):
        return
    
    if not repo.endsWith(".git"):
      return findDir(org, repo & ".git", files)

proc handleRequest(req: Request) {.async.} =
  # infoNow "http request: ", req.reqMethod, " url: ", req.url.path

  let arg = req.url.path.strip(chars={'/'})
  var path: string
  try:
    let dirs = arg.split('/')
    let org = dirs[0]
    let repo = dirs[1]
    let files = dirs[2..^1].join($DirSep)
    path = findDir(org, repo, files)
    # infoNow "http repo: ", " repo: ", repo, " path: ", path
  except IndexDefect:
    {.cast(gcsafe).}:
      path = findDir("", "", arg)
      # infoNow "http direct file: ", path

  # Serve static files if not a git request
  if fileExists(path):
    let ext = splitFile(path).ext
    var contentType = newMimetypes().getMimetype(ext.strip(chars={'.'}))
    if contentType == "": contentType = "application/octet-stream"
    
    var headers = newHttpHeaders()
    headers["Content-Type"] = contentType
    
    let content = readFile(path)
    await req.respond(Http200, content, headers)
  else:
    await req.respond(Http404, "File not found")

proc runGitHttpServer*(dirs: seq[string], port = Port(4242)) =
  {.cast(gcsafe).}:
    for dir in dirs:
      let d = dir.absolutePath()
      if not dirExists(d):
        raise newException(ValueError, "directory not found: " & d)
      searchDirs.add(d)
    let server = newAsyncHttpServer()
    doAssert searchDirs.len() >= 1, "must provide at least one directory to serve repos from"
    infoNow "githttpserver", "Starting http git server on port " & repr(port)
    infoNow "githttpserver", "Git http server serving directories: "
    for sd in searchDirs:
      infoNow "githttpserver", "\t" & sd
    waitFor server.serve(port, handleRequest)

proc threadGitHttpServer*(args: (seq[string], Port)) {.thread.} =
  let dirs = args[0]
  let port = args[1]
  runGitHttpServer(dirs, port)

var thread: Thread[(seq[string], Port)]
proc runGitHttpServerThread*(dirs: openArray[string], port = Port(4242)) =
  let dirs = @dirs
  createThread(thread, threadGitHttpServer, (dirs, port))

proc checkHttpReadme*(): bool =
    let client = newHttpClient()
    let response = client.get("http://localhost:4242/readme.md")
    infoNow "githttpserver", "HTTP Server gave response: " & response.body
    response.body == "This directory holds the bare git modules used for testing."

when isMainModule:
  var dirs: seq[string]
  runGitHttpServer(commandLineParams())
