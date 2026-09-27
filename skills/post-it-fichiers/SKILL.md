---
name: post-it-fichiers
description: Méthode Post-it pour toute tâche sur des fichiers de bureau dans un dossier (PDF, factures, scans, Excel, exports SAP / Sage / ERP, CSV, relevés bancaires) — surtout un dossier en vrac comme Téléchargements. Utilise-le AVANT d'ouvrir le premier fichier dès que la demande porte sur « les fichiers », « mon dossier », « mes téléchargements », « les factures », « l'export », « le relevé », « le fichier Excel », « les PDF » — contrôler, rapprocher, vérifier, extraire, comparer, consolider, pointer, lettrer, trouver des écarts.
---

# Post-it fichiers

Un dossier de bureau ment : les scans s'appellent `Scan_20260910_2824.pdf`, les factures les plus fiables ont leurs données cachées dans un XML, l'export a trois versions et des sous-totaux au milieu des lignes. Chercher « par nom » rate la moitié du dossier. **On regarde le contenu, une fois, avec un outil — puis on ne lit que ce qui compte.**

Garde-fous : `../../shared/garde-fous.md`. Règles de réponse : skill `post-it`.

## 1. Inventaire — toujours en premier

```
python "<dossier de ce skill>/scripts/inventaire.py" "<dossier de travail>"
```

(`<dossier de ce skill>` = le répertoire de base indiqué au chargement du skill.) Une ligne par fichier : type, date, doublons, PDF scanné ou non, **XML Factur-X embarqué**, et pour les Excel : lignes masquées, sous-totaux, nombres en texte, en-tête. Le script ne modifie rien.

Puis décide, **sans ouvrir** les fichiers manifestement hors sujet (CGV, rapport annuel, CV, installeurs) :
- **Pertinent par le nom** → à lire.
- **Nom non parlant** (`Scan_`, `IMG_`, `document`, numéros) **et date dans la période** → à ouvrir : c'est souvent là que sont les pièces manquantes. Ne conclus jamais « facture absente » avant d'avoir regardé les scans de la période.
- **Doublons** (contenu identique) → un seul compte. **Versions** (`v2`, `FINAL`, `(1)`) → la plus récente par date d'extraction ; dis laquelle en une ligne.

Au-delà de ~15 documents à lire, découpe en lots traités par des sous-agents (un lot = une liste de fichiers, sortie imposée : n°, date, HT, TVA, TTC, fichier source), puis consolide.

## 2. Lire chaque fichier par la méthode la plus fiable

| Fichier | Méthode, dans cet ordre |
|---|---|
| PDF avec ★ XML Factur-X | `inventaire.py --pj fichier.pdf` → montants du XML (exacts). L'image n'est qu'un contrôle. |
| PDF texte | extraction texte (pypdf / pdfplumber / PyMuPDF) |
| PDF scanné | outil **Read** sur le PDF (pages ciblées) : lecture visuelle. Contrôle : HT + TVA = TTC ; sinon relis ou marque `[lecture incertaine]`. |
| Excel | pandas / openpyxl en **excluant** lignes masquées et lignes total / sous-total, en convertissant les nombres en texte (« 3 150,00 »). Jamais tout le classeur dans la conversation : en-têtes + résultat. |
| CSV | encodage et séparateur donnés par l'inventaire (souvent cp1252 et `;` en France). |

Pas d'installation de logiciel sans raison ; si une bibliothèque manque, passe à la ligne suivante du tableau.

## 3. Prouver avant de répondre

Avant de conclure, vérifie et garde **une** ligne de contrôle :
- chaque pièce attendue est trouvée ou déclarée manquante **après** examen des scans ;
- totaux recalculés = totaux du fichier (hors sous-totaux) ;
- pas de doublon compté deux fois, pas de document hors période.

## 4. Rendre (format Post-it)

```
Écarts (2)
- FA-2026-305 : facture 4 800,00 € TTC ≠ SAP 4 080,00 € → écart 720 € (4 000 vs 3 400 HT).
- FA-2026-306 : dans SAP (1 140,00 € TTC), aucune facture dans le dossier.

Contrôle : 6 factures Axa sept. dans SAP, 5 retrouvées (dont 2 scans, 1 Factur-X), 4 conformes.
Source : export_SAP_ventes_0926_v2_FINAL.xlsx (le plus récent ; 2 exports plus anciens ignorés).
```

En texte simple, sans bloc de code. Écarts d'abord, puis contrôle et source. Pas de récit des étapes, pas de liste des fichiers ignorés, pas de tableau de toutes les lignes conformes (📎 si l'utilisateur pourrait le vouloir).

## Ne laisse rien traîner

Scripts et extractions intermédiaires : dans un dossier temporaire hors du dossier de l'utilisateur, ou supprimés à la fin. Le dossier de l'utilisateur ne reçoit que le livrable demandé.
