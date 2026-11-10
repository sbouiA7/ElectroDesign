import 'dart:ui';

class Part {
  const Part(this.name, this.family, this.symbol, this.details);
  final String name, family, symbol, details;
}
const library = <Part>[
  Part('Interrupteur', 'Domestique', 'S', 'Commande d’éclairage'),
  Part('Prise 2P+T', 'Domestique', 'P', 'Prise avec conducteur de protection'),
  Part('Lampe', 'Domestique', 'L', 'Point lumineux'),
  Part('Disjoncteur', 'Protection', 'QF', 'Protection contre les surintensités'),
  Part('Interrupteur différentiel', 'Protection', 'ID', 'Protection différentielle'),
  Part('Parafoudre', 'Protection', 'SPD', 'Protection contre les surtensions'),
  Part('Contacteur', 'Tertiaire', 'KM', 'Commande de puissance'),
  Part('Relais thermique', 'Industriel', 'RT', 'Protection moteur'),
  Part('Moteur triphasé', 'Industriel', 'M 3~', 'Récepteur triphasé'),
  Part('Variateur de vitesse', 'Nouvelle génération', 'VFD', 'Commande électronique moteur'),
  Part('Automate programmable', 'Nouvelle génération', 'PLC', 'Commande programmable'),
  Part('Compteur intelligent', 'Nouvelle génération', 'kWh', 'Mesure et suivi énergétique'),
  Part('Fusible', 'Protection', 'F', 'Protection par fusion'),
  Part('Sectionneur', 'Industriel', 'QS', 'Isolement visible d’un circuit'),
  Part('Disjoncteur moteur', 'Industriel', 'QF-M', 'Protection et commande moteur'),
  Part('Démarreur progressif', 'Industriel', 'ATS', 'Démarrage moteur progressif'),
  Part('Transformateur', 'Industriel', 'T', 'Adaptation de tension'),
  Part('Alimentation 24 V CC', 'Tertiaire', 'PS', 'Alimentation de commande'),
  Part('Bouton poussoir', 'Tertiaire', 'BP', 'Commande momentanée'),
  Part('Arrêt d’urgence', 'Industriel', 'AU', 'Commande de sécurité'),
  Part('Capteur de proximité', 'Industriel', 'B', 'Détection sans contact'),
  Part('Fin de course', 'Industriel', 'FC', 'Détection de position'),
  Part('Onduleur', 'Nouvelle génération', 'UPS', 'Alimentation sans interruption'),
  Part('Batterie de stockage', 'Nouvelle génération', 'BAT', 'Stockage électrique'),
  Part('Borne de recharge VE', 'Nouvelle génération', 'EV', 'Recharge de véhicule électrique'),
  Part('Relais connecté', 'Nouvelle génération', 'IoT', 'Commande et supervision connectées'),
  Part('Détecteur de fumée', 'Tertiaire', 'DF', 'Détection incendie'),
  Part('Bloc de secours', 'Tertiaire', 'BAES', 'Éclairage de sécurité'),
  Part('Contrôleur GTB', 'Tertiaire', 'BMS', 'Gestion technique du bâtiment'),

  Part('Disjoncteur différentiel', 'Protection', 'RCBO', 'Protection surintensité et courant différentiel résiduel'),
  Part('Disjoncteur tétrapolaire', 'Protection', '4P', 'Protection des réseaux triphasés avec neutre'),
  Part('Disjoncteur sélectif', 'Protection', 'S', 'Protection avec temporisation sélective'),
  Part('Relais de contrôle de phase', 'Protection', 'RCP', 'Surveillance ordre et perte de phase'),
  Part('Contrôleur d’isolement', 'Protection', 'IMD', 'Surveillance permanente du réseau IT'),
  Part('Compteur d’énergie Modbus', 'Tertiaire', 'M-BUS', 'Mesure électrique communicante'),
  Part('Analyseur de réseau', 'Tertiaire', 'PQ', 'Mesure tension, courant, puissance et qualité réseau'),
  Part('Transformateur de courant', 'Tertiaire', 'TC', 'Adaptation du courant pour mesure et protection'),
  Part('Variateur solaire', 'Nouvelle génération', 'PV', 'Conversion CC/CA pour installation photovoltaïque'),
  Part('Panneau photovoltaïque', 'Nouvelle génération', 'PV+', 'Générateur solaire photovoltaïque'),
  Part('Micro-onduleur solaire', 'Nouvelle génération', 'MICRO', 'Conversion individuelle au niveau du module PV'),
  Part('Batterie lithium', 'Nouvelle génération', 'Li-BAT', 'Stockage électrochimique avec BMS'),
  Part('Gestionnaire de batterie', 'Nouvelle génération', 'BMS', 'Surveillance et protection des cellules'),
  Part('Gestionnaire de charge VE', 'Nouvelle génération', 'EVSE', 'Pilotage intelligent de recharge'),
  Part('Pompe à chaleur', 'Nouvelle génération', 'PAC', 'Équipement thermique à alimentation électrique'),
  Part('Thermostat connecté', 'Nouvelle génération', 'TH-IoT', 'Régulation thermique communicante'),
  Part('Passerelle domotique', 'Nouvelle génération', 'GW', 'Passerelle de communication des équipements'),
  Part('Module KNX', 'Nouvelle génération', 'KNX', 'Commande et communication domotique filaire'),
  Part('Module Zigbee', 'Nouvelle génération', 'ZB', 'Commande domotique radio maillée'),
  Part('Variateur LED', 'Domestique', 'DIM', 'Variation de luminosité compatible LED'),
  Part('Télérupteur', 'Domestique', 'TL', 'Commande d’éclairage depuis plusieurs poussoirs'),
  Part('Minuterie', 'Domestique', 'MIN', 'Commande temporisée d’éclairage'),
  Part('Détecteur de mouvement', 'Domestique', 'PIR', 'Détection infrarouge de présence'),
  Part('VMC', 'Domestique', 'VMC', 'Ventilation mécanique contrôlée'),
  Part('Groupe électrogène', 'Industriel', 'GEN', 'Source électrique autonome'),
  Part('Inverseur de sources', 'Industriel', 'ATS', 'Commutation entre réseau et source de secours'),
  Part('Démarreur moteur étoile-triangle', 'Industriel', 'Y-Δ', 'Démarrage moteur asynchrone triphasé'),
  Part('Servo-variateur', 'Industriel', 'SERVO', 'Commande précise de moteur asservi'),
  Part('Codeur incrémental', 'Industriel', 'ENC', 'Retour de position et de vitesse'),
  Part('Relais de sécurité', 'Industriel', 'SR', 'Surveillance des circuits de sécurité'),
  Part('Rideau lumineux de sécurité', 'Industriel', 'AOPD', 'Détection de présence pour protection machine'),
  Part('Électrovanne', 'Industriel', 'YV', 'Commande électrique de fluide'),
  Part('Variateur de fréquence régénératif', 'Industriel', 'AFE', 'Entraînement avec récupération d’énergie'),
  Part('Filtre harmonique actif', 'Industriel', 'AHF', 'Compensation dynamique des harmoniques'),
];

class PlacedPart {
  PlacedPart(this.part, this.position);
  final Part part;
  final Offset position;
}
