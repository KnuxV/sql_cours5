## [**Cours 4**](https://cs50.harvard.edu/sql/2024/notes/3/)

- [Introduction](#introduction)
- [Schéma de la base de données (Database Schema)](#schéma-de-la-base-de-données-database-schema)
- [Insertion de données (Inserting Data)](#insertion-de-données-inserting-data)
- [Autres contraintes (Other Constraints)](#autres-contraintes-other-constraints)
- [Insertion de plusieurs lignes (Inserting Multiple Rows)](#insertion-de-plusieurs-lignes-inserting-multiple-rows)
- [Suppression de données (Deleting Data)](#suppression-de-données-deleting-data)
- [Mise à jour de données (Updating Data)](#mise-à-jour-de-données-updating-data)
- [Fin](#fin)

## **Introduction**

- Dans le cours précédent, nous avons appris à créer notre propre schéma de base de données. Dans ce cours, nous allons explorer comment ajouter, mettre à jour et supprimer des données dans nos bases de données.
- Le Boston MFA (Museum of Fine Arts) est un musée centenaire à Boston. Le MFA gère une vaste collection d'artefacts et d'œuvres d'art historiques et contemporains. Ils utilisent probablement une base de données pour stocker des informations sur leur art et leurs artefacts.
- Lorsqu'un nouvel artefact est ajouté à leur collection, nous pouvons imaginer qu'ils insèrent les données correspondantes dans leur base de données. De même, il existe des cas d'utilisation où les données peuvent nécessiter d'être lues, mises à jour ou supprimées.
- Nous allons maintenant nous concentrer sur la création (ou l'insertion) de données dans une base de données du Boston MFA.

## **Schéma de la base de données (Database Schema)**

- Considérons ce schéma que le MFA pourrait utiliser pour sa collection.

  !["Table des collections du MFA contenant des ID, des titres d'œuvres d'art et d'autres informations"](https://cs50.harvard.edu/sql/2024/notes/3/images/11.jpg)

- Chaque ligne de données contient le titre d'une œuvre d'art ainsi que le `numéro d'accession` (accession number), qui est un identifiant unique utilisé en interne par le musée. Il y a également une date indiquant quand l'art a été acquis.
- La table contient un ID qui sert de clé primaire (primary key).
- Nous pouvons imaginer que l'administrateur de la base de données du MFA exécute une requête SQL pour insérer chacune de ces œuvres d'art dans la table.
- Pour comprendre comment cela fonctionne, créons d'abord une base de données appelée `mfa.db`. Ensuite, lisons le fichier de schéma `schema0.sql` dans la base de données. Ce fichier de schéma, déjà fourni, nous aide à créer la table `collections`.

  - ```sqlite
    .read schema0.sql
    ```
  - Pour confirmer que la table a été créée, nous pouvons sélectionner à partir de la table. 

  - Cela devrait nous donner un résultat vide, car la table n'a pas encore de données.

  ```sql
  SELECT * FROM "collections";
  ```

  - Ou utiliser la commande suivante:

  ```sqlite
  .schema
  ```

  **Insertion de données (Inserting Data)**

- L'instruction SQL `INSERT INTO` est utilisée pour insérer une ligne de données dans une table donnée.

  ```sql
  INSERT INTO "collections" ("id", "title", "accession_number", "acquired")
  VALUES (1, 'Profusion de fleurs', '56.257', '1956-04-12');
  ```

  Nous pouvons voir que cette commande nécessite la liste des colonnes de la table qui recevront les nouvelles données et les valeurs à ajouter à chaque colonne, dans le même ordre.
- L'exécution de la commande `INSERT INTO` ne retourne rien, mais nous pouvons exécuter une requête pour confirmer que la ligne est maintenant présente dans `collections`.

  ```sql
  SELECT * FROM "collections";
  ```

- Nous pouvons ajouter plus de lignes à la base de données en insérant plusieurs fois. Cependant, saisir manuellement la valeur de la clé primaire (comme 1, 2, 3, etc.) peut entraîner des erreurs. Heureusement, SQLite peut remplir automatiquement les valeurs de la clé primaire. Pour utiliser cette fonctionnalité, nous omettons la colonne ID lors de l'insertion d'une ligne.

  ```sql
  INSERT INTO "collections" ("title", "accession_number", "acquired")
  VALUES ('Fermiers travaillant à l'aube', '11.6152', '1911-08-03');
  ```

  Nous pouvons vérifier que cette ligne a été insérée avec un `id` de 2 en exécutant

  ```sql
  SELECT * FROM "collections";
  ```

  Remarquez que SQLite remplit les valeurs de la clé primaire en incrémentant la clé primaire précédente, dans ce cas, 1.

## **Autres contraintes (Other Constraints)**

- L'ouverture du fichier `schema.sql` affiche le schéma de la base de données.

  ```sql
  CREATE TABLE "collections" (
      "id" INTEGER,
      "title" TEXT NOT NULL,
      "accession_number" TEXT NOT NULL UNIQUE,
      "acquired" NUMERIC,
      PRIMARY KEY("id")
  );
  ```

- Il est spécifié que le numéro d'accession est unique. Si nous essayons d'insérer une ligne avec un numéro d'accession répété, nous déclencherons une erreur indiquant `UNIQUE constraint failed: collections.accession_number (19)`.
- Cette erreur nous informe que la ligne que nous essayons d'insérer viole une contrainte dans le schéma, spécifiquement la contrainte `UNIQUE` dans ce scénario.
- De même, nous pouvons essayer d'ajouter une ligne avec un titre `NULL`, violant la contrainte `NOT NULL`.

  ```sql
  INSERT INTO "collections" ("title", "accession_number", "acquired")
  VALUES(NULL, NULL, '1900-01-10');
  ```

  En exécutant ceci, nous verrons à nouveau une erreur indiquant `NOT NULL constraint failed: collections.title (19)`.
- De cette manière, les contraintes de schéma sont des garde-fous qui nous protègent de l'ajout de lignes qui ne suivent pas le schéma de notre base de données.

## **Insertion de plusieurs lignes (Inserting Multiple Rows)**

- Nous pourrions avoir besoin d'insérer plus d'une ligne à la fois lors de l'écriture dans une base de données. Une façon de le faire est de séparer les lignes par des virgules dans la commande `INSERT INTO`.

  !["Insertion de plusieurs lignes à la fois séparées par des virgules"](https://cs50.harvard.edu/sql/2024/notes/3/images/13.jpg)

  L'insertion de plusieurs lignes de cette manière offre une certaine commodité au programmeur. C'est également une méthode plus rapide et plus efficace d'insérer des lignes dans une base de données.
  
- Insérons maintenant deux nouvelles peintures dans la table `collections`.

  ```sql
  INSERT INTO "collections" ("title", "accession_number", "acquired")
  VALUES
  ('Paysage imaginatif', '56.496', NULL),
  ('Pivoines et papillon', '06.1899', '1906-01-01');
  ```

  Le musée ne connaît pas toujours exactement quand une peinture a été acquise, donc il est possible que la valeur `acquired` soit `NULL`, comme c'est le cas pour la première peinture que nous venons d'insérer.
  
- Pour voir la table mise à jour, nous pouvons sélectionner toutes les lignes de la table comme toujours.

  ```sql
  SELECT * FROM "collections";
  ```

- Nos données pourraient également être stockées dans un format de valeurs séparées par des virgules, ou CSV. Observons dans l'exemple suivant comment les valeurs de chaque ligne sont séparées par une virgule.

  !["Données de peintures au format de valeurs séparées par des virgules"](https://cs50.harvard.edu/sql/2024/notes/3/images/14.jpg)

- SQLite permet d'importer directement un fichier CSV dans notre base de données. Pour ce faire, **nous devons repartir de zéro** en **supprimant** mfa.db. Dans le terminal, on peut utiliser: 

  ```sqlite
  .quit --pour sortir de sqlite
  ```

  ```bash
  rm mda.db # pour supprimer un ficher (rm = remove)
  ```

- Nous avons déjà un fichier CSV appelé `mfa.csv` qui contient les données dont nous avons besoin. En ouvrant ce fichier, nous pouvons noter que la première ligne contient les noms des colonnes, qui correspondent exactement aux noms des colonnes de notre table `collections` selon le schéma.

- Créons à nouveau la base de données `mfa.db` et lisons le fichier de schéma comme nous l'avons fait précédemment.

  ```sqlite
  sqlite3 mfa.db
  ```

  

- Ensuite, nous pouvons importer le CSV en exécutant une commande SQLite.

  ```sqlite
  .import --csv mfa.csv collections
  ```

  Le premier argument, `--csv`, indique à SQLite que nous importons un fichier CSV. Cela aidera SQLite à analyser correctement le fichier. Le deuxième argument indique que la première ligne du fichier CSV (la ligne d'en-tête) doit être ignorée, ou non insérée dans la table.
  
- Nous pouvons sélectionner toutes les données de la table `collections` pour voir que chaque peinture de `mfa.csv` a été importée avec succès dans la table.

- Le fichier CSV que nous venons d'insérer contenait des valeurs de clé primaire (1, 2, 3, etc.) pour chaque ligne de données. Cependant, il est plus probable que les fichiers CSV avec lesquels nous travaillons ne contiennent pas les valeurs d'ID ou de clé primaire. Comment pouvons-nous faire en sorte que SQLite les insère automatiquement ?

- Pour essayer cela, ouvrons `mfa.csv` dans notre espace de code et supprimons la colonne `id` de la ligne d'en-tête, ainsi que les valeurs de chaque colonne. Voici à quoi devrait ressembler `mfa.csv` une fois que nous aurons fini de le modifier :

  ```
  title,accession_number,acquired
  Profusion de fleurs,56.257,1956-04-12
  Fermiers travaillant à l'aube,11.6152,1911-08-03
  Sortie de printemps,14.76,1914-01-08
  Paysage imaginatif,56.496,
  Pivoines et papillon,06.1899,1906-01-01
  ```

- Nous allons également supprimer toutes les lignes qui sont déjà dans la table `collections`.

  ```sql
  DELETE FROM "collections";
  ```

- Maintenant, nous voulons importer ce fichier CSV dans une table. Cependant, la table `collections` (selon notre schéma) doit avoir quatre colonnes dans chaque ligne. Ce nouveau fichier CSV ne contient que trois colonnes pour chaque ligne. Par conséquent, nous ne pouvons pas procéder à l'importation de la même manière que précédemment.

- Pour importer avec succès le fichier CSV sans valeurs d'ID, nous devons utiliser une table temporaire :

  ```sqlite
  .import --csv mfa_noid.csv temp
  ```

  Remarquez que nous n'utilisons pas l'argument `--skip 1` avec cette commande. C'est parce que SQLite est capable de reconnaître la toute première ligne de données CSV comme la ligne d'en-tête, et convertit ces données en noms de colonnes de la nouvelle table `temp`.
  
- Nous pouvons voir les données dans la table `temp` en l'interrogeant.

  ```sql
  SELECT * FROM "temp";
  ```

- Ensuite, nous allons sélectionner les données (sans clés primaires) de `temp` et les déplacer vers `collections`, ce qui était notre objectif depuis le début ! Nous pouvons utiliser la commande suivante pour y parvenir.

  ```sql
  INSERT INTO "collections" ("title", "accession_number", "acquired")
  SELECT "title", "accession_number", "acquired" FROM "temp";
  ```

  Dans ce processus, SQLite ajoutera automatiquement les valeurs de clé primaire dans la colonne `id`.
  
- Juste pour nettoyer notre base de données, nous pouvons également supprimer la table `temp` une fois que nous avons fini de déplacer les données.

  ```sql
  DROP TABLE "temp";
  ```

## **Suppression de données (Deleting Data)**

- Nous avons vu précédemment que l'exécution de la commande suivante supprimait toutes les lignes de la table `collections`. (Nous ne voulons pas exécuter cette commande maintenant, sinon nous perdrons toutes les données de la table !)

  ```sql
  DELETE FROM "collections";
  ```

- Nous pouvons également supprimer des lignes qui correspondent à des conditions spécifiques. Par exemple, pour supprimer la peinture "Sortie de printemps" de notre table `collections`, nous pouvons exécuter :

  ```sql
  DELETE FROM "collections"
  WHERE "title" = 'Sortie de printemps';
  ```

- Pour supprimer toute peinture avec la date d'acquisition `NULL`, nous pouvons exécuter

  ```sql
  DELETE FROM "collections"
  WHERE "acquired" IS NULL;
  ```

- Comme toujours, nous nous assurerons que la suppression a fonctionné comme prévu en sélectionnant toutes les données de la table.

  ```sql
  SELECT * FROM "collections";
  ```

  Nous voyons que les peintures "Sortie de printemps" et "Paysage imaginatif" ne sont plus dans la table.
- Pour supprimer les lignes concernant des peintures antérieures à 1909, nous pouvons exécuter

  ```sql
  DELETE FROM "collections"
  WHERE "acquired" < '1909-01-01';
  ```

  En utilisant l'opérateur `<` ici, nous trouvons les peintures acquises avant le 1er janvier 1909. Ce sont les peintures qui seront supprimées lors de l'exécution de la requête.
- Il peut y avoir des cas où la suppression de certaines données pourrait affecter l'intégrité d'une base de données. Les contraintes de clé étrangère en sont un bon exemple. Une colonne de clé étrangère fait référence à la clé primaire d'une table différente. Si nous devions supprimer la clé primaire, la colonne de clé étrangère n'aurait plus rien à référencer !
- Considérons maintenant un schéma mis à jour pour la base de données du MFA, contenant des informations non seulement sur les œuvres d'art mais aussi sur les artistes. Les deux entités Artiste et Collection ont une relation plusieurs-à-plusieurs : une peinture peut être créée par plusieurs artistes et un seul artiste peut également créer plusieurs œuvres d'art.

  ["Schéma mis à jour avec les entités artiste et collection"]

- Voici une base de données mettant en œuvre le diagramme ER ci-dessus.

  ["Trois tables : artistes, créés, collections"]

  Les tables `artistes` et `collections` ont des clés primaires : les colonnes ID. La table `created` fait référence à ces ID dans ses deux colonnes de clé étrangère.
- Étant donné cette base de données, si nous choisissons de supprimer l'artiste non identifié (avec l'ID 3), que se passera-t-il avec les lignes de la table `created` avec un `artist_id` de 3 ? Essayons-le.
- Après avoir ouvert `mfa.db`, nous pouvons maintenant voir le schéma mis à jour en exécutant la commande `.schema`. La table `created` a effectivement deux contraintes de clé étrangère, une pour l'ID de l'artiste et une pour l'ID de la collection.
- Maintenant, nous pouvons essayer de supprimer de la table `artistes`.

  ```sql
  DELETE FROM "artists"
  WHERE "name" = 'Artiste non identifié';
  ```

  En exécutant ceci, nous obtenons une erreur très similaire à celles que nous avons déjà vues dans ce cours : `Runtime error: FOREIGN KEY constraint failed (19)`. Cette erreur nous informe que la suppression de ces données violerait la contrainte de clé étrangère définie dans la table `created`.
- Comment nous assurer que la contrainte n'est pas violée ? Une possibilité est de supprimer les lignes correspondantes de la table `created` avant de supprimer de la table `artistes`.

  ```sql
  DELETE FROM "created"
  WHERE "artist_id" = (
      SELECT "id"
      FROM "artists"
      WHERE "name" = 'Artiste non identifié'
  );
  ```

  Cette requête supprime efficacement l'affiliation de l'artiste avec son œuvre. Une fois l'affiliation supprimée, nous pouvons supprimer les données de l'artiste sans violer la contrainte de clé étrangère. Pour ce faire, nous pouvons exécuter

  ```sql
  DELETE FROM "artists"
  WHERE "name" = 'Artiste non identifié';
  ```

- Dans une autre possibilité, nous pouvons spécifier l'action à entreprendre lorsqu'un ID référencé par une clé étrangère est supprimé. Pour ce faire, nous utilisons le mot-clé `ON DELETE` suivi de l'action à entreprendre.
  - `ON DELETE RESTRICT` : Cela nous empêche de supprimer des ID lorsque la contrainte de clé étrangère est violée.
  - `ON DELETE NO ACTION` : Cela permet la suppression d'ID référencés par une clé étrangère et rien ne se passe.
  - `ON DELETE SET NULL` : Cela permet la suppression d'ID référencés par une clé étrangère et définit les références de clé étrangère sur `NULL`.
  - `ON DELETE SET DEFAULT` : Cela fait la même chose que le précédent, mais nous permet de définir une valeur par défaut au lieu de `NULL`.
  - `ON DELETE CASCADE` : Cela permet la suppression d'ID référencés par une clé étrangère et supprime également en cascade les lignes de clé étrangère référentes. Par exemple, si nous utilisions ceci pour supprimer un ID d'artiste, toutes les affiliations de l'artiste avec les œuvres d'art seraient également supprimées de la table `created`.
- La dernière version du fichier de schéma met en œuvre la méthode ci-dessus. Les contraintes de clé étrangère ressemblent maintenant à ceci :

  ```sql
  FOREIGN KEY("artist_id") REFERENCES "artists"("id") ON DELETE CASCADE
  FOREIGN KEY("collection_id") REFERENCES "collections"("id") ON DELETE CASCADE
  ```

  Maintenant, l'exécution de l'instruction `DELETE` suivante ne résultera pas en une erreur, et supprimera en cascade de la table `artistes` à la table `created` :

  ```sql
  DELETE FROM "artists"
  WHERE "name" = 'Artiste non identifié';
  ```

  Pour vérifier que cette suppression en cascade a fonctionné, nous pouvons interroger la table `created` :

  ```sql
  SELECT * FROM "created";
  ```

  Nous observons qu'aucune des lignes n'a un ID de 3 (l'ID de l'artiste supprimé de la table `artistes`).

## **Mise à jour de données (Updating Data)**

- Nous pouvons facilement imaginer des scénarios dans lesquels des données dans une base de données devraient être mises à jour. Peut-être, dans le cas de la base de données du MFA, nous découvrons que la peinture "Fermiers travaillant à l'aube" initialement attribuée à un "Artiste non identifié" a en fait été créée par l'artiste Li Yin.
- Nous pouvons utiliser la commande de mise à jour pour apporter des modifications, par exemple, à l'affiliation d'une peinture. Voici la syntaxe de la commande de mise à jour.

  ["Syntaxe de la commande de mise à jour"]

- Changeons cette affiliation pour "Fermiers travaillant à l'aube" dans la table `created` en utilisant la syntaxe ci-dessus.

  ```sql
  UPDATE "created"
  SET "artist_id" = (
      SELECT "id"
      FROM "artists"
      WHERE "name" = 'Li Yin'
  )
  WHERE "collection_id" = (
      SELECT "id"
      FROM "collections"
      WHERE "title" = 'Fermiers travaillant à l'aube'
  );
  ```

  La première partie de cette requête spécifie la table à mettre à jour. La partie suivante récupère l'ID de Li Yin à définir comme nouvel ID. La dernière partie sélectionne la ou les lignes dans `created` qui seront mises à jour avec l'ID de Li Yin, qui est la peinture "Fermiers travaillant à l'aube" !

## **Fin**

- Cela conclut le Cours 3 sur l'écriture en SQL !

---

Si vous avez besoin de plus d'informations ou d'aide supplémentaire, n'hésitez pas à demander !