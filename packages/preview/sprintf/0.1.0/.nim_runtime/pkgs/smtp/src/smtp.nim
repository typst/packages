#
#
#            Nim's Runtime Library
#        (c) Copyright 2012 Dominik Picheta
#
#    See the file "copying.txt", included in this
#    distribution, for details about the copyright.
#

## .. note:: In order to use this module, run `nimble install smtp`.
##
## This module implements the SMTP client protocol as specified by RFC 5321,
## this can be used to send mail to any SMTP Server.
##
## This module also implements the protocol used to format messages,
## as specified by RFC 2822.
##
## Example gmail use:
##
##
## .. code-block:: Nim
##   var msg = createMessage("Hello from Nim's SMTP",
##                           "Hello!.\n Is this awesome or what?",
##                           @["foo@gmail.com"])
##   let smtpConn = newSmtp(useSsl = true, debug=true)
##   smtpConn.connect("smtp.gmail.com", Port 465)
##   smtpConn.auth("username", "password")
##   smtpConn.sendmail("username@gmail.com", @["foo@gmail.com"], $msg)
##
##
## Example for startTls use:
##
##
## .. code-block:: Nim
##   var msg = createMessage("Hello from Nim's SMTP",
##                           "Hello!.\n Is this awesome or what?",
##                           @["foo@gmail.com"])
##   let smtpConn = newSmtp(debug=true)
##   smtpConn.connect("smtp.mailtrap.io", Port 2525)
##   smtpConn.startTls()
##   smtpConn.auth("username", "password")
##   smtpConn.sendmail("username@gmail.com", @["foo@gmail.com"], $msg)
##
##
## For SSL support this module relies on OpenSSL. If you want to
## enable SSL, compile with `-d:ssl`.

import net, strutils, strtabs, base64, options, sequtils, strformat
import asyncnet, asyncdispatch

when defined(nimPreviewSlimSystem):
  import std/assertions

export Port

type
  Message* = object
    msgTo: seq[Email]
    msgCc: seq[Email]
    msgBcc: seq[Email]
    msgReplyTo: seq[Email]
    msgSender: Email
    msgSubject: string
    msgOtherHeaders: StringTableRef
    msgBody: string

  Email* = object
    name: string
    address*: string

  ReplyError* = object of IOError

  SmtpBase[SocketType] = ref object
    sock: SocketType
    address: string
    debug: bool

  Smtp* = SmtpBase[Socket]
  AsyncSmtp* = SmtpBase[AsyncSocket]

const nl = "\c\L"

proc sender*(msg: Message): Email =
  msg.msgSender

proc recipients*(msg: Message): seq[Email] =
  ## Retrieves all recipients of the message, which are all recipients defined for to, cc and bcc
  return msg.msgTo & msg.msgCc & msg.msgBcc

proc containsNewline(str: string): bool =
  str.contains({'\c', '\L'})

proc containsNewline(xs: seq[string]): bool =
  for x in xs:
    if x.containsNewline():
      return true

proc createEmail*(address: string, name: string = ""): Email =
  ## Creates a new email address
  ## 
  ## You need to make sure that `address` and `name` (if specified) do not contain any newline characters. 
  ## Failing to do so will raise `AssertionDefect`.
  doAssert(
    not address.containsNewline(), "'address' shouldn't contain any newline characters"
  )
  if (name != ""):
    doAssert(
      not name.containsNewline(), "'name' shouldn't contain any newline characters"
    )

  result.address = address
  result.name = name

proc toEmail(value: string | Email): Email =
  when typeof(value) is string:
    createEmail(value)
  else:
    value

