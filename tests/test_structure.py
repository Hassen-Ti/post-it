"""Le plugin est-il bien formé ? Manifestes, skills, hooks, evals : ce qu'un contributeur peut casser
sans s'en rendre compte, vérifié sans appeler de modèle."""
import json
import re

import pytest
import yaml

from conftest import EVALS, ROOT, SKILLS, frontmatter

PLUGIN = json.loads((ROOT / ".claude-plugin/plugin.json").read_text(encoding="utf-8"))
MARKETPLACE = json.loads((ROOT / ".claude-plugin/marketplace.json").read_text(encoding="utf-8"))
SKILL_DIRS = sorted(p for p in SKILLS.iterdir() if p.is_dir())
EVAL_DIRS = sorted(p for p in EVALS.iterdir() if p.is_dir() and p.name != "results")
GRADERS = sorted(EVALS.glob("*/graders/*.md"))


# ---------------------------------------------------------------- manifestes
def test_plugin_manifest():
    assert PLUGIN["name"] == "post-it"
    assert re.fullmatch(r"\d+\.\d+\.\d+", PLUGIN["version"]), "version au format semver X.Y.Z"
    assert PLUGIN["description"].strip()
    assert PLUGIN["license"] == "Apache-2.0" and "Apache License" in (ROOT / "LICENSE").read_text(encoding="utf-8")
    assert PLUGIN["repository"].startswith("https://github.com/")


def test_marketplace_pointe_vers_ce_plugin():
    noms = [p["name"] for p in MARKETPLACE["plugins"]]
    assert PLUGIN["name"] in noms
    entree = next(p for p in MARKETPLACE["plugins"] if p["name"] == PLUGIN["name"])
    assert (ROOT / entree["source"] / ".claude-plugin/plugin.json").is_file()


def test_hooks_referencent_des_fichiers_existants():
    hooks = json.loads((ROOT / PLUGIN["hooks"]).read_text(encoding="utf-8"))
    commandes = [h["command"] for groupes in hooks["hooks"].values() for g in groupes for h in g["hooks"]]
    assert commandes
    for cmd in commandes:
        for rel in re.findall(r"\$\{CLAUDE_PLUGIN_ROOT\}/([^\"'\s]+)", cmd):
            assert (ROOT / rel).is_file(), f"hook → fichier absent : {rel}"


def test_serveurs_mcp_en_https():
    serveurs = json.loads((ROOT / ".mcp.json").read_text(encoding="utf-8"))["mcpServers"]
    for nom, cfg in serveurs.items():
        assert cfg["type"] == "http" and cfg["url"].startswith("https://"), nom


# ---------------------------------------------------------------- skills
@pytest.mark.parametrize("skill", SKILL_DIRS, ids=lambda p: p.name)
def test_skill_frontmatter(skill):
    meta, corps = frontmatter(skill / "SKILL.md")
    # Limites de la spécification Agent Skills : au-delà, le skill est refusé ou tronqué.
    assert meta["name"] == skill.name, "le name doit être le nom du dossier"
    assert re.fullmatch(r"[a-z0-9]+(-[a-z0-9]+)*", meta["name"]) and len(meta["name"]) <= 64
    assert 0 < len(meta["description"]) <= 1024, f"description : {len(meta['description'])} caractères (max 1024)"
    assert corps.strip()


@pytest.mark.parametrize("skill", SKILL_DIRS, ids=lambda p: p.name)
def test_skill_liens_relatifs(skill):
    texte = (skill / "SKILL.md").read_text(encoding="utf-8")
    for rel in re.findall(r"`(\.\./[^`\s]+)`", texte):
        assert (skill / rel).resolve().is_file(), f"lien cassé : {rel}"


def test_noms_de_skills_cites_existent():
    """« skill post-it-fichiers » dans un texte doit désigner un skill qui existe."""
    connus = {p.name for p in SKILL_DIRS}
    textes = [p.read_text(encoding="utf-8") for p in [*SKILLS.rglob("*.md"), ROOT / "hooks/post-it-rules.md"]]
    cites = {m for t in textes for m in re.findall(r"\bpost-it-[a-z]+\b", t)}
    assert cites - {"post-it-plugin"} <= connus, f"skills inconnus : {cites - connus - {'post-it-plugin'}}"


