# EvoTree — Datenschutzhinweise zur lokalen Grundversion

Stand: 24.10.2026. Herausgeber: Andreas Aschenbrenner. Als öffentlicher Kontaktweg ist nach Freigabe dieses Integrationsrepositorys dessen GitHub-Issues-Bereich vorgesehen. Keine private E-Mail-Adresse ist Bestandteil dieses Pakets.

## Zweck und Aktivierung

EvoTree stellt die Entwicklung eines ausgewählten lokalen Codex-Projekts als
Featurestruktur mit Herkunft, Änderungen und Prüfbelegen dar. Installation allein
aktiviert keine Erfassung, Produzentenverarbeitung oder Runtime. Vor Aktivierung
werden das konkrete Projekt, die native Sitzung, die Quelldatei, der Start am
aktuellen Dateiende, die Laufzeit und der Konfigurationshash angezeigt.
Capture, lokale Anforderungsverarbeitung und optionale Vorschläge im vorhandenen
Codex-Kontext benötigen ihre jeweiligen getrennten Zustimmungen. Kein Vollimport
alter Sitzungen und keine Suche nach Inhalten anderer Chats.

## Welche Daten lokal verarbeitet und gespeichert werden

Im normalen project-session-v1-Modus liest EvoTree zukünftige freigegebene native
Eingänge aus der gebundenen Quelldatei. Gespeichert werden Projekt-/Sitzungs-/
Eingangsidentitäten, Inhalts-Hashes, Zeitpunkte, Cursor, Quittungen, Feature- und
Anforderungstitel, Beschreibungen, Beziehungen, Revisionen und Historie.
Vollständige Prompttexte und Toolantworten werden in diesem Modus nicht als solche
archiviert. Abgeleitete Titel oder Beschreibungen können dennoch private Inhalte
enthalten. Hashes sind kein Beweis einer Anonymisierung. Keine allgemeine Erkennung
oder vollständige Entfernung aller Geheimnisse wird zugesagt. Keine Credentials
oder fremden privaten Inhalte für eine Aufnahme auswählen.

Autonome Vorschläge bleiben als Agentenherkunft von UserMessages und tatsächlichen
Prüfbelegen getrennt. Ein optional ausdrücklich vorbereiteter lokaler Evidence-Test
liest die konkret bestätigten Projektdateien und führt nur den bestätigten Befehl
aus. Er speichert Datei-/Befehlshashes, Scope, Ergebnis, Zeitpunkte und signierte
Belege; stdout/stderr nur als Hash und Bytezahl, nicht als freie Ausgabe.
Ein Testbefehl ist keine zusätzliche Betriebssystem-Sandbox: Er besitzt die
tatsächlichen bestehenden Codex-/macOS-Rechte. Keine untrusted Befehle bestätigen.

Lokale Betriebsdiagnose enthält begrenzte Zustands-/Fehlerzähler und gegebenenfalls
die erste technische Fehlerklasse, einen festen Fehlercode, Phase, Runtimebezug,
UTC-/monotone Zeit und minimierten Lifecycle-Zustand. Keine freien Exceptiontexte,
Stacktraces oder vollständigen Settingswerte in dieser Erstfehlerdiagnose.

## Speicherort, Dauer und lokale Ansicht

Der tatsächliche private Speicherort und die Bindung stehen im Projektstatus.
Runtime-/Registrierungsdaten liegen projektbezogen unter .evotree; Produktdateien
unter .agents/skills/evotree. Der lokale Ansichtsserver bindet ausschließlich an
127.0.0.1 und verlangt projektbezogene Authentifizierung. Wer das Nutzerkonto,
dessen lokale Schlüssel oder eigene Backups kontrolliert, kann Daten gegebenenfalls
lesen oder kopieren; EvoTree ersetzt keinen Betriebssystem-Zugriffsschutz.

Gespeicherte Graph-, Herkunfts- und Prüfdaten haben keine automatische Löschfrist.
Sie bleiben lokal bis zur ausdrücklich bestätigten Produktlöschung erhalten.
Das Ende eines zeitlich begrenzten Aufnahmefensters und Deaktivierung beenden neue
Aufnahme, löschen aber keine bisherige Historie. Eine gespeicherte Ansicht kann
bei deaktivierter Erfassung geöffnet werden und startet diese nicht erneut.

