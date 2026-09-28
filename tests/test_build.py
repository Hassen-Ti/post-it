"""Les livrables de dist/ sont ceux que les gens téléchargent : ils doivent correspondre aux sources."""
import importlib.util
import zipfile

import pytest

from conftest import ROOT


@pytest.fixture(scope="module")
def build():
    spec = importlib.util.spec_from_file_location("build", ROOT / "scripts/build.py")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module.build


def test_contenu_du_plugin(build, tmp_path):
    z = zipfile.ZipFile(build(tmp_path) / "post-it-plugin.zip")
    noms = set(z.namelist())
    for attendu in (".claude-plugin/plugin.json", ".claude-plugin/marketplace.json", ".mcp.json", "hooks/hooks.json",
                    "hooks/post-it-rules.md", "shared/garde-fous.md", "README.md",
                    "skills/post-it-fichiers/scripts/inventaire.py"):
        assert attendu in noms
    assert {n.split("/")[1] for n in noms if n.startswith("skills/")} == {p.name for p in (ROOT / "skills").iterdir()}
    assert not [n for n in noms if n.startswith(("evals/", "tests/", "scripts/", "dist/")) or "__pycache__" in n]
    assert not [n for n in noms if b"\r\n" in z.read(n)], "fins de ligne LF dans l'archive"


def test_skill_seul_autonome(build, tmp_path):
    z = zipfile.ZipFile(build(tmp_path) / "post-it.skill")
    assert sorted(z.namelist()) == ["post-it/SKILL.md", "post-it/garde-fous.md"]
    skill = z.read("post-it/SKILL.md").decode("utf-8")
    assert "../../" not in skill and "`garde-fous.md`" in skill


def test_build_reproductible(build, tmp_path):
    a, b = build(tmp_path / "a"), build(tmp_path / "b")
    for nom in ("post-it-plugin.zip", "post-it.skill"):
        assert (a / nom).read_bytes() == (b / nom).read_bytes()


@pytest.mark.parametrize("nom", ["post-it-plugin.zip", "post-it.skill"])
def test_dist_a_jour(build, tmp_path, nom):
    """Échoue si une source a changé sans rebuild : lancer `python scripts/build.py` et committer dist/."""
    # On compare le contenu, pas les octets du zip : la compression varie selon la version de zlib
    # (Windows / Linux, Python 3.11 / 3.13) sans que le contenu change.
    def contenu(chemin):
        with zipfile.ZipFile(chemin) as z:
            return {n: z.read(n) for n in z.namelist()}

    assert contenu(ROOT / "dist" / nom) == contenu(build(tmp_path) / nom), \
        f"dist/{nom} n'est pas à jour : python scripts/build.py"
