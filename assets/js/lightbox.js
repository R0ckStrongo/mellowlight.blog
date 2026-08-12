/*
 * Mellowlight Journal — lightbox
 *
 * A single dark frame around one photograph. No chrome, no counter, no
 * download button, no filmstrip, no captions overlaid on the image (§18, §46).
 *
 * It builds its own list from the buttons already in the page, so there is no
 * separate index to keep in sync and nothing to configure per article.
 *
 * Accessibility: the dialog traps focus while open, returns focus to the
 * thumbnail that opened it, announces itself as a modal, and every control is
 * a real button reachable by keyboard. Arrow keys move, Escape closes.
 */
(function () {
  "use strict";

  var triggers = Array.prototype.slice.call(
    document.querySelectorAll("[data-lightbox]")
  );
  if (!triggers.length) return;

  var index = 0;
  var opener = null;
  var root = null;
  var imgEl = null;

  var reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  function build() {
    root = document.createElement("div");
    root.className = "lightbox";
    root.setAttribute("role", "dialog");
    root.setAttribute("aria-modal", "true");
    root.setAttribute("aria-label", "Bildansicht");
    root.hidden = true;

    root.innerHTML =
      '<button class="lightbox__close" type="button" aria-label="Schließen">' +
      '<svg viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" stroke-width="1.5" aria-hidden="true"><path d="M5 5l14 14M19 5L5 19"/></svg>' +
      "</button>" +
      '<button class="lightbox__nav lightbox__nav--prev" type="button" aria-label="Vorheriges Bild">' +
      '<svg viewBox="0 0 24 24" width="28" height="28" fill="none" stroke="currentColor" stroke-width="1.5" aria-hidden="true"><path d="M15 4L7 12l8 8"/></svg>' +
      "</button>" +
      '<figure class="lightbox__figure"><img class="lightbox__img" alt=""></figure>' +
      '<button class="lightbox__nav lightbox__nav--next" type="button" aria-label="Nächstes Bild">' +
      '<svg viewBox="0 0 24 24" width="28" height="28" fill="none" stroke="currentColor" stroke-width="1.5" aria-hidden="true"><path d="M9 4l8 8-8 8"/></svg>' +
      "</button>";

    document.body.appendChild(root);
    imgEl = root.querySelector(".lightbox__img");

    root.querySelector(".lightbox__close").addEventListener("click", close);
    root.querySelector(".lightbox__nav--prev").addEventListener("click", function () { step(-1); });
    root.querySelector(".lightbox__nav--next").addEventListener("click", function () { step(1); });

    // Clicking the backdrop closes; clicking the photograph does not.
    root.addEventListener("click", function (e) {
      if (e.target === root || e.target.classList.contains("lightbox__figure")) close();
    });

    addSwipe();
  }

  function show(i) {
    var total = triggers.length;
    index = (i + total) % total;                 // wraps in both directions
    var t = triggers[index];

    imgEl.src = t.getAttribute("data-full");
    var srcset = t.getAttribute("data-srcset");
    if (srcset) {
      imgEl.srcset = srcset;
      imgEl.sizes = "100vw";
    } else {
      imgEl.removeAttribute("srcset");
    }
    imgEl.alt = t.getAttribute("data-alt") || "";

    // Reserving the box stops the frame jumping as each photograph loads.
    var w = t.getAttribute("data-width");
    var h = t.getAttribute("data-height");
    if (w && h) {
      imgEl.width = w;
      imgEl.height = h;
    }

    // Warm the neighbours so stepping through feels instant.
    [1, -1].forEach(function (offset) {
      var next = triggers[(index + offset + total) % total];
      if (!next) return;
      var pre = new Image();
      pre.src = next.getAttribute("data-full");
    });
  }

  function open(i, from) {
    if (!root) build();
    opener = from;
    show(i);
    root.hidden = false;
    document.body.classList.add("has-lightbox");
    if (!reduceMotion) root.classList.add("is-entering");
    root.querySelector(".lightbox__close").focus();
    document.addEventListener("keydown", onKey);
  }

  function close() {
    root.hidden = true;
    document.body.classList.remove("has-lightbox");
    root.classList.remove("is-entering");
    document.removeEventListener("keydown", onKey);
    imgEl.removeAttribute("src");
    if (opener) opener.focus();               // focus goes back where it came from
  }

  function step(delta) {
    show(index + delta);
  }

  function onKey(e) {
    switch (e.key) {
      case "Escape":     close(); break;
      case "ArrowLeft":  step(-1); break;
      case "ArrowRight": step(1); break;
      case "Tab":        trapFocus(e); break;
    }
  }

  // Keeps Tab inside the dialog while it is open.
  function trapFocus(e) {
    var focusable = root.querySelectorAll("button");
    var first = focusable[0];
    var last = focusable[focusable.length - 1];

    if (e.shiftKey && document.activeElement === first) {
      e.preventDefault();
      last.focus();
    } else if (!e.shiftKey && document.activeElement === last) {
      e.preventDefault();
      first.focus();
    }
  }

  function addSwipe() {
    var startX = 0;
    var startY = 0;

    root.addEventListener("touchstart", function (e) {
      startX = e.changedTouches[0].clientX;
      startY = e.changedTouches[0].clientY;
    }, { passive: true });

    root.addEventListener("touchend", function (e) {
      var dx = e.changedTouches[0].clientX - startX;
      var dy = e.changedTouches[0].clientY - startY;
      // Horizontal intent only, so scrolling a tall photograph still works.
      if (Math.abs(dx) > 50 && Math.abs(dx) > Math.abs(dy)) {
        step(dx < 0 ? 1 : -1);
      }
    }, { passive: true });
  }

  triggers.forEach(function (trigger, i) {
    trigger.addEventListener("click", function () {
      open(i, trigger);
    });
  });
})();
