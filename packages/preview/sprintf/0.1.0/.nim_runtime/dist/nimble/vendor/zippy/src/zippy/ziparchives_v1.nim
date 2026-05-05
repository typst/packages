import common, crc, internal, std/os, std/streams, std/strutils, std/tables,
    std/times, zippy

export common

## NOTE: This file exists for backward compatibility. I already reworked how
## reading zip archives works, but have not reworked writing them. Keeping this
## original version around ensures people's code doesn't break and atleast there
## exists an option, even if I no longer like how this approach worked out.

type
  EntryKind* = enum
    ekFile, ekDirectory

  ArchiveEntry* = object
    kind*: EntryKind
    contents*: string
    lastModified*: times.Time
    permissions: set[FilePermission]

  ZipArchive* = ref object
    contents*: OrderedTable[string, ArchiveEntry]

proc addDir(archive: ZipArchive, base, relative: string) =
  if relative.len > 0 and relative notin archive.contents:
    archive.contents[(relative & os.DirSep).toUnixPath()] =
      ArchiveEntry(kind: ekDirectory)

  for kind, path in walkDir(base / relative, relative = true):
    case kind:
    of pcFile:
      archive.contents[(relative / path).toUnixPath()] = ArchiveEntry(
        kind: ekFile,
        contents: readFile(base / relative / path),
        lastModified: getLastModificationTime(base / relative / path),
        permissions: getFilePermissions(base / relative / path),
      )
    of pcDir:
      archive.addDir(base, relative / path)
    else:
      discard

proc addDir*(
  archive: ZipArchive, dir: string
) {.raises: [IOError, OSError, ZippyError].} =
  ## Recursively adds all of the files and directories inside dir to archive.
  if splitFile(dir).ext.len > 0:
    raise newException(
      ZippyError,
      "Error adding dir " & dir & " to archive, appears to be a file?"
    )

  let (head, tail) = splitPath(dir)
  archive.addDir(head, tail)

proc addFile*(
  archive: ZipArchive, path: string
) {.raises: [IOError, OSError, ZippyError].} =
  ## Adds a single file to the archive.

  let fileInfo = getFileInfo(path)
  case fileInfo.kind:
  of {pcFile, pcLinkToFile}:
    archive.contents[path.extractFilename] = ArchiveEntry(
      kind: ekFile,
      contents: readFile(path),
      lastModified: fileInfo.lastWriteTime,
      permissions: fileInfo.permissions,
    )
  else:
    raise newException(
      ZippyError,
      "Error adding file " & path & " to archive, appears to be a directory?"
    )

proc clear*(archive: ZipArchive) {.raises: [].} =
  archive.contents.clear()

template failEOF() =
  raise newException(
    ZippyError, "Attempted to read past end of file, corrupted zip archive?"
  )

proc extractPermissions(externalFileAttr: uint32): set[FilePermission] =
  let permissions = externalFileAttr shr 16
  if defined(windows) or permissions == 0:
    # Ignore file permissions on Windows. If they are absent (.zip made on
    # Windows for example), set default permissions.
    result.incl fpUserRead
    result.incl fpUserWrite
    result.incl fpGroupRead
    result.incl fpGroupWrite
    result.incl fpOthersRead
  else:
    if (permissions and 0o00400) != 0: result.incl fpUserRead
    if (permissions and 0o00200) != 0: result.incl fpUserWrite
    if (permissions and 0o00100) != 0: result.incl fpUserExec
    if (permissions and 0o00040) != 0: result.incl fpGroupRead
    if (permissions and 0o00020) != 0: result.incl fpGroupWrite
    if (permissions and 0o00010) != 0: result.incl fpGroupExec
    if (permissions and 0o00004) != 0: result.incl fpOthersRead
    if (permissions and 0o00002) != 0: result.incl fpOthersWrite
    if (permissions and 0o00001) != 0: result.incl fpOthersExec

