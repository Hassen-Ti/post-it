---
type: llm
weight: 3
---
Vérité terrain. Export à utiliser : export_SAP_ventes_0926_v2_FINAL.xlsx (le plus récent ; l'ancien export et sa copie « (1) » n'ont pas FA-2026-306). Factures Axa de septembre :
- FA-2026-301 (2 880,00 TTC), FA-2026-302 (3 150,00, PDF scanné), FA-2026-303 (7 200,00, Factur-X), FA-2026-304 (1 800,00, présente en double) : conformes à SAP.
- FA-2026-305 (PDF scanné) : 4 800,00 € TTC (4 000 HT) sur la facture contre 4 080,00 € TTC (3 400 HT) dans SAP → écart de 720 € TTC (600 € HT).
- FA-2026-306 : dans SAP (1 140,00 TTC) mais aucune facture PDF trouvée.
- FA-2026-288 est d'août : hors périmètre. La ligne FA-2026-301 « Annulée » (masquée) et les sous-totaux ne sont pas des factures.
PASS si la réponse finale identifie l'écart FA-2026-305 (720 € TTC ou 600 € HT) ET la facture FA-2026-306 sans PDF, sans signaler de faux écart sur 301, 302, 303 ou 304 (ni doublon comptabilisé deux fois, ni FA-288 traité comme écart de septembre).
FAIL si l'un des deux vrais écarts manque, ou si un faux écart est affirmé.
