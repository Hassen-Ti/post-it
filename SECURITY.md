# Sécurité

Post-it lit des mails et des fichiers de bureau : une faille peut exposer des données réelles.

**Signaler en privé** : [Security → Report a vulnerability](https://github.com/Hassen-Ti/post-it/security/advisories/new). Pas d'issue publique.

Sont concernés en particulier :

- une injection (mail ou fichier qui fait exécuter une instruction à Claude) que les garde-fous ne bloquent pas ;
- un envoi, paiement, partage ou suppression possible sans validation explicite de l'utilisateur ;
- une fuite de données personnelles ou de santé (RGPD) dans une réponse ou un brouillon.

Joins la demande, le contenu piégé (anonymisé) et la réponse obtenue. Réponse sous 7 jours. Un correctif s'accompagne d'un cas `evals/stress-*` pour que la faille ne revienne pas.
