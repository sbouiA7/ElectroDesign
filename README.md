# ElectroDesign

Application Flutter native de conception de schémas électriques pour Android et Windows.

## Fonctions présentes sur `main`

- Éditeur de schémas adaptatif, bibliothèque générique de 63 composants, placement, sélection et suppression.
- Configuration des bornes électriques, connexions entre bornes et tracé des liaisons.
- Création, sauvegarde et ouverture de projets locaux au format JSON versionné.
- Catalogue de protections accessible depuis la barre d’outils de l’éditeur, avec fiches ABB, Hager, Legrand et SOMEF chargées depuis des ressources embarquées (consultation hors ligne).
- Affectation à un composant d’une protection dont les caractéristiques requises sont suffisamment qualifiées.
- Socle métier de calcul : estimation de courant DC/monophasé/triphasé, estimation résistive de chute de tension, section théorique minimale et pré-dimensionnement de câble à partir de tables d’ampacité et de facteurs fournis.
- Premiers contrôles TT/TN, contraintes RCD, coordination de protections et sélectivité à un point de courant donné.
- Tests unitaires des modèles, du catalogue et des fonctions de calcul.

### Limite actuelle de l’interface de calcul

Les classes de calcul sont présentes dans la couche métier et testées, mais il n’existe pas encore de parcours graphique dédié permettant à l’utilisateur de saisir les données d’une étude, de lancer les calculs et de consulter un rapport. Cette interface reste à développer. Le catalogue des protections, lui, est accessible depuis l’éditeur.

## Limites et sécurité

Les calculs sont des aides à l’étude, pas une vérification exhaustive de conformité ni une certification. Le résultat dépend des données exactes de câble, de protection, de réseau, de pose et des référentiels applicables.

- Le pré-dimensionnement exige des valeurs d’ampacité et des facteurs de correction issus d’une table vérifiée correspondant au câble et au mode de pose réels ; aucune valeur générique n’est inventée.
- Les contrôles TT/TN exigent les mesures et paramètres applicables. Un réseau IT impose une étude spécifique des premier et second défauts.
- La sélectivité actuelle évalue uniquement le point de courant fourni ; elle ne remplace pas les courbes et tableaux fabricant.
- Les fiches fabricants ne contiennent pas toutes les courbes temps-courant, valeurs I²t et tableaux de sélectivité nécessaires à une étude complète.
- Pour SOMEF 801106CX20, la page source annonce Icn = 6 kA sans préciser la norme ni la tension d’essai ; cette valeur est conservée comme déclaration de source mais n’est pas admise comme pouvoir de coupure qualifié pour les calculs.

Les fonctions essentielles de conception, les projets locaux et le catalogue embarqué sont conçus pour rester utilisables hors ligne. Les prix des matériaux et de la main-d’œuvre, les devis/factures et les tarifs régionaux vérifiés ne sont pas encore intégrés : aucun prix ni devise ne doit être imposé. Les référentiels normatifs devront être configurables et les alertes justifiées.

## Étapes ultérieures

- Interface utilisateur des calculs et rapports d’étude.
- Catalogue multimarque étendu et enrichi avec les courbes et documents officiels exacts.
- Outillage et instruments de mesure.
- Tableaux électriques 2D/3D, placement manuel et génération depuis schéma.
- Métrés, devis/factures, prix modifiables par l’utilisateur et tarifs régionaux sourcés.
- Exports techniques et PDF.
- Parcours de formation débutant, étudiant et professionnel.

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

Les workflows GitHub Actions vérifient l’analyse et les tests Flutter et préparent les compilations Android APK et Windows. Les artefacts ne sont considérés disponibles qu’après une exécution réussie.
