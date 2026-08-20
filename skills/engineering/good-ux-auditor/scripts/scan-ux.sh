#!/usr/bin/env bash
# Good UX Auditor — first-pass signal scanner.
#
# Generates LEADS, not verdicts. Every hit must be opened and read in context;
# every miss proves nothing. Use alongside reading the actual components.
#
# Usage: ./scan-ux.sh <path> [--json]

set -uo pipefail

ROOT="${1:-.}"
[ -d "$ROOT" ] || { echo "error: '$ROOT' is not a directory" >&2; exit 1; }

if command -v rg >/dev/null 2>&1; then
  SEARCH() { rg -n --no-heading -S "$1" "$ROOT" \
    -g '!**/node_modules/**' -g '!**/.git/**' -g '!**/dist/**' -g '!**/build/**' \
    -g '!**/.next/**' -g '!**/coverage/**' -g '!**/*.min.*' \
    -g '*.{js,jsx,ts,tsx,vue,svelte,astro,html}' 2>/dev/null
  }
else
  echo "note: ripgrep (rg) not found, falling back to grep — results will be noisier" >&2
  SEARCH() { grep -rnE --binary-files=without-match \
    --exclude-dir={node_modules,.git,dist,build,.next,coverage} \
    --include=\*.{js,jsx,ts,tsx,vue,svelte,astro,html} \
    "$1" "$ROOT" 2>/dev/null
  }
fi

section() {
  local id="$1" title="$2" pattern="$3" note="$4"
  local out count
  out="$(SEARCH "$pattern")"
  count="$(printf '%s' "$out" | grep -c . || true)"
  printf '\n=== %s — %s ===\n' "$id" "$title"
  printf '%s\n' "$note"
  if [ "$count" -eq 0 ]; then
    printf -- '  (no hits)\n'
  else
    printf -- '  %s hit(s)\n\n' "$count"
    printf '%s\n' "$out" | head -40
    [ "$count" -gt 40 ] && printf -- '  ... (%s more)\n' "$((count - 40))"
  fi
}

printf '################################################\n'
printf '# Good UX Audit — signal scan\n'
printf '# Target: %s\n' "$ROOT"
printf '# Leads only. Open every hit and read it in context.\n'
printf '################################################\n'

# ---------- H5: error message anatomy ----------
section "H5" "Silent failures (empty or log-only catch)" \
  'catch\s*(\([^)]*\))?\s*\{\s*(\}|//|console\.(log|error|warn)\([^)]*\)\s*;?\s*\})|\.catch\(\s*\(?\w*\)?\s*=>\s*\{?\s*\}?\s*\)' \
  'The failure she calls the worst kind: user clicks, nothing happens, no message.'

section "H5" "Vague catch-all error copy" \
  '"(Something went wrong|An error occurred|An error has occurred|Error occurred|Oops[!.]?|Failed|Unknown error)"|'"'"'(Something went wrong|An error occurred|Oops[!.]?|Failed)'"'"'' \
  'Needs what happened / why / what next. Check each for a cause and an action.'

section "H5" "Raw backend text surfaced to UI" \
  'setError\((err|error|e)\.message\)|\{(err|error|e)\.(message|stack)\}|toast\.error\((err|error|e)\.message\)' \
  'Unreadable to users, and she flags it as a possible security leak.'

# ---------- H7: error placement ----------
section "H7" "Toasts on high-stakes failures" \
  'toast\.error|toast\.danger|notify\.error|message\.error' \
  'Cross-check: is any of these on a payment, auth, permission, or delete path? Those need inline or modal.'

# ---------- H1/H2/H3/H4: loading ----------
section "H1" "Fetch sites (cross-check each for all four states)" \
  'useQuery\(|useSWR\(|useEffect\(\s*\(\)\s*=>\s*\{[^}]*fetch\(|await\s+fetch\(|axios\.(get|post|put|patch|delete)\(' \
  'Every one of these needs loading + error + empty branches, not just success.'

section "H9" "Promise.all gating a render" \
  'Promise\.all\(' \
  'One rejection kills the whole view. Prefer allSettled or per-section queries.'

section "H3" "Loader inventory (is each the right type for its job?)" \
  '<(Spinner|Loader|Loading|CircularProgress|ActivityIndicator|Skeleton|ProgressBar|Progress)\b|animate-spin|className="[^"]*\bspinner\b' \
  'Skeleton = page/section. Progress bar = known duration. Inline spinner = one control.'

section "H3" "Uploads/downloads — should use a progress bar" \
  'onUploadProgress|upload\.onprogress|XMLHttpRequest|createReadStream|FormData\(' \
  'Her named anti-pattern: a spinner on a file upload reads as stuck.'

section "H4" "Spinner delay guards (absence is the signal)" \
  'setTimeout\([^,]+,\s*(2[0-9][0-9]|3[0-9][0-9]|4[0-9][0-9]|500)\s*\)|useDebounce|delayMs|minimumLoading|showAfter' \
  'Sub-1s spinners flash and make things feel slower. Few or no hits here = likely missing guards.'

# ---------- H8: empty states ----------
section "H8" "List renders (check for a zero-length branch)" \
  '\.map\(\s*\(?\w+' \
  'Noisy by nature. Filter to list/collection renders in the surfaces you are auditing.'

section "H8" "Empty-state copy (does each have a CTA?)" \
  '(No|no) [a-z]+ (yet|found)|>\s*No [A-Za-z ]+<|"No [a-z ]+|Nothing (here|to show|yet)|You have no |No results|is empty' \
  'Must say why it is empty and what to do next. Echo the query on empty search.'