proc openStreamImpl*(archive: ZipArchive, stream: Stream) =
  let data = stream.readAll() # TODO: actually treat as a stream

  archive.clear()

  template failOpen() =
    raise newException(ZippyError, "Unexpected error opening zip archive")

  var pos: int
  while true:
    if pos + 4 > data.len:
      failEOF()

    let signature = read32(data, pos)
    case signature:
    of 0x04034b50: # Local file header
      if pos + 30 > data.len:
        failEOF()

      let
        # minVersionToExtract = read16(data, pos + 4)
        generalPurposeFlag = read16(data, pos + 6)
        compressionMethod = read16(data, pos + 8)
        lastModifiedTime = read16(data, pos + 10)
        lastModifiedDate = read16(data, pos + 12)
        uncompressedCrc32 = read32(data, pos + 14)
        compressedSize = read32(data, pos + 18).int
        uncompressedSize = read32(data, pos + 22).int
        fileNameLength = read16(data, pos + 26).int
        extraFieldLength = read16(data, pos + 28).int

      pos += 30 # Move to end of fixed-size entries

      if (generalPurposeFlag and 0b100) != 0:
        raise newException(
          ZippyError,
          "Unsupported zip archive, data descriptor bit set"
        )

      if (generalPurposeFlag and 0b1000) != 0:
        raise newException(
          ZippyError,
          "Unsupported zip archive, uses deflate64"
        )

      # echo minVersionToExtract
      # echo generalPurposeFlag
      # echo compressionMethod
      # echo lastModifiedTime
      # echo lastModifiedDate
      # echo uncompressedCrc32
      # echo compressedSize
      # echo uncompressedSize
      # echo fileNameLength
      # echo extraFieldLength

      let
        seconds = (lastModifiedTime and 0b0000000000011111).int * 2
        minutes = ((lastModifiedTime shr 5) and 0b0000000000111111).int
        hours = ((lastModifiedTime shr 11) and 0b0000000000011111).int
        days = (lastModifiedDate and 0b0000000000011111).int
        months = ((lastModifiedDate shr 5) and 0b0000000000001111).int
        years = ((lastModifiedDate shr 9) and 0b0000000001111111).int

      var lastModified: times.Time
      if seconds <= 59 and minutes <= 59 and hours <= 23:
        lastModified = initDateTime(
          days.MonthdayRange,
          months.Month,
          years + 1980,
          hours.HourRange,
          minutes.MinuteRange,
          seconds.SecondRange,
          local()
        ).toTime()

      if compressionMethod notin [0.uint16, 8]:
        raise newException(
          ZippyError,
          "Unsupported zip archive compression method " & $compressionMethod
        )

      if pos + fileNameLength + extraFieldLength > data.len:
        failEOF()

      let fileName = data[pos ..< pos + fileNameLength]
      pos += fileNameLength

      # let extraField = data[pos ..< pos + extraFieldLength]
      pos += extraFieldLength

      # echo fileName
      # echo extraField

      if pos + compressedSize > data.len:
        failEOF()

      let uncompressed =
        if compressionMethod == 0:
          data[pos ..< pos + compressedSize]
        else:
          uncompress(data[pos ..< pos + compressedSize], dfDeflate)

      if crc32(uncompressed) != uncompressedCrc32:
        raise newException(
          ZippyError,
          "Verifying archive entry " & fileName & " CRC-32 failed"
        )
      if uncompressed.len != uncompressedSize:
        raise newException(
          ZippyError,
          "Unexpected error verifying " & fileName & " uncompressed size"
        )

      archive.contents[fileName.toUnixPath()] =
        ArchiveEntry(
          contents: uncompressed,
          lastModified: lastModified,
        )

      pos += compressedSize

    of 0x02014b50: # Central directory header
      if pos + 46 > data.len:
        failEOF()

      let
        # versionMadeBy = read16(data, pos + 4)
        # minVersionToExtract = read16(data, pos + 6)
        # generalPurposeFlag = read16(data, pos + 8)
        # compressionMethod = read16(data, pos + 10)
        # lastModifiedTime = read16(data, pos + 12)
        # lastModifiedDate = read16(data, pos + 14)
        # uncompressedCrc32 = read32(data, pos + 16)
        # compressedSize = read32(data, pos + 20).int
        # uncompressedSize = read32(data, pos + 24).int
        fileNameLength = read16(data, pos + 28).int
        extraFieldLength = read16(data, pos + 30).int
        fileCommentLength = read16(data, pos + 32).int
        # diskNumber = read16(data, pos + 34)
        # internalFileAttr = read16(data, pos + 36)
        externalFileAttr = read32(data, pos + 38) and uint32.high
        # relativeOffsetOfLocalFileHeader = read32(data, pos + 42)

      # echo versionMadeBy
      # echo minVersionToExtract
      # echo generalPurposeFlag
      # echo compressionMethod
      # echo lastModifiedTime
      # echo lastModifiedDate
      # echo uncompressedCrc32
      # echo compressedSize
      # echo uncompressedSize
      # echo fileNameLength
      # echo extraFieldLength
      # echo fileCommentLength
      # echo diskNumber
      # echo internalFileAttr
      # echo externalFileAttr
      # echo relativeOffsetOfLocalFileHeader

      pos += 46 # Move to end of fixed-size entries

      if pos + fileNameLength + extraFieldLength + fileCommentLength > data.len:
        failEOF()

      let fileName = data[pos ..< pos + fileNameLength]
      pos += fileNameLength
      # let extraField = data[pos ..< pos + extraFieldLength]
      pos += extraFieldLength
      # let fileComment = data[pos ..< pos + fileCommentLength]
      pos += fileCommentLength

      # echo fileName
      # echo extraField
      # echo fileComment

      try:
        # Update the entry kind for directories
        if (externalFileAttr and 0x10) == 0x10:
          archive.contents[fileName].kind = ekDirectory
      except KeyError:
        failOpen()

      try:
        # Update file permissions
        archive.contents[fileName].permissions = externalFileAttr.extractPermissions()
      except KeyError:
        failOpen()

    of 0x06054b50: # End of central directory record
      if pos + 22 > data.len:
        failEOF()

      let
        # diskNumber = read16(data, pos + 4)
        # startDisk = read16(data, pos + 6)
        # numRecordsOnDisk = read16(data, pos + 8)
        # numCentralDirectoryRecords = read16(data, pos + 10)
        # centralDirectorySize = read32(data, pos + 12)
        # relativeOffsetOfCentralDirectory = read32(data, pos + 16)
        commentLength = read16(data, pos + 20).int

      # echo diskNumber
      # echo startDisk
      # echo numRecordsOnDisk
      # echo numCentralDirectoryRecords
      # echo centralDirectorySize
      # echo relativeOffsetOfCentralDirectory
      # echo commentLength

      pos += 22 # Move to end of fixed-size entries

      if pos + commentLength > data.len:
        failEOF()

      # let comment = readStr(data, pos, commentLength)
      pos += commentLength

      # echo comment

      break

    else:
      failOpen()

