/*
 * Client-side search. ~1.5 KB, no library.
 *
 * The index is fetched on first interaction rather than on page load, so
 * arriving at the page costs nothing extra. Scoring is deliberately simple:
 * a title match outranks a category match, which outranks a tag or standfirst
 * match. Every term in the query must match something.
 */
(function () {
  "use strict";

  var input = document.getElementById("search-input");
  var list = document.getElementById("search-results");
  var status = document.querySelector(".search__status");
  if (!input || !list) return;

  var index = null;
  var loading = null;

  function load() {
    if (loading) return loading;
    loading = fetch(document.body.dataset.searchIndex || "/search.json")
      .then(function (r) { return r.json(); })
      .then(function (data) { index = data; return data; })
      .catch(function () {
        status.textContent = "Die Suche konnte nicht geladen werden. Bitte lade die Seite neu.";
        return [];
      });
    return loading;
  }

  function normalise(s) {
    return s
      .toLowerCase()
      .replace(/ä/g, "ae").replace(/ö/g, "oe").replace(/ü/g, "ue").replace(/ß/g, "ss");
  }

  function score(entry, terms) {
    var title = normalise(entry.t);
    var cat = normalise(entry.c);
    var rest = normalise(entry.g + " " + entry.d);
    var total = 0;

    for (var i = 0; i < terms.length; i++) {
      var term = terms[i];
      var hit = 0;
      if (title.indexOf(term) > -1) hit = title.indexOf(term) === 0 ? 12 : 8;
      else if (cat.indexOf(term) > -1) hit = 5;
      else if (rest.indexOf(term) > -1) hit = 2;
      if (!hit) return 0;            // every term must match something
      total += hit;
    }
    return total;
  }

  function render(results, query) {
    list.innerHTML = "";

    if (!query) {
      status.textContent = "";
      return;
    }
    if (!results.length) {
      status.textContent = 'Keine Treffer für „' + query + '".';
      return;
    }

    status.textContent =
      results.length === 1 ? "1 Treffer" : results.length + " Treffer";

    var frag = document.createDocumentFragment();
    results.forEach(function (entry) {
      var li = document.createElement("li");
      li.className = "search__result";

      var a = document.createElement("a");
      a.href = entry.u;
      a.className = "search__result-link";

      if (entry.c) {
        var eyebrow = document.createElement("span");
        eyebrow.className = "search__result-cat";
        eyebrow.textContent = entry.c;
        a.appendChild(eyebrow);
      }

      var h = document.createElement("span");
      h.className = "search__result-title";
      h.textContent = entry.t;
      a.appendChild(h);

      if (entry.d) {
        var p = document.createElement("span");
        p.className = "search__result-excerpt";
        p.textContent = entry.d;
        a.appendChild(p);
      }

      li.appendChild(a);
      frag.appendChild(li);
    });
    list.appendChild(frag);
  }

  function run() {
    var query = input.value.trim();
    if (!query) return render([], "");

    var terms = normalise(query).split(/\s+/).filter(Boolean);
    var results = (index || [])
      .map(function (e) { return { e: e, s: score(e, terms) }; })
      .filter(function (r) { return r.s > 0; })
      .sort(function (a, b) { return b.s - a.s; })
      .map(function (r) { return r.e; });

    render(results, query);
  }

  input.addEventListener("focus", load, { once: true });

  var timer;
  input.addEventListener("input", function () {
    clearTimeout(timer);
    timer = setTimeout(function () {
      load().then(run);
    }, 120);
  });

  // Allow /suche/?q=standesamt to work as a direct link.
  var initial = new URLSearchParams(location.search).get("q");
  if (initial) {
    input.value = initial;
    load().then(run);
  }
})();
