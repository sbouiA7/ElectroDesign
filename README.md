# ElectroDesign

Application Flutter de conception électrique. La cible produit est multiplateforme : Android, iOS/iPadOS, Windows, macOS, Linux et Web, avec une extension progressive vers ChromeOS et une étude ultérieure de HarmonyOS.

**Important :** le dépôt contient actuellement une première base Flutter pour Android et Windows. Les autres plateformes sont des objectifs de la feuille de route et ne doivent pas être considérées comme déjà compilées, testées ou publiées.

## Première base disponible
- Éditeur de schéma sur grille.
- Bibliothèque initiale domestique, tertiaire, industrielle et nouvelle génération.
- Placement, sélection et suppression de symboles.
- Interface adaptative téléphone / ordinateur.

## Cibles de la feuille de route
- **Applications :** Android, iOS, iPadOS, Windows, macOS et Linux.
- **Web :** application responsive accessible depuis un navigateur, avec étude d'une expérience installable (PWA) lorsque les fonctions le permettent.
- **ChromeOS :** accès via navigateur et/ou compatibilité Android, à valider.
- **HarmonyOS :** étude de faisabilité, sans engagement de support avant validation.

L'objectif est de partager autant que possible le code métier et les formats de projets, tout en adaptant l'interface et les fonctions système à chaque plateforme. Les projets devront pouvoir être transférés entre appareils sans perte silencieuse de données.

## Prérequis actuels
Flutter stable, Android SDK pour APK, Windows + Visual Studio (Desktop development with C++) pour EXE.

Les compilations iOS et macOS nécessitent un environnement Apple avec macOS et Xcode. Les prérequis Linux et Web seront documentés lors de l'activation de ces cibles.

## Démarrer
```sh
flutter pub get
flutter run
```

## Compiler les cibles actuellement prévues dans la base
```sh
flutter build apk --release
flutter build windows --release
```

Les commandes de build pour les autres plateformes seront ajoutées et validées au fur et à mesure de leur intégration.

## État du produit
Cette base est le début du produit. Les connexions électriques, calculs, export de plans, bibliothèque technique étendue, stockage portable des projets et conception 3D nécessitent des étapes dédiées et des tests. Voir [la feuille de route et l'architecture produit](docs/PRODUCT_ARCHITECTURE.md).
