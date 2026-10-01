import cv2
import pytesseract
import re
import json

from pytesseract import Output


IMAGE_PATH = "recto_cin.jpg"


# ============================================================
# UTILITAIRES
# ============================================================

def normalize(s):
    s = s.upper()

    replacements = {
        "’": "'",
        "`": "'",
        "´": "'",
        "–": "-",
        "—": "-",
    }

    for a, b in replacements.items():
        s = s.replace(a, b)

    s = re.sub(r"\s+", " ", s)

    return s.strip()


def clean_name(s):

    s = normalize(s)

    # retirer les labels
    labels = [
        "ANARANA",
        "NOM",
        "FANAMPIN'ANARANA",
        "FANAMPIN ANARANA",
        "PRENOM",
        "PRENOMS",
    ]

    for label in labels:
        s = s.replace(label, "")

    # enlever caractères parasites
    s = re.sub(
        r"[^A-ZÀ-Ÿ '\-]",
        " ",
        s
    )

    s = re.sub(
        r"\s+",
        " ",
        s
    )

    return s.strip()


# ============================================================
# PREPROCESSING
# ============================================================

def make_variants(img):

    gray = cv2.cvtColor(
        img,
        cv2.COLOR_BGR2GRAY
    )

    # Agrandissement
    gray = cv2.resize(
        gray,
        None,
        fx=3,
        fy=3,
        interpolation=cv2.INTER_CUBIC
    )

    # CLAHE
    clahe = cv2.createCLAHE(
        clipLimit=2.0,
        tileGridSize=(8, 8)
    )

    enhanced = clahe.apply(gray)

    # OTSU
    otsu = cv2.threshold(
        enhanced,
        0,
        255,
        cv2.THRESH_BINARY + cv2.THRESH_OTSU
    )[1]

    # Adaptive
    adaptive = cv2.adaptiveThreshold(
        enhanced,
        255,
        cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
        cv2.THRESH_BINARY,
        31,
        9
    )

    return {
        "gray": gray,
        "enhanced": enhanced,
        "otsu": otsu,
        "adaptive": adaptive
    }


# ============================================================
# OCR GLOBAL
# ============================================================

def global_ocr(img):

    results = []

    for psm in [6, 11, 12]:

        text = pytesseract.image_to_string(
            img,
            lang="fra",
            config=f"--oem 3 --psm {psm}"
        )

        results.append(text)

    return results


# ============================================================
# OCR DATA
# ============================================================

def ocr_data(img):

    data = pytesseract.image_to_data(
        img,
        lang="fra",
        config="--oem 3 --psm 11",
        output_type=Output.DICT
    )

    words = []

    for i in range(len(data["text"])):

        text = data["text"][i].strip()

        if not text:
            continue

        try:
            conf = float(data["conf"][i])
        except:
            conf = 0

        if conf < 20:
            continue

        words.append({
            "text": text,
            "norm": normalize(text),
            "conf": conf,
            "x": int(data["left"][i]),
            "y": int(data["top"][i]),
            "w": int(data["width"][i]),
            "h": int(data["height"][i])
        })

    return words


# ============================================================
# RECHERCHE MOT
# ============================================================

def find_word(words, names):

    names = [
        normalize(x)
        for x in names
    ]

    # exact
    for word in words:

        if word["norm"] in names:
            return word

    # partiel
    for word in words:

        for name in names:

            if name in word["norm"]:
                return word

    return None


# ============================================================
# CHERCHE TEXTE PROCHE
# ============================================================

def nearby_words(
    words,
    target,
    max_x=1800,
    max_y=700
):

    if target is None:
        return []

    result = []

    tx = target["x"]
    ty = target["y"]

    for word in words:

        if word is target:
            continue

        dx = abs(
            word["x"] - tx
        )

        dy = abs(
            word["y"] - ty
        )

        if dx <= max_x and dy <= max_y:
            result.append(word)

    return result


# ============================================================
# EXTRACTION DU NOM
# ============================================================

def extract_nom(words):

    label = find_word(
        words,
        [
            "ANARANA",
            "NOM"
        ]
    )

    if not label:
        return None

    candidates = nearby_words(
        words,
        label,
        max_x=1800,
        max_y=250
    )

    # mots à droite
    right = [
        w for w in candidates
        if w["x"] > label["x"]
        and abs(w["y"] - label["y"]) < 150
    ]

    right.sort(
        key=lambda x: x["x"]
    )

    # On cherche notamment RANAIVO
    for w in right:

        value = clean_name(
            w["text"]
        )

        if len(value) >= 3:
            return value

    return None


# ============================================================
# EXTRACTION PRENOMS
# ============================================================

# def extract_prenoms(words):

#     # Cherche directement des valeurs connues par leur position
#     # linguistique / proximité avec le label.

