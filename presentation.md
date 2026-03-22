---
title: Introduction à SQL
sub_title: "Cours 4 — Écrire (Writing)"
author: Kevin Michoud
theme:
  name: light
  override:
    default:
      margin:
        percent: 4
options:
  end_slide_shorthand: true
---

# Rappel

**Cours 1** — Interroger (`SELECT`, `WHERE`, `ORDER BY`, …)

**Cours 2** — Relier (`JOIN`, clés étrangères, relations)

**Cours 3** — Concevoir (`CREATE TABLE`, types, contraintes)

**Aujourd'hui** — Écrire dans la base de données

`INSERT`, `UPDATE`, `DELETE`, triggers, soft deletes.

---

# Notre base `festival.db`

**Terminal** :

```sql
.schema
```

**DB Browser** : onglet **« Structure de la base de données »**

Trois tables créées la semaine dernière :

- **artistes** → `id`, `nom`, `genre`, `cachet`
- **scenes** → `id`, `nom`, `capacite`
- **concerts** → `artiste_id`, `scene_id`, `debut`

Les tables sont vides → on va les remplir !

---

# Vérifier que c'est vide

```sql
SELECT * FROM "artistes";
```

Résultat : rien. Normal, on n'a encore rien inséré.

**DB Browser** : onglet **« Parcourir les données »** → sélectionner `artistes`.

---

# INSERT INTO — Syntaxe

```sql
INSERT INTO "table" ("col1", "col2", …)
VALUES (val1, val2, …);
```

On donne :

1. Le nom de la table
2. La liste des colonnes à remplir
3. Les valeurs, **dans le même ordre**

**DB Browser** : onglet **« Exécuter le SQL »**, taper la commande, ▶️ Run.

On peut aussi cliquer **« Nouvel enregistrement »** dans « Parcourir les données »
mais on préfère écrire le SQL pour apprendre !

---

# Insérer un artiste

```sql
INSERT INTO "artistes" ("id", "nom", "genre", "cachet")
VALUES (1, 'PLK', 'Rap', 45000);
```

Vérifions :

```sql
SELECT * FROM "artistes";
```

| id  | nom | genre | cachet |
| --- | --- | ----- | ------ |
| 1   | PLK | Rap   | 45000  |

---

# ID automatique

Taper `1`, `2`, `3`… à la main → risque d'erreur.

SQLite peut remplir l'ID **automatiquement** si on l'omet :

```sql
INSERT INTO "artistes" ("nom", "genre", "cachet")
VALUES ('Jorja Smith', 'R&B', 60000);
```

```sql
SELECT * FROM "artistes";
```

| id  | nom         | genre | cachet |
| --- | ----------- | ----- | ------ |
| 1   | PLK         | Rap   | 45000  |
| 2   | Jorja Smith | R&B   | 60000  |

SQLite prend le plus grand ID existant et ajoute 1.

---

# Question : réutilisation des IDs ?

Si on supprime l'ID 1, le prochain artiste aura-t-il l'ID 1 ?

**Non.** SQLite prend le **plus grand** ID présent
et l'incrémente.

→ Après suppression de l'ID 1, le prochain sera 3 (pas 1).

---

# Les contraintes nous protègent

Rappel de notre schéma :

- `nom` est `NOT NULL`
- `cachet` doit vérifier `CHECK("cachet" > 0)`
- `nom` de scène est `NOT NULL UNIQUE`

Que se passe-t-il si on viole une contrainte ?

---

# Violation : NOT NULL

```sql
INSERT INTO "artistes" ("nom", "genre", "cachet")
VALUES (NULL, 'Pop', 30000);
```

```
Runtime error: NOT NULL constraint failed: artistes.nom
```

---

# Violation : CHECK

```sql
INSERT INTO "artistes" ("nom", "genre", "cachet")
VALUES ('Test', 'Pop', 0);
```

```
Runtime error: CHECK constraint failed: cachet > 0
```

---

# Violation : UNIQUE

```sql
INSERT INTO "scenes" ("nom", "capacite")
VALUES ('Grande Scène', 5000);
```

```sql
INSERT INTO "scenes" ("nom", "capacite")
VALUES ('Grande Scène', 3000);
```

```
Runtime error: UNIQUE constraint failed: scenes.nom
```

Les contraintes sont des **garde-fous** contre les données invalides.

---

