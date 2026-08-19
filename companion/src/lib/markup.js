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

// Renders one known ability name (no brackets) as a Wowhead link when
// resolved, or an inert gold span when not. Shared by the "[Name]" markup
// path below and by any structured field (e.g. overview.interrupts[].spell)
// that is already known to be an ability name and so skips markup brackets
// entirely. `abilities` is a Map<name, spellID | null> (see
// content.js#loadAbilities).
export function renderKnownAbility(name, abilities) {
  if (typeof name !== "string" || !name) return "";
  const label = escapeHtml(name);
  const spellID = abilities?.get(name);
  // Bracketed + link-blue means "this has a real tooltip", matching the addon.
  // An unresolved ability keeps plain gold and no brackets, because there is
  // nothing to hover — the two states must stay tellable apart.
  return typeof spellID === "number"
    ? `<a href="https://www.wowhead.com/spell=${spellID}" target="_blank" rel="noopener" class="ability-link">[${label}]</a>`
    : `<span class="ability-unresolved">${label}</span>`;
}

export function renderAbilityMarkup(text, abilities) {
  if (typeof text !== "string" || !text) return "";
  const re = /\[([^[\]]+)\]/g;
  let out = "";
  let last = 0;
  let m;
  while ((m = re.exec(text))) {
    out += escapeHtml(text.slice(last, m.index));
    out += renderKnownAbility(m[1], abilities);
    last = re.lastIndex;
  }
  out += escapeHtml(text.slice(last));
  return out;
}