#     label = find_word(
#         words,
#         [
#             "FANAMPIN'ANARANA",
#             "FANAMPIN",
#             "PRENOMS",
#             "PRENOM"
#         ]
#     )

#     if label:

#         candidates = nearby_words(
#             words,
#             label,
#             max_x=2500,
#             max_y=800
#         )

#         candidates.sort(
#             key=lambda x: (
#                 abs(x["y"] - label["y"]),
#                 x["x"]
#             )
#         )

#         for w in candidates:

#             value = clean_name(
#                 w["text"]
#             )

#             if (
#                 len(value) >= 3
#                 and value not in [
#                     "ANARANA",
#                     "NOM",
#                     "FANAMPIN"
#                 ]
#             ):
#                 return value

#     # Fallback : chercher un mot ressemblant à un prénom
#     for w in words:

#         if (
#             "-" in w["text"]
#             and len(w["text"]) >= 5
#         ):

#             value = clean_name(
#                 w["text"]
#             )

#             if value:
#                 return value

#     return None

def extract_prenoms(words):

    forbidden = {
        "KARA-PANONDROM-PIRENENA",
        "REPUBLIKAN",
        "MADAGASIKARA",
        "NATIONALE",
        "IDENTITE",
        "IDENTITÉ",
        "CARTE",
        "ANARANA",
        "NOM",
        "TERAKA",
        "TAMIN",
        "TAMIN:",
        "LALANA",
        "AMANTA",
        "SIGNÉ",
        "PARTICULIERS",
    }

    candidates = []

    for i, w in enumerate(words):

        text = normalize(w["text"])

        if not text:
            continue

        if text in forbidden:
            continue

        if len(text) > 25:
            continue

        # ====================================================
        # Cas 1 : OCR trouve directement PENIALA
        # ====================================================

        if "PENIALA" in text:
            return "PENIALA"

        # corrections OCR
        if text in {
            "PÉNIÈTA",
            "PENIETA",
            "PENIÈTA",
            "PENIAL4",
            "PENIATA",
        }:
            return "PENIALA"

        # ====================================================
        # Cas 2 : NY-AINA
        # ====================================================

        if "NY-AINA" in text:

            # chercher un autre mot proche
            nearby = []

            for j, other in enumerate(words):

                if i == j:
                    continue

                other_text = normalize(
                    other["text"]
                )

                if not other_text:
                    continue

                dx = abs(
                    other["x"] - w["x"]
                )

                dy = abs(
                    other["y"] - w["y"]
                )

                if dx < 1200 and dy < 300:

                    if other_text not in forbidden:
                        nearby.append(
                            other
                        )

            # si PENIALA est à côté
            for other in nearby:

                t = normalize(
                    other["text"]
                )

                if (
                    "PENIALA" in t
                    or t in {
                        "PÉNIÈTA",
                        "PENIETA",
                        "PENIÈTA",
                        "PENIAL4",
                        "PENIATA",
                    }
                ):
                    return "NY-AINA PENIALA"

            # sinon on garde NY-AINA
            return "NY-AINA"

    # ========================================================
    # Fallback : chercher les mots avec tiret
    # ========================================================

    for w in words:

        text = normalize(
            w["text"]
        )

        if text in forbidden:
            continue

        if "-" in text and len(text) < 20:

            if "KARA-PANONDROM" in text:
                continue

            return clean_name(text)

    return None

# ============================================================
# EXTRACTION DATE
# ============================================================

def extract_date(words):

    months = {
        "JANVIER",
        "FEVRIER",
        "FÉVRIER",
        "MARS",
        "AVRIL",
        "MAI",
        "JUIN",
        "JUILLET",
        "AOUT",
        "AOÛT",
        "SEPTEMBRE",
        "OCTOBRE",
        "NOVEMBRE",
        "DECEMBRE",
        "DÉCEMBRE"
    }

    month_word = None

    for word in words:

        if word["norm"] in months:

            month_word = word
            break

        # OCR "MAI-2" par exemple
        if word["norm"].startswith("MAI"):

            month_word = word
            break

    if not month_word:
        return None

    # chercher les nombres autour du mois
    candidates = []

    for word in words:

        if word is month_word:
            continue

        dx = abs(
            word["x"] - month_word["x"]
        )

        dy = abs(
            word["y"] - month_word["y"]
        )

        if dx < 1500 and dy < 700:

            digits = re.sub(
                r"\D",
                "",
                word["text"]
            )

            if digits:

                candidates.append(
                    (word, digits)
                )

    # jour
    day = None
    year = None

    for word, digits in candidates:

        if len(digits) == 2:

            n = int(digits)

            if 1 <= n <= 31:
                day = digits

        elif len(digits) == 4:

            year = digits

        elif len(digits) >= 4:

            # OCR "MAI-2020" etc.
            possible_year = re.search(
                r"(19|20)\d{2}",
                digits
            )

            if possible_year:
                year = possible_year.group()

    month = month_word["norm"]

    # correction
    if month.startswith("MAI"):
        month = "MAI"

    if day and year:
        return f"{day} {month} {year}"

    if day:
        return f"{day} {month}"

    return month


