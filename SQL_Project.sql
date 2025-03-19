-- Database: finanzbetrug

CREATE TABLE Benutzer (
    benutzer_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    telefon VARCHAR(15) UNIQUE,
    adresse TEXT,
    erstellt_am TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Händler (
    händler_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    kategorie VARCHAR(50),
    standort VARCHAR(100),
    risikostufe VARCHAR(20) CHECK (risikostufe IN ('Niedrig', 'Mittel', 'Hoch'))
);

CREATE TABLE Transaktionen (
    transaktion_id SERIAL PRIMARY KEY,
    benutzer_id INT REFERENCES Benutzer(benutzer_id),
    händler_id INT REFERENCES Händler(händler_id),
    betrag DECIMAL(10,2),
    transaktionsdatum TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) CHECK (status IN ('Abgeschlossen', 'Ausstehend', 'Fehlgeschlagen', 'Betrügerisch')),
    zahlungsmethode VARCHAR(50) CHECK (zahlungsmethode IN ('Kreditkarte', 'Debitkarte', 'Banküberweisung', 'Krypto')),
    ip_adresse VARCHAR(50)
);

CREATE TABLE Betrugsberichte (
    bericht_id SERIAL PRIMARY KEY,
    transaktion_id INT REFERENCES Transaktionen(transaktion_id),
    gemeldet_von INT REFERENCES Benutzer(benutzer_id),
    meldedatum TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    grund TEXT,
    untersuchungsstatus VARCHAR(20) CHECK (untersuchungsstatus IN ('In Überprüfung', 'Bestätigter Betrug', 'Fehlalarm'))
);

CREATE TABLE Kontostände (
    kontostand_id SERIAL PRIMARY KEY,
    benutzer_id INT REFERENCES Benutzer(benutzer_id),
    kontostand DECIMAL(15,2) DEFAULT 0.00,
    zuletzt_aktualisiert TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Transaktionsprotokolle (
    protokoll_id SERIAL PRIMARY KEY,
    transaktion_id INT REFERENCES Transaktionen(transaktion_id),
    protokollnachricht TEXT,
    protokollzeit TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Gesperrte_Benutzer (
    sperrliste_id SERIAL PRIMARY KEY,
    benutzer_id INT REFERENCES Benutzer(benutzer_id),
    grund TEXT,
    hinzugefügt_am TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


INSERT INTO Benutzer (name, email, telefon, adresse) VALUES 
('Markus Meier', 'markus.meier@beispiel.ch', '079-123-4567', 'Bahnhofstrasse 12, Zürich'),
('Sandra Kunz', 'sandra.kunz@beispiel.ch', '078-987-6543', 'Seefeldstrasse 45, Bern'),
('Lukas Huber', 'lukas.huber@beispiel.ch', '076-555-7890', 'Freiestrasse 30, Basel');

INSERT INTO Händler (name, kategorie, standort, risikostufe) VALUES 
('TechStore', 'Elektronik', 'Berlin', 'Niedrig'),
('FastFood', 'Gastronomie', 'Hamburg', 'Mittel'),
('Luxusautos', 'Automobil', 'München', 'Hoch');

INSERT INTO Transaktionen (benutzer_id, händler_id, betrag, status, zahlungsmethode, ip_adresse) VALUES 
(1, 1, 1200.50, 'Abgeschlossen', 'Kreditkarte', '192.168.1.10'),
(2, 2, 15.99, 'Abgeschlossen', 'Debitkarte', '192.168.1.11'),
(1, 3, 45000.00, 'Betrügerisch', 'Banküberweisung', '192.168.1.12'),
(3, 1, 500.00, 'Abgeschlossen', 'Krypto', '192.168.1.13'),
(2, 3, 35000.75, 'Betrügerisch', 'Kreditkarte', '192.168.1.14');

INSERT INTO Betrugsberichte (transaktion_id, gemeldet_von, grund, untersuchungsstatus) VALUES 
(3, 1, 'Verdächtiger hoher Kaufbetrag', 'In Überprüfung'),
(5, 2, 'Unbefugte Transaktion', 'Bestätigter Betrug');

INSERT INTO Kontostände (benutzer_id, kontostand) VALUES 
(1, 5000.00),
(2, 300.00),
(3, 7000.00);

INSERT INTO Transaktionsprotokolle (transaktion_id, protokollnachricht) VALUES 
(1, 'Transaktion erfolgreich verarbeitet'),
(3, 'Transaktion als betrügerisch markiert'),
(5, 'Benutzer meldete unbefugte Aktivität');

INSERT INTO Gesperrte_Benutzer (benutzer_id, grund) VALUES 
(1, 'Mehrere Betrugsberichte'),
(2, 'Bestätigte betrügerische Aktivität');

-- Erkennen verdächtiger Transaktionen
SELECT t.transaktion_id, b.name AS benutzername, t.betrag, t.transaktionsdatum, h.name AS händlername, t.zahlungsmethode, t.ip_adresse 
FROM Transaktionen t
JOIN Benutzer b ON t.benutzer_id = b.benutzer_id
JOIN Händler h ON t.händler_id = h.händler_id
WHERE t.betrag > 10000 OR t.status = 'Betrügerisch';

-- Gesamte Transaktionen pro Händler abrufen
SELECT h.name AS händlername, COUNT(t.transaktion_id) AS anzahl_transaktionen, SUM(t.betrag) AS gesamtbetrag
FROM Transaktionen t
JOIN Händler h ON t.händler_id = h.händler_id
GROUP BY h.name
ORDER BY gesamtbetrag DESC;

-- Benutzer mit mehreren Betrugsberichten identifizieren
SELECT b.name, COUNT(br.bericht_id) AS anzahl_betrugsberichte
FROM Betrugsberichte br
JOIN Transaktionen t ON br.transaktion_id = t.transaktion_id
JOIN Benutzer b ON t.benutzer_id = b.benutzer_id
GROUP BY b.name
HAVING COUNT(br.bericht_id) > 1;

-- Benutzerkontostände nach Transaktionen abrufen
SELECT b.name, k.kontostand
FROM Kontostände k
JOIN Benutzer b ON k.benutzer_id = b.benutzer_id;

-- Transaktionsprotokolle für eine bestimmte Transaktion abrufen
SELECT t.transaktion_id, t.status, p.protokollnachricht, p.protokollzeit
FROM Transaktionsprotokolle p
JOIN Transaktionen t ON p.transaktion_id = t.transaktion_id
WHERE t.transaktion_id = 3;

-- Händler mit hohem Risiko anhand von Betrugstransaktionen ermitteln
SELECT h.name AS händlername, COUNT(t.transaktion_id) AS betrugsfälle
FROM Transaktionen t
JOIN Händler h ON t.händler_id = h.händler_id
WHERE t.status = 'Betrügerisch'
GROUP BY h.name
HAVING COUNT(t.transaktion_id) > 1
ORDER BY betrugsfälle DESC;

-- Gesperrte Benutzer und ihre Betrugshistorie identifizieren
SELECT b.name, g.grund, COUNT(br.bericht_id) AS gesamt_betrugsberichte
FROM Gesperrte_Benutzer g
JOIN Benutzer b ON g.benutzer_id = b.benutzer_id
LEFT JOIN Transaktionen t ON b.benutzer_id = t.benutzer_id
LEFT JOIN Betrugsberichte br ON t.transaktion_id = br.transaktion_id
GROUP BY b.name, g.grund;
