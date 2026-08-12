/* Copy-link button. Revealed only if the browser can actually copy. */
(function () {
  "use strict";
  var btn = document.querySelector("[data-copy-link]");
  if (!btn || !navigator.clipboard) return;

  btn.hidden = false;
  var label = btn.querySelector("[data-copy-label]");
  var original = label.textContent;

  btn.addEventListener("click", function () {
    navigator.clipboard.writeText(btn.getAttribute("data-url")).then(function () {
      label.textContent = "Link kopiert";
      setTimeout(function () { label.textContent = original; }, 2000);
    });
  });
})();
