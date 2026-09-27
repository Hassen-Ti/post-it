---
name: post-it-review
description: Relit un livrable existant (email, note, rapport, deck, fichier Excel, compte rendu) et rend uniquement la liste de ce qui peut être coupé, sans réécrire. Utilise-le quand l'utilisateur dit « post-it review », « c'est trop long ? », « relis mon mail / ma note / mon deck », « qu'est-ce que je peux enlever », « on peut faire plus court ? », ou partage un livrable en demandant un avis sur sa longueur. Pas pour « raccourcis-moi ça » (réécriture directe → skill post-it).
---

# Post-it review

Ne réécris pas. Liste ce qui peut partir. Le meilleur résultat d'une review, c'est un livrable plus court.

## Format

Une ligne par coupe : `[où] — [étiquette] : [quoi]. [ce qui le remplace]`

Étiquettes :
- **couper** — redondant, hors sujet, déjà connu du lecteur. Remplacé par : rien.
- **fusionner** — deux sections / slides / paragraphes qui disent la même chose.
- **alléger** — même idée, moins de mots. Montre la version courte.
- **format** — le mauvais contenant (un Word pour ce qui tient dans un mail, un graphique pour 3 chiffres, un onglet pour 5 lignes).
- **natif** — refait à la main ce que l'outil fait déjà (total saisi au lieu d'une formule, tableau recopié au lieu d'un TCD, pièce jointe au lieu d'un lien).

Puis, séparément, ce qui **manque** (c'est aussi le rôle de la review) :
- **manque** — chiffre sans source ou sans période, total qui ne boucle pas, hypothèse critique absente, action sans responsable ou sans date, données personnelles exposées.

## Exemples

- `Slide 2 — couper : sommaire. Rien, 5 slides n'en ont pas besoin.`
- `Slides 4 et 7 — fusionner : même graphique de marge, deux angles. Garder la 7.`
- `§1 — alléger : « Suite à notre échange de ce jour et comme convenu lors de notre réunion… » → « Comme convenu mardi : »`
- `Onglet Dashboard — format : 3 graphiques pour 6 chiffres. Un tableau de 6 lignes dans l'onglet Données.`
- `Colonne F — natif : totaux saisis à la main. =SOMME(F2:F40).`
- `Slide 5 — manque : « +12 % » sans période ni source.`

## Fin

**Toujours** terminer par une seule ligne de bilan, avant → après, en chiffres : `12 slides → 5` ou `227 mots → ~110`. C'est la dernière ligne de la réponse (pas de 📎 après).

Rien à couper : « Déjà court. Envoie. » et stop.

Ne réécris que si l'utilisateur le demande ensuite (« vas-y, applique »). Ne propose jamais de couper ce qui figure dans « Jamais sur la liste des coupes » de `post-it` ni dans `../../shared/garde-fous.md` (chiffres sourcés, hypothèses qui comptent, conformité, ce qui a été demandé).