proc createMessage*[T: Email | string](
    mSubject, mBody: string,
    sender: T,
    mTo: seq[T] = @[],
    mCc: seq[T] = @[],
    mBcc: seq[T] = @[],
    mReplyTo: seq[T] = @[],
    otherHeaders: openArray[tuple[name, value: string]] = @[],
): Message =
  ## Creates a new MIME compliant message.
  ##
  ## You need to make sure that `mSubject` does not contain any newline characters. 
  ## Failing to do so will raise `AssertionDefect`.
  doAssert(
    not mSubject.containsNewline(),
    "'mSubject' shouldn't contain any newline characters",
  )

  let senderMail = sender.toEmail()

  result = Message(msgSubject: mSubject,
    msgBody: mBody,
    msgTo: mTo.mapIt(toEmail(it)),
    msgCc: mCc.mapIt(toEmail(it)),
    msgBcc: mBcc.mapIt(toEmail(it)),
    msgReplyTo: mReplyTo.mapIt(toEmail(it)),
    msgSender: senderMail,
    msgOtherHeaders: newStringTable())
  for n, v in items(otherHeaders):
    result.msgOtherHeaders[n] = v

proc createMessage*(mSubject, mBody: string, mTo, mCc: seq[string],
                otherHeaders: openArray[tuple[name, value: string]]): Message {.deprecated: "use `createMessage` overloads with a `sender`".} =
  ## Creates a new MIME compliant message.
  ##
  ## You need to make sure that `mSubject`, `mTo` and `mCc` don't contain
  ## any newline characters. Failing to do so will raise `AssertionDefect`.
  doAssert(not mSubject.contains({'\c', '\L'}),
           "'mSubject' shouldn't contain any newline characters")
  doAssert(not (mTo.containsNewline() or mCc.containsNewline()),
           "'mTo' and 'mCc' shouldn't contain any newline characters")

  result.msgTo = mTo.mapIt(toEmail(it))
  result.msgCc = mCc.mapIt(toEmail(it))
  result.msgSubject = mSubject
  result.msgBody = mBody
  result.msgOtherHeaders = newStringTable()
  for n, v in items(otherHeaders):
    result.msgOtherHeaders[n] = v

proc createMessage*(mSubject, mBody: string, mTo,
                    mCc: seq[string] = @[]): Message {.deprecated: "use `createMessage` overloads with a `sender`".} =
  ## Alternate version of the above.
  ##
  ## You need to make sure that `mSubject`, `mTo` and `mCc` don't contain
  ## any newline characters. Failing to do so will raise `AssertionDefect`.
  doAssert(not mSubject.contains({'\c', '\L'}),
           "'mSubject' shouldn't contain any newline characters")
  doAssert(not (mTo.containsNewline() or mCc.containsNewline()),
           "'mTo' and 'mCc' shouldn't contain any newline characters")
  result.msgTo = mTo.mapIt(toEmail(it))
  result.msgCc = mCc.mapIt(toEmail(it))
  result.msgSubject = mSubject
  result.msgBody = mBody
  result.msgOtherHeaders = newStringTable()

proc `$`*(email: Email): string =
  ## stringify for `Email`.
  if email.name != "":
    result = fmt""""{email.name}" <{email.address}>"""
  else:
    result = email.address

proc toSmtpField(name: string, value: string): string =
  fmt"{name}: {value}{nl}"

proc `$`*(msg: Message): string =
  ## stringify for `Message`.
  result = ""

  let sender = $msg.msgSender
  result.add(toSmtpField("From", sender))
  if msg.msgTo.len() > 0:
    result.add(toSmtpField("To", msg.msgTo.join(", ")))
  if msg.msgReplyTo.len() > 0:
    result.add(toSmtpField("Reply-To", msg.msgReplyTo.join(", ")))
  if msg.msgCc.len() > 0:
    result.add(toSmtpField("Cc", msg.msgCc.join(", ")))
  if msg.msgBcc.len() > 0:
    result.add(toSmtpField("Bcc", msg.msgBcc.join(", ")))

  result.add(toSmtpField("Subject", msg.msgSubject))
  for key, value in pairs(msg.msgOtherHeaders):
    result.add(toSmtpField(key, value))

  result.add(nl)
  result.add(msg.msgBody)

proc debugSend*(smtp: Smtp | AsyncSmtp, cmd: string) {.multisync.} =
  ## Sends `cmd` on the socket connected to the SMTP server.
  ##
  ## If the `smtp` object was created with `debug` enabled,
  ## debugSend will invoke `echo("C:" & cmd)` before sending.
  ##
  ## This is a lower level proc and not something that you typically
  ## would need to call when using this module. One exception to
  ## this is if you are implementing any
  ## `SMTP extensions<https://en.wikipedia.org/wiki/Extended_SMTP>`_.

  if smtp.debug:
    echo("C:" & cmd)
  await smtp.sock.send(cmd)