when (NimMajor, NimMinor, NimPatch) >= (1, 4, 0):
  proc open*(
    archive: ZipArchive, stream: Stream
  ) {.raises: [IOError, OSError, ZippyError].} =
    ## Opens the zip archive from a stream and reads its contents into
    ## archive.contents (clears any existing archive.contents entries).
    openStreamImpl(archive, stream)
else:
  proc open*(
    archive: ZipArchive, stream: Stream
  ) {.raises: [Defect, IOError, OSError, ZippyError].} =
    ## Opens the zip archive from a stream and reads its contents into
    ## archive.contents (clears any existing archive.contents entries).
    openStreamImpl(archive, stream)

proc open*(archive: ZipArchive, path: string) {.inline.} =
  ## Opens the zip archive file located at path and reads its contents into
  ## archive.contents (clears any existing archive.contents entries).
  archive.open(newStringStream(readFile(path)))

proc toMsDos(time: times.Time): (uint16, uint16) =
  let
    dateTime = time.local()
    seconds = (dateTime.second div 2).uint16
    minutes = (dateTime.minute).uint16
    hours = (dateTime.hour).uint16
    days = (dateTime.monthday).uint16
    months = (dateTime.month).uint16
    years = (max(0, dateTime.year - 1980)).uint16

  var lastModifiedTime = seconds
  lastModifiedTime = (minutes shl 5) or lastModifiedTime
  lastModifiedTime = (hours shl 11) or lastModifiedTime

  var lastModifiedDate = days
  lastModifiedDate = (months shl 5) or lastModifiedDate
  lastModifiedDate = (years shl 9) or lastModifiedDate

  (lastModifiedTime, lastModifiedDate)