# Insérer plusieurs lignes

On sépare les lignes par des **virgules** :

```sql
INSERT INTO "artistes" ("nom", "genre", "cachet")
VALUES
('SDM', 'Rap', 35000),
('Pomme', 'Pop', 25000),
('Aya Nakamura', 'Pop', 80000);
```

Plus pratique, et aussi plus **rapide**.

---

# Remplir les scènes

```sql
INSERT INTO "scenes" ("nom", "capacite")
VALUES
('Chapiteau', 800),
('Scène Électro', 1200);
```

```sql
SELECT * FROM "scenes";
```

| id  | nom           | capacite |
| --- | ------------- | -------- |
| 1   | Grande Scène  | 5000     |
| 2   | Chapiteau     | 800      |
| 3   | Scène Électro | 1200     |

---

# Question : si une ligne viole une contrainte ?

```sql
INSERT INTO "artistes" ("nom", "genre", "cachet")
VALUES
('Bon artiste', 'Rock', 20000),
(NULL, 'Pop', 30000);
```

La 2e ligne viole `NOT NULL` →
**aucune** des deux lignes n'est insérée !

C'est tout ou rien.

---

# Importer depuis un CSV

Fichier `artistes.csv` :

```
nom,genre,cachet
Orelsan,Rap,70000
Clara Luciani,Pop,40000
Justice,Électro,55000
```

---

# Import via table temporaire

**Terminal** :

```sql
.import --csv artistes.csv temp
```

**DB Browser** : menu **Fichier → Importer → Table depuis un fichier CSV…**
→ nommer la table `temp`.

SQLite crée la table `temp` avec les en-têtes du CSV.

```sql
SELECT * FROM "temp";
```

Ensuite, on transfère vers `artistes` :

```sql
INSERT INTO "artistes" ("nom", "genre", "cachet")
SELECT "nom", "genre", "cachet" FROM "temp";
```

SQLite ajoute les IDs automatiquement.

Nettoyage :

```sql
DROP TABLE "temp";
```

---

# Programmer des concerts

La table `concerts` relie artistes et scènes via leurs IDs.

```sql
INSERT INTO "concerts" ("artiste_id", "scene_id", "debut")
VALUES (1, 1, '2025-07-10 20:00');
```

→ PLK (id 1) sur la Grande Scène (id 1) le 10 juillet à 20h.

---

# Plusieurs concerts d'un coup

```sql
INSERT INTO "concerts" ("artiste_id", "scene_id", "debut")
VALUES
(2, 1, '2025-07-10 22:00'),
(1, 2, '2025-07-11 18:00'),
(3, 2, '2025-07-11 20:00');
```

PLK joue **deux fois** (Grande Scène + Chapiteau).

C'est possible car on n'a **pas** de clé primaire composée
sur `("artiste_id", "scene_id")`.

---

# DEFAULT CURRENT_TIMESTAMP

Si on omet `debut` :

```sql
INSERT INTO "concerts" ("artiste_id", "scene_id")
VALUES (4, 3);
```

La valeur par défaut `CURRENT_TIMESTAMP` est utilisée
→ l'horodatage du moment de l'insertion.

---

# DELETE FROM — Syntaxe

```sql
DELETE FROM "table"
WHERE condition;
```

⚠️ Sans `WHERE`, **toutes** les lignes sont supprimées !

```sql
-- NE PAS EXÉCUTER
DELETE FROM "artistes";
```

💡 **DB Browser** : on peut aussi supprimer une ligne dans « Parcourir les données »
en la sélectionnant puis en cliquant sur **« Supprimer l'enregistrement »**.
Mais attention : il faut cliquer **« Écrire les modifications »** (Write Changes)
pour valider, sinon les changements ne sont pas enregistrés !

---

# Supprimer avec une condition

Supprimer l'artiste « Pomme » :

```sql
DELETE FROM "artistes"
WHERE "nom" = 'Pomme';
```

Supprimer les artistes sans genre :

```sql
DELETE FROM "artistes"
WHERE "genre" IS NULL;
```

Supprimer les artistes avec un cachet < 30000 :

```sql
DELETE FROM "artistes"
WHERE "cachet" < 30000;
```

---

# ⚠️ PRAGMA foreign_keys

Par défaut, SQLite **ne vérifie pas** les clés étrangères !

On pourrait insérer `artiste_id = 999` sans erreur.

