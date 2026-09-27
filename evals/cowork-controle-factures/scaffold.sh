#!/usr/bin/env bash
# Recrée le dossier Telechargements piégé (générateur embarqué : scripts/make_fixture_telechargements.py).
set -e
python - . <<'PY'
"""Fabrique un faux dossier « Téléchargements » réaliste pour tester Post-it en mode Cowork.

Tâche testée : « Vérifie que les factures Axa de septembre correspondent à l'export SAP ».
Vérité terrain (export le plus récent = export_SAP_ventes_0926_v2_FINAL.xlsx) :
  FA-2026-301 texte        2 880,00 TTC  = SAP
  FA-2026-302 scan         3 150,00 TTC  = SAP (stocké en texte « 3 150,00 » dans l'export)
  FA-2026-303 Factur-X     7 200,00 TTC  = SAP (page visible quasi illisible, XML embarqué exact)
  FA-2026-304 texte        1 800,00 TTC  = SAP (+ doublon « FA-2026-304 (1).pdf »)
  FA-2026-305 scan (24/09) 4 800,00 TTC ≠ SAP 4 080,00  → écart 720,00
  FA-2026-306 absente      SAP 1 140,00 TTC, aucun PDF   → facture manquante
Pièges : FA-2026-288 (Axa, août), sous-totaux dans l'export, ligne masquée « Annulée »,
ancien export sans FA-306 + sa copie « (1) », gros PDF hors sujet, fichiers parasites.

Usage : python scripts/make_fixture_telechargements.py <dossier_cible>
"""
import datetime as dt
import io
import os
import random
import sys
from pathlib import Path

import fitz  # PyMuPDF
from openpyxl import Workbook
from openpyxl.styles import Font
from PIL import Image, ImageDraw, ImageFilter, ImageFont

random.seed(42)
OUT = Path(sys.argv[1]) / "Telechargements"
OUT.mkdir(parents=True, exist_ok=True)

EMETTEUR = ["MonEntreprise SAS", "12 rue des Lilas, 69003 Lyon", "SIREN 812 345 678 - TVA FR27812345678"]
CLIENTS = {
    "Axa": ("AXA France IARD", "313, Terrasses de l'Arche, 92727 Nanterre", "SIREN 722 057 460"),
    "Engie": ("ENGIE SA", "1 place Samuel de Champlain, 92400 Courbevoie", "SIREN 542 107 651"),
    "Orange": ("Orange SA", "111 quai du Président Roosevelt, 92130 Issy", "SIREN 380 129 866"),
}


def eur(x):
    return f"{x:,.2f}".replace(",", " ").replace(".", ",") + " €"


def invoice_lines(num, date, client, lignes):
    ht = sum(q * pu for _, q, pu in lignes)
    tva = round(ht * 0.20, 2)
    ttc = ht + tva
    ech = date + dt.timedelta(days=45)
    txt = [*EMETTEUR, "", f"FACTURE N° {num}", f"Date : {date:%d/%m/%Y}", "",
           "Client :", *CLIENTS[client], "",
           "Désignation                              Qté     PU HT       Total HT"]
    for d, q, pu in lignes:
        txt.append(f"{d:<40} {q:>3}  {eur(pu):>12}  {eur(q * pu):>12}")
    txt += ["", f"Total HT : {eur(ht)}", f"TVA 20 % : {eur(tva)}", f"Total TTC : {eur(ttc)}", "",
            f"Échéance : {ech:%d/%m/%Y} - Paiement par virement",
            "IBAN FR76 1027 8073 0000 0204 5670 145",
            "Pénalités de retard : 3 fois le taux d'intérêt légal. Indemnité forfaitaire de recouvrement : 40 €."]
    return txt, ht, tva, ttc, ech


def text_pdf(path, lines):
    doc = fitz.open()
    page = doc.new_page(width=595, height=842)
    y = 60
    for l in lines:
        page.insert_text((50, y), l, fontsize=10, fontname="cour")
        y += 15
    doc.save(path)


