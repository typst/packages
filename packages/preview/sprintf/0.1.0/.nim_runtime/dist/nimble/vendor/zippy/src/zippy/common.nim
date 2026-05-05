type
  ZippyError* = object of CatchableError ## Raised if an operation fails.

  CompressedDataFormat* = enum ## Supported compressed data formats
    dfDetect, dfZlib, dfGzip, dfDeflate

const
  NoCompression* = 0
  BestSpeed* = 1
  BestCompression* = 9
  DefaultCompression* = -1
  HuffmanOnly* = -2