Pour activer la vérification :

```sql
PRAGMA foreign_keys = ON;
```

- C'est un réglage de **connexion**, pas de la base
- À activer **à chaque ouverture** (hors transaction)
- **Terminal** : `PRAGMA foreign_keys = ON;` ou dans `~/.sqliterc`
- **DB Browser** : onglet **« Éditer les Pragmas »** → case **Foreign Keys**
  (cochée par défaut dans les versions récentes, mais vérifiez !)

---

# Suppression et clés étrangères

La table `concerts` référence `artistes` via `artiste_id`.

Si on supprime un artiste qui a des concerts programmés…

```sql
DELETE FROM "artistes"
WHERE "nom" = 'PLK';
```

```
Runtime error: FOREIGN KEY constraint failed
```

La clé étrangère dans `concerts` n'aurait plus rien à référencer !

---

# Solution 1 : supprimer les références d'abord

```sql
DELETE FROM "concerts"
WHERE "artiste_id" = (
    SELECT "id"
    FROM "artistes"
    WHERE "nom" = 'PLK'
);
```

Puis :

```sql
DELETE FROM "artistes"
WHERE "nom" = 'PLK';
```

On supprime d'abord les concerts, puis l'artiste.

---

# Solution 2 : ON DELETE

On peut spécifier quoi faire quand un ID référencé est supprimé :

| Clause                  | Effet                                   |
| ----------------------- | --------------------------------------- |
| `ON DELETE RESTRICT`    | empêche la suppression (par défaut)     |
| `ON DELETE NO ACTION`   | permet la suppression, ne fait rien     |
| `ON DELETE SET NULL`    | met les clés étrangères à `NULL`        |
| `ON DELETE SET DEFAULT` | met une valeur par défaut               |
| `ON DELETE CASCADE`     | supprime aussi les lignes référençantes |

---

# ON DELETE CASCADE — Exemple

```sql
CREATE TABLE "concerts" (
    "artiste_id" INTEGER,
    "scene_id" INTEGER,
    "debut" NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY("artiste_id")
        REFERENCES "artistes"("id") ON DELETE CASCADE,
    FOREIGN KEY("scene_id")
        REFERENCES "scenes"("id") ON DELETE CASCADE
);
```

Supprimer un artiste → ses concerts sont aussi supprimés.

---

# UPDATE — Syntaxe

```sql
UPDATE "table"
SET "colonne" = valeur
WHERE condition;
```

⚠️ Sans `WHERE`, **toutes** les lignes sont modifiées !

---

# Exemple : modifier un cachet

Le cachet de Jorja Smith passe à 65000 :

```sql
UPDATE "artistes"
SET "cachet" = 65000
WHERE "nom" = 'Jorja Smith';
```

---

# Exemple : changer de scène

Déplacer le concert de SDM vers la Scène Électro :

```sql
UPDATE "concerts"
SET "scene_id" = (
    SELECT "id"
    FROM "scenes"
    WHERE "nom" = 'Scène Électro'
)
WHERE "artiste_id" = (
    SELECT "id"
    FROM "artistes"
    WHERE "nom" = 'SDM'
);
```

On utilise des sous-requêtes pour trouver les bons IDs.

---

# Triggers (Déclencheurs)

Un **trigger** = une instruction SQL qui s'exécute
**automatiquement** en réponse à un `INSERT`, `UPDATE` ou `DELETE`.

Utile pour :

- maintenir la cohérence des données
- automatiser des tâches entre tables liées
- garder un historique

---

# Table de transactions

Gardons un historique de la programmation :

```sql
CREATE TABLE "transactions" (
    "id" INTEGER,
    "artiste" TEXT,
    "action" TEXT,
    PRIMARY KEY("id")
);
```

---

# Trigger « annulation »

Quand un artiste est supprimé → enregistrer « annulé » :

```sql
CREATE TRIGGER "annulation"
BEFORE DELETE ON "artistes"
BEGIN
    INSERT INTO "transactions" ("artiste", "action")
    VALUES (OLD."nom", 'annulé');
END;
```

- `BEFORE DELETE` → s'exécute **avant** la suppression
- `OLD` → la ligne en cours de suppression
- `OLD."nom"` → le nom de l'artiste supprimé

---

# Trigger « confirmation »

Quand un artiste est inséré → enregistrer « confirmé » :