## Kontrolle und Löschung

Die installierte Referenz SESSION_CONSENT.md beschreibt Status, Deaktivierung,
Stopp und die getrennt zu bestätigende Projektlöschung. Die Projekt-ID muss für
die Löschung ausdrücklich bestätigt werden. Ein eingerichteter optionaler
Anmeldestart muss zuvor regulär deaktiviert werden. Die Produktlöschung entfernt
die erfassten Eingangs-Hashes, Graphen und Quittungen; ein deaktivierter
Wiederimportsperrvermerk bleibt erhalten. Native Codex-Originaldateien werden
nicht verändert oder gelöscht. Registrierungs-/Consentmetadaten und Paketbackups
verbleiben bis zum gesonderten sicheren Artefaktcleanup.

Selbst erstellte Exporte, Betriebssystem-/Nutzerbackups und originale Codex-
Transkripte liegen außerhalb dieser Produktlöschung. Vor Weitergabe lokale
Graphen, Exporte und Diagnoseangaben selbst auf vertrauliche Inhalte prüfen.
Nach erneuter Zustimmung beginnt ein neues Aufnahmefenster am aktuellen EOF;
deaktivierte Zeiträume werden nicht rückwirkend importiert.

## Übermittlungen und andere Anbieter

EvoTree verwendet keine Telemetrie-SDKs, eigenen Modellclients oder zusätzlichen
KI-APIs. Speicher-, Layout- und Livewege laufen lokal. Optionaler semantischer
Abgleich findet im bestehenden Codex-Modellkontext statt und unterliegt dessen
vorhandenen Daten- und Kontoeinstellungen; dies ist keine Aussage, dass Codex selbst
offline arbeitet. Kein Nutzerprojekt wird an einen EvoTree-Cloudserver übertragen.

Das OpenAI-Pluginpaket bündelt das gepinnte Kernarchiv. Der skills.sh-Weg kann
einmalig ein fest versioniertes HTTPS-Artefakt vom vorgesehenen statischen Anbieter Cloudflare Pages beziehen; die konkrete Origin ist https://evotree-downloads.pages.dev (statischer Download öffentlich bereitgestellt).
Der Host kann technische Abrufmetadaten wie IP, Zeitpunkt und Artefaktpfad sehen.
Im Downloadrequest werden keine Projektpfade, Sitzungs-IDs, Prompts oder Credentials
übergeben. Nach Installation benötigt der Kern diesen Host nicht zur Verarbeitung.
Künftige Updates oder erneute Einrichtung können einen neuen ausdrücklich
gewählten Bezug erfordern. Cloudflare verarbeitet technische Abruf-/Verkehrsmetadaten nach seinen eigenen Bedingungen und seiner Datenschutzerklärung (https://www.cloudflare.com/privacypolicy/). Keine feste Loglöschfrist oder Null-Logging-Zusage. Kostenloser Tarif und pages.dev-Name begründen keine dauerhafte Verfügbarkeits- oder Retentionsgarantie. Die unveränderte öffentliche HTTPS-Auslieferung einschließlich TLS, Bytes, Hashes und Headern wurde geprüft. Das ist keine Codex-Plugin-/Directory-Vertrauensabnahme. Ergänzende Downloadhinweise: https://evotree-downloads.pages.dev/PRIVACY.md.

Codex/OpenAI und skills.sh beziehungsweise deren Installationswerkzeuge haben
eigene Datenschutzbedingungen. Für dokumentierte Skills-CLI-Nutzung außerhalb
einer gesondert freigegebenen Indexierungsprobe ist DISABLE_TELEMETRY=1 vorgesehen;
dies ist keine Zusage über sämtliche Drittanbieterwerkzeuge oder Plattformlogs.
Es gibt keinen Login bei EvoTree, keine verpflichtende Cloud und keine Übertragung
an den Rechner des Entwicklers.

Diese Hinweise beschreiben die dokumentierten Datenwege und lokalen Kontrollen. Die genaue öffentliche Developer-Namenszuordnung und Verzeichnisannahme werden dadurch nicht bestätigt. Keine privaten Nutzerdaten in öffentliche Supportkanäle übertragen.