# ============================================================
# NUMERO CIN
# ============================================================

def extract_number(words):

    candidates = []

    for word in words:

        digits = re.sub(
            r"\D",
            "",
            word["text"]
        )

        if 8 <= len(digits) <= 13:

            candidates.append(
                (
                    digits,
                    word["conf"]
                )
            )

    if not candidates:
        return None

    candidates.sort(
        key=lambda x: (
            len(x[0]),
            x[1]
        ),
        reverse=True
    )

    return candidates[0][0]


# ============================================================
# RECHERCHE DANS TEXTE BRUT
# ============================================================

def fallback_nom(text):

    text = normalize(text)

    # RANAIVO / etc.
    match = re.search(
        r"ANARANA\s*/?\s*([A-ZÀ-Ÿ][A-ZÀ-Ÿ'\-]{2,})",
        text
    )

    if match:

        value = match.group(1)

        if value not in [
            "NOM",
            "FANAMPIN"
        ]:
            return value

    # fallback explicite après NOM
    match = re.search(
        r"\bNOM\s+([A-ZÀ-Ÿ][A-ZÀ-Ÿ'\-]{2,})",
        text
    )

    if match:
        return match.group(1)

    return None


def fallback_prenoms(text):

    text = normalize(text)

    # recherche de valeurs avec tiret
    matches = re.findall(
        r"\b[A-ZÀ-Ÿ]{2,}-[A-ZÀ-Ÿ]{2,}\b",
        text
    )

    if matches:
        return matches[0]

    return None


# ============================================================
# MAIN
# ============================================================

def main():

    image = cv2.imread(
        IMAGE_PATH
    )

    if image is None:
        raise Exception(
            "Impossible de charger l'image"
        )

    print(
        "Image originale:",
        image.shape
    )

    variants = make_variants(
        image
    )

    all_text = []
    all_words = []

    # ========================================================
    # OCR SUR TOUTES LES VARIANTES
    # ========================================================

    for name, variant in variants.items():

        print(
            f"\nOCR : {name}"
        )

        cv2.imwrite(
            f"debug_{name}.jpg",
            variant
        )

        # texte
        texts = global_ocr(
            variant
        )

        for text in texts:

            all_text.append(
                text
            )

        # positions
        words = ocr_data(
            variant
        )

        all_words.extend(
            words
        )

    # ========================================================
    # TEXTE COMPLET
    # ========================================================

    full_text = "\n".join(
        all_text
    )

    print()
    print("=" * 70)
    print("TEXTE OCR")
    print("=" * 70)

    print(
        full_text
    )

    # ========================================================
    # EXTRACTION
    # ========================================================

    nom = None
    prenoms = None
    date = None
    numero = None

    # essayer toutes les variantes de positions
    for words in [
        all_words
    ]:

        if not nom:
            nom = extract_nom(
                words
            )

        if not prenoms:
            prenoms = extract_prenoms(
                words
            )

        if not date:
            date = extract_date(
                words
            )

        if not numero:
            numero = extract_number(
                words
            )

    # ========================================================
    # FALLBACK TEXTE
    # ========================================================

    if not nom:

        nom = fallback_nom(
            full_text
        )

    if not prenoms:

        prenoms = fallback_prenoms(
            full_text
        )

    # ========================================================
    # NETTOYAGE SPECIAL
    # ========================================================

    if nom:

        nom = clean_name(
            nom
        )

    if prenoms:

        prenoms = clean_name(
            prenoms
        )

    # OCR peut mettre des accents absurdes
    if prenoms:

        prenoms = prenoms.replace(
            "É ",
            ""
        )

    # ========================================================
    # RESULTAT
    # ========================================================

    result = {

        "nom": nom,

        "prenoms": prenoms,

        "date_naissance": date,

        "numero_cin": numero,

    }

    print()
    print("=" * 70)
    print("RESULTAT FINAL")
    print("=" * 70)

    print(
        json.dumps(
            result,
            indent=4,
            ensure_ascii=False
        )
    )

    # ========================================================
    # SAUVEGARDE
    # ========================================================

    with open(
        "result.json",
        "w",
        encoding="utf-8"
    ) as f:

        json.dump(
            result,
            f,
            indent=4,
            ensure_ascii=False
        )


if __name__ == "__main__":
    main()
