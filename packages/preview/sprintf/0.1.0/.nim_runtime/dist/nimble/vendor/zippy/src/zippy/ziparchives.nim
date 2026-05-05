import common, crc, internal, std/memfiles, std/os, std/strutils, std/tables,
    std/times, std/unicode, ziparchives_v1, zippy, std/sequtils

export common, ziparchives_v1

const
  fileHeaderLen = 30
  fileHeaderSignature = 0x04034b50.uint32
  centralDirectoryFileHeaderSignature = 0x02014b50.uint32
  endOfCentralDirectorySignature = 0x06054b50.uint32
  zip64EndOfCentralDirectorySignature = 0x06064b50.uint32
  zip64EndOfCentralDirectoryLocatorSignature = 0x07064b50.uint32
  zip64ExtraFieldId = 1.uint16

type
  ZipArchiveRecordKind = enum
    FileRecord, DirectoryRecord

  ZipArchiveRecord = object
    kind: ZipArchiveRecordKind
    fileHeaderOffset: int
    path: string
    uncompressedCrc32: uint32
    compressedSize: int
    uncompressedSize: int
    filePermissions: set[FilePermission]

  ZipArchiveReader* = ref object
    memFile: MemFile
    records: OrderedTable[string, ZipArchiveRecord]

iterator walkFiles*(reader: ZipArchiveReader): string =
  ## Walks over all files in the archive and returns the file name
  ## (including the path).
  for _, record in reader.records:
    if record.kind == FileRecord:
      yield record.path

proc extractFile*(
  reader: ZipArchiveReader, path: string
): string {.raises: [ZippyError].} =

  template failNoFileRecord() =
    raise newException(ZippyError, "No file record found for " & path)

  let
    src = cast[ptr UncheckedArray[uint8]](reader.memFile.mem)
    record =
      try:
        reader.records[path]
      except KeyError:
        failNoFileRecord()

  var pos = record.fileHeaderOffset

  if pos + fileHeaderLen > reader.memFile.size:
    failArchiveEOF()

  if read32(src, pos) != fileHeaderSignature:
    raise newException(ZippyError, "Invalid file header")

  let
    # minVersionToExtract = read16(src, pos + 4)
    # generalPurposeFlag = read16(src, pos + 6)
    compressionMethod = read16(src, pos + 8)
    # lastModifiedTime = read16(src, pos + 10)
    # lastModifiedDate = read16(src, pos + 12)
    # uncompressedCrc32 = read32(src, pos + 14)
    # compressedSize = read32(src, pos + 18)
    # uncompressedSize = read32(src, pos + 22)
    fileNameLen = read16(src, pos + 26).int
    extraFieldLen = read16(src, pos + 28).int

  pos += fileHeaderLen + fileNameLen + extraFieldLen

  if pos + record.compressedSize > reader.memFile.size:
    failArchiveEOF()

  case record.kind:
  of FileRecord:
    if compressionMethod == 0: # No compression
      if record.compressedSize > 0:
        result.setLen(record.compressedSize)
        copyMem(result[0].addr, src[pos].addr, record.compressedSize)
    elif compressionMethod == 8: # Deflate
      result = uncompress(src[pos].addr, record.compressedSize, dfDeflate)
    else:
      raise newException(ZippyError, "Unsupported archive, compression method")
  of DirectoryRecord:
    failNoFileRecord()

  if crc32(result) != record.uncompressedCrc32:
    raise newException(ZippyError, "Verifying crc32 failed")

proc close*(reader: ZipArchiveReader) {.raises: [OSError].} =
  reader.memFile.close()

proc parseMsDosDateTime(time, date: uint16): Time =
  let
    seconds = (time and 0b0000000000011111).int * 2
    minutes = ((time shr 5) and 0b0000000000111111).int
    hours = ((time shr 11) and 0b0000000000011111).int
    days = (date and 0b0000000000011111).int
    months = ((date shr 5) and 0b0000000000001111).int
    years = ((date shr 9) and 0b0000000001111111).int
  if seconds <= 59 and minutes <= 59 and hours <= 23:
    result = initDateTime(
      days.MonthdayRange,
      months.Month,
      years + 1980,
      hours.HourRange,
      minutes.MinuteRange,
      seconds.SecondRange,
      local()
    ).toTime()