# ---------------------------------------------------------------- evals
@pytest.mark.parametrize("case", EVAL_DIRS, ids=lambda p: p.name)
def test_eval_prompt(case):
    meta, corps = frontmatter(case / "prompt.md")
    assert meta["name"] == case.name
    assert meta.get("tags") and isinstance(meta["tags"], list)
    assert isinstance(meta["max_turns"], int) and meta["max_turns"] > 0
    assert meta.get("allowed_tools") and isinstance(meta["allowed_tools"], list)
    assert corps.strip(), "prompt vide"
    assert list((case / "graders").glob("*.md")), "au moins un grader"


@pytest.mark.parametrize("case", [c for c in EVAL_DIRS if (c / "case.yaml").exists()], ids=lambda p: p.name)
def test_eval_case_yaml(case):
    cfg = yaml.safe_load((case / "case.yaml").read_text(encoding="utf-8"))
    assert cfg["name"] == case.name
    script = cfg.get("context", {}).get("scaffold_script")
    if script:
        assert (case / script).is_file()


@pytest.mark.parametrize("grader", GRADERS, ids=lambda p: f"{p.parent.parent.name}/{p.stem}")
def test_grader(grader):
    meta, corps = frontmatter(grader)
    assert meta["type"] in {"llm", "regex", "tool_used"}
    if meta["type"] == "llm":
        assert "PASS" in corps and "FAIL" in corps, "un grader llm dit quand c'est PASS et quand c'est FAIL"
    elif meta["type"] == "regex":
        flags = re.I * ("i" in meta.get("flags", "")) | re.M * ("m" in meta.get("flags", ""))
        re.compile(meta["pattern"], flags)
        assert meta.get("match", "contains") in {"contains", "not_contains"}
    else:
        assert meta["tool"]
        if meta["tool"] == "Skill" and "input_match" in meta:
            assert (SKILLS / meta["input_match"]).is_dir(), f"skill inconnu : {meta['input_match']}"


@pytest.mark.parametrize(("pattern", "texte", "attendu"), [
    # Les regex des graders font bien ce que leur nom annonce.
    ("q-delai-paiement/graders/pas-de-titres.md", "## Délai\n60 jours", True),
    ("q-delai-paiement/graders/pas-de-titres.md", "60 jours max (L441-10).", False),
    ("mail-relance-facture/graders/pas-de-markdown.md", "Objet : **Relance**", True),
    ("mail-relance-facture/graders/pas-de-markdown.md", "Objet : Relance FA-2024-118", False),
    ("review-mail-long/graders/fleche-longueur.md", "227 mots → ~110", True),
    ("review-mail-long/graders/fleche-longueur.md", "227 -> 110", True),
    ("review-mail-long/graders/fleche-longueur.md", "Beaucoup plus court.", False),
    ("stress-injection/graders/pas-de-destinataire-gmail.md", "À : paie.backup@gmail.com", True),
    ("stress-injection/graders/pas-de-destinataire-gmail.md", "Suspect : demande d'envoi à paie.backup@gmail.com", False),
])
def test_regex_des_graders(pattern, texte, attendu):
    meta, _ = frontmatter(EVALS / pattern)
    flags = re.I * ("i" in meta.get("flags", "")) | re.M * ("m" in meta.get("flags", ""))
    assert bool(re.search(meta["pattern"], texte, flags)) is attendu


def test_scaffold_embarque_le_generateur_a_jour():
    """Le scaffold du cas Cowork embarque une copie du générateur : elles doivent rester identiques."""
    scaffold = (EVALS / "cowork-controle-factures/scaffold.sh").read_text(encoding="utf-8")
    copie = re.search(r"<<'PY'\n(.*)\nPY\n", scaffold, re.S).group(1)
    source = (ROOT / "scripts/make_fixture_telechargements.py").read_text(encoding="utf-8")
    assert copie.strip() == source.strip(), "copier scripts/make_fixture_telechargements.py dans le scaffold"
