#!/usr/bin/env bash
# ============================================================
#  JARVIS Installer — pasang identitas Jarvis (SOUL + AGENTS)
#  ke Hermes / Claude Code / Codex / opencode.
#  Semua identitas syadagentic dibuang; yang dipasang:
#    L1 = SOUL-JARVIS.md   (identitas + aturan eksekusi)
#    L2 = AGENTS-JARVIS.md (routing task → modul)
#    L3 = tools bawaan agent (terminal/file/web) — gak perlu file
#
#  CARA PAKAI:
#    bash jarvis-install.sh              # install ke semua agent terdeteksi
#    bash jarvis-install.sh --revert     # balikin semua dari backup
# ============================================================
set -euo pipefail

GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'; RED=$'\033[0;31m'; CYAN=$'\033[0;36m'; BOLD=$'\033[1m'; NC=$'\033[0m'
info() { echo -e "${CYAN}[i]${NC} $*"; }
ok()   { echo -e "${GREEN}[✓]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*"; }
fail() { echo -e "${RED}[✗]${NC} $*"; exit 1; }

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOUL="$SRC_DIR/SOUL-JARVIS.md"
AGENTS="$SRC_DIR/AGENTS-JARVIS.md"

[ -f "$SOUL" ]   || fail "SOUL-JARVIS.md gak ketemu di $SRC_DIR"
[ -f "$AGENTS" ] || fail "AGENTS-JARVIS.md gak ketemu di $SRC_DIR"

banner() {
  echo ""
  echo "==============================================================="
  echo "   ${BOLD}JARVIS${NC} — Identity Installer (SOUL + AGENTS routing)"
  echo "==============================================================="
  echo ""
}

# ---- Deteksi home Hermes: HERMES_HOME env → ~/.hermes → /opt/data (fallback server) ----
hermes_dir() {
  if [ -n "${HERMES_HOME:-}" ] && [ -f "$HERMES_HOME/config.yaml" ]; then
    echo "$HERMES_HOME"; return
  fi
  if [ -f "$HOME/.hermes/config.yaml" ]; then
    echo "$HOME/.hermes"; return
  fi
  if [ -f /opt/data/config.yaml ]; then
    echo "/opt/data"; return
  fi
  echo ""
}

combine_prompt() {
  # L1 + L2 digabung jadi satu system prompt
  cat "$SOUL"
  echo ""
  echo ""
  cat "$AGENTS"
}

# ---- Hermes ----
install_hermes() {
  local d
  d="$(hermes_dir)"
  if [ -z "$d" ]; then
    warn "Hermes config.yaml gak ketemu (cek HERMES_HOME, /opt/data, ~/.hermes) — skip"
    return
  fi
  if [ ! -f "$d/config.yaml" ]; then
    warn "config.yaml gak ada di $d — skip"
    return
  fi
  cp "$d/config.yaml" "$d/config.yaml.bak-jarvis" 2>/dev/null || true
  combine_prompt > "$d/.jarvis-prompt.tmp"
  python3 - "$d" <<'PYEOF' 2>/dev/null || warn "Hermes config update skip (perlu python3+pyyaml: pip install pyyaml)"
import sys, os
try:
    import yaml
except ImportError:
    sys.exit(1)
d = sys.argv[1]
prompt = open(os.path.join(d, ".jarvis-prompt.tmp"), encoding="utf-8").read()
cfg_path = os.path.join(d, "config.yaml")
cfg = yaml.safe_load(open(cfg_path, encoding="utf-8")) or {}
cfg.setdefault("agent", {})
cfg["agent"]["system_prompt"] = prompt
yaml.safe_dump(cfg, open(cfg_path, "w", encoding="utf-8"), allow_unicode=True)
print("OK")
PYEOF
  rm -f "$d/.jarvis-prompt.tmp"
  ok "Hermes: SOUL+AGENTS jadi system_prompt ($d/config.yaml)"
}

revert_hermes() {
  local d
  d="$(hermes_dir)"
  if [ -n "$d" ] && [ -f "$d/config.yaml.bak-jarvis" ]; then
    cp "$d/config.yaml.bak-jarvis" "$d/config.yaml"
    ok "Hermes: balik dari backup ($d/config.yaml)"
  else
    warn "Hermes: backup gak ada — skip"
  fi
}

# ---- Claude Code (L1+L2 gabung jadi CLAUDE.md, kebaca otomatis) ----
install_claude() {
  command -v claude >/dev/null 2>&1 || { warn "claude gak ada — skip"; return; }
  mkdir -p "$HOME/.claude"
  cp "$HOME/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md.bak-jarvis" 2>/dev/null || true
  combine_prompt > "$HOME/.claude/CLAUDE.md"
  ok "Claude Code: CLAUDE.md di-set"
}
revert_claude() {
  [ -f "$HOME/.claude/CLAUDE.md.bak-jarvis" ] && cp "$HOME/.claude/CLAUDE.md.bak-jarvis" "$HOME/.claude/CLAUDE.md" && ok "Claude: balik dari backup" || warn "Claude: backup gak ada"
}

# ---- Codex ----
install_codex() {
  command -v codex >/dev/null 2>&1 || { warn "codex gak ada — skip"; return; }
  mkdir -p "$HOME/.codex"
  cp "$HOME/.codex/AGENTS.md" "$HOME/.codex/AGENTS.md.bak-jarvis" 2>/dev/null || true
  combine_prompt > "$HOME/.codex/AGENTS.md"
  ok "Codex: AGENTS.md di-set"
}
revert_codex() {
  [ -f "$HOME/.codex/AGENTS.md.bak-jarvis" ] && cp "$HOME/.codex/AGENTS.md.bak-jarvis" "$HOME/.codex/AGENTS.md" && ok "Codex: balik dari backup" || warn "Codex: backup gak ada"
}

# ---- opencode ----
install_opencode() {
  command -v opencode >/dev/null 2>&1 || { warn "opencode gak ada — skip"; return; }
  mkdir -p "$HOME/.config/opencode"
  cp "$HOME/.config/opencode/AGENTS.md" "$HOME/.config/opencode/AGENTS.md.bak-jarvis" 2>/dev/null || true
  combine_prompt > "$HOME/.config/opencode/AGENTS.md"
  ok "opencode: AGENTS.md di-set"
}
revert_opencode() {
  [ -f "$HOME/.config/opencode/AGENTS.md.bak-jarvis" ] && cp "$HOME/.config/opencode/AGENTS.md.bak-jarvis" "$HOME/.config/opencode/AGENTS.md" && ok "opencode: balik dari backup" || warn "opencode: backup gak ada"
}

# ---- Main ----
banner
if [ "${1:-}" = "--revert" ]; then
  info "Revert semua agent dari backup..."
  revert_hermes
  revert_claude
  revert_codex
  revert_opencode
  echo ""
  ok "Done. Restart agent biar efek."
  exit 0
fi

info "Sumber: $SOUL + $AGENTS"
install_hermes
install_claude
install_codex
install_opencode

echo ""
echo "==============================================================="
echo "   ${GREEN}JARVIS TERPASANG ✓${NC}"
echo "   L1 SOUL (identitas) + L2 AGENTS (routing) aktif"
echo "   L3 = tools bawaan agent (otomatis)"
echo ""
echo "   Restart agent biar aktif."
echo "   Balikin: bash jarvis-install.sh --revert"
echo "==============================================================="
