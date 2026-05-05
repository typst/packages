import common, gzip, internal, std/memfiles, std/os, std/times, strutils, tarballs_v1

export common, tarballs_v1

proc parseTarOctInt(s: string): int =
  # Walk the bytes to find the start and len of the acii digits
  var start, len: int
  for c in s:
    if c in {'0' .. '9'}:
      break
    inc start
  for i in start ..< s.len:
    if s[i] notin {'0' .. '9'}:
      break
    inc len

  try:
    if len == 0:
      0
    else:
      parseOctInt(s[start ..< start + len])
  except ValueError:
    raise currentExceptionAsZippyError()

proc extractAll*(
  tarPath, dest: string
) {.raises: [IOError, OSError, ZippyError].} =
  ## Extracts the files stored in tarball to the destination directory.
  ## The path to the destination directory must exist.
  ## The destination directory itself must not exist (it is not overwitten).
  if dest == "" or dirExists(dest):
    raise newException(ZippyError, "Destination " & dest & " already exists")

  var (head, tail) = splitPath(dest)
  if tail == "": # For / at end of path
    (head, tail) = splitPath(head)
  if head != "" and not dirExists(head):
    raise newException(ZippyError, "Path to " & dest & " does not exist")

  var uncompressed: string
  block:
    var memFile = memfiles.open(tarPath)
    try:
      if memFile.size < 2:
        failUncompress()

      let src = cast[ptr UncheckedArray[uint8]](memFile.mem)
      if src[0] == 31 and src[1] == 139:
        # Looks like a compressed tarball (.tar.gz)
        uncompressGzip(uncompressed, src, memFile.size, trustSize = true)
      else:
        # Treat this as an uncompressed tarball (.tar)
        uncompressed.setLen(memFile.size)
        copyMem(uncompressed[0].addr, src, memFile.size)
    finally:
      memFile.close()

  try:
    var
      lastModifiedTimes: seq[(string, Time)]
      longFileName: string # Set by 'L' blocks, used for subsequent file

    var pos: int
    while pos < uncompressed.len:
      if pos + 512 > uncompressed.len:
        failArchiveEOF()

      # See https://www.gnu.org/software/tar/manual/html_node/Standard.html

      let
        name = $(uncompressed[pos ..< pos + 100]).cstring
        mode = parseTarOctInt(uncompressed[pos + 100 ..< pos + 100 + 7])
        size = parseTarOctInt(uncompressed[pos + 124 ..< pos + 124 + 11])
        mtime = parseTarOctInt(uncompressed[pos + 136 ..< pos + 136 + 11])
        typeflag = uncompressed[pos + 156]
        linkname = $(uncompressed[pos + 157 ..< pos + 157 + 100]).cstring
        magic = $(uncompressed[pos + 257 ..< pos + 257 + 6]).cstring
        prefix =
          if magic == "ustar":
            $(uncompressed[pos + 345 ..< pos + 345 + 155]).cstring
          else:
            ""

      pos += 512

      if pos + size > uncompressed.len:
        failArchiveEOF()

      if name.len > 0 or longFileName.len > 0:
        var path: string
        if longFileName != "":
          path = longFileName
          longFileName = ""
        else:
          path = prefix / name

        path.verifyPathIsSafeToExtract()

        if typeflag == '0' or typeflag == '\0': # Files
          createDir(dest / splitFile(path).dir)
          writeFile(
            dest / path,
            uncompressed.toOpenArray(pos, max(pos + size - 1, 0))
          )
          setFilePermissions(
            dest / path,
            parseFilePermissions(cast[uint32](mode))
          )
          lastModifiedTimes.add (path, initTime(mtime, 0))
        elif typeflag == '5': # Directories
          createDir(dest / path)
          lastModifiedTimes.add (path, initTime(mtime, 0))
        elif typeflag == '2': # Symlinks
          createDir(dest / splitFile(path).dir)
          createSymlink(linkname, dest / path)
        elif typeflag == 'L': # Long file names
          longFileName = uncompressed[pos ..< pos + size]
        elif typeflag in ['g', 'x'] or typeflag in {'A' .. 'Z'}:
          discard
        else:
          raise newException(ZippyError, "Unsupported header type " & typeflag)

      pos += (size + 511) and not 511

    # Set last modification time as a second pass otherwise directories get
    # updated last modification times as files are added on Mac.
    for (path, lastModified) in lastModifiedTimes:
      if lastModified > Time():
        setLastModificationTime(dest / path, lastModified)

  # If something bad happens delete the destination directory to avoid leaving
  # an incomplete extract.
  except IOError as e:
    removeDir(dest)
    raise e
  except OSError as e:
    removeDir(dest)
    raise e
  except ZippyError as e:
    removeDir(dest)
    raise e
