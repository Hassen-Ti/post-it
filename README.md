# Post-it

*Il ne fait pas de deck. Il colle un post-it. Ça suffit.*

Post-it fait travailler Claude comme le collègue le plus efficace de l'étage. Il s'adresse aux métiers de bureau : finance, compta, contrôle de gestion, facturation, RH, business analyse.

- **Il fait le travail.** Il lit lui-même tes mails, tes messages Teams, ton agenda et tes fichiers via tes connecteurs (Microsoft 365, Gmail, Slack…). Pas besoin de « bien prompter ».
- **Il répond court.** Il choisit le format le plus léger qui marche : chat < mail < tableau < document < présentation.
- **Il ne coupe jamais l'essentiel.** Les chiffres gardent leur source, le RGPD et la piste d'audit sont respectés. Il n'envoie, ne paie et ne supprime **rien** sans ton « oui ».

C'est l'équivalent de [Ponytail](https://github.com/DietrichGebert/ponytail) pour le travail de bureau.

## Installer

**Cowork / Claude Desktop :** Paramètres → Plugins → téléverser `dist/post-it-plugin.zip`. Branche ensuite tes connecteurs dans Paramètres → Connecteurs : Microsoft 365 (Outlook, Teams, OneDrive/SharePoint) ou Gmail / Google Agenda, et Slack si tu l'utilises. Post-it se sert de ceux qui sont branchés, quel que soit l'éditeur.

**Claude Code :**
```
/plugin marketplace add <chemin-ou-repo-git-de-ce-dossier>
/plugin install post-it@post-it
```

**Chat claude.ai sans plugin :** importe `dist/post-it.skill` comme skill. Sans hook, il se déclenche seulement quand la demande ressemble à du travail de bureau.

## Utiliser

Demande comme à un collègue :

| Tu dis | Tu obtiens |
|---|---|
| « Trie mes mails » / « J'ai raté quoi sur Teams ? » | Les 3 choses pour toi + les brouillons prêts |
| « Réponds au mail de Paul » | Un brouillon dans le fil, pas envoyé |
| « Prépare ma réunion de 14h » | 3 lignes : enjeu, ce qu'on attend de toi, ce qui est à décider |
| « Fais le CR » + transcription | Décisions + actions (qui, quoi, quand) |
| « post-it review » + un livrable | Ce qu'on peut couper, sans réécrire : `12 slides → 5` |
| « post-it aide » | La carte d'aide avec des exemples par métier |

Niveaux : `post-it lite`, `post-it` (full, par défaut), `post-it ultra`, `post-it off`.

## Contenu

| Élément | Rôle |
|---|---|
| `hooks/` | Réinjecte les règles Post-it à chaque début de session (toujours actif, comme Ponytail) |
| `skills/post-it` | Le mode lui-même : l'échelle de décision, ce qui ne se coupe jamais, les niveaux |
| `skills/post-it-inbox` | Tri des mails, de Teams et de Slack, et brouillons de réponse |
| `skills/post-it-reunion` | Préparation de réunion et compte rendu |
| `skills/post-it-review` | Liste de coupes sur un livrable existant |
| `skills/post-it-fichiers` | Méthode pour les dossiers de fichiers (PDF, scans, Factur-X, Excel, exports) + script d'inventaire par le contenu |
| `skills/post-it-aide` | Carte d'aide |
| `shared/garde-fous.md` | Envoi, fraude, chiffres, RGPD : les règles communes |
| `.mcp.json` | Connecteurs proposés avec le plugin : Microsoft 365, Gmail, Google Agenda, Google Drive (Slack : à brancher depuis tes connecteurs) |
| `evals/` | Tests avec / sans plugin : `claude plugin eval . --runs 2` |
| `scripts/bench_cowork.py` | Banc « Cowork » : Claude avec un shell sur un dossier Téléchargements piégé (`make_fixture_telechargements.py`), avec / sans plugin |

## Construire

```
python scripts/build.py
```
Cette commande produit `dist/post-it-plugin.zip` (le plugin) et `dist/post-it.skill` (le skill seul).