proc utf8ify(fileName: string): string =
  const cp437AfterAscii = [
    # 0x80 - 0x8f
    0x00c7.uint32, 0x00fc, 0x00e9, 0x00e2, 0x00e4, 0x00e0, 0x00e5, 0x00e7,
    0x00ea, 0x00eb, 0x00e8, 0x00ef, 0x00ee, 0x00ec, 0x00c4, 0x00c5,
    # 0x90 - 0x9f
    0x00c9, 0x00e6, 0x00c6, 0x00f4, 0x00f6, 0x00f2, 0x00fb, 0x00f9,
    0x00ff, 0x00d6, 0x00dc, 0x00a2, 0x00a3, 0x00a5, 0x20a7, 0x0192,
    # 0xa0 - 0xaf
    0x00e1, 0x00ed, 0x00f3, 0x00fa, 0x00f1, 0x00d1, 0x00aa, 0x00ba,
    0x00bf, 0x2310, 0x00ac, 0x00bd, 0x00bc, 0x00a1, 0x00ab, 0x00bb,
    # 0xb0 - 0xbf
    0x2591, 0x2592, 0x2593, 0x2502, 0x2524, 0x2561, 0x2562, 0x2556,
    0x2555, 0x2563, 0x2551, 0x2557, 0x255d, 0x255c, 0x255b, 0x2510,
    # 0xc0 - 0xcf
    0x2514, 0x2534, 0x252c, 0x251c, 0x2500, 0x253c, 0x255e, 0x255f,
    0x255a, 0x2554, 0x2569, 0x2566, 0x2560, 0x2550, 0x256c, 0x2567,
    # 0xd0 - 0xdf
    0x2568, 0x2564, 0x2565, 0x2559, 0x2558, 0x2552, 0x2553, 0x256b,
    0x256a, 0x2518, 0x250c, 0x2588, 0x2584, 0x258c, 0x2590, 0x2580,
    # 0xd0 - 0xdf
    0x03b1, 0x00df, 0x0393, 0x03c0, 0x03a3, 0x03c3, 0x00b5, 0x03c4,
    0x03a6, 0x0398, 0x03a9, 0x03b4, 0x221e, 0x03c6, 0x03b5, 0x2229,
    # 0xf0 - 0xff
    0x2261, 0x00b1, 0x2265, 0x2264, 0x2320, 0x2321, 0x00f7, 0x2248,
    0x00b0, 0x2219, 0x00b7, 0x221a, 0x207f, 0x00b2, 0x25a0, 0x00a0
  ]

  if validateUtf8(fileName) == -1:
    return fileName

  # If the file name is not valid utf-8, assume it is CP437 / OEM / DOS
  var runes: seq[Rune]
  for c in fileName:
    if c > 0x7f.char:
      runes.add Rune(cp437AfterAscii[c.int - 0x80])
    else:
      runes.add Rune(c)
  $runes

proc findEndOfCentralDirectory(reader: ZipArchiveReader): int =
  let src = cast[ptr UncheckedArray[uint8]](reader.memFile.mem)

  result = reader.memFile.size - 22 # Work backwards in the file starting here
  while true:
    if result < 0:
      failArchiveEOF()
    if read32(src, result) == endOfCentralDirectorySignature:
      return
    else:
      dec result

proc findStartOfCentralDirectory(
  reader: ZipArchiveReader,
  start, numRecordEntries: int
): int =
  let src = cast[ptr UncheckedArray[uint8]](reader.memFile.mem)

  result = start # Work backwards in the file starting here
  var numRecordsFound: int
  while true:
    if result < 0:
      failArchiveEOF()
    if read32(src, result) == centralDirectoryFileHeaderSignature:
      inc numRecordsFound
      if numRecordsFound == numRecordEntries:
        return
    dec result

