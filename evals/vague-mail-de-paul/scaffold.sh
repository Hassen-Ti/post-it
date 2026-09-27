#!/usr/bin/env bash
# Recrée la boîte mail exportée et le suivi budgétaire dans le dossier de travail.
set -e
mkdir -p resources/boite_mail
cat > 'resources/boite_mail/2026-09-15_paul-martin_dejeuner.txt' <<'FIN'
De : Paul Martin <p.martin@monentreprise.fr>
Date : 15/09/2026 12:40
À : équipe
Objet : Déjeuner d'équipe

Hello, déjeuner d'équipe jeudi 18 au Bistrot, qui vient ?
FIN
cat > 'resources/boite_mail/2026-09-22_paul-martin_bon-de-commande.txt' <<'FIN'
De : Paul Martin <p.martin@monentreprise.fr>
Date : 25/09/2026 09:12
À : moi
Objet : BC-5521 - validation

Salut,
Peux-tu valider le bon de commande BC-5521 (prestataire Sopra, 18 000 € HT, centre de coût 420) avant mercredi 30/09 ? Sans validation, le prestataire ne démarre pas le 1er octobre.
Merci
Paul
FIN
cat > 'resources/boite_mail/2026-09-23_newsletter.txt' <<'FIN'
De : DFCG <news@dfcg.fr>
Date : 23/09/2026
Objet : Webinar IFRS 18
FIN
cat > 'resources/budget_centres_2026.csv' <<'FIN'
Centre;Libellé;Budget annuel;Engagé à date
410;Achats;5000000;3680000
420;Transport;3400000;3378000
430;Informatique;2100000;1650000
FIN
