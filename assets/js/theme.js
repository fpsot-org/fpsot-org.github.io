/* Colour-scheme toggle: system → light → dark. Vanilla JS, no dependencies.
   Adapted from sitenetsoft.org. The choice is saved in localStorage
   "fpsot-color-scheme". The small inline script in each page's <head> applies
   the saved value before first paint; this file only wires up the button.
   Without JavaScript the button stays hidden and the site follows the OS. */
(function () {
  "use strict";

  var KEY = "fpsot-color-scheme";
  var ORDER = ["system", "light", "dark"];

  var button = document.getElementById("theme-toggle");
  if (!button) return;

  var fr = document.documentElement.lang === "fr";
  var NAMES = fr
    ? { system: "système", light: "clair", dark: "sombre" }
    : { system: "system", light: "light", dark: "dark" };

  function stored() {
    var value = null;
    try { value = localStorage.getItem(KEY); } catch (e) { /* storage blocked */ }
    return value === "light" || value === "dark" ? value : "system";
  }

  function save(scheme) {
    try { localStorage.setItem(KEY, scheme); } catch (e) { /* storage blocked */ }
  }

  function apply(scheme) {
    if (scheme === "system") {
      delete document.documentElement.dataset.theme;
    } else {
      document.documentElement.dataset.theme = scheme;
    }
    var next = ORDER[(ORDER.indexOf(scheme) + 1) % ORDER.length];
    var label = fr
      ? "Thème : " + NAMES[scheme] + ". Passer au thème " + NAMES[next] + "."
      : "Color scheme: " + NAMES[scheme] + ". Switch to " + NAMES[next] + ".";
    button.setAttribute("aria-label", label);
    button.title = fr ? "Thème : " + NAMES[scheme] : "Color scheme: " + NAMES[scheme];
  }

  var current = stored();

  button.addEventListener("click", function () {
    current = ORDER[(ORDER.indexOf(current) + 1) % ORDER.length];
    save(current);
    apply(current);
  });

  apply(current);
  button.hidden = false;
})();
