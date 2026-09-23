#!/usr/bin/env python3
"""jarvis.py — Pasang SOUL-JARVIS.md sebagai system prompt Hermes.

Cara pakai (di Termux, dari folder repo syadagentic):
    python3 jarvis.py          # pasang
    python3 jarvis.py --revert # balikin ke backup terakhir

Butuh: pip install pyyaml
"""
import os
import shutil
import sys

try:
    import yaml
except ImportError:
    print("pyyaml belum ada. Jalankan: pip install pyyaml")
    sys.exit(1)

HOME = os.path.expanduser("~")
CFG = os.path.join(HOME, ".hermes", "config.yaml")
BAK = CFG + ".bak-jarvis"
SOUL = os.path.join(os.path.dirname(os.path.abspath(__file__)), "SOUL-JARVIS.md")


def revert():
    if not os.path.exists(BAK):
        print("Backup gak ketemu:", BAK)
        sys.exit(1)
    shutil.copy(BAK, CFG)
    print("Balikin dari backup:", BAK, "->", CFG)
    print("Restart Hermes biar efek.")


def install():
    if not os.path.exists(CFG):
        print("config.yaml gak ketemu di", CFG)
        sys.exit(1)
    if not os.path.exists(SOUL):
        print("SOUL-JARVIS.md gak ketemu di", SOUL)
        sys.exit(1)

    shutil.copy(CFG, BAK)
    cfg = yaml.safe_load(open(CFG, encoding="utf-8")) or {}
    cfg.setdefault("agent", {})
    cfg["agent"]["system_prompt"] = open(SOUL, encoding="utf-8").read()
    yaml.safe_dump(cfg, open(CFG, "w", encoding="utf-8"), allow_unicode=True)
    print("Terpasang! Backup:", BAK)
    print("Sekarang restart Hermes: hermes restart (atau matiin + nyalain lagi)")


if __name__ == "__main__":
    if "--revert" in sys.argv:
        revert()
    else:
        install()
