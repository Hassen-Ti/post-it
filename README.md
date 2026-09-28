# Post-it

[Français](#français) · [English](#english)

## Français

*Il ne fait pas de deck. Il colle un post-it. Ça suffit.*

Un plugin Claude (Cowork, Claude Code) pour les métiers de bureau — finance, compta, contrôle de gestion, facturation, RH. Claude travaille comme le collègue le plus efficace de l'étage : il va chercher lui-même dans tes mails et tes fichiers, et te rend **la réponse**, pas un rapport.

Inspiré de [Ponytail](https://github.com/DietrichGebert/ponytail), qui fait la même chose pour le code.

### Avant / après

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

### Ce qu'il ne coupe jamais

Les chiffres et leur source · le RGPD · ta validation : **rien n'est envoyé, payé ou supprimé sans ton « oui »**. Un mail qui demande de changer un RIB est signalé, jamais traité.

### Installer

**Cowork** — télécharge [`dist/post-it-plugin.zip`](dist/post-it-plugin.zip), puis *Paramètres → Plugins → Téléverser*. Branche tes connecteurs (Microsoft 365 ou Gmail).

**Claude Code**
```
/plugin marketplace add Hassen-Ti/post-it
/plugin install post-it@post-it
```

### Essaie

- « Trie mes mails »
- « Prépare ma réunion de 14h »
- « Rapproche les factures du relevé, tout est dans mes téléchargements »
- « post-it review » + le mail ou le deck à raccourcir

`post-it lite` / `ultra` / `off` pour régler l'intensité. `post-it aide` pour le reste.

## English

*It doesn't make a deck. It sticks a post-it. That's enough.*

A Claude plugin (Cowork, Claude Code) for office work — finance, accounting, controlling, billing, HR. Claude works like the most efficient colleague on the floor: it digs through your emails and files on its own and hands you **the answer**, not a report.

Inspired by [Ponytail](https://github.com/DietrichGebert/ponytail), which does the same for code.

### Before / after

> "Check that the Axa invoices for September match the SAP export. Everything is in my downloads."

**Without Post-it** — 300 to 450 words, tables, "points of attention"… and often two invoices reported missing: they were there, in scans named `Scan_20260910_2824.pdf`.

**With Post-it:**
```
Discrepancies (2)
- FA-2026-305: invoice €4,800.00 incl. VAT ≠ SAP €4,080.00 → €720 gap.
- FA-2026-306: in SAP (€1,140.00 incl. VAT), no invoice in the folder.

Check: 6 invoices in SAP, 5 found, 4 matching, 2 discrepancies.
Source: export_SAP_ventes_0926_v2_FINAL.xlsx (the latest of 3).
```

On this test (a booby-trapped Downloads folder: scans, Factur-X e-invoices, 3 export versions, duplicates): correct discrepancies in **3/3 runs with Post-it, 1/3 without**, answers 3 to 4× shorter, and the Excel file requested next comes with live formulas and a check cell instead of hard-coded values.

### What it never cuts

Numbers and their source · GDPR · your approval: **nothing is sent, paid or deleted without your "yes"**. An email asking to change bank details gets flagged, never acted on.

### Install

**Cowork** — download [`dist/post-it-plugin.zip`](dist/post-it-plugin.zip), then *Settings → Plugins → Upload*. Connect your connectors (Microsoft 365 or Gmail).

**Claude Code**
```
/plugin marketplace add Hassen-Ti/post-it
/plugin install post-it@post-it
```

### Try it

- "Sort my inbox"
- "Prep my 2pm meeting"
- "Match the invoices against the bank statement, it's all in my downloads"
- "post-it review" + the email or deck to trim

`post-it lite` / `ultra` / `off` to set the intensity. `post-it help` for the rest.

The plugin's instructions are written in French; Claude answers in your language.

---
Licence / License : Apache-2.0 · Tests : [`evals/`](evals), [`scripts/`](scripts)