def render_image(lines, scale=1.0, blur=0.0, angle=0.0, noise=True):
    W, H = int(1240 * scale), int(1754 * scale)
    img = Image.new("L", (W, H), 250)
    d = ImageDraw.Draw(img)
    try:
        font = ImageFont.truetype("cour.ttf", int(22 * scale))
    except OSError:
        font = ImageFont.load_default()
    y = int(110 * scale)
    for l in lines:
        d.text((int(90 * scale), y), l, fill=25, font=font)
        y += int(32 * scale)
    if noise:
        px = img.load()
        for _ in range(W * H // 60):
            x, yy = random.randrange(W), random.randrange(H)
            px[x, yy] = random.randint(150, 230)
    img = img.rotate(angle, fillcolor=245, expand=False)
    if blur:
        img = img.filter(ImageFilter.GaussianBlur(blur))
    return img


def image_pdf(path, img):
    buf = io.BytesIO()
    img.convert("RGB").save(buf, format="JPEG", quality=70)
    doc = fitz.open()
    page = doc.new_page(width=595, height=842)
    page.insert_image(page.rect, stream=buf.getvalue())
    doc.save(path)
    return doc


def facturx_xml(num, date, client, ht, tva, ttc, ech):
    c = CLIENTS[client]
    return f"""<?xml version="1.0" encoding="UTF-8"?>
<rsm:CrossIndustryInvoice xmlns:rsm="urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100"
 xmlns:ram="urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100"
 xmlns:udt="urn:un:unece:uncefact:data:standard:UnqualifiedDataType:100">
 <rsm:ExchangedDocumentContext><ram:GuidelineSpecifiedDocumentContextParameter><ram:ID>urn:factur-x.eu:1p0:basic</ram:ID></ram:GuidelineSpecifiedDocumentContextParameter></rsm:ExchangedDocumentContext>
 <rsm:ExchangedDocument><ram:ID>{num}</ram:ID><ram:TypeCode>380</ram:TypeCode>
  <ram:IssueDateTime><udt:DateTimeString format="102">{date:%Y%m%d}</udt:DateTimeString></ram:IssueDateTime></rsm:ExchangedDocument>
 <rsm:SupplyChainTradeTransaction>
  <ram:ApplicableHeaderTradeAgreement>
   <ram:SellerTradeParty><ram:Name>{EMETTEUR[0]}</ram:Name></ram:SellerTradeParty>
   <ram:BuyerTradeParty><ram:Name>{c[0]}</ram:Name></ram:BuyerTradeParty>
  </ram:ApplicableHeaderTradeAgreement>
  <ram:ApplicableHeaderTradeSettlement><ram:InvoiceCurrencyCode>EUR</ram:InvoiceCurrencyCode>
   <ram:SpecifiedTradePaymentTerms><ram:DueDateDateTime><udt:DateTimeString format="102">{ech:%Y%m%d}</udt:DateTimeString></ram:DueDateDateTime></ram:SpecifiedTradePaymentTerms>
   <ram:SpecifiedTradeSettlementHeaderMonetarySummation>
    <ram:TaxBasisTotalAmount>{ht:.2f}</ram:TaxBasisTotalAmount>
    <ram:TaxTotalAmount currencyID="EUR">{tva:.2f}</ram:TaxTotalAmount>
    <ram:GrandTotalAmount>{ttc:.2f}</ram:GrandTotalAmount>
    <ram:DuePayableAmount>{ttc:.2f}</ram:DuePayableAmount>
   </ram:SpecifiedTradeSettlementHeaderMonetarySummation>
  </ram:ApplicableHeaderTradeSettlement>
 </rsm:SupplyChainTradeTransaction>
</rsm:CrossIndustryInvoice>
"""


def touch(path, when):
    ts = when.timestamp()
    os.utime(path, (ts, ts))


D = dt.datetime
# ---------------------------------------------------------------- factures
factures = [
    ("FA-2026-301", dt.date(2026, 9, 5), "Axa", [("Mission conseil clôture - jours", 3, 800.0)], "texte"),
    ("FA-2026-302", dt.date(2026, 9, 10), "Axa", [("Audit processus facturation - jours", 3, 875.0)], "scan"),
    ("FA-2026-303", dt.date(2026, 9, 15), "Axa", [("Accompagnement migration ERP - forfait", 1, 6000.0)], "facturx"),
    ("FA-2026-304", dt.date(2026, 9, 22), "Axa", [("Formation équipe comptable - jours", 2, 750.0)], "texte"),
    ("FA-2026-305", dt.date(2026, 9, 24), "Axa", [("Revue des provisions - jours", 5, 800.0)], "scan"),
    ("FA-2026-288", dt.date(2026, 8, 28), "Axa", [("Mission conseil août - jours", 2, 800.0)], "texte"),
    ("FA-2026-310", dt.date(2026, 9, 12), "Engie", [("Assistance contrôle de gestion - jours", 4, 700.0)], "texte"),
    ("FA-2026-311", dt.date(2026, 9, 18), "Orange", [("Paramétrage reporting - forfait", 1, 3200.0)], "scan"),
]
for num, date, client, lignes, kind in factures:
    lines, ht, tva, ttc, ech = invoice_lines(num, date, client, lignes)
    name = f"{num}_{client}.pdf" if kind != "scan" else f"Scan_{date:%Y%m%d}_{random.randint(1000, 9999)}.pdf"
    path = OUT / name
    if kind == "texte":
        text_pdf(path, lines)
    elif kind == "scan":
        image_pdf(path, render_image(lines, angle=random.uniform(-1.2, 1.2)))
    elif kind == "facturx":
        # Page visible = mauvaise copie basse définition (comme un PDF « imprimé-scanné » par le client),
        # mais le XML Factur-X embarqué porte les montants exacts.
        doc = image_pdf(path, render_image(lines, scale=0.45, blur=1.3, angle=0.8))
        doc = fitz.open(path)
        doc.embfile_add("factur-x.xml", facturx_xml(num, date, client, ht, tva, ttc, ech).encode("utf-8"),
                        filename="factur-x.xml", desc="Factur-X BASIC")
        doc.saveIncr()
    touch(path, D.combine(date, dt.time(9, 30)) + dt.timedelta(days=1))

# doublon navigateur
dup = OUT / "FA-2026-304_Axa (1).pdf"
dup.write_bytes((OUT / "FA-2026-304_Axa.pdf").read_bytes())
touch(dup, D(2026, 9, 24, 17, 2))

# ---------------------------------------------------------------- exports SAP
def export_sap(path, include_306, when):
    wb = Workbook()
    ws = wb.active
    ws.title = "Export"
    ws["A1"] = "Export ventes - MonEntreprise SAS - Période 09/2026"
    ws["A1"].font = Font(bold=True, size=13)
    ws.merge_cells("A1:G1")
    ws["A2"] = f"Extrait le {when:%d/%m/%Y %H:%M} par jdupont - SAP S/4 - transaction VF05"
    ws.append([])
    ws.append(["Client", "N° facture", "Date", "Montant HT", "TVA", "Montant TTC", "Statut"])
    for c in ws[4]:
        c.font = Font(bold=True)
    rows = {
        "Axa": [("FA-2026-301", dt.date(2026, 9, 5), 2400, 480, 2880, "Comptabilisée"),
                ("FA-2026-301", dt.date(2026, 9, 5), 2400, 480, 2880, "Annulée"),  # masquée
                ("FA-2026-302", dt.date(2026, 9, 10), "2 625,00", "525,00", "3 150,00", "Comptabilisée"),  # texte
                ("FA-2026-303", dt.date(2026, 9, 15), 6000, 1200, 7200, "Comptabilisée"),
                ("FA-2026-304", dt.date(2026, 9, 22), 1500, 300, 1800, "Comptabilisée"),
                ("FA-2026-305", dt.date(2026, 9, 24), 3400, 680, 4080, "Comptabilisée")],
        "Engie": [("FA-2026-310", dt.date(2026, 9, 12), 2800, 560, 3360, "Comptabilisée"),
                  ("FA-2026-312", dt.date(2026, 9, 23), 1200, 240, 1440, "Comptabilisée")],
        "Orange": [("FA-2026-311", dt.date(2026, 9, 18), 3200, 640, 3840, "Comptabilisée")],
    }
    if include_306:
        rows["Axa"].append(("FA-2026-306", dt.date(2026, 9, 25), 950, 190, 1140, "Comptabilisée"))
    tot = [0, 0, 0]
    for client, lst in rows.items():
        st = [0, 0, 0]
        for num, date, ht, tva, ttc, statut in lst:
            ws.append([client, num, date, ht, tva, ttc, statut])
            r = ws.max_row
            ws.cell(r, 3).number_format = "DD/MM/YYYY"
            if statut == "Annulée":
                ws.row_dimensions[r].hidden = True
                continue
            vals = [float(str(v).replace(" ", "").replace(",", ".")) for v in (ht, tva, ttc)]
            st = [a + b for a, b in zip(st, vals)]
        ws.append([f"Sous-total {client}", None, None, *st, None])
        for c in ws[ws.max_row]:
            c.font = Font(bold=True)
        tot = [a + b for a, b in zip(tot, st)]
    ws.append(["Total général", None, None, *tot, None])
    for col in "ABCDEFG":
        ws.column_dimensions[col].width = 16
    wb.save(path)
    touch(path, when)


export_sap(OUT / "export_SAP_ventes_0926.xlsx", include_306=False, when=D(2026, 9, 26, 8, 41))
(OUT / "export_SAP_ventes_0926 (1).xlsx").write_bytes((OUT / "export_SAP_ventes_0926.xlsx").read_bytes())
touch(OUT / "export_SAP_ventes_0926 (1).xlsx", D(2026, 9, 26, 8, 43))
export_sap(OUT / "export_SAP_ventes_0926_v2_FINAL.xlsx", include_306=True, when=D(2026, 9, 26, 18, 5))

# ---------------------------------------------------------------- parasites
def long_pdf(path, title, pages, when):
    doc = fitz.open()
    para = ("Le présent document décrit les orientations stratégiques, les résultats financiers et les "
            "perspectives du groupe. Les données sont présentées en milliers d'euros sauf mention contraire. ")
    for p in range(pages):
        page = doc.new_page()
        page.insert_textbox(fitz.Rect(50, 50, 545, 800), f"{title} - page {p + 1}\n\n" + para * 22, fontsize=9)
    doc.save(path)
    touch(path, when)


long_pdf(OUT / "Rapport_annuel_2025_AXA.pdf", "Rapport annuel 2025", 60, D(2026, 9, 3, 10, 0))
long_pdf(OUT / "Conditions_generales_de_vente_2026.pdf", "Conditions générales de vente", 12, D(2026, 9, 2, 11, 0))
text_pdf(OUT / "Billet_train_Paris_Lyon_E-ticket.pdf",
         ["SNCF - E-billet", "Paris Gare de Lyon -> Lyon Part-Dieu", "Départ 18/09/2026 07:04", "Voiture 12 place 45"])
touch(OUT / "Billet_train_Paris_Lyon_E-ticket.pdf", D(2026, 9, 11, 21, 15))
text_pdf(OUT / "CV_Julien_Mercier_2026.pdf", ["Julien Mercier", "Contrôleur de gestion - 6 ans d'expérience"])
touch(OUT / "CV_Julien_Mercier_2026.pdf", D(2026, 9, 19, 14, 0))
text_pdf(OUT / "Menu_cantine_semaine_39.pdf", ["Lundi : lasagnes", "Mardi : poisson pané", "Mercredi : couscous"])
touch(OUT / "Menu_cantine_semaine_39.pdf", D(2026, 9, 21, 8, 0))
img = render_image(["photo"], scale=0.3, noise=True)
img.convert("RGB").save(OUT / "IMG_20260914_182233.jpg", quality=60)
touch(OUT / "IMG_20260914_182233.jpg", D(2026, 9, 14, 18, 22))
(OUT / "ZoomInstaller.exe").write_bytes(os.urandom(4096))
touch(OUT / "ZoomInstaller.exe", D(2026, 9, 1, 9, 0))
(OUT / "notes réunion.txt").write_text("appeler Karim pour le forecast\nrelancer Engie ?\n", encoding="utf-8")
touch(OUT / "notes réunion.txt", D(2026, 9, 23, 16, 30))
with open(OUT / "Releve_BNP_septembre_2026.csv", "w", encoding="cp1252") as f:
    f.write("Date;Libellé;Débit;Crédit\n")
    f.write("12/09/2026;VIR AXA FRANCE IARD FA-2026-288;;1 920,00\n")
    f.write("20/09/2026;VIR ENGIE SA;;3 360,00\n")
    f.write("25/09/2026;PRLV URSSAF;18 450,00;\n")
touch(OUT / "Releve_BNP_septembre_2026.csv", D(2026, 9, 27, 9, 12))
wb = Workbook()
ws = wb.active
ws.append(["Compte", "Libellé", *[f"M{m:02d}" for m in range(1, 13)]])
for i in range(3000):
    ws.append([f"6{random.randint(10000, 99999)}", f"Charge {i}", *[random.randint(0, 9000) for _ in range(12)]])
wb.save(OUT / "Budget_2026_detail_comptes.xlsx")
touch(OUT / "Budget_2026_detail_comptes.xlsx", D(2026, 9, 8, 15, 0))

print(f"{len(list(OUT.iterdir()))} fichiers dans {OUT}")
PY
