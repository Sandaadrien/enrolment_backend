"""
OCR du recto d'une CIN malagasy (Kara-panondrom-pirenena).

Principe :
  * Sur la CIN, les LIBELLES imprimes (ANARANA, TERAKA TAMIN'NY...) sont en gris,
    les DONNEES saisies sont en noir profond -> un seuillage tres sombre
    elimine libelles, filigrane et tampon rouge.
  * On decoupe la carte en zones (ROI) par champ, on fait plusieurs passes OCR
    (seuils differents) et on garde la meilleure lecture selon des regles de validation.
  * Les libelles servent aussi de repli : si une zone echoue, on cherche par regex
    dans l'OCR complet.

Dependances : opencv-python-headless, pytesseract, numpy
Systeme     : tesseract-ocr + tesseract-ocr-fra
"""
from __future__ import annotations

import re
from collections import Counter
from dataclasses import dataclass, asdict
from datetime import date
from typing import Optional

import cv2
import numpy as np
import pytesseract

MOIS = {
    "JANVIER": 1, "FEVRIER": 2, "FÉVRIER": 2, "MARS": 3, "AVRIL": 4, "MAI": 5,
    "JUIN": 6, "JUILLET": 7, "AOUT": 8, "AOÛT": 8, "SEPTEMBRE": 9,
    "OCTOBRE": 10, "NOVEMBRE": 11, "DECEMBRE": 12, "DÉCEMBRE": 12,
}

# (x0, y0, x1, y1) en fractions de la carte redimensionnee.
# A ajuster si votre cadrage differe (voir debug=True).
ROIS = {
    "nom":             (0.24, 0.205, 0.95, 0.295),
    "prenoms":         (0.42, 0.345, 0.98, 0.430),
    "date_naissance":  (0.48, 0.545, 0.98, 0.620),
    "lieu_naissance":  (0.48, 0.625, 0.98, 0.760),
    "signe_particulier": (0.38, 0.815, 0.98, 0.885),
    "numero":          (0.39, 0.905, 0.85, 0.995),
}

SEUILS = (70, 85, 100, 115, 125, 135)          # niveaux de gris : en dessous = encre noire
CARTE_LARGEUR = 2000                 # normalisation de taille


@dataclass
class CinData:
    nom: Optional[str] = None
    prenoms: Optional[str] = None
    date_naissance: Optional[str] = None        # ISO AAAA-MM-JJ
    date_naissance_brute: Optional[str] = None
    lieu_naissance: Optional[str] = None
    signe_particulier: Optional[str] = None
    numero: Optional[str] = None                # 12 chiffres
    confiance: float = 0.0
    avertissements: list = None

    def to_dict(self):
        d = asdict(self)
        d["avertissements"] = self.avertissements or []
        return d


# --------------------------------------------------------------------------- #
# Pre-traitement
# --------------------------------------------------------------------------- #
def charger(path_or_bytes) -> np.ndarray:
    if isinstance(path_or_bytes, (bytes, bytearray)):
        arr = np.frombuffer(path_or_bytes, np.uint8)
        img = cv2.imdecode(arr, cv2.IMREAD_COLOR)
    else:
        img = cv2.imread(str(path_or_bytes))
    if img is None:
        raise ValueError("Image illisible")
    h, w = img.shape[:2]
    if h > w * 1.1:                       # photo prise en portrait -> rotation
        img = cv2.rotate(img, cv2.ROTATE_90_CLOCKWISE)
    h, w = img.shape[:2]
    s = CARTE_LARGEUR / w
    return cv2.resize(img, (CARTE_LARGEUR, int(h * s)), interpolation=cv2.INTER_AREA if s < 1 else cv2.INTER_CUBIC)


def binariser(gris: np.ndarray, seuil: int) -> np.ndarray:
    """Ne garde que l'encre tres sombre (donnees), en noir sur blanc."""
    out = np.where(gris < seuil, 0, 255).astype("uint8")
    out = cv2.medianBlur(out, 3)
    return cv2.copyMakeBorder(out, 20, 20, 20, 20, cv2.BORDER_CONSTANT, value=255)


