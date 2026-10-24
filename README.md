# EvoTree

Lokaler Featurebaum für ein Codex-Projekt auf einem Mac: Anforderungen,
beobachtete Änderungen, Herkunft und Prüfbelege in einer Pixel-Art-Liveansicht.
Absicht, beobachtete Änderung und geprüfter Abschluss bleiben getrennt.

## Voraussetzungen und Einrichtung

Native Vorschau für macOS 26+ auf arm64. Einrichtung über den lokalen
Codex-Executor mit vorhandenen Mac-Systemwerkzeugen, ohne zusätzliche Python-
Installation. Keine separate Mac-App, Hooks, Companion oder MCP-Server.
Für die Einrichtung die Anweisungen in
[evotree-setup](skills/evotree-setup/SKILL.md) verwenden. Konkretes Projekt,
Download und Installation bestätigen. Installation aktiviert keine Aufnahme.

Dieser Kanal bezieht den exakt gepinnten Kern einmalig vom öffentlichen HTTPS-Host.
Der [Artefaktindex](https://evotree-downloads.pages.dev/ARTIFACTS.json) nennt Version,
Größe und SHA-256. Keine Ersatzquelle oder ungeprüften Updates verwenden.
Nach Einrichtung die installierte evotree-Anleitung und die ausgegebene
instruction_file lesen. Aufnahme, Produzent und Runtime benötigen getrennte
Zustimmungen. Gespeicherte Ansichten starten eine deaktivierte Erfassung nicht neu.

## Lokal und kostenlos

Die Grundversion bleibt dauerhaft kostenlos lokal für eigene private, berufliche
und kommerzielle Projekte nutzbar. Kein Entwicklerkonto, Abo, Premiumkauf,
zusätzlicher Modell-API-Schlüssel oder verpflichtende Cloudverarbeitung.
Deterministisches Layout und Liveansicht laufen lokal. Optionaler semantischer
Abgleich nutzt den vorhandenen Codex-Kontext und dessen Kontoeinstellungen.
Codex selbst ist damit nicht als offline oder kostenlos zugesagt.

Eigene schmale Integration: MIT. Eigene Kernanteile: EvoTree Free Local License1.0.
Drittanbieter- und früher erteilte Rechte bleiben erhalten. Exakte Datei-/
Lizenzzuordnung unter skills/evotree-setup/LICENSE-MAP.json, gültige Lizenztexte
unter skills/evotree-setup/licenses/. Der Kern und seine Quellen gehören nicht zum
öffentlichen GitHub-Integrationsbaum. Kompilierung verhindert weder Kopien noch
Analyse; Wrapper und Browserdateien bleiben lesbar. Keine pauschale ursprüngliche
Urheberschaft oder vollständige Herkunftsklärung wird daraus abgeleitet.

## Grenzen und Hilfe

Die öffentliche HTTPS-Auslieferung und der Python-freie Download-/Installationsweg
sind auf dem vorhandenen macOS26/arm64-Testhost geprüft. Kein Clean-Mac-, Intel-,
älteres-macOS-, Notarisierungs- oder pauschaler Plattform-Trustnachweis. Der
Installer entfernt keine Quarantäne oder anderen Schutzattribute. Bei Blockaden
stoppen; keine Schutzumgehung oder automatische Nachinstallation.
Die öffentliche Verzeichnisannahme und Auffindbarkeit stehen noch aus.

[Datenschutzhinweise](PRIVACY.md). Vorgesehener öffentlicher Support nach Freigabe
dieses Integrationsrepositorys: GitHub Issues dieses Repositorys. Keine privaten
Prompts, Kundendaten, Secrets oder vollständigen Projektarchive in Fehlerberichte.
Herausgeber: Andreas Aschenbrenner; Copyrightalias: tsn65wtnrj-max.
Integrationsstand 0.7.0-dev.64-publication-candidate; ausführbarer Setupvertrag unverändert .62,
geprüfter und öffentlich gehosteter Kern unverändert .60. Downloadhost und
Verzeichnisse können sich ändern oder ausfallen; rechtmäßig installierte
Grundversionen bleiben davon unabhängig lokal nutzbar.
