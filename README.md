# ElectroDesign

Application Flutter native de conception de schémas électriques pour Android et Windows.

## Fonctions présentes dans la branche de calcul

- Éditeur de schémas adaptatif, bibliothèque de composants, placement et sélection.
- Connexions interactives entre bornes configurées, enregistrement et ouverture de projets JSON.
- Catalogue de protections avec références ABB, Hager, Legrand et SOMEF ; les caractéristiques incomplètes restent signalées et ne sont pas utilisées comme données vérifiées.
- Estimation des courants en DC, monophasé et triphasé.
- Calcul de chute de tension et pré-dimensionnement des sections de câbles à partir des données fournies.
- Contrôles de coordination des protections, de mise à la terre TT/TN et vérifications RCD/selectivité sur les données disponibles.
- Tests unitaires des modèles et fonctions de calcul.

## Limites et sécurité

Les résultats dépendent des données de câbles, fabricants, protections, normes et conditions réelles de l'installation. Les contrôles sont des aides à l'étude ; ils ne constituent ni une vérification exhaustive de conformité ni une certification. Les données fabricant incomplètes, notamment certaines fiches de catalogue, ne doivent pas être extrapolées.

Les tableaux 2D/3D, métrés, devis/factures, tarifs régionaux sourcés et parcours de formation restent des étapes ultérieures.

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

Les workflows GitHub Actions vérifient l'analyse et les tests Flutter et préparent les compilations Android APK et Windows. Les artefacts ne sont considérés disponibles qu'après une exécution réussie.
