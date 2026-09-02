// The generic step bridge.
//
// An embedded document cannot be driven from Typst, but it can be told, on
// every step, what to do. The core knows nothing about what is inside: it
// collects named jobs per slide, hands them to the runtime as JSON, and the
// runtime posts them into the frame whose element carries that name.
//
// A companion package builds the document with `embed(html: …, bridge: name)`
// and pushes its jobs here. `geogebra.typ` does exactly that and nothing more,
// although it now lives in this package -- the bridge stays the only way in,
// so a foreign package goes the same road as the one next door. The same
// mechanism carries anything else that lives in an iframe.

#import "internal.typ": (bridge-jobs, name-of, selector, slide-counter,
                         step-cursor)

/// Send a job to a bridged element.
///
/// - `target` is the `bridge` name given to `embed`.
/// - `at` is a step selector, resolved exactly as for `anim`: `auto` takes
///   the next free step, an integer counts as "from this step on". The default
///   is `"1-"`, because most jobs set the document up on slide entry.
///
///   A job does not move the step cursor: an applet's tween and the bullet
///   explaining it usually belong on the *same* step, not one after the other.
/// - `payload` is a dictionary. Its meaning is entirely up to the document on
///   the other side. The core passes it through unread.
///
/// When paging backwards or entering a slide the runtime replays the whole run
/// from its start with a `reset` flag, so jobs should be repeatable.
///
/// *The document has to announce itself.* Nothing is sent to a frame that has
/// not said hello. The runtime marks a frame live only after receiving
///
/// ```js
/// parent.postMessage({ typstage: 1, ready: 1 }, "*");
/// ```
///
/// from it. Both fields are needed: the runtime drops every message without
/// `typstage: 1` before it ever looks at `ready`. Miss this and the jobs simply
/// never arrive. There is no error, the applet just sits there.
#let bridge-job(target, payload, at: "1-") = {
  // `payload` wird ungelesen durchgereicht -- aber nicht ungeprueft. Ohne das
  // hier brach ein `bridge-job(<a>, "hallo")` mit "cannot add dictionary and
  // string" aus dem Inneren ab, und schlimmer: ein `payload` mit den
  // Schluesseln `t` oder `at` ueberschrieb Ziel oder Selektor, weil bei `+`
  // der rechte Operand gewinnt. Der Auftrag ging dann kaputt los, ohne ein
  // Wort. Fuer ein Fremdpaket, dem die Doku ausdruecklich freie Hand bei
  // `payload` zusagt, war das eine Falle.
  assert(type(payload) == dictionary, message:
    "typstage: bridge-job() takes a dictionary as its payload, not "
    + str(type(payload)) + ".")
  assert("t" not in payload and "at" not in payload, message:
    "typstage: bridge-job() reserves the payload keys `t` and `at` for the "
    + "target and the step; a payload carrying them would overwrite the job "
    + "itself. Rename them.")
  context {
    // Der Zeiger wird *nicht* vorgerueckt, und das ist Absicht: die Tween
    // eines Applets und der Stichpunkt, der sie erklaert, gehoeren auf
    // denselben Schritt. `auto` heisst darum "der naechste freie", nicht "und
    // dann ist er verbraucht". Vorher stand hier ein `step-cursor.step()`,
    // das dem Docstring darueber widersprach.
    let sel = if at == auto {
      str(step-cursor.get().first() + 1) + "-"
    } else { selector(at) }
    bridge-jobs.update(a => a + ((t: name-of(target), at: sel) + payload,))
  }
}

/// The bridge names on the current slide, in the order they appear.
///
/// This is how a companion package can leave the applet unnamed: with exactly
/// one bridged element on the slide there is nothing to choose between.
///
/// Must be called in a context. Duplicates are dropped, because a tracked element is
/// laid out twice, once in the background and once as its sprite, so it
/// announces itself twice.
#let bridge-targets() = {
  let n = slide-counter.get().first()
  query(<typstage-bridge-target>)
    .map(m => m.value)
    .filter(v => v.slide == n)
    .map(v => v.name)
    .dedup()
}