proc openZipArchive*(
  zipPath: string
): ZipArchiveReader {.raises: [IOError, OSError, ZippyError].} =
  result = ZipArchiveReader()
  result.memFile = memfiles.open(zipPath)

  try:
    let src = cast[ptr UncheckedArray[uint8]](result.memFile.mem)

    let eocd = result.findEndOfCentralDirectory()
    if eocd + 22 > result.memFile.size:
      failArchiveEOF()

    var zip64 = false
    if eocd - 20 >= 0:
      if read32(src, eocd - 20) == zip64EndOfCentralDirectoryLocatorSignature:
        zip64 = true

    var
      diskNumber, startDisk, numRecordsOnDisk, numCentralDirectoryRecords: int
      centralDirectorySize, centralDirectoryStart: int
    if zip64:
      let
        zip64EndOfCentralDirectoryDiskNumber = read32(src, eocd - 20 + 4)
        zip64EndOfCentralDirectoryStart = read64(src, eocd - 20 + 8).int
        numDisks = read32(src, eocd - 20 + 16)

      if zip64EndOfCentralDirectoryDiskNumber != 0:
        raise newException(ZippyError, "Unsupported archive, disk number")

      if numDisks != 1:
        raise newException(ZippyError, "Unsupported archive, num disks")

      var pos = zip64EndOfCentralDirectoryStart
      if pos + 64 > result.memFile.size:
        failArchiveEOF()

      if read32(src, pos) != zip64EndOfCentralDirectorySignature:
        raise newException(ZippyError, "Invalid central directory file header")

      # let
        # endOfCentralDirectorySize = read64(src, pos + 4).int
        # versionMadeBy = read16(src, pos + 12)
        # minVersionToExtract = read16(src, pos + 14)
      diskNumber = read32(src, pos + 16).int
      startDisk = read32(src, pos + 20).int
      numRecordsOnDisk = read64(src, pos + 24).int
      numCentralDirectoryRecords = read64(src, pos + 32).int
      centralDirectorySize = read64(src, pos + 40).int
      centralDirectoryStart = read64(src, pos + 48).int
        # anotherDisk = read64(src, pos + 56).int
    else:
      diskNumber = read16(src, eocd + 4).int
      startDisk = read16(src, eocd + 6).int
      numRecordsOnDisk = read16(src, eocd + 8).int
      numCentralDirectoryRecords = read16(src, eocd + 10).int
      centralDirectorySize = read32(src, eocd + 12).int
      centralDirectoryStart = read32(src, eocd + 16).int
        # commentLen = read16(src, eocd + 20).int

    if diskNumber != 0:
      raise newException(ZippyError, "Unsupported archive, disk number")

    if startDisk != 0:
      raise newException(ZippyError, "Unsupported archive, start disk")

    if numRecordsOnDisk != numCentralDirectoryRecords:
      raise newException(ZippyError, "Unsupported archive, record number")

    # A zip archive may be concatenated to the end of another file (like an
    # exe). This handles that by determining where the zip archive is from
    # the start of the file.
    let
      socd =
        try:
          # Try to find the start relative to the end of the file, supporting
          # zip archives being concatenated to the end. If this fails for any
          # reason, fall back to the default behavior.
          result.findStartOfCentralDirectory(eocd, numCentralDirectoryRecords)
        except ZippyError:
          centralDirectoryStart
      socdOffset = socd - centralDirectoryStart

    var pos = socdOffset + centralDirectoryStart

    if eocd + 22 > result.memFile.size:
      failArchiveEOF()

    for _ in 0 ..< numCentralDirectoryRecords:
      if pos + 46 > result.memFile.size:
        failArchiveEOF()

      if read32(src, pos) != centralDirectoryFileHeaderSignature:
        raise newException(ZippyError, "Invalid central directory file header")

      let
        # versionMadeBy = read16(src, pos + 4)
        # minVersionToExtract = read16(src, pos + 6)
        generalPurposeFlag = read16(src, pos + 8)
        compressionMethod = read16(src, pos + 10)
        # lastModifiedTime = read16(src, pos + 12)
        # lastModifiedDate = read16(src, pos + 14)
        uncompressedCrc32 = read32(src, pos + 16)
        fileNameLen = read16(src, pos + 28).int
        extraFieldLen = read16(src, pos + 30).int
        fileCommentLen = read16(src, pos + 32).int
        fileDiskNumber = read16(src, pos + 34).int
        # internalFileAttr = read16(src, pos + 36)
        externalFileAttr = read32(src, pos + 38)

      if compressionMethod notin [0.uint16, 8]:
        raise newException(ZippyError, "Unsupported archive, compression method")

      if fileDiskNumber != 0:
        raise newException(ZippyError, "Invalid file disk number")

      var
        compressedSize = read32(src, pos + 20).int
        uncompressedSize = read32(src, pos + 24).int
        fileHeaderOffset = read32(src, pos + 42).int

      pos += 46

      if pos + fileNameLen > result.memFile.size:
        failArchiveEOF()

      var fileName = newString(fileNameLen)
      copyMem(fileName[0].addr, src[pos].addr, fileNameLen)

      if fileName in result.records:
        raise newException(ZippyError, "Unsupported archive, duplicate entry")

      pos += fileNameLen

      block: # Handle zip64 values as needed
        var extraFieldsOffset = pos

        while extraFieldsOffset < pos + extraFieldLen:
          if pos + 4 > result.memFile.size:
            failArchiveEOF()

          let
            fieldId = read16(src, pos + 0)
            fieldLen = read16(src, pos + 2).int

          extraFieldsOffset += 4

          if fieldId != zip64ExtraFieldId:
            extraFieldsOffset += fieldLen
          else:
            # These are the zip64 sizes
            var zip64ExtrasOffset = extraFieldsOffset

            if uncompressedSize == 0xffffffff:
              if zip64ExtrasOffset + 8 > extraFieldsOffset + fieldLen:
                failArchiveEOF()
              uncompressedSize = read64(src, zip64ExtrasOffset).int
              zip64ExtrasOffset += 8

            if compressedSize == 0xffffffff:
              if zip64ExtrasOffset + 8 > extraFieldsOffset + fieldLen:
                failArchiveEOF()
              compressedSize = read64(src, zip64ExtrasOffset).int
              zip64ExtrasOffset += 8

            if fileHeaderOffset == 0xffffffff:
              if zip64ExtrasOffset + 8 > extraFieldsOffset + fieldLen:
                failArchiveEOF()
              fileHeaderOffset = read64(src, zip64ExtrasOffset).int
              zip64ExtrasOffset += 8
            break

      pos += extraFieldLen + fileCommentLen

      if pos > socdOffset + centralDirectoryStart + centralDirectorySize:
        raise newException(ZippyError, "Invalid central directory size")

      let utf8FileName =
        if (generalPurposeFlag and 0b100000000000) != 0:
          # Language encoding flag (EFS) set, assume utf-8
          fileName
        else:
          fileName.utf8ify()

      let
        dosDirectoryFlag = (externalFileAttr and 0x10) != 0
        unixDirectoryFlag = (externalFileAttr and (S_IFDIR.uint32 shl 16)) != 0
        recordKind =
          if dosDirectoryFlag or unixDirectoryFlag or utf8FileName.endsWith("/"):
            DirectoryRecord
          else:
            FileRecord

      result.records[utf8FileName] = ZipArchiveRecord(
        kind: recordKind,
        fileHeaderOffset: fileHeaderOffset.int + socdOffset,
        path: utf8FileName,
        compressedSize: compressedSize,
        uncompressedSize: uncompressedSize,
        uncompressedCrc32: uncompressedCrc32,
        filePermissions: parseFilePermissions(externalFileAttr shr 16)
      )
  except IOError as e:
    result.close()
    raise e
  except OSError as e:
    result.close()
    raise e
  except ZippyError as e:
    result.close()
    raise e