def decouper(img: np.ndarray, roi) -> np.ndarray:
    h, w = img.shape[:2]
    x0, y0, x1, y1 = roi
    return img[int(y0 * h):int(y1 * h), int(x0 * w):int(x1 * w)]


# --------------------------------------------------------------------------- #
# OCR bas niveau
# --------------------------------------------------------------------------- #
def _ocr(img, psm=6, whitelist=None, lang="fra") -> str:
    cfg = f"--psm {psm} --oem 1"
    if whitelist:
        cfg += f" -c tessedit_char_whitelist={whitelist}"
    return pytesseract.image_to_string(img, lang=lang, config=cfg).strip()


def _nettoyer_ligne(s: str) -> str:
    s = re.sub(r"[|_\[\]{}<>~=*#@$%^&+\\]", " ", s)
    return re.sub(r"\s+", " ", s).strip(" .,:;-'\"`")


def _lignes(txt: str) -> list[str]:
    return [l for l in (_nettoyer_ligne(x) for x in txt.splitlines()) if len(l) > 1]


# --------------------------------------------------------------------------- #
# Extraction par champ
# --------------------------------------------------------------------------- #
def _vote(candidats: list[str]) -> Optional[str]:
    candidats = [c for c in candidats if c]
    if not candidats:
        return None
    return Counter(candidats).most_common(1)[0][0]


def _vote_mot(candidats: list[str]) -> Optional[str]:
    """Vote caractere par caractere sur les lectures de meme longueur (noms propres)."""
    c = [x for x in candidats if x and re.fullmatch(r"[A-Za-zÀ-ÿ' \-]{3,}", x)]
    if not c:
        return _vote(candidats)
    L = Counter(len(x) for x in c).most_common(1)[0][0]
    c = [x for x in c if len(x) == L]
    return "".join(Counter(x[i] for x in c).most_common(1)[0][0] for i in range(L))


def lire_numero(gris_carte) -> tuple[Optional[str], list[str]]:
    roi = decouper(gris_carte, ROIS["numero"])
    lectures = []
    for s in SEUILS:
        b = binariser(roi, s)
        for psm in (7, 13):
            t = _ocr(b, psm=psm, whitelist="0123456789 ")
            digits = re.sub(r"\D", "", t)
            if len(digits) == 12:
                lectures.append(digits)
            elif len(digits) > 12:                      # bruit des cases -> on cherche 12 chiffres
                m = re.search(r"\d{12}", digits)
                if m:
                    lectures.append(m.group())
    best = _vote(lectures)
    warn = [] if best else ["Numero CIN non lu (12 chiffres attendus)"]
    return best, warn


def _corriger_annee(t: str) -> Optional[int]:
    """Corrige les confusions OCR classiques 0/8/9, O/0, I/1 sur 4 caracteres."""
    t = t.upper().replace("O", "0").replace("I", "1").replace("L", "1")
    if not re.fullmatch(r"\d{4}", t):
        return None
    if t[0] == "2":                       # 20xx : 2e chiffre = 0
        t = "20" + t[2:]
    elif t[0] == "1":                     # 19xx : 2e chiffre = 9
        t = "19" + t[2:]
    a = int(t)
    return a if 1900 <= a <= date.today().year else None


