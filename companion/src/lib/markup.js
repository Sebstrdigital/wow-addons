// Render `[Ability Name]` markup found in playbook prose.
//
// Resolved (abilities.yaml has a spellID) -> link to Wowhead, opens in a new
// tab. Unresolved/unknown -> plain gold text, no link. The brackets
// themselves never reach the output either way.
//
// A plain link is the chosen baseline (see companion CLAUDE.md-adjacent
// notes / task report) rather than pulling in Wowhead's tooltip script —
// keeps the static build free of a third-party runtime dependency and any
// CSP exception it would require, at the cost of no hover tooltip.

function escapeHtml(str) {
  return str
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

// `abilities` is a Map<name, spellID | null> (see content.js#loadAbilities).
export function renderAbilityMarkup(text, abilities) {
  if (typeof text !== "string" || !text) return "";
  const re = /\[([^[\]]+)\]/g;
  let out = "";
  let last = 0;
  let m;
  while ((m = re.exec(text))) {
    out += escapeHtml(text.slice(last, m.index));
    const name = m[1];
    const label = escapeHtml(name);
    const spellID = abilities?.get(name);
    out += typeof spellID === "number"
      ? `<a href="https://www.wowhead.com/spell=${spellID}" target="_blank" rel="noopener" class="ability-link">${label}</a>`
      : `<span class="ability-link">${label}</span>`;
    last = re.lastIndex;
  }
  out += escapeHtml(text.slice(last));
  return out;
}
