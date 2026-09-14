
/// Create a time item.
///
/// - body (content): The time body.
#let time(body) = {
  (kind: "time", body: body)
}

/// Create a message item.
///
/// - side: The message side (left | right).
/// - user: The message sender.
/// - body (content): The message body.
/// - time (content): The time the message is sent, or will be sent.
/// - merge (bool): If this message will be merged with the previous message
#let message(side, user, body, time: none, merge: false) = {
  (
    kind: "message",
    side: side,
    user: user,
    body: body,
    time: time,
    merge: merge,
  )
}

/// Create a free message item without specific user or side.
///
/// - body (content): The message body.
/// - time (content): The time the message is sent, or will be sent.
/// - merge (bool): If this message will be merged with the previous message
#let free-message(body, time: none, merge: false) = {
  (
    kind: "message",
    body: body,
    time: time,
    merge: merge,
  )
}

/// Create a plain item. Different from `message`, it does not have padding.
///
/// - side: The image side (left | right).
/// - user: The message sender.
/// - body (content): The image body.
/// - name (content): The name of sender.
/// - avatar (content): The avatar of sender.
#let plain(side, user, body) = {
  (kind: "plain", side: side, user: user, body: body)
}

/// Create a user profile.
///
/// - name (content): The user's display name.
/// - avatar (content): The user's avatar image or element.
/// - title (content): Optional title or role badge.
/// -> dictionary: User profile dictionary
#let user(name: none, avatar: none, badge: none) = {
  (
    name: name,
    avatar: avatar,
    badge: badge,
  )
}

/// Apply a user and side to multiple messages for convenience.
///
/// This function takes a side (left/right), a user, and multiple message items,
/// and applies the user and side to all message items in the collection.
///
/// - side: The message side (left | right).
/// - user: The message sender to apply to all messages.
/// - messages: Variable arguments of message items.
/// -> array: Array of messages with user and side applied
#let with-side-user(side, user, ..messages) = {
  messages
    .pos()
    .map(msg => if msg.kind == "message" {
      msg.side = side
      msg.user = user
      msg
    } else {
      msg
    })
}
