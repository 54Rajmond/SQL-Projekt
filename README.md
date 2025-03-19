# Finanzielle Betrugserkennung - SQL Projekt

## 📌 Projektübersicht
Dieses Projekt implementiert eine **Datenbank zur Erkennung von finanziellen Betrugsfällen**. Die Datenbank enthält verschiedene Tabellen zur Verwaltung von Benutzern, Händlern, Transaktionen, Betrugsberichten und gesperrten Benutzern. Zusätzlich ermöglicht sie detaillierte Analysen zur Erkennung verdächtiger Transaktionen.

## 📂 Enthaltene Tabellen

### 1️⃣ **Benutzer** (`Benutzer`)
- Speichert Informationen über registrierte Nutzer, einschließlich Name, E-Mail, Telefonnummer und Adresse.

### 2️⃣ **Händler** (`Händler`)
- Enthält Informationen über Händler, deren Kategorien und Risikostufen.

### 3️⃣ **Transaktionen** (`Transaktionen`)
- Speichert jede Transaktion mit Beträgen, Status (abgeschlossen, ausstehend, fehlgeschlagen, betrügerisch) und Zahlungsinformationen.

### 4️⃣ **Betrugsberichte** (`Betrugsberichte`)
- Enthält Meldungen zu betrügerischen Aktivitäten, inklusive Untersuchungsergebnisse.

### 5️⃣ **Kontostände** (`Kontostände`)
- Zeigt die aktuellen Salden der Benutzerkonten an.

### 6️⃣ **Transaktionsprotokolle** (`Transaktionsprotokolle`)
- Enthält Logs zu jeder Transaktion für detaillierte Nachverfolgung.

### 7️⃣ **Gesperrte Benutzer** (`Gesperrte_Benutzer`)
- Listet Benutzer auf, die aufgrund von Betrugsaktivitäten gesperrt wurden.

##  Hauptfunktionen und SQL-Abfragen

 **Erkennen verdächtiger Transaktionen:**
```sql
SELECT t.transaktion_id, b.name AS benutzername, t.betrag, t.transaktionsdatum, h.name AS händlername, t.zahlungsmethode, t.ip_adresse
FROM Transaktionen t
JOIN Benutzer b ON t.benutzer_id = b.benutzer_id
JOIN Händler h ON t.händler_id = h.händler_id
WHERE t.betrag > 10000 OR t.status = 'Betrügerisch';
```

 **Gesamte Transaktionen pro Händler abrufen:**
```sql
SELECT h.name AS händlername, COUNT(t.transaktion_id) AS anzahl_transaktionen, SUM(t.betrag) AS gesamtbetrag
FROM Transaktionen t
JOIN Händler h ON t.händler_id = h.händler_id
GROUP BY h.name
ORDER BY gesamtbetrag DESC;
```

 **Benutzer mit mehreren Betrugsberichten identifizieren:**
```sql
SELECT b.name, COUNT(br.bericht_id) AS anzahl_betrugsberichte
FROM Betrugsberichte br
JOIN Transaktionen t ON br.transaktion_id = t.transaktion_id
JOIN Benutzer b ON t.benutzer_id = b.benutzer_id
GROUP BY b.name
HAVING COUNT(br.bericht_id) > 1;
```

 **Händler mit hohem Risiko identifizieren:**
```sql
SELECT h.name AS händlername, COUNT(t.transaktion_id) AS betrugsfälle
FROM Transaktionen t
JOIN Händler h ON t.händler_id = h.händler_id
WHERE t.status = 'Betrügerisch'
GROUP BY h.name
HAVING COUNT(t.transaktion_id) > 1
ORDER BY betrugsfälle DESC;
```


##  Anwendungsfälle
 Banken & Finanzinstitute zur Betrugserkennung und Risikoanalyse
 E-Commerce-Plattformen zur Identifikation von verdächtigen Käufen
 Analyse von Transaktionen, um betrügerische Muster zu identifizieren




