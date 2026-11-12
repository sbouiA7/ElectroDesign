# ElectroDesign — architecture produit et feuille de route

## Vision
Application Flutter native Android et Windows, simple à prendre en main, utilisable par les débutants, les étudiants et les professionnels de l'électricité. L'application doit aider à produire des plans et schémas, dimensionner les installations, concevoir des tableaux, établir des devis et apprendre l'électricité.

## Principes non négociables
- Interface claire, navigation courte, vocabulaire expliqué et assistants étape par étape.
- Trois parcours : Débutant, Étudiant et Professionnel. Les parcours adaptent l'aide et la densité des outils sans enfermer les utilisateurs.
- Une base de données centrale partagée par les modules, avec fonctionnement hors connexion pour les fonctions essentielles.
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

**À ne pas confondre :** le brasage électronique au fer à panne fine est la technique visée pour ces petits projets. Le soudage par résistance dit « par points » (électrodes qui assemblent des pièces métalliques, notamment certaines languettes de batteries) est une technique différente, à documenter séparément dans un parcours spécialisé et non comme équipement de base pour débutants.

## Sécurité et normes
- Référentiels configurables selon le pays et leur édition applicable (par exemple IEC 60364, IEC 61439, IEC 60947, IEC 60898, IEC 61008/61009, ainsi que les règles nationales applicables).
- Contrôles à développer : surcharge, court-circuit et pouvoir de coupure, sections et chute de tension, protection différentielle, terre, sélectivité, coordination, échauffement, indice IP/IK et parafoudre.
- Chaque alerte doit indiquer sa gravité, la donnée manquante, l'hypothèse et la référence normative.
- Les règles doivent être testées et versionnées ; une conformité ne peut être déclarée que si toutes les données et vérifications requises sont disponibles.

## Architecture logicielle recommandée
- Séparer interface, domaine métier, données et services.
- Modèles partagés pour projets, locaux, circuits, composants, connexions, tableaux, articles, tarifs et référentiels.
- Stockage local pour les projets et catalogues téléchargés ; synchronisation distante facultative, avec résolution explicite des conflits.
- Moteur de calcul et moteur de règles indépendants de l'interface.
- Catalogue de composants extensible par fabricants, sans lier les calculs à une marque unique.
- Tests unitaires des calculs, tests de règles normatives, tests de widgets et tests d'intégration Android/Windows.
- Pour les éditions commerciales : catalogue de fonctions et service d'accès centralisé, droits signés vérifiables hors ligne, fournisseur de paiement abstrait et indépendant des modules métier. Ne jamais embarquer de clé privée de signature dans l'application.

## Feuille de route proposée
### Phase 0 — Stabiliser la base Flutter
Vérifier compilation, analyse statique et tests Android/Windows ; corriger les problèmes de CI et garantir des artefacts reproductibles.

### Phase 1 — Fondations utilisables
Navigation simple, modes Débutant/Étudiant/Professionnel, projets enregistrables, éditeur de plans et schémas avec connexions, sauvegarde locale et export initial.

### Phase 2 — Catalogue et devis
Catalogue de composants structuré, unités et caractéristiques ; base tarifaire Tunisie (24 gouvernorats) puis modèle international ; devis avec main-d'œuvre et fournitures séparées.

### Phase 3 — Calculs et sécurité
Moteur de dimensionnement, hypothèses visibles, contrôles de sécurité versionnés et rapports d'anomalies.

### Phase 4 — Tableaux 2D/3D
Génération depuis les schémas, placement manuel, nomenclature, encombrement et vérifications.

### Phase 5 — Formation et internationalisation
Cours, exercices, langues, pays supplémentaires, catalogues régionaux vérifiés et synchronisation optionnelle.

### Phase 6 — Préparation commerciale
Définir les limites Free/Pro/Expert, implémenter le contrôle d'accès et les licences en mode test, vérifier la sécurité et le fonctionnement hors ligne, puis étudier les paiements et obligations par pays avant tout lancement commercial.

## État initial constaté
Le dépôt contient actuellement un éditeur Flutter sur grille avec une bibliothèque de composants de départ et une CI prévue pour Android et Windows. Les connexions électriques, calculs, export, catalogue tarifaire, stockage de projets et conception 3D restent à développer. Cette feuille de route décrit la cible ; elle ne signifie pas que ces fonctions sont déjà implémentées.
