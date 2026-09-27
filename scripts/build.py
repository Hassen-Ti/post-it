"""Construit les deux livrables dans dist/ :
- post-it-plugin.zip : le plugin complet (Cowork « Téléverser un plugin », Claude Code)
- post-it.skill      : le skill seul (claude.ai / Chat, bouton « Importer un skill »)
"""
import pathlib, zipfile

root = pathlib.Path(__file__).resolve().parent.parent
dist = root / "dist"
dist.mkdir(exist_ok=True)
plugin_parts = [".claude-plugin", ".mcp.json", "hooks", "shared", "skills", "README.md"]

with zipfile.ZipFile(dist / "post-it-plugin.zip", "w", zipfile.ZIP_DEFLATED) as z:
    for part in plugin_parts:
        p = root / part
        for f in ([p] if p.is_file() else sorted(p.rglob("*"))):
            if f.is_file():
                z.write(f, f.relative_to(root).as_posix())

# Le skill seul : pas de hook ni de dossier shared/, donc on embarque les garde-fous à côté.
skill = (root / "skills/post-it/SKILL.md").read_text(encoding="utf-8")
skill = skill.replace("`../../shared/garde-fous.md`", "`garde-fous.md`")
with zipfile.ZipFile(dist / "post-it.skill", "w", zipfile.ZIP_DEFLATED) as z:
    z.writestr("post-it/SKILL.md", skill)
    z.write(root / "shared/garde-fous.md", "post-it/garde-fous.md")

for f in sorted(dist.iterdir()):
    print(f.name, f.stat().st_size, "octets")