proc debugRecv*(smtp: Smtp | AsyncSmtp): Future[string] {.multisync.} =
  ## Receives a line of data from the socket connected to the
  ## SMTP server.
  ##
  ## If the `smtp` object was created with `debug` enabled,
  ## debugRecv will invoke `echo("S:" & result.string)` after
  ## the data is received.
  ##
  ## This is a lower level proc and not something that you typically
  ## would need to call when using this module. One exception to
  ## this is if you are implementing any
  ## `SMTP extensions<https://en.wikipedia.org/wiki/Extended_SMTP>`_.
  ##
  ## See `checkReply(reply)<#checkReply,AsyncSmtp,string>`_.
  result = await smtp.sock.recvLine()
  if smtp.debug:
    echo("S:" & result)

proc quitExcpt(smtp: Smtp, msg: string) =
  smtp.debugSend("QUIT")
  raise newException(ReplyError, msg)

const compiledWithSsl = defined(ssl)

when not defined(ssl):
  let defaultSSLContext: SslContext = nil
else:
  var defaultSSLContext {.threadvar.}: SslContext

  proc getSSLContext(): SslContext =
    if defaultSSLContext == nil:
      defaultSSLContext = newContext(verifyMode = CVerifyNone)
    result = defaultSSLContext

proc newSmtp*(useSsl = false, debug = false, sslContext: SslContext = nil): Smtp =
  ## Creates a new `Smtp` instance.
  new result
  result.debug = debug
  result.sock = newSocket()
  if useSsl:
    when compiledWithSsl:
      if sslContext == nil:
        getSSLContext().wrapSocket(result.sock)
      else:
        sslContext.wrapSocket(result.sock)
    else:
      raise newException(AssertionDefect, "SMTP module compiled without SSL support")

proc newAsyncSmtp*(useSsl = false, debug = false, sslContext: SslContext = nil): AsyncSmtp =
  ## Creates a new `AsyncSmtp` instance.
  new result
  result.debug = debug
  result.sock = newAsyncSocket()
  if useSsl:
    when compiledWithSsl:
      if sslContext == nil:
        getSSLContext().wrapSocket(result.sock)
      else:
        sslContext.wrapSocket(result.sock)
    else:
      raise newException(AssertionDefect, "SMTP module compiled without SSL support")

proc quitExcpt(smtp: AsyncSmtp, msg: string): Future[void] =
  var retFuture = newFuture[void]()
  var sendFut = smtp.debugSend("QUIT")
  sendFut.callback = proc() =
    retFuture.fail(newException(ReplyError, msg))
  return retFuture

proc checkReply*(smtp: Smtp | AsyncSmtp, reply: string) {.multisync.} =
  ## Calls `debugRecv<#debugRecv,AsyncSmtp>`_ and checks that the received
  ## data starts with `reply`. If the received data does not start
  ## with `reply`, then a `QUIT` command will be sent to the SMTP
  ## server and a `ReplyError` exception will be raised.
  ##
  ## This is a lower level proc and not something that you typically
  ## would need to call when using this module. One exception to
  ## this is if you are implementing any
  ## `SMTP extensions<https://en.wikipedia.org/wiki/Extended_SMTP>`_.
  var line = await smtp.debugRecv()
  if not line.startsWith(reply):
    await quitExcpt(smtp, "Expected " & reply & " reply, got: " & line)

proc helo*(smtp: Smtp | AsyncSmtp) {.multisync.} =
  # Sends the HELO request
  await smtp.debugSend("HELO " & smtp.address & nl)
  await smtp.checkReply("250")

proc recvEhlo(smtp: Smtp | AsyncSmtp): Future[bool] {.multisync.} =
  ## Skips "250-" lines, read until "250 " found.
  ## Return `true` if server supports `EHLO`, false otherwise.
  while true:
    var line = await smtp.sock.recvLine()
    if smtp.debug:
      echo("S:" & line)
    if line.startsWith("250-"):
      continue
    elif line.startsWith("250 "):
      return true # last line
    else:
      return false

