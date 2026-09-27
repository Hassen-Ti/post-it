---
name: post-it-reunion
description: Prépare une réunion en 3 lignes ou en fait le compte rendu en décisions et actions, sans roman. Lit l'agenda (Outlook / Microsoft 365, Google Agenda), les mails et fils Teams liés à la réunion, et la transcription ou les notes si elles existent. Utilise-le pour « prépare ma réunion de 14h », « j'ai quoi aujourd'hui dans mon agenda », « ma journée », « de quoi on parle au comité », « ordre du jour », « fais le compte rendu », « compte-rendu », « CR », « PV », « relevé de décisions », « résume la réunion d'hier », « envoie les actions aux participants », ou quand l'utilisateur colle une transcription ou des notes de réunion.
argument-hint: "[prépa|cr] [réunion, ex. « comité budget de 14h »]"
---

# Post-it réunion

Une réunion produit deux choses utiles : des **décisions** et des **actions**. Tout le reste est du remplissage.

Toutes les règles de `post-it` s'appliquent. Garde-fous : `../../shared/garde-fous.md`.

Mode déduit de la demande : avant la réunion → **prépa** ; après, ou transcription / notes fournies → **compte rendu**. « Ma journée » → prépa de toutes les réunions du jour.

## Prépa — avant

Lis : l'invitation (objet, participants, pièces jointes), les derniers mails et messages Teams avec ces participants sur ce sujet, le compte rendu de la réunion précédente s'il existe.

Rends **3 lignes par réunion**, pas plus (en texte normal, pas dans un bloc de code) :

```
14h — Comité budget (Sophie, Karim, Marc)
Enjeu : valider la révision du forecast T4 (-120 k€ sur le transport).
En attente de toi : les chiffres du centre 420 promis à Karim le 20/09.
À décider : gel des recrutements T4 oui/non.
```

Pas de biographie des participants, pas d'historique du projet, pas d'ordre du jour recopié. Une réunion sans enjeu visible : « Point hebdo — rien en attente de toi. »

« Ma journée » : une ligne par réunion, puis le seul point qui demande de la préparation.

## Compte rendu — après

Source : transcription (Teams, notes collées, enregistrement transcrit) ou notes de l'utilisateur. Rien ? Demande les notes en une phrase, n'invente pas.

Format unique (en texte normal, pas dans un bloc de code) :

```
CR — Comité budget — 24/09/2026
Présents : Sophie, Karim, Marc

Décisions
- Forecast T4 révisé à 4,82 M€ (-120 k€, transport).
- Gel des recrutements T4, sauf remplacement.

Actions
- Karim — envoyer le détail du centre 420 — ven. 02/10
- Marc — mettre à jour le fichier de forecast — lun. 05/10
- [responsable à confirmer] — informer les managers du gel — avant le 10/10

Points ouverts
- Budget formation 2027 : reporté au comité d'octobre.
```

Règles :
- Une action = **qui + quoi + quand**. Il manque le responsable ou la date ? Écris `[à confirmer]` : ne l'invente pas.
- Pas de « tour de table », pas de verbatim, pas de « il a été rappelé que… ».
- Décisions et chiffres **tels que dits** : pas d'arrondi ni de reformulation qui change le sens. En cas de doute, marque `[à vérifier]`.
- Dates : reprends la date dite ; n'ajoute un jour de semaine que s'il a été dit, et signale `[à vérifier]` si le jour et la date ne concordent pas.
- Un sujet reporté sans décision va dans **Points ouverts**, pas dans Décisions.
- Sujets RH sensibles (cas individuel, salaire, sanction) évoqués en réunion : pas de nom ni de détail dans un CR destiné à une diffusion large ; signale-le à l'utilisateur.
- Envoi aux participants : **brouillon seulement**, en texte brut prêt à coller, envoyé uniquement après « oui ».

Les apartés hors sujet (météo, sport, blagues) disparaissent sans être mentionnés, même en 📎.

📎 Si un sujet de travail a été discuté longuement sans décision ni action, une ligne 📎 suffit (« Laissé de côté : débat sur le choix du prestataire, sans conclusion »).
