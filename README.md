# Mellowlight Journal

Das redaktionelle Journal von Mellowlight. Läuft mit Jekyll, wird von GitHub
Actions gebaut und auf GitHub Pages unter **blog.mellowlight.de** veröffentlicht.

Diese Anleitung ist für Marie-Claire und Martin geschrieben. Programmierkenntnisse
sind nicht nötig — wer eine Textdatei speichern kann, kann einen Artikel schreiben.

---

## Inhalt

1. [Einen Artikel schreiben](#einen-artikel-schreiben)
2. [Das Front Matter](#das-front-matter)
3. [Kategorien und Themen](#kategorien-und-themen)
4. [Bilder vorbereiten](#bilder-vorbereiten)
5. [Fotostories mit vielen Bildern](#fotostories-mit-vielen-bildern)
6. [Artikeltypen](#artikeltypen)
7. [Was automatisch passiert](#was-automatisch-passiert)
8. [Lokal ausprobieren](#lokal-ausprobieren)
9. [Veröffentlichen](#veröffentlichen)
10. [Projektstruktur](#projektstruktur)
11. [Wartung](#wartung)

---

## Einen Artikel schreiben

1. Eine neue Datei in `_posts/` anlegen. Der Dateiname beginnt immer mit dem
   Datum: `2026-08-11-titel-des-artikels.md`
2. Oben das Front Matter einfügen (siehe unten).
3. Darunter den Text schreiben, in Markdown.
4. Bilder nach `assets/images/posts/` legen.
5. Datei speichern, committen, pushen.
6. Nach etwa zwei Minuten ist der Artikel online.

**Wichtig:** Im Text niemals eine Überschrift mit einem einzelnen `#` beginnen.
Die große Überschrift kommt automatisch aus dem Feld `title`. Im Text geht es
bei `##` los.

```markdown
---
title: "Wie viel Zeit braucht eine Hochzeitsreportage?"
slug: wie-viel-zeit-hochzeitsreportage
date: 2026-08-11
author: martin
categories: [hochzeitsfotografie]
tags: ["Hochzeitsreportage", "Zeitplan"]
excerpt: "Acht Stunden klingen nach viel. Wir rechnen einen echten Tag durch."
description: "Wie viele Stunden Hochzeitsfotografie ihr braucht — mit einem realistischen Zeitplan vom Getting Ready bis zum Tortenanschnitt."
hero_image: /assets/images/posts/brautpaar-vor-bergen.webp
hero_image_alt: "Brautpaar vor einer Bergkulisse"
---

Der erste Absatz steht direkt hier.

## Die erste Zwischenüberschrift

Und so weiter.
```

---

## Das Front Matter

Das Front Matter ist der Block zwischen den beiden `---` ganz oben.

### Pflichtfelder

| Feld | Was es ist |
|---|---|
| `title` | Die Überschrift. In Anführungszeichen. |
| `date` | Datum im Format `2026-08-11`. |
| `description` | Der Text, den Google im Suchergebnis anzeigt. 120–160 Zeichen. |
| `categories` | Mindestens eine der sechs Kategorien (siehe unten). |
| `hero_image` | Das große Bild oben. Pfad ab `/assets/…`. |
| `hero_image_alt` | Bildbeschreibung für blinde Leser:innen und Google. |

### Empfohlen

| Feld | Was es ist |
|---|---|
| `slug` | Die Adresse des Artikels: `blog.mellowlight.de/slug/`. Kleinschreibung, Bindestriche. Ohne Angabe wird der Dateiname verwendet. |
| `excerpt` | Der Vorspann, der im Artikel unter der Überschrift steht. Ein bis zwei Sätze. Nicht dasselbe wie `description`. |
| `author` | `mc`, `martin` oder `mc-martin`. Standard ist `mc-martin`. |
| `tags` | Freie Schlagworte in Anführungszeichen, z. B. `["Standesamt", "Würzburg"]`. |
| `type` | `guide`, `story`, `location` oder `wissen`. Standard ist `guide`. |

### Optional

| Feld | Was es ist |
|---|---|
| `featured: true` | Der Artikel wird auf der Startseite groß ausgespielt. |
| `location` | z. B. `"Haßfurt, Unterfranken"`. Verbessert die Vorschläge am Artikelende. |
| `last_modified_at` | Datum der letzten Überarbeitung. |
| `toc: false` | Schaltet das Inhaltsverzeichnis ab. |
| `toc: true` | Erzwingt es auch bei kurzen Artikeln. |
| `signoff` | Ein handschriftlicher Abschiedsgruß am Artikelende. |
| `seo_title` | Überschreibt den Titel im Google-Ergebnis. |
| `canonical` | Nur nötig, wenn derselbe Text noch woanders steht. |
| `gallery` | Die Fotostory (siehe unten). |
| `location_facts` | Infokasten bei `type: location`. |
| `cta_heading`, `cta_body`, `cta_label`, `cta_href` | Ersetzt den Standard-Aufruf am Artikelende. |

### Wird automatisch berechnet — bitte nicht eintragen

Lesezeit · Bildgrößen und `srcset` · Inhaltsverzeichnis · verwandte Artikel ·
Brotkrumennavigation · strukturierte Daten · Sitemap · RSS-Feed ·
Open-Graph-Bilder · Wortanzahl.

---

## Kategorien und Themen

Es gibt genau sechs Kategorien. Sie sind in `_data/categories.yml` definiert:

`hochzeitsplanung` · `hochzeitsfotografie` · `echte-hochzeiten` · `locations` ·
`alternative-hochzeiten` · `fuer-fotografinnen`

Ein Artikel kann in mehreren stehen. Die **erste** ist die Hauptkategorie und
erscheint in der Brotkrumennavigation.

**Themen (Tags)** sind frei, sollten aber sparsam vergeben werden — lieber drei
gute als zehn beliebige. Schreibweise immer gleich halten: `"Alternative Hochzeit"`,
nicht mal `AlternativeHochzeit` und mal `alternative hochzeit`. Unter
`/themen/` steht, was es schon gibt; von dort ein bestehendes Thema
übernehmen ist besser als ein neues erfinden.

Themen mit weniger als drei Artikeln funktionieren normal, werden aber nicht an
Google gemeldet, damit sie die Seite nicht verwässern.

---

## Bilder vorbereiten

**Format:** WebP. **Qualität:** 80–85.
**Größe:** lange Kante 2000 px.
**Dateiname:** kleingeschrieben, mit Bindestrichen, beschreibend.
`brautpaar-vor-standesamt-hassfurt.webp` — nicht `IMG_4471.webp`.

Bilder kommen nach `assets/images/posts/`. Für eine Fotostory einen eigenen
Ordner anlegen: `assets/images/posts/standesamt-hassfurt/`.

### Die drei Größen

Damit auf dem Handy nicht das 2000-Pixel-Bild geladen wird, exportiert ihr aus
Lightroom zusätzlich drei Varianten in Unterordner — genau wie auf der
Hauptwebsite:

```
assets/images/posts/standesamt-hassfurt/
├─ brautpaar-vor-standesamt.webp        ← Original, 2000 px
├─ webp-800/brautpaar-vor-standesamt.webp
├─ webp-1200/brautpaar-vor-standesamt.webp
└─ webp-2000/brautpaar-vor-standesamt.webp
```

**Die Dateinamen müssen in allen Ordnern identisch sein.** Mehr ist nicht nötig
— den Rest macht die Website allein.

Fehlen die Unterordner, funktioniert alles trotzdem, es wird dann nur das
Original ausgeliefert. Ihr könnt die Größen also nach und nach nachliefern.

### Bildbeschreibungen

Jedes Bild braucht eine. Sie beschreibt, was zu sehen ist:

> ✅ `"Brautpaar küsst sich vor dem Standesamt Haßfurt"`
> ❌ `"Hochzeitsfoto"`, `"IMG_4471"`, `"Bild 12"`

---

## Fotostories mit vielen Bildern

Für eine echte Hochzeit mit 30 bis 60 Bildern legt ihr die Bilder in einen
Ordner und listet sie im Front Matter auf — **in der Reihenfolge, in der sie
erzählt werden sollen.** Das Layout entsteht danach von selbst.

```yaml
type: story
gallery:
  folder: standesamt-hassfurt
  images:
    - file: first-look-standesamt-hassfurt.webp
      alt: "First Look des Brautpaars vor der Trauung"
    - file: braut-portrait-in-schwarz-weiss.webp
      alt: "Portrait der Braut in Schwarzweiß"
      featured: true
    - file: tortenanschnitt-im-gasthaus-goger.webp
      alt: "Tortenanschnitt am Abend"
      caption: "Der Tortenanschnitt kurz vor neun."
```

- `file` und `alt` sind Pflicht.
- `featured: true` gibt einem Bild eine ganze Seitenbreite für sich. Sparsam
  einsetzen — zwei bis drei pro Story.
- `caption` erscheint klein unter dem Bild. Ohne Angabe steht dort nichts.

**Ihr müsst nichts positionieren.** Die Website erkennt Hoch- und Querformate,
gruppiert sie zu Paaren, Dreiergruppen und ganzseitigen Bildern, und sorgt
dafür, dass sich kein Muster wiederholt und kein Bild allein übrig bleibt.
Zwei Stories mit derselben Bildfolge sehen trotzdem unterschiedlich aus.

---

## Artikeltypen

| `type` | Wofür | Was anders ist |
|---|---|---|
| `guide` | Ratgeber, Erklärstücke | Vorspann, Inhaltsverzeichnis, Textspalte |
| `story` | Echte Hochzeiten | Titelbild über die volle Breite, Überschrift darunter, Galerie trägt den Artikel |
| `location` | Locationvorstellungen | Zusätzlicher Infokasten `location_facts` |
| `wissen` | Fachliches für Fotograf:innen | Wie `guide` |

Beispiel für den Infokasten:

```yaml
type: location
location_facts:
  - label: "Adresse"
    value: "Hauptstraße 5, 97437 Haßfurt"
  - label: "Trauzimmer"
    value: "Etwa 25 Sitzplätze"
  - label: "Licht"
    value: "Große Fenster nach Süden, mittags hart"
```

---

## Was automatisch passiert

Beim Bauen der Seite laufen vier kleine Erweiterungen in `_plugins/`:

| Datei | Aufgabe |
|---|---|
| `ml_image_meta.rb` | Liest Bildgrößen direkt aus der Datei und baut `srcset`. |
| `ml_gallery.rb` | Verteilt Fotostory-Bilder auf ein abwechslungsreiches Layout. |
| `ml_related.rb` | Sucht passende weitere Artikel (nicht einfach die neuesten). |
| `ml_toc.rb` | Erzeugt das Inhaltsverzeichnis aus den Zwischenüberschriften. |

Beim Bauen wird außerdem gewarnt, wenn ein Bild keine Beschreibung hat oder
eine Bilddatei fehlt. Beides steht dann im Build-Log.

---

## Lokal ausprobieren

Einmalig:

```bash
bundle install
```

Danach jedes Mal:

```bash
bundle exec jekyll serve
```

Die Seite läuft dann unter `http://localhost:4000`. Änderungen an Artikeln
erscheinen nach dem Speichern automatisch. Änderungen an `_config.yml` oder in
`_plugins/` brauchen einen Neustart.

**Unter Windows:** Falls `tzinfo-data` fehlt, ist es bereits im `Gemfile`
eingetragen — dann hilft ein erneutes `bundle install`.

Vor dem Pushen prüfen lassen:

```bash
bundle exec jekyll build
ruby script/check_build.rb
```

Das findet kaputte interne Links, fehlende Bildbeschreibungen, doppelte
Seitentitel und ungültige strukturierte Daten.

---

## Veröffentlichen

Push auf `main`. Der Rest passiert automatisch:

1. GitHub Actions baut die Seite.
2. `script/check_build.rb` prüft das Ergebnis.
3. Bei Fehlern wird **nicht** veröffentlicht — die alte Version bleibt online.
4. Sonst geht die neue Version live.

Den Status seht ihr im Reiter **Actions** auf GitHub.

---

## Projektstruktur

```
_config.yml            Grundeinstellungen
Gemfile                Abhängigkeiten
index.html             Startseite
artikel/index.html     Alle Artikel, mit Seitennummerierung
themen.html            Themenübersicht
suche.html             Suche
404.html               Fehlerseite
search.json            Suchindex (wird erzeugt)
robots.txt             Anweisungen für Suchmaschinen
CNAME                  Die Domain

_posts/                Die Artikel — hier arbeitet ihr
_data/
  authors.yml          Marie-Claire, Martin, beide
  categories.yml       Die sechs Kategorien samt SEO-Texten
_layouts/              Seitengerüste
_includes/             Bausteine
_plugins/              Die vier Erweiterungen
_sass/                 Stylesheet-Bausteine
assets/
  css/main.scss        Einstiegspunkt
  js/                  Vier kleine Skripte, zusammen 7 KB
  fonts/               Die sieben Schriften
  images/posts/        Eure Bilder
script/check_build.rb  Prüfung nach dem Bauen
```

---

## Wartung

**Eine siebte Kategorie hinzufügen:** einen Block in `_data/categories.yml`
ergänzen. Navigation, Startseite, Fußzeile und Kategorieseite ziehen automatisch
nach.

**Eine dritte Autorin hinzufügen:** einen Block in `_data/authors.yml`.

**Farben oder Schriften ändern:** ausschließlich in `_sass/_tokens.scss`. Die
Werte dort stammen eins zu eins aus dem Stylesheet der Hauptwebsite — ändert
sich dort etwas, gehört es hier hinein und sonst nirgends.

**Newsletter oder Wedding Guide später einbauen:** der Baustein
`_includes/cta.html` ist dafür vorbereitet. Er nimmt Überschrift, Text,
Buttonbeschriftung und Ziel als Parameter entgegen, es muss also nichts neu
gestaltet werden.

### Bekannte Punkte

- **futura-pt** stammt von Adobe Fonts. Die Schriftdatei liegt hier — wie auf
  der Hauptwebsite — direkt im Repository. Adobes Lizenz deckt das nicht ab.
  Wer das sauber lösen will, ersetzt sie auf beiden Seiten durch eine frei
  lizenzierte Alternative.
- Die drei Bildgrößen werden derzeit von Hand exportiert. Ein automatischer
  Schritt im Build lässt sich später ergänzen, ohne dass sich am Ablauf für
  euch etwas ändert.
