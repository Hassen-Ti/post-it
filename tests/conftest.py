import importlib.util
import subprocess
import sys
from pathlib import Path

import pytest
import yaml

ROOT = Path(__file__).resolve().parent.parent
SKILLS = ROOT / "skills"
EVALS = ROOT / "evals"
INVENTAIRE = SKILLS / "post-it-fichiers" / "scripts" / "inventaire.py"


def frontmatter(path):
    """(métadonnées, corps) d'un fichier Markdown à en-tête YAML `--- ... ---`."""
    texte = Path(path).read_text(encoding="utf-8")
    assert texte.startswith("---\n"), f"{path} : pas d'en-tête YAML en première ligne"
    _, entete, corps = texte.split("---\n", 2)
    return yaml.safe_load(entete) or {}, corps


@pytest.fixture(scope="session")
def inventaire():
    spec = importlib.util.spec_from_file_location("inventaire", INVENTAIRE)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


@pytest.fixture(scope="session")
def telechargements(tmp_path_factory):
    """Le dossier Téléchargements piégé du banc Cowork, généré une fois pour toute la session."""
    base = tmp_path_factory.mktemp("fixture")
    subprocess.run([sys.executable, str(ROOT / "scripts/make_fixture_telechargements.py"), str(base)],
                   check=True, capture_output=True)
    return base / "Telechargements"