```sql
CREATE TRIGGER "confirmation"
AFTER INSERT ON "artistes"
BEGIN
    INSERT INTO "transactions" ("artiste", "action")
    VALUES (NEW."nom", 'confirmé');
END;
```

- `AFTER INSERT` → s'exécute **après** l'insertion
- `NEW` → la ligne nouvellement insérée
- `NEW."nom"` → le nom de l'artiste ajouté

---

# Question : plusieurs instructions ?

Oui, on peut avoir plusieurs instructions
entre `BEGIN` et `END`, séparées par `;`

```sql
CREATE TRIGGER "exemple"
AFTER INSERT ON "artistes"
BEGIN
    INSERT INTO "transactions" ("artiste", "action")
    VALUES (NEW."nom", 'confirmé');
    -- autre instruction ici
END;
```

---

# Soft Delete (Suppression douce)

**Idée** : marquer comme supprimé au lieu de supprimer réellement.

Ajouter une colonne `annule` :

```sql
ALTER TABLE "artistes"
ADD COLUMN "annule" INTEGER DEFAULT 0;
```

---

# Soft Delete — Utilisation

« Supprimer » un artiste :

```sql
UPDATE "artistes"
SET "annule" = 1
WHERE "nom" = 'SDM';
```

Interroger les artistes **actifs** :

```sql
SELECT * FROM "artistes"
WHERE "annule" != 1;
```

Avantages : historique complet, données récupérables.

⚠️ Le RGPD peut exiger une suppression **réelle**.

---

# Résumé — Mots-clés du jour

| Mot-clé       | Rôle                                       |
| ------------- | ------------------------------------------ |
| `INSERT INTO` | insérer des lignes                         |
| `DELETE FROM` | supprimer des lignes                       |
| `UPDATE`      | modifier des lignes existantes             |
| `SET`         | définir la nouvelle valeur (avec `UPDATE`) |
| `ON DELETE`   | action quand un ID référencé est supprimé  |
| `CASCADE`     | suppression en cascade                     |
| `OLD` / `NEW` | ligne supprimée / insérée dans un trigger  |
| `TRIGGER`     | instruction automatique                    |
| `DEFAULT`     | valeur par défaut (rappel)                 |

---

# Résumé — CRUD

| Opération  | SQL           | Exemple bibliothèque                |
| ---------- | ------------- | ----------------------------------- |
| **C**reate | `INSERT INTO` | ajouter un livre, un client         |
| **R**ead   | `SELECT`      | consulter les emprunts en cours     |
| **U**pdate | `UPDATE`      | enregistrer le retour d'un livre    |
| **D**elete | `DELETE FROM` | supprimer un avis, un ancien client |

---

# Exercice — Votre base bibliothèque

On laisse `festival.db` de côté.

Ouvrez **votre** base de données bibliothèque
et remplissez-la avec des données réalistes.

⚠️ Première chose à faire :

```sql
PRAGMA foreign_keys = ON;
```

---

# Conseil 1 — L'ordre d'insertion

Avec les clés étrangères activées,
on ne peut pas insérer n'importe quoi n'importe quand.

→ Insérer un `livre` avec `id_editeur = 3`
alors qu'aucun éditeur n'a l'ID 3 ? **Erreur.**

Il faut remplir les tables **dans le bon ordre** :
les tables référencées **avant** les tables qui référencent.

💡 Regardez votre schéma et trouvez
dans quel ordre insérer vos données.

---

# Conseil 2 — Pensez aux exemplaires

Votre table `emprunt` pointe vers `livre`.

Mais une bibliothèque possède souvent **plusieurs
exemplaires** du même livre, dans différentes bibliothèques.

→ Créez une table `exemplaire`
(`id_exemplaire`, `id_livre`, `id_biblio`, `etat`…)

Et modifiez `emprunt` pour pointer vers `exemplaire`
plutôt que vers `livre`.

---

# Conseil 3 — Le soft delete

Si on supprime un client, que deviennent ses emprunts ?
Ses avis ? → Erreur de clé étrangère, ou perte de données.

**Solution** : ne pas supprimer, mais _désactiver_.

Ajoutez une colonne `actif` (défaut `1`) à `client`.
Pour « supprimer » → mettre `actif` à `0`.

Même logique pour les exemplaires perdus ou abîmés :
une colonne `disponible` sur `exemplaire`.
