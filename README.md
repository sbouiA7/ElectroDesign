# ElectroDesign

Application Flutter native de conception de schémas électriques pour Android et Windows.

## Fonctions présentes sur `main`

- Éditeur de schéma sur grille, adaptatif téléphone / ordinateur.
- Bibliothèque initiale de 63 composants génériques : domestique, protection, tertiaire, industriel et nouvelles générations.
- Placement, sélection et suppression de composants.
- Configuration manuelle des bornes lorsqu'aucune implantation vérifiée n'est disponible.
- Connexions interactives entre bornes et tracé orthogonal des liaisons.
- Enregistrement et ouverture de projets locaux au format JSON.
- Modèle de projet versionné (schéma 2) avec validation des identifiants, bornes et connexions.
- Tests Flutter de l'ouverture de l'éditeur, du modèle de projet et du rafraîchissement du dessin.

## Limites actuelles

Cette version constitue le socle de l'application. Le catalogue multimarque documenté, les calculs et dimensionnements électriques, les contrôles normatifs, les tableaux 2D/3D, les métrés, devis/factures, tarifs régionaux sourcés, exports techniques et parcours de formation ne sont pas encore intégrés à `main`.

Les caractéristiques fabricants doivent être associées à leur référence exacte, leur norme, leur tension et leur document source. Une donnée incomplète ne doit pas être utilisée automatiquement dans un calcul ni servir à déclarer une conformité.

Les fonctions essentielles de conception et de gestion des fichiers doivent rester utilisables hors ligne. Les prix des matériaux et de la main-d'œuvre sont à saisir et modifier par l'utilisateur ; aucun prix ni devise n'est imposé.

## Prérequis

Flutter stable, Android SDK pour APK, Windows + Visual Studio (Desktop development with C++) pour EXE.

## Démarrer

```sh
flutter pub get
flutter run
```

## Compiler

```sh
flutter build apk --release
flutter build windows --release
```

Le workflow GitHub Actions vérifie l'analyse et les tests Flutter, puis construit les versions Android APK et Windows.
