---
type: regex
# BC-5521 n'existe que dans le mail exporté (pas dans la demande) : le citer prouve que Claude est allé lire
# au lieu de demander « quel mail ? ». Critère sur le résultat plutôt que sur l'outil : un motif sur la trace
# (Read|Grep) ratait 6 lectures sur 15.
pattern: 'BC-?5521'
---
