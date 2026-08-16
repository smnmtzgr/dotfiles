# Globale Agent-Anweisungen

Diese Datei gilt für alle Projekte. Was nur für ein Projekt gilt, steht in dessen eigener
`AGENTS.md` und gehört nicht hierher.

## Sprache

Kommunikation auf Deutsch, mit korrekten Umlauten. Code, Bezeichner, Commit-Messages und
Dateinamen bleiben englisch, sofern das Projekt es nicht anders vorgibt.

## Doku gehört zur Änderung

Wer Verhalten ändert, ändert die Dokumentation im **selben** Pull Request mit. Nicht danach,
nicht demnächst - danach passiert es nie. Falsche Doku ist schlimmer als keine: sie kostet
niemanden Zeit beim Schreiben, aber jeden beim Lesen, und man merkt es erst, wenn man ihr
geglaubt hat.

Auto-generierte Dateien und `CHANGELOG.md` werden nie von Hand editiert, wenn das Projekt sie
generiert.

## Technische Entscheidungen

Entwicklungskosten sind ein schwaches Argument. Gewichte stattdessen Qualität, Einfachheit,
Robustheit und langfristige Wartbarkeit.

Für einmalige oder seltene Arbeiten: nimm den einfachsten direkten Weg von Anfang bis Ende.
Keine Wrapper, keine Abstraktionsschichten, keine eigenen Verifizierer, keine Automatisierung -
es sei denn, der direkte Weg stößt auf einen konkreten Blocker oder wiederholten Bedarf, der
die zusätzliche Maschinerie rechtfertigt.

## Bugfixes

Immer damit anfangen, den Fehler end-to-end zu reproduzieren, so nah wie möglich daran, wie ein
Endnutzer ihn erlebt. Erst dann fixen.

## Qualitätsanspruch

Lint-Fehler, fehlschlagende Tests und flaky Tests sind keine Randnotizen, sondern Arbeit, die
noch offen ist. Beim Prüfen von UI genau hinsehen statt durchzuwinken.

## Commits

Keinen Agent-Namen als Co-Author anhängen, sofern nicht ausdrücklich gewünscht.

## Rückfragen vor teuren Aktionen

Bevor du Features nutzt, die sofort einen großen Schwarm Subagents starten (dynamic workflows,
ultra code und Ähnliches): Trade-offs erklären und explizit um Erlaubnis fragen.
