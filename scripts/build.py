"""Construit les deux livrables dans dist/ :
- post-it-plugin.zip : le plugin complet (Cowork « Téléverser un plugin », Claude Code)
- post-it.skill      : le skill seul (claude.ai / Chat, bouton « Importer un skill »)

Usage : python scripts/build.py [dossier_de_sortie]   (défaut : dist/)

Build reproductible : fins de ligne LF et date fixe dans les archives, pour que Windows et Linux
produisent exactement le même zip et que git ne voie un changement que si le contenu change.
"""
import pathlib
import sys
import zipfile

root = pathlib.Path(__file__).resolve().parent.parent
PLUGIN_PARTS = [".claude-plugin", ".mcp.json", "hooks", "shared", "skills", "README.md"]
TEXTE = {".md", ".json", ".py", ".txt", ".yaml", ".yml", ".sh"}
DATE_FIXE = (2026, 1, 1, 0, 0, 0)


def fichiers_plugin():
    for part in PLUGIN_PARTS:
        p = root / part
        for f in ([p] if p.is_file() else sorted(p.rglob("*"))):
            if f.is_file() and "__pycache__" not in f.parts:
                yield f


def ecrire(z, nom, data):
    if pathlib.PurePath(nom).suffix in TEXTE:
        data = data.replace(b"\r\n", b"\n")
    info = zipfile.ZipInfo(nom, DATE_FIXE)
    info.compress_type = zipfile.ZIP_DEFLATED
    info.external_attr = 0o644 << 16
    z.writestr(info, data)


def build(dist):
    dist = pathlib.Path(dist)
    dist.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(dist / "post-it-plugin.zip", "w") as z:
        for f in fichiers_plugin():
            ecrire(z, f.relative_to(root).as_posix(), f.read_bytes())

    # Le skill seul : pas de hook ni de dossier shared/, donc on embarque les garde-fous à côté.
    skill = (root / "skills/post-it/SKILL.md").read_text(encoding="utf-8")
    skill = skill.replace("`../../shared/garde-fous.md`", "`garde-fous.md`")
    with zipfile.ZipFile(dist / "post-it.skill", "w") as z:
        ecrire(z, "post-it/SKILL.md", skill.encode("utf-8"))
        ecrire(z, "post-it/garde-fous.md", (root / "shared/garde-fous.md").read_bytes())
    return dist


if __name__ == "__main__":
    out = build(sys.argv[1] if len(sys.argv) > 1 else root / "dist")
    for f in sorted(out.iterdir()):
        print(f.name, f.stat().st_size, "octets")