proc extractAll*(
  zipPath, dest: string
) {.raises: [IOError, OSError, ZippyError].} =
  ## Extracts the files stored in archive to the destination directory.
  ## The path to the destination directory must exist.
  ## The destination directory itself must not exist (it is not overwitten).
  if dest == "" or dirExists(dest):
    raise newException(ZippyError, "Destination " & dest & " already exists")

  var (head, tail) = splitPath(dest)
  if tail == "": # For / at end of path
    (head, tail) = splitPath(head)
  if head != "" and not dirExists(head):
    raise newException(ZippyError, "Path to " & dest & " does not exist")

  let
    reader = openZipArchive(zipPath)
    src = cast[ptr UncheckedArray[uint8]](reader.memFile.mem)

  # Verify some things before attempting to write the files
  for _, record in reader.records:
    record.path.verifyPathIsSafeToExtract()

  try:
    # Create the directories and write the extracted files
    for _, record in reader.records:
      case record.kind:
      of DirectoryRecord:
        createDir(dest / record.path)
      of FileRecord:
        createDir(dest / splitFile(record.path).dir)
        writeFile(dest / record.path, reader.extractFile(record.path))
        setFilePermissions(dest / record.path, record.filePermissions)

    # Set last modification time as a second pass otherwise directories get
    # updated last modification times as files are added on Mac.
    for _, record in reader.records:
      let
        lastModifiedTime = read16(src, record.fileHeaderOffset + 10)
        lastModifiedDate = read16(src, record.fileHeaderOffset + 12)
        lastModified = parseMsDosDateTime(lastModifiedTime, lastModifiedDate)
      setLastModificationTime(dest / record.path, lastModified)

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
  finally:
    reader.close()

