---
name: evotree-setup
description: Install EvoTree into a selected local macOS Codex project. Use for EvoTree setup; recording and runtime operation use the installed evotree skill and require separate consent.
metadata:
  version: "0.7.0-dev.64-publication-candidate"
  stage: "publication candidate; Directory admission pending"
---
# EvoTree einrichten

Der einmalige Kernbezug benötigt zusätzlich die Zustimmung zum offengelegten Download. Die genaue Downloadadresse ist an die im eigenen Cloudflare-Konto zugewiesene Pages-Origin gebunden. Artefakt öffentlich bereitgestellt, TLS/Hash/Bytes und der native Download-Installationsweg auf dem Testhost geprüft; keine pauschale Plattform-Trustabnahme. Download nur nach ausdrücklicher Zustimmung gemäß channel.json.

Bei gewünschter Installation den absoluten physischen Projektroot prüfen und
mit der vorliegenden Installationszustimmung ausführen:

```sh
/bin/sh <dieser-skill>/scripts/install.sh --root <absoluter-projektroot> --confirm-install --confirm-download
```

Die genaue Version, Bezugsart, SHA-256 und Manifestbindung stehen in
[channel.json](channel.json). Keine Ersatzquelle, neuere Version oder automatischen
Retries verwenden. Die gebundenen Dateien werden vor Ausführung geprüft;
Installation aktiviert weder Capture, Producer, autonome Aufnahme noch Runtime.
Fehler können einen teilweise installierten Zustand hinterlassen; dann Status
prüfen, keine erfolgreiche Installation oder Aktivierung unterstellen.

Nach Erfolg die installierte `.agents/skills/evotree/SKILL.md` und die im Ergebnis
genannte `instruction_file` lesen; für Betrieb `$evotree` verwenden. Dieser
Setupskill ist separat benannt, damit sein Pfad den Produktinstaller nicht blockiert.
Ausdrückliche Nutzeranweisungen haben Vorrang. Lizenzaufteilung und sämtliche
installierten Kernpfade: [LICENSE-MAP.json](LICENSE-MAP.json), gültige Texte unter
`licenses/`. Eigene Integration MIT, eigene Kernanteile Free Local; Drittrechte bleiben erhalten. Kompilierter Kern bleibt kopierbar und analysierbar; dünne Wrapper und Browserdateien sind lesbar.

Native Vorschau: ausschließlich macOS 26+ auf arm64. Die Einrichtung nutzt vorhandene Mac-Systemwerkzeuge; keine zusätzliche Pythoninstallation erforderlich. Kein Intel-/Clean-Mac-/Notarisierungs-PASS. Konkrete Drittanbietertexte und die Dateizuordnung sind im Kern enthalten; Vollständige Herkunftsprüfung und Plattformannahme bleiben offen; die Hostfreigabe ist getrennt von der öffentlichen Integration.

Dieser Installer entfernt keine Quarantäneattribute. Ein als quarantiniert markiertes Kern-ZIP blockiert vor Ausführung und bleibt erhalten, bis ein regulärer Plattformvertrauensweg nachgewiesen ist. Bei nicht lesbaren Sicherheitsmetadaten ebenfalls stoppen; keine Attribute löschen oder Systemschutz umgehen.

Codex führt die Einrichtung aus; keine separate Mac-App und kein manuell zu bedienender App-Installer. Ausführung ausschließlich im lokalen Codex-Executor, mit absoluten physischen Pfaden. Bei fehlenden Systemwerkzeugen blockiert melden; nichts nachinstallieren. Installation und Download benötigen ihre vorhandene Zustimmung; Wiederholung oder Start erteilt kein neues Opt-in.

Der gebundene Setupadapter verwendet ein endliches 65-Sekunden-Fenster. Unerwartete oder unvollständige Stagedaten bleiben erhalten; keine automatische Wiederholung oder rekursive Löschung. Er bestätigt keinen öffentlichen Plattformvertrauens- oder Verzeichnisannahmenachweis.
