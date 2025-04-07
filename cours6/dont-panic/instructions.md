# [Don't Panic](https://cs50.harvard.edu/sql/2024/psets/3/dont-panic/) // Ne Paniquez Pas ! ([Version originale](https://cs50.harvard.edu/sql/2024/psets/3/dont-panic/))

![Un seul ordinateur de bureau posé sur un bureau dans un bureau vide la nuit, dans le style d'un roman noir](https://cs50.harvard.edu/sql/2024/psets/3/dont-panic/dont-panic-glitch.png) "Un seul ordinateur de bureau posé sur un bureau dans un bureau vide la nuit, dans le style d'un roman noir", généré par [DALL·E 2](https://openai.com/dall-e-2)

## Problème à Résoudre

Vous êtes un "pentester" (testeur d'intrusion) entraîné. Les entreprises vous engagent souvent pour effectuer des tests de pénétration et signaler les vulnérabilités dans leurs systèmes de données. Il n'y a pas si longtemps, vous avez été engagé par une petite entreprise qui avait besoin de vous pour effectuer un tel test sur une base de données SQLite : celle qui alimente leur site web à faible trafic.

Pour réussir cette opération secrète, vous devrez :

- Modifier le mot de passe du compte administratif du site web.
- Effacer tous les journaux (logs) de ce changement de mot de passe enregistrés par la base de données.
- Ajouter de fausses données pour détourner l'attention de l'entreprise.

Et maintenant, une opportunité en or se présente : vous vous êtes faufilé dans les locaux de l'entreprise, juste à temps pour voir un ingénieur logiciel quitter son bureau. La connexion de l'ingénieur à la base de données est toujours ouverte. Vous estimez avoir 5 minutes avant qu'il ne revienne. Prêt ?

## Demo

![image-20250224182119613](/home/kevin-desktop/.config/Typora/typora-user-images/image-20250224182119613.png)

Vous avez une base de données nommée `dont-panic.db` à côté d'un fichier `hack.sql` et `reset.sql`. L'exécution de `sqlite3 dont-panic.db` devrait ouvrir la base de données.

## Schéma

Désolé, il n'y a pas beaucoup de temps pour expliquer le schéma de la base de données. N'oubliez pas que vous pouvez accéder au schéma d'une base de données SQLite avec `.schema`.

## Spécification

Dans `hack.sql`, écrivez une séquence d'instructions SQL pour réaliser ce qui suit :

- Modifier le mot de passe du compte administratif du site web, `admin`, pour qu'il soit "oops!".
- Effacer tous les journaux (logs) du changement de mot de passe ci-dessus enregistrés par la base de données.
- Ajouter de fausses données pour détourner l'attention des autres. En particulier, pour piéger `emily33`, faites en sorte qu'il semble seulement - dans la table `user_logs` - que le mot de passe du compte `admin` a été changé pour celui de `emily33`.

Lorsque vos instructions SQL dans `hack.sql` sont exécutées sur une nouvelle instance de la base de données, elles doivent produire les résultats ci-dessus. Sachez simplement que l'ordre dans lequel ces objectifs sont présentés n'est peut-être pas l'ordre dans lequel ils sont le mieux accomplis !

Gardez également à l'esprit que les mots de passe ne sont généralement pas stockés "en clair" - c'est-à-dire sous forme de caractères simples qui composent le mot de passe. Au lieu de cela, ils sont "hachés" (hashés), ou brouillés, pour préserver la confidentialité. Étant donné cette réalité, vous devrez vous assurer que le mot de passe auquel vous changez le mot de passe administratif est également haché. Heureusement, vous savez que les mots de passe de la table `users` sont déjà stockés sous forme de hachages MD5. Vous pouvez générer rapidement de tels hachages à partir de texte brut sur md5hashgenerator.com.

L'horloge tourne !

### Indices

- Rappelez-vous que vous pouvez `INSERT` (insérer) dans une table les lignes retournées par une instruction `SELECT`, tant que le nombre de colonnes correspond.
- Vous pouvez créer une sous-requête à tout moment dans une instruction SQL, pas seulement dans le cadre d'une clause `WHERE`. Par exemple, considérez la requête SQL suivante sur une table `user_logs` simplifiée :

```sqlite
INSERT INTO "user_logs" ("type", "password")
SELECT 'update', (
    SELECT "password"
    FROM "users"
    WHERE "username" = 'carter'
);
```

La requête ci-dessus insérera une nouvelle ligne dans la table `user_logs`. La colonne `type` aura la valeur "update" et la colonne `password` aura le mot de passe actuel de l'utilisateur `carter`.

## Utilisation

Pour tester votre piratage au fur et à mesure que vous l'écrivez dans vos fichiers `hack.sql`, vous pouvez interroger la base de données en exécutant

```
.read hack.sql
```

Si vous devez réinitialiser la base de données à tout moment, vous pouvez exécuter

```
.read reset.sql
```

pour la ramener à sa forme originale.