proc writeZipArchive*(
  archive: ZipArchive, path: string
) {.raises: [IOError, ZippyError].} =
  ## Writes archive.contents to a zip file at path.

  if archive.contents.len == 0:
    raise newException(ZippyError, "Zip archive has no contents")

  type Values = object
    offset, crc32, compressedLen, uncompressedLen: uint32
    compressionMethod: uint16

  var
    data: seq[uint8]
    values: Table[string, Values]

  # Write each file entry
  for path, entry in archive.contents:
    var v: Values
    v.offset = data.len.uint32

    data.add(cast[array[4, uint8]](0x04034b50)) # Local file header signature
    data.add(cast[array[2, uint8]](20.uint16)) # Min version to extract
    data.add(cast[array[2, uint8]](1.uint16 shl 11)) # General purpose flag UTF-8

    # Compression method
    if splitFile(path).name.len == 0 or entry.contents.len == 0:
      v.compressionMethod = 0
    else:
      v.compressionMethod = 8

    data.add(cast[array[2, uint8]](v.compressionMethod))

    let (lastModifiedTime, lastModifiedDate) = entry.lastModified.toMsDos()
    data.add(cast[array[2, uint8]](lastModifiedTime))
    data.add(cast[array[2, uint8]](lastModifiedDate))

    v.crc32 = crc32(entry.contents)
    data.add(cast[array[4, uint8]](v.crc32))

    let compressed =
      if entry.contents.len > 0:
        compress(entry.contents, DefaultCompression, dfDeflate)
      else:
        ""

    v.compressedLen = compressed.len.uint32
    v.uncompressedLen = entry.contents.len.uint32

    data.add(cast[array[4, uint8]](v.compressedLen))
    data.add(cast[array[4, uint8]](v.uncompressedLen))

    data.add(cast[array[2, uint8]](path.len.uint16)) # File name len
    data.add([0.uint8, 0]) # Extra field len

    data.add(cast[seq[uint8]](path))

    data.add(cast[seq[uint8]](compressed))

    values[path] = v

  # Write the central directory
  let centralDirectoryOffset = data.len
  var centralDirectorySize: int
  for path, entry in archive.contents:
    let v =
      try:
        values[path]
      except KeyError:
        raise newException(ZippyError, "Unexpected error writing archive")

    data.add(cast[array[4, uint8]](0x02014b50)) # Central directory signature
    data.add(cast[array[2, uint8]](63.uint16)) # Version made by
    data.add(cast[array[2, uint8]](20.uint16)) # Min version to extract
    data.add(cast[array[2, uint8]](1.uint16 shl 11)) # General purpose flag UTF-8
    data.add(cast[array[2, uint8]](v.compressionMethod))

    let (lastModifiedTime, lastModifiedDate) = entry.lastModified.toMsDos()
    data.add(cast[array[2, uint8]](lastModifiedTime))
    data.add(cast[array[2, uint8]](lastModifiedDate))

    data.add(cast[array[4, uint8]](v.crc32))
    data.add(cast[array[4, uint8]](v.compressedLen))
    data.add(cast[array[4, uint8]](v.uncompressedLen))
    data.add(cast[array[2, uint8]](path.len.uint16)) # File name len
    data.add([0.uint8, 0]) # Extra field len
    data.add([0.uint8, 0]) # File comment len
    data.add([0.uint8, 0]) # Disk number
    data.add([0.uint8, 0]) # Internal file attrib

    # External file attrib
    case entry.kind:
    of ekDirectory:
      data.add([0x10.uint8, 0, 0, 0])
    of ekFile:
      data.add([0x20.uint8, 0, 0, 0])

    data.add(cast[array[4, uint8]](v.offset)) # Relative offset of local file header
    data.add(cast[seq[uint8]](path))

    centralDirectorySize += 46 + path.len

  # Write the end of central directory record
  data.add(cast[array[4, uint8]](0x06054b50)) # End of central directory signature
  data.add([0.uint8, 0])
  data.add([0.uint8, 0])
  data.add(cast[array[2, uint8]](archive.contents.len.uint16))
  data.add(cast[array[2, uint8]](archive.contents.len.uint16))
  data.add(cast[array[4, uint8]](centralDirectorySize.uint32))
  data.add(cast[array[4, uint8]](centralDirectoryOffset.uint32))
  data.add([0.uint8, 0])

  when (NimMajor, NimMinor, NimPatch) >= (1, 4, 0):
    writeFile(path, data)
  else:
    writeFile(path, cast[string](data))

proc extractAll*(
  archive: ZipArchive, dest: string
) {.raises: [IOError, OSError, ZippyError].} =
  ## Extracts the files stored in archive to the destination directory.
  ## The path to the destination directory must exist.
  ## The destination directory itself must not exist (it is not overwitten).
  if dirExists(dest):
    raise newException(
      ZippyError, "Destination " & dest & " already exists"
    )

  let (head, tail) = splitPath(dest)
  if tail != "" and not dirExists(head):
    raise newException(
      ZippyError, "Path to destination " & dest & " does not exist"
    )

  # Ensure we only raise exceptions we handle below
  proc writeContents(
    archive: ZipArchive, dest: string
  ) {.raises: [IOError, OSError, ZippyError].} =
    for path, entry in archive.contents:
      if path.isAbsolute():
        raise newException(
          ZippyError,
          "Extracting absolute paths is not supported (" & path & ")"
        )
      if path.startsWith("../") or path.startsWith(r"..\"):
        raise newException(
          ZippyError,
          "Extracting paths starting with `..` is not supported (" & path & ")"
        )
      if "/../" in path or r"\..\" in path:
        raise newException(
          ZippyError,
          "Extracting paths containing `/../` is not supported (" & path & ")"
        )

      case entry.kind:
      of ekDirectory:
        createDir(dest / path)
      of ekFile:
        createDir(dest / splitFile(path).dir)
        writeFile(dest / path, entry.contents)
        if entry.lastModified > Time():
          setLastModificationTime(dest / path, entry.lastModified)
        setFilePermissions(dest / path, entry.permissions)

  try:
    archive.writeContents(dest)
  except IOError as e:
    removeDir(dest)
    raise e
  except OSError as e:
    removeDir(dest)
    raise e
  except ZippyError as e:
    removeDir(dest)
    raise e

proc createZipArchive*(
  source, dest: string
) {.raises: [IOError, OSError, ZippyError].} =
  ## Creates an archive containing all of the files and directories inside
  ## source and writes the zip file to dest.
  let archive = ZipArchive()
  archive.addDir(source)
  archive.writeZipArchive(dest)
