# Nettoyage de Météorites ([Version originale](https://cs50.harvard.edu/sql/2024/psets/3/meteorites/))

![Astronautes de la NASA nettoyant une grosse météorite, dans le style d'une bande dessinée de science-fiction](https://cs50.harvard.edu/sql/2024/psets/3/meteorites/cleaning_comic.png) "Astronautes de la NASA nettoyant une grosse météorite, dans le style d'une bande dessinée de science-fiction", généré par [DALL·E 2](https://openai.com/dall-e-2)

## Problème à Résoudre

En tant qu'ingénieur de données à la NASA, vous passez souvent votre temps à nettoyer des météorites - ou du moins les données qu'elles génèrent.

On vous a fourni un fichier CSV des atterrissages historiques de météorites ici sur Terre, et il y en a pas mal ! Votre travail consiste à importer les données dans une base de données SQLite, en les nettoyant au passage. Une fois terminé, la base de données sera utilisée dans des analyses par certains de vos collègues ingénieurs.

## Distribution Code

et voir un fichier CSV nommé `meteorites.csv` à côté d'un fichier `import.sql`. Si ce n'est pas le cas, revenez sur vos pas et voyez si vous pouvez déterminer où vous vous êtes trompé !

## Spécification

Dans `import.sql`, écrivez une série d'instructions SQL (et SQLite) pour importer et nettoyer les données de `meteorites.csv` dans une table, `meteorites`, dans une base de données appelée `meteorites.db`.

Dans `meteorites.db`, la table `meteorites` doit avoir les colonnes suivantes :

Colonnes dans la table `meteorites`
- `id`, qui représente l'ID unique de la météorite.
- `name`, qui représente le nom donné à la météorite.
- `class`, qui est la classification de la météorite, selon le schéma de classification traditionnel.
- `mass`, qui est le poids de la météorite, en grammes.
- `discovery`, qui est soit "Fell" (chute) soit "Found" (trouvée). "Fell" indique que la météorite a été vue tombant sur Terre, tandis que "Found" indique que la météorite n'a été trouvée qu'après avoir atterri sur Terre.
- `year`, qui est l'année de découverte de la météorite.
- `lat`, qui est la latitude à laquelle la météorite a atterri.
- `long`, qui est la longitude à laquelle la météorite a atterri.

Gardez à l'esprit que toutes les colonnes du CSV ne doivent pas se retrouver dans la table finale !

Pour considérer les données de la table `meteorites` comme propres, vous devez vous assurer que...

1. Toutes les valeurs vides dans `meteorites.csv` sont représentées par `NULL` dans la table `meteorites`.
    - Gardez à l'esprit que les colonnes `mass`, `year`, `lat`, et `long` ont des valeurs vides dans le CSV.
2. Toutes les colonnes avec des valeurs décimales (par exemple, 70.4777) doivent être arrondies au centième le plus proche (par exemple, 70.4777 devient 70.48).
    - Gardez à l'esprit que les colonnes `mass`, `lat`, et `long` ont des valeurs décimales.
3. Toutes les météorites avec le `nametype` "Relict" ne sont pas incluses dans la table `meteorites`.
4. Les météorites sont triées par `year`, de la plus ancienne à la plus récente, et ensuite - si deux météorites ont atterri la même année - par `name`, dans l'ordre alphabétique.
5. Vous avez mis à jour les IDs des météorites de `meteorites.csv`, selon l'ordre spécifié en #4.
    - L'`id` des météorites doit commencer à 1, en commençant par la météorite qui a atterri l'année la plus ancienne et qui est la première dans l'ordre alphabétique pour cette année-là.

## Conseils

Il peut sembler accablant de savoir par où commencer pour nettoyer un fichier de données aussi volumineux ! Décomposons le problème en morceaux plus petits.

Commencez par importer `meteorites.csv` dans une table temporaire

Commencez par importer toutes les données de `meteorites.csv` dans une table temporaire, appelée `meteorites_temp`. Une table temporaire est un espace réservé utile : vous pouvez l'utiliser pour nettoyer vos données jusqu'à ce qu'elles soient sous une forme adaptée à votre table `meteorites` finale.

Avant d'importer un CSV dans une base de données SQLite, il est préférable de définir le schéma de la table dans laquelle ces données seront importées. Dans `import.sql`, essayez ce qui suit :

```
CREATE TABLE "meteorites_temp" (
    -- TODO
);
```

Nous vous laissons le soin de choisir les noms des colonnes.

Ensuite, rappelez-vous que `.import` est une instruction SQLite qui peut importer un CSV dans une table de votre choix. Après votre instruction `CREATE TABLE`, écrivez une instruction `.import` pour importer les données de `meteorites.csv` dans la table `meteorites_temp`.

Enfin, conformément à la section Utilisation ci-dessous, essayez de créer `meteorites.db` en exécutant les instructions dans `import.sql`.

Écrivez des instructions SQL pour nettoyer les données importées

Avec vos données dans une table temporaire, continuez à écrire des instructions SQL pour nettoyer les données. Considérez comment vous pourriez mettre à jour les valeurs de la colonne `mass`, par exemple :

```
UPDATE "meteorites_temp"
SET "mass" = ...
WHERE ...
```

Vous devrez peut-être écrire quelques instructions de ce type, une (ou plus) pour chaque colonne que vous essayez de nettoyer.

Transférez les données de votre table temporaire dans une table `meteorites`

Rappelez-vous que vous pouvez `INSERT` des valeurs dans une nouvelle table en `SELECT`ionnant des lignes d'une autre :

```
INSERT INTO "table0" ("column0", "column1")
SELECT "column0", "column1" FROM "table1";
```

Lorsque vous le faites, vous pouvez réorganiser vos données en utilisant `ORDER BY`. Et, tant que vous avez spécifié une colonne de clé primaire dans votre nouvelle table, une telle instruction attribuera automatiquement de nouveaux IDs aux lignes insérées si aucun n'est spécifié.

Une fois que vous avez terminé avec la table temporaire, il est bon de la supprimer !

## Utilisation

Introduisons quelques commandes de terminal qui pourraient être utiles pendant que vous travaillez sur le nettoyage de cet ensemble de données ! Considérez ce qui suit :

```
cat import.sql | sqlite3 meteorites.db
```

La commande ci-dessus peut être décomposée en deux parties :

- `cat import.sql` affiche les données dans `import.sql`. Essayez-le seul si vous êtes curieux.
- `sqlite3 meteorites.db` ouvre un fichier appelé `meteorites.db` avec le moteur `sqlite3`, comme vous en avez déjà l'habitude.

Lorsque ces commandes sont combinées avec un pipe, `|`, les données de `import.sql` sont traitées comme un ensemble d'instructions pour `sqlite3` à exécuter sur `meteorites.db`. Si `meteorites.db` n'existe pas encore, il sera créé et les instructions dans `import.sql` seront exécutées dessus.

Et si votre `import.sql` n'est pas parfait et que vous souhaitez recréer la base de données ? Considérez la suppression de la version actuelle de `meteorites.db` avec :

```
rm meteorites.db
```

`rm` signifie remove (supprimer). Si vous y êtes invité, tapez "y" suivi de Entrée pour confirmer la suppression de `meteorites.db`. À partir de là, vous pouvez réexécuter `cat import.sql | sqlite3 meteorites.db` pour créer `meteorites.db` à partir de zéro.