when (NimMajor, NimMinor, NimPatch) >= (1, 6, 0):
  # For some reason `sink Table | OrderedTable` does not work, so work around:
  template createZipArchiveImpl(
    entries: var Table[string, string] | var OrderedTable[string, string]
  ) =

    proc add16(dst: var string, v: int16 | uint16) =
      dst.setLen(dst.len + 2)
      var tmp = v
      copyMem(dst[^2].addr, tmp.addr, 2)

    proc add32(dst: var string, v: int32 | uint32) =
      dst.setLen(dst.len + 4)
      var tmp = v
      copyMem(dst[^4].addr, tmp.addr, 4)

    proc add64(dst: var string, v: int | int64 | uint | uint64) =
      dst.setLen(dst.len + 8)
      var tmp = v
      copyMem(dst[^8].addr, tmp.addr, 8)

    proc msdos(time: Time): (uint16, uint16) =
      let
        dt = time.local()
        seconds = (dt.second div 2).uint16
        minutes = dt.minute.uint16
        hours = dt.hour.uint16
        days = dt.monthday.uint16
        months = dt.month.uint16
        years = (max(0, dt.year - 1980)).uint16

      var time = seconds
      time = (minutes shl 5) or time
      time = (hours shl 11) or time

      var date = days
      date = (months shl 5) or date
      date = (years shl 9) or date

      (time, date)

    let (lastModifiedTime, lastModifiedDate) = msdos(getTime())

    type ArchiveEntry = object
      fileHeaderOffset: int
      uncompressedLen: int
      compressedLen: int
      compressionMethod: uint16
      uncompressedCrc32: uint32

    var
      keys = toSeq(entries.keys) # The entries table is modified so use toSeq
      records: seq[(string, ArchiveEntry)]
    while keys.len > 0:
      let fileName = keys.pop()
      if fileName == "":
        raise newException(ZippyError, "Invalid empty file name")
      if fileName[0] == '/':
        raise newException(ZippyError, "File paths must be relative")
      if fileName.len > uint16.high.int:
        raise newException(ZippyError, "File name len > uint16.high")

      var
        uncompressedLen: int
        uncompressedCrc32: uint32
        compressed: string
        compressionMethod: uint16
      block: # Free `contents` after this block
        var contents: string
        discard entries.pop(fileName, contents)
        uncompressedLen = contents.len
        uncompressedCrc32 = crc32(contents)
        if contents == "":
          discard
        else:
          compressed = compress(contents, BestSpeed, dfDeflate)
          compressionMethod = 8

      records.add((fileName, ArchiveEntry(
        fileHeaderOffset: result.len,
        uncompressedLen: uncompressedLen,
        compressedLen: compressed.len,
        compressionMethod: compressionMethod,
        uncompressedCrc32: uncompressedCrc32
      )))

      result.add32(fileHeaderSignature)
      result.add16(45) # Min version to extract
      result.add16(1.uint16 shl 11) # General purpose flags
      result.add16(compressionMethod)
      result.add16(lastModifiedTime)
      result.add16(lastModifiedDate)
      result.add32(uncompressedCrc32) # CRC-32 of uncompressed data
      result.add32(uint32.high) # Compressed size (or 0xffffffff for ZIP64)
      result.add32(uint32.high) # Uncompressed size (or 0xffffffff for ZIP64)
      result.add16(cast[uint16](fileName.len)) # File name length
      result.add16(20) # Extra field length

      result.add(fileName)

      result.add16(zip64ExtraFieldId)
      result.add16(16)
      result.add64(uncompressedLen)
      result.add64(compressed.len)

      # result.add(compressed)
      if compressed != "":
        result.setLen(result.len + compressed.len)
        copyMem(
          result[result.len - compressed.len].addr,
          compressed.cstring,
          compressed.len
        )

    let centralDirectoryStart = result.len

    for i in 0 ..< records.len:
      let entry = records[i][1]
      result.add32(centralDirectoryFileHeaderSignature)
      result.add16(45) # Version made by
      result.add16(45) # Min version to extract
      result.add16(1.uint16 shl 11) # General purpose flags
      result.add16(entry.compressionMethod)
      result.add16(lastModifiedTime)
      result.add16(lastModifiedDate)
      result.add32(entry.uncompressedCrc32)
      result.add32(uint32.high) # Compressed size (or 0xffffffff for ZIP64)
      result.add32(uint32.high) # Uncompressed size (or 0xffffffff for ZIP64)
      result.add16(cast[uint16](records[i][0].len)) # File name length
      result.add16(28) # Extra field length
      result.add16(0) # File comment length
      result.add16(0) # Disk number where file starts
      result.add16(0) # Internal file attributes
      result.add32(0) # External file attributes
      result.add32(uint32.high) # Relative offset of local file header (or 0xffffffff for ZIP64)

      result.add(records[i][0])

      result.add16(zip64ExtraFieldId)
      result.add16(24)
      result.add64(entry.uncompressedLen)
      result.add64(entry.compressedLen)
      result.add64(entry.fileHeaderOffset)

    let centralDirectoryEnd = result.len

    result.add32(zip64EndOfCentralDirectorySignature)
    result.add64(44)
    result.add16(45)
    result.add16(45)
    result.add32(0)
    result.add32(0)
    result.add64(records.len)
    result.add64(records.len)
    result.add64(centralDirectoryEnd - centralDirectoryStart)
    result.add64(centralDirectoryStart)

    result.add32(zip64EndOfCentralDirectoryLocatorSignature)
    result.add32(0)
    result.add64(centralDirectoryEnd)
    result.add32(1)

    result.add32(endOfCentralDirectorySignature)
    result.add16(0) # Number of this disk
    result.add16(0) # Disk where central directory starts
    result.add16(uint16.high) # Number of central directory records on this disk (or 0xffff for ZIP64)
    result.add16(uint16.high) # Total number of central directory records (or 0xffff for ZIP64)
    result.add32(uint32.high) # Size of central directory (bytes) (or 0xffffffff for ZIP64)
    result.add32(uint32.high) # Offset of start of central directory, relative to start of archive (or 0xffffffff for ZIP64)
    result.add16(0)

  proc createZipArchive*(
    entries: sink Table[string, string]
  ): string {.raises: [ZippyError].} =
    createZipArchiveImpl(entries)

  proc createZipArchive*(
    entries: sink OrderedTable[string, string]
  ): string {.raises: [ZippyError].} =
    createZipArchiveImpl(entries)