proc ehlo*(smtp: Smtp | AsyncSmtp): Future[bool] {.multisync.} =
  ## Sends EHLO request.
  await smtp.debugSend("EHLO " & smtp.address & nl)
  return await smtp.recvEhlo()

proc connect*(smtp: Smtp | AsyncSmtp, address: string, port: Port) {.multisync.} =
  ## Establishes a connection with a SMTP server.
  ## May fail with ReplyError or with a socket error.
  smtp.address = address
  await smtp.sock.connect(address, port)
  await smtp.checkReply("220")
  let speaksEsmtp = await smtp.ehlo()
  if not speaksEsmtp:
    await smtp.helo()

proc startTls*(smtp: Smtp | AsyncSmtp, sslContext: SslContext = nil) {.multisync.} =
  ## Put the SMTP connection in TLS (Transport Layer Security) mode.
  ## May fail with ReplyError
  await smtp.debugSend("STARTTLS\c\L")
  await smtp.checkReply("220")
  when compiledWithSsl:
    if sslContext == nil:
      getSSLContext().wrapConnectedSocket(smtp.sock, handshakeAsClient)
    else:
      sslContext.wrapConnectedSocket(smtp.sock, handshakeAsClient)
    let speaksEsmtp = await smtp.ehlo()
    if not speaksEsmtp:
      await smtp.helo()
  else:
    raise newException(AssertionDefect, "SMTP module compiled without SSL support")

proc auth*(smtp: Smtp | AsyncSmtp, username, password: string) {.multisync.} =
  ## Sends an AUTH command to the server to login as the `username`
  ## using `password`.
  ## May fail with ReplyError.

  await smtp.debugSend("AUTH LOGIN\c\L")
  await smtp.checkReply("334")
    # TODO: Check whether it's asking for the "Username:"
    # i.e "334 VXNlcm5hbWU6"
  await smtp.debugSend(encode(username) & nl)
  await smtp.checkReply("334") # TODO: Same as above, only "Password:" (I think?)

  await smtp.debugSend(encode(password) & nl)
  await smtp.checkReply("235") # Check whether the authentication was successful.

proc sendMail*(
    smtp: Smtp | AsyncSmtp, fromAddr: string, toAddrs: seq[string], msg: string
) {.multisync.} =
  ## Sends `msg` from `fromAddr` to the addresses specified in `toAddrs`.
  ## Messages may be formed using `createMessage` by converting the
  ## Message into a string.
  ##
  ## You need to make sure that `fromAddr` and `toAddrs` don't contain
  ## any newline characters. Failing to do so will raise `AssertionDefect`.
  doAssert(
    not (toAddrs.containsNewline() or fromAddr.containsNewline()),
    "'toAddrs' and 'fromAddr' shouldn't contain any newline characters",
  )

  await smtp.debugSend(fmt"""MAIL FROM:<{fromAddr}>{nl}""")
  await smtp.checkReply("250")
  for address in items(toAddrs):
    await smtp.debugSend(fmt"""RCPT TO:<{address}>{nl}""")
    await smtp.checkReply("250")

  # Send the message
  await smtp.debugSend("DATA" & nl)
  await smtp.checkReply("354")
  await smtp.sock.send(msg & nl)
  await smtp.debugSend("." & nl)
  await smtp.checkReply("250")

proc sendMail*(smtp: Smtp | AsyncSmtp, msg: Message) {.multisync.} =
  ## Convenience utility for sending messages.
  ## Sends `msg` from the sender as specified in `sender <#sender,Message>`_
  ## and the recipients as specified in `recipients <#recipients,Message>`_.
  ## 
  ## See also:
  ## * `sendMail <#sendMail,Smtp,string,seq[string],string>`_
  let senderAddress = msg.sender().address
  let recipientAddresses = msg.recipients().mapIt(it.address)
  let msgBody = $msg
  await smtp.sendMail(senderAddress, recipientAddresses, msgBody)

proc close*(smtp: Smtp | AsyncSmtp) {.multisync.} =
  ## Disconnects from the SMTP server and closes the socket.
  await smtp.debugSend("QUIT\c\L")
  smtp.sock.close()
