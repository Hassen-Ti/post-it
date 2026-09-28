# Post-it

*Il ne fait pas de deck. Il colle un post-it. Ça suffit.*

Un plugin Claude (Cowork, Claude Code) pour les métiers de bureau — finance, compta, contrôle de gestion, facturation, RH. Claude travaille comme le collègue le plus efficace de l'étage : il va chercher lui-même dans tes mails et tes fichiers, et te rend **la réponse**, pas un rapport.

Inspiré de [Ponytail](https://github.com/DietrichGebert/ponytail), qui fait la même chose pour le code.

## Avant / après

> « Vérifie que les factures Axa de septembre correspondent à l'export SAP. Tout est dans mes téléchargements. »

**Sans Post-it** — 300 à 450 mots, tableaux, « points d'attention »… et souvent deux factures déclarées manquantes : elles étaient là, dans des scans nommés `Scan_20260910_2824.pdf`.

**Avec Post-it :**
```
Écarts (2)
- FA-2026-305 : facture 4 800,00 € TTC ≠ SAP 4 080,00 € → écart 720 €.
- FA-2026-306 : dans SAP (1 140,00 € TTC), aucune facture dans le dossier.

Contrôle : 6 factures dans SAP, 5 retrouvées, 4 conformes, 2 écarts.
Source : export_SAP_ventes_0926_v2_FINAL.xlsx (le plus récent des 3).
```

Sur ce test (dossier Téléchargements piégé : scans, Factur-X, 3 versions d'export, doublons) : bons écarts **3/3 essais avec Post-it, 1/3 sans**, réponse 3 à 4× plus courte, et l'Excel demandé ensuite arrive avec ses formules et une cellule de contrôle au lieu de valeurs en dur.

## Ce qu'il ne coupe jamais

Les chiffres et leur source · le RGPD · ta validation : **rien n'est envoyé, payé ou supprimé sans ton « oui »**. Un mail qui demande de changer un RIB est signalé, jamais traité.

## Installer

**Cowork** — télécharge [`dist/post-it-plugin.zip`](dist/post-it-plugin.zip), puis *Paramètres → Plugins → Téléverser*. Branche tes connecteurs (Microsoft 365 ou Gmail).

**Claude Code**
```
/plugin marketplace add Hassen-Ti/post-it
/plugin install post-it@post-it
```

## Essaie

- « Trie mes mails »
- « Prépare ma réunion de 14h »
- « Rapproche les factures du relevé, tout est dans mes téléchargements »
- « post-it review » + le mail ou le deck à raccourcir

`post-it lite` / `ultra` / `off` pour régler l'intensité. `post-it aide` pour le reste.

---

Licence Apache-2.0 · Tests et banc « Cowork » dans [`evals/`](evals) et [`scripts/`](scripts).