# ---------- H10: section ownership ----------
section "H10" "Retry affordances (absence is the signal)" \
  'onClick=\{[^}]*(refetch|retry|reload|mutate)|>\s*(Try again|Retry|Reload)\s*<' \
  'Each failing section needs its own error message AND its own retry button.'

section "H10" "Error boundaries" \
  'ErrorBoundary|componentDidCatch|getDerivedStateFromError|error\.(tsx|jsx|js)$' \
  'One route-level boundary is not enough — sections should fail independently.'

# ---------- H11: success states ----------
section "H11" "Success feedback" \
  'toast\.success|onSuccess\s*[:(]|setSuccess\(|confetti' \
  'Compare against the mutation count. Money/auth/destructive paths must confirm.'

section "H11" "Mutations (cross-check each has a success branch)" \
  'useMutation\(|onSubmit\s*[=:]|handleSubmit|action=\{' \
  'Her flight-booking test: paid, clicked confirm, nothing happened.'

# ---------- H6: forms ----------
section "H6" "Disabled submit (is what is missing made obvious?)" \
  'disabled=\{[^}]*(!?(is)?[Vv]alid|!?dirty|errors|!?canSubmit)' \
  'A greyed-out button with no explanation is worse than no gate at all.'

section "H6" "Validation timing" \
  'mode:\s*'"'"'(onBlur|onChange|onTouched|all)'"'"'|onBlur=\{|validateOn' \
  'Inline on blur. Submit-only validation forces a scroll back up to fix.'

section "H6" "maxLength without a counter" \
  'maxLength=|maxlength=' \
  'Each of these needs a visible remaining-characters count.'

section "H6" "Strict format regexes (should normalize instead)" \
  'replace\(/\[\^0-9\]/|\^\\\(\?\[0-9\]\{3\}|test\(\s*(phone|zip|postal|card)|pattern="' \
  'Accept dashes, parens, spaces — normalize on the backend.'

# ---------- H13: device and locale ----------
section "H13" "Physical direction properties (RTL risk)" \
  'margin-(left|right)|padding-(left|right)|(margin|padding)(Left|Right)|border-(left|right)|textAlign:\s*.(left|right)|text-align:\s*(left|right)|\b(left|right):\s*[0-9]|\b(ml|mr|pl|pr|left|right)-[0-9]' \
  'Prefer logical properties (inline-start/end) if RTL locales are in scope. Covers CSS and JSX camelCase.'

section "H13" "RTL / direction handling" \
  'dir=|direction:\s*rtl|rtl|useRtl|I18nManager' \
  'No hits plus international users = an H13 gap.'

# ---------- H14/H15: choice load ----------
# H14 needs occurrence counts per file, not line counts — several fields often
# share one line. Handled separately from section().
printf '\n=== H14 — Form field density (per file; >7 in one form → split) ===\n'
printf 'Her threshold: over seven fields, multi-page can lift conversion substantially.\n'
FIELD_RE='<(input|Input|TextField|TextInput|Select|select|Textarea|textarea|Checkbox|Radio|DatePicker)\b'
if command -v rg >/dev/null 2>&1; then
  FIELD_COUNTS="$(rg -o --no-heading -S "$FIELD_RE" "$ROOT" \
    -g '!**/node_modules/**' -g '!**/.git/**' -g '!**/dist/**' -g '!**/build/**' \
    -g '!**/.next/**' -g '!**/coverage/**' -g '!**/*.min.*' \
    -g '*.{js,jsx,ts,tsx,vue,svelte,astro,html}' 2>/dev/null \
    | cut -d: -f1 | sort | uniq -c | sort -rn)"
else
  FIELD_COUNTS="$(grep -roE --binary-files=without-match \
    --exclude-dir={node_modules,.git,dist,build,.next,coverage} \
    --include=\*.{js,jsx,ts,tsx,vue,svelte,astro,html} \
    "$FIELD_RE" "$ROOT" 2>/dev/null | cut -d: -f1 | sort | uniq -c | sort -rn)"
fi
if [ -z "$FIELD_COUNTS" ]; then
  printf -- '  (no form fields found)\n'
else
  printf -- '  count  file    (>7 in a single form is the trigger)\n'
  printf '%s\n' "$FIELD_COUNTS" | head -25 | while read -r n f; do
    flag=""; [ "$n" -gt 7 ] && flag="   <-- OVER THRESHOLD"
    printf -- '  %5s  %s%s\n' "$n" "$f" "$flag"
  done
  printf -- '\n  Note: per-file counts. Confirm the fields are in ONE form before flagging.\n'
fi

section "H15" "Progressive disclosure affordances" \
  'CommandPalette|cmdk|Combobox|Accordion|Collapsible|Disclosure|showAdvanced|isExpanded|Popover' \
  'Feature-dense surfaces with no hits here are likely showing everything at once.'

printf '\n################################################\n'
printf '# Scan complete.\n'
printf '#\n'
printf '# NOT COVERED BY THIS SCAN — judge these by reading the\n'
printf '# code and screenshots; the scanner is blind to them:\n'
printf '#   H2  loader presence vs. perceived brokenness\n'
printf '#   H12 Jakob'"'"'s Law — conventional control placement\n'
printf '#   H16 Tesler'"'"'s Law — who absorbs inherent complexity\n'
printf '#\n'
printf '# Next: open every hit in context, then fill in the H1\n'
printf '# four-state matrix per screen. Grep cannot see what\n'
printf '# renders at runtime — exercise the unhappy paths too:\n'
printf '#   submit an empty form / submit an invalid email /\n'
printf '#   kill the network and reload / load as a new account\n'
printf '################################################\n'
