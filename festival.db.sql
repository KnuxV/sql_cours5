BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS "artistes" (
	"id"	INTEGER NOT NULL UNIQUE,
	"nom"	TEXT NOT NULL UNIQUE,
	"cachet"	INTEGER,
	"genre"	TEXT,
	PRIMARY KEY("id")
);
CREATE TABLE IF NOT EXISTS "concerts" (
	"id"	INTEGER NOT NULL UNIQUE,
	"artiste_id"	INTEGER,
	"scene_id"	INTEGER,
	"debut"	NUMERIC,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("artiste_id") REFERENCES "artistes"("id"),
	FOREIGN KEY("scene_id") REFERENCES "scenes"("id")
);
CREATE TABLE IF NOT EXISTS "scenes" (
	"id"	INTEGER NOT NULL UNIQUE,
	"capacite"	INTEGER,
	"nom"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
INSERT INTO "artistes" VALUES (1,'PLK','Rap','45000.00');
INSERT INTO "artistes" VALUES (2,'Jorja Smith','R&B','60000.00');
INSERT INTO "artistes" VALUES (3,'SDM','Rap','35000.00');
INSERT INTO "artistes" VALUES (4,'Tiakola','Afrotrap','40000.00');
INSERT INTO "artistes" VALUES (5,'Central Cee','Rap','55000.00');
INSERT INTO "artistes" VALUES (6,'Aya Nakamura','R&B','80000.00');
INSERT INTO "artistes" VALUES (7,'Ninho','Rap','70000.00');
INSERT INTO "artistes" VALUES (8,'Rema','Afrobeats','50000.00');
INSERT INTO "concerts" VALUES (1,1,2,'2025-07-10 18:00');
INSERT INTO "concerts" VALUES (2,2,1,'2025-07-10 20:00');
INSERT INTO "concerts" VALUES (3,3,2,'2025-07-10 20:00');
INSERT INTO "concerts" VALUES (4,4,3,'2025-07-10 21:00');
INSERT INTO "concerts" VALUES (5,5,1,'2025-07-10 22:00');
INSERT INTO "concerts" VALUES (6,6,1,'2025-07-11 20:00');
INSERT INTO "concerts" VALUES (7,7,1,'2025-07-11 22:00');
INSERT INTO "concerts" VALUES (8,1,4,'2025-07-11 23:00');
INSERT INTO "concerts" VALUES (9,8,2,'2025-07-11 18:00');
INSERT INTO "concerts" VALUES (10,3,3,'2025-07-11 19:00');
INSERT INTO "scenes" VALUES (1,'Grande Scène','5000');
INSERT INTO "scenes" VALUES (2,'Chapiteau','800');
INSERT INTO "scenes" VALUES (3,'Scène Tremplin','300');
INSERT INTO "scenes" VALUES (4,'Club Tent','500');
COMMIT;