def lire_date(gris_carte) -> tuple[Optional[str], Optional[str], list[str]]:
    roi = decouper(gris_carte, ROIS["date_naissance"])
    jours, mois_l, ans = [], [], []
    for sc in SEUILS:
        b = binariser(roi, sc)
        for psm in (7, 6):
            t = _ocr(b, psm=psm).upper()
            m = re.search(r"([0-3OIl]?[0-9OIl])\s*([A-Z0-9ÉÛ]{3,9})\s*([0-9OIL]{4})", t)
            if not m:
                continue
            j = m.group(1).replace("O", "0").replace("I", "1").replace("L", "1")
            mo = _mois_proche(m.group(2))
            an = _corriger_annee(m.group(3))
            if j.isdigit() and 1 <= int(j) <= 31: jours.append(int(j))
            if mo: mois_l.append(mo)
            if an: ans.append(an)
    if not (jours and mois_l and ans):
        return None, None, ["Date de naissance non lue"]
    j, mo, a = (Counter(x).most_common(1)[0][0] for x in (jours, mois_l, ans))
    brut = f"{j:02d}/{mo:02d}/{a}"
    try:
        return date(a, mo, j).isoformat(), brut, []
    except ValueError:
        return None, brut, [f"Date invalide : {brut}"]


def _mois_proche(txt: str) -> Optional[int]:
    """Tolere 1-2 erreurs OCR sur le nom du mois (MAI lu MA1, JUIN lu JUlN...)."""
    txt = txt.replace("1", "I").replace("0", "O").replace("5", "S")
    if txt in MOIS:
        return MOIS[txt]
    best, best_d = None, 3
    for nom, num in MOIS.items():
        d = _lev(txt, nom)
        if d < best_d and d <= max(1, len(nom) // 4):
            best, best_d = num, d
    return best


def _lev(a: str, b: str) -> int:
    prev = list(range(len(b) + 1))
    for i, ca in enumerate(a, 1):
        cur = [i]
        for j, cb in enumerate(b, 1):
            cur.append(min(prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + (ca != cb)))
        prev = cur
    return prev[-1]


def lire_texte(gris_carte, cle, nb_lignes_max=1, majuscules=False) -> Optional[str]:
    roi = decouper(gris_carte, ROIS[cle])
    lectures = []
    for s in SEUILS:
        b = binariser(roi, s)
        ls = _lignes(_ocr(b, psm=6))
        # on retire les residus de libelles (mots tout en majuscules type "ANARANA")
        ls = [l for l in ls if not re.fullmatch(r"[A-Z' /\-]{6,}(?:/.*)?", l) or cle in ("nom", "lieu_naissance")]
        if ls:
            txt = " ".join(ls[:nb_lignes_max])
            lectures.append(txt.upper() if majuscules else txt)
    return _vote_mot(lectures) if cle in ("nom", "prenoms") else _vote(lectures)


# --------------------------------------------------------------------------- #
# API principale
# --------------------------------------------------------------------------- #
def extraire_cin(source, debug: bool = False) -> CinData:
    img = charger(source)
    gris = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    warns: list[str] = []

    numero, w = lire_numero(gris); warns += w
    date_iso, date_brute, w = lire_date(gris); warns += w
    nom = lire_texte(gris, "nom", 1, majuscules=True)
    prenoms = lire_texte(gris, "prenoms", 1)
    lieu = lire_texte(gris, "lieu_naissance", 2, majuscules=False)
    signe = lire_texte(gris, "signe_particulier", 1)

    if not nom: warns.append("Nom non lu")
    if not prenoms: warns.append("Prenoms non lus")
    if not lieu: warns.append("Lieu de naissance non lu")

    champs = [nom, prenoms, date_iso, lieu, numero]
    confiance = round(sum(1 for c in champs if c) / len(champs), 2)

    if debug:
        for k, roi in ROIS.items():
            cv2.imwrite(f"debug_{k}.png", binariser(decouper(gris, roi), 85))

    return CinData(
        nom=nom, prenoms=prenoms, date_naissance=date_iso,
        date_naissance_brute=date_brute, lieu_naissance=lieu,
        signe_particulier=signe, numero=numero,
        confiance=confiance, avertissements=warns,
    )


if __name__ == "__main__":
    import json, sys
    r = extraire_cin(sys.argv[1], debug="--debug" in sys.argv)
    print(json.dumps(r.to_dict(), ensure_ascii=False, indent=2))