# ElectroDesign — architecture produit et feuille de route

## Vision
Application Flutter multiplateforme de conception électrique, simple à prendre en main, destinée aux débutants, aux étudiants et aux professionnels. Elle doit aider à produire des plans et schémas, dimensionner les installations, concevoir des tableaux, établir des devis et apprendre l'électricité.

## Objectif multiplateforme
La cible est de rendre ElectroDesign accessible progressivement sur le plus grand nombre de systèmes utiles, avec un socle métier et des modèles de projets communs. Les plateformes visées sont :
- **Applications mobiles :** Android, iOS et iPadOS.
- **Ordinateurs :** Windows, macOS et Linux.
- **Navigateur :** version Web responsive, utilisable sans installation lorsque possible.
- **Chromebooks / ChromeOS :** accès prioritaire par la version Web et, selon compatibilité, par l'application Android. Pas de cible native ChromeOS séparée à ce stade.
- **HarmonyOS :** étude de faisabilité ultérieure selon le support Flutter, les outils disponibles et les contraintes de distribution. Ne pas le considérer comme une plateforme prise en charge avant validation technique.

Flutter est le socle commun envisagé, mais cela ne garantit pas automatiquement une expérience identique partout. Chaque cible devra avoir ses adaptations, tests, processus de compilation, signature et distribution. Les builds iOS et macOS nécessitent l'environnement Apple et Xcode. La version Web devra notamment traiter le stockage navigateur, les téléchargements/imports, les limites hors ligne et les fonctions qui dépendent du système.

## Principes non négociables
- Interface claire, navigation courte, vocabulaire expliqué et assistants étape par étape.
- Trois parcours : Débutant, Étudiant et Professionnel. Les parcours adaptent l'aide et la densité des outils sans enfermer les utilisateurs.
- Une base de données centrale partagée par les modules, avec fonctionnement hors connexion pour les fonctions essentielles selon les capacités de chaque plateforme.
- Les projets doivent être portables entre plateformes : format de fichier documenté et versionné, import/export fiable, sans perte silencieuse de données. La synchronisation en ligne reste facultative et doit gérer les conflits.
- Interface responsive adaptée aux téléphones, tablettes, ordinateurs et navigateurs.
- Aucune tarification imposée : les prix et la devise sont toujours modifiables par l'utilisateur.
- Ne jamais présenter un calcul ou un tableau comme conforme sans préciser le référentiel, les hypothèses et les contrôles requis.
- La validation logicielle ne remplace pas les mesures, essais et vérifications sur site par une personne qualifiée.
- Modèle commercial hybride Freemium pour la Tunisie et l'international : édition gratuite utile, éditions Pro et Expert payantes, puis offre Équipe/Entreprise à étudier.
- La monétisation ne doit jamais masquer une alerte de sécurité connue, détruire ou verrouiller les projets de l'utilisateur, ni imposer un fournisseur de paiement avant validation pays par pays.

## Modèle commercial
La stratégie détaillée, les éditions Free/Pro/Expert/Équipe, la conception des licences, le fonctionnement hors ligne, les précautions de paiement et la feuille de route de lancement sont documentés dans [docs/COMMERCIAL_STRATEGY.md](COMMERCIAL_STRATEGY.md). Aucun prix, devise par défaut, prestataire de paiement, durée d'essai ou limite chiffrée n'est encore décidé.

## Modules cibles
1. Accueil et parcours utilisateur.
2. Plans d'implantation électrique (symboles, calques, cotations, pièces et circuits).
3. Schémas unifilaires et multifilaires avec connexions réelles.
4. Métrés et dimensionnement (charges, sections, protections, chute de tension, court-circuit et mise à la terre selon données disponibles).
5. Tableaux 2D/3D : placement manuel ou génération depuis le schéma, enveloppe, rails, modules, nomenclature et contrôles.
6. Catalogue technique multimarque : composants domestiques, tertiaires, industriels et technologies récentes, caractéristiques, références et symboles.
7. Devis et factures : main-d'œuvre et fournitures séparées, quantités issues des plans quand possible, prix min/moyen/max indicatifs, taxes et devise configurables.
8. Tarifs internationaux : pays puis région/gouvernorat/ville, provenance et date de chaque prix, import/export, mode hors connexion et mise à jour sans écraser les tarifs personnalisés.
9. Formation : cours illustrés, exercices, quiz, exemples et simulations.
10. Rapports et exports : PDF et formats techniques à définir.

## Tarification internationale
- Détecter le pays à l'installation comme suggestion, puis demander confirmation ou permettre le choix manuel.
- Modèle de données : pays, subdivision administrative, ville, devise, prestation ou article, unité, prix minimum/moyen/maximum, type de prix (main-d'œuvre ou fourniture), source, date de vérification et niveau de fiabilité.
- La Tunisie doit couvrir ses 24 gouvernorats.
- La France doit pouvoir être organisée par régions, départements et villes.
- Étendre ensuite à d'autres pays sans modifier le moteur de devis.
- Les catalogues non vérifiés doivent être explicitement signalés ; ne jamais inventer des prix locaux.
- Les prix personnels de l'utilisateur sont prioritaires et ne sont jamais remplacés silencieusement.

## Rubrique « Outils et appareils de mesure »
Une rubrique dédiée rassemble les outils de travail de l'électricien, avec fiches pédagogiques, usages, précautions, exemples et compatibilités selon les tâches. Elle doit être accessible depuis l'accueil et reliée aux modules de formation et de sécurité.

Familles à couvrir progressivement :
- **Mesure électrique** : multimètre numérique, pince ampèremétrique, VAT (vérificateur d'absence de tension), testeur de continuité, contrôleur d'isolement (mégohmmètre), telluromètre (résistance de terre), contrôleur d'ordre des phases et détecteur de câbles.
- **Outillage manuel** : pinces universelles, coupantes et à dénuder, pinces à sertir, tournevis isolés, clés, coupe-câbles, couteaux et outils de tirage de conducteurs.
- **Outillage de pose** : perceuse/visseuse, perforateur, outils de fixation, aiguilles tire-fils et accessoires de repérage.
- **Protection et sécurité** : gants et équipements adaptés, lunettes, tapis isolant, balisage et consignation ; rappeler que les EPI et procédures dépendent du travail et du risque.

Chaque fiche précisera la fonction, les situations d'utilisation, les limites, les contrôles avant usage et les précautions. Les caractéristiques (catégorie CAT, tension, courant, plage de mesure, précision, normes et état de vérification) seront affichées uniquement lorsqu'elles sont connues pour le modèle concerné : aucune valeur technique ne sera inventée. Les guides devront rappeler les procédures de mise hors tension, de vérification d'absence de tension et le recours à une personne qualifiée ; l'application ne remplace ni un appareil adapté ni les règles de sécurité du chantier.

### Atelier d'assemblage électronique pour petits projets
Un parcours pratique prioritaire pour les débutants et les étudiants permettra d'assembler et de réparer de petits montages électroniques et circuits basse tension, avec des étapes guidées et des exercices progressifs.

Équipement à intégrer :
- **Station de soudage électronique à température réglable**, avec fer léger et panne fine (conique ou biseautée fine) adaptée aux petits composants et aux travaux de précision.
- Support stable pour le fer, nettoyage de panne (laine de laiton ou éponge adaptée), fil de brasage électronique et flux adaptés.
- Pompe et tresse à dessouder pour corriger les erreurs, support de circuit imprimé, pince coupante et pince à dénuder de précision.
- Loupe ou éclairage grossissant, tapis de travail résistant à la chaleur et extraction des fumées.
- Kits pédagogiques basse tension : assemblages simples, LED, résistances, interrupteurs, connecteurs et petits circuits imprimés.

L'application proposera une prise en main pas à pas : préparer le poste, identifier les composants et polarités, préparer les surfaces, réaliser et inspecter une soudure, corriger un défaut et ranger le matériel. Les consignes insisteront sur le risque de brûlure, la ventilation ou l'extraction des fumées, le support du fer chaud et la mise hors tension avant toute intervention sur un circuit. Les exercices pour débutants commenceront par des kits basse tension et des composants traversants avant d'aborder les composants plus petits.

**À ne pas confondre :** le brasage électronique au fer à panne fine est la technique visée pour ces petits projets. Le soudage par résistance dit « par points » est une technique différente, à documenter séparément dans un parcours spécialisé et non comme équipement de base pour débutants.

## Sécurité et normes
- Référentiels configurables selon le pays et leur édition applicable (par exemple IEC 60364, IEC 61439, IEC 60947, IEC 60898, IEC 61008/61009, ainsi que les règles nationales applicables).
- Contrôles à développer : surcharge, court-circuit et pouvoir de coupure, sections et chute de tension, protection différentielle, terre, sélectivité, coordination, échauffement, indice IP/IK et parafoudre.
- Chaque alerte doit indiquer sa gravité, la donnée manquante, l'hypothèse et la référence normative.
- Les règles doivent être testées et versionnées ; une conformité ne peut être déclarée que si toutes les données et vérifications requises sont disponibles.

## Architecture logicielle recommandée
- Séparer interface, domaine métier, données et services.
- Modèles partagés pour projets, locaux, circuits, composants, connexions, tableaux, articles, tarifs et référentiels.
- Définir un format de projet portable, versionné et indépendant de l'interface ; prévoir migration de versions, sauvegardes et tests d'import/export entre plateformes.
- Stockage local pour les projets et catalogues téléchargés ; synchronisation distante facultative, avec résolution explicite des conflits.
- Abstraire les fonctions dépendantes de la plateforme (fichiers, impression, partage, notifications, stockage sécurisé, caméra et accès réseau) derrière des interfaces dédiées.
- Pour le Web : prévoir persistance navigateur adaptée, gestion de quotas, import/export de fichiers, téléchargements et stratégie de cache/PWA ; expliquer clairement les fonctions indisponibles hors connexion.
- Moteur de calcul et moteur de règles indépendants de l'interface.
- Catalogue de composants extensible par fabricants, sans lier les calculs à une marque unique.
- Tests unitaires des calculs, tests de règles normatives, tests de widgets et tests d'intégration sur chaque plateforme activée.
- Pour les éditions commerciales : catalogue de fonctions et service d'accès centralisé, droits signés vérifiables hors ligne, fournisseur de paiement abstrait et indépendant des modules métier. Ne jamais embarquer de clé privée de signature dans l'application.

## Feuille de route proposée
### Phase 0 — Stabiliser la base Flutter
Vérifier compilation, analyse statique et tests sur les cibles actuellement présentes (Android/Windows) ; corriger les problèmes de CI et garantir des artefacts reproductibles.

### Phase 1 — Fondations utilisables et portabilité
Navigation simple, modes Débutant/Étudiant/Professionnel, projets enregistrables, éditeur de plans et schémas avec connexions, sauvegarde locale, format de projet versionné et export initial. Préparer les adaptations responsive mobile/tablette/ordinateur.

### Phase 2 — Catalogue et devis
Catalogue de composants structuré, unités et caractéristiques ; base tarifaire Tunisie (24 gouvernorats) puis modèle international ; devis avec main-d'œuvre et fournitures séparées.

### Phase 3 — Calculs et sécurité
Moteur de dimensionnement, hypothèses visibles, contrôles de sécurité versionnés et rapports d'anomalies.

### Phase 4 — Tableaux 2D/3D
Génération depuis les schémas, placement manuel, nomenclature, encombrement et vérifications.

### Phase 5 — Version Web
Développer et tester l'interface Web responsive, l'import/export de projets, le stockage navigateur, les téléchargements et la stratégie PWA/cache. Vérifier les différences fonctionnelles avec les applications installables.

### Phase 6 — Extension des applications de bureau et mobiles
Étendre progressivement le même socle à iOS/iPadOS, macOS et Linux. Pour chaque plateforme : adapter les fonctions système, mettre en place compilation et CI dédiées, tests sur appareils/environnements réels, signature et distribution. Les cibles Apple nécessitent un environnement macOS avec Xcode.

### Phase 7 — Compatibilité complémentaire
Valider l'expérience ChromeOS via Web et/ou Android. Étudier HarmonyOS uniquement après prototype et vérification de la faisabilité technique et de la distribution.

### Phase 8 — Formation, internationalisation et synchronisation
Cours, exercices, langues, pays supplémentaires, catalogues régionaux vérifiés et synchronisation optionnelle entre appareils.

### Phase 9 — Préparation commerciale
Définir les limites Free/Pro/Expert, implémenter le contrôle d'accès et les licences en mode test, vérifier la sécurité et le fonctionnement hors ligne, puis étudier les paiements et obligations par pays avant tout lancement commercial.

## État initial constaté
Le dépôt contient actuellement un éditeur Flutter sur grille avec une bibliothèque de composants de départ et une CI prévue pour Android et Windows. Les autres plateformes de cette feuille de route sont des objectifs, pas des versions déjà compilées ou validées. Les connexions électriques, calculs, export, catalogue tarifaire, stockage de projets et conception 3D restent à développer. Cette feuille de route décrit la cible ; elle ne signifie pas que ces fonctions sont déjà implémentées.
