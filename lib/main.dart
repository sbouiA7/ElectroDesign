import 'package:flutter/material.dart';

void main() => runApp(const ElectroDesignApp());

class ElectroDesignApp extends StatelessWidget {
  const ElectroDesignApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'ElectroDesign',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF087E8B)), useMaterial3: true),
    home: const EditorPage(),
  );
}

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

class EditorPage extends StatefulWidget {
  const EditorPage({super.key});
  @override
  State<EditorPage> createState() => _EditorPageState();
}
class _EditorPageState extends State<EditorPage> {
  final placed = <PlacedPart>[];
  Part tool = library.first;
  int? selected;
  String family = 'Toutes';
  List<Part> get visible => library.where((p) => family == 'Toutes' || p.family == family).toList();

  void add(Offset p) => setState(() { placed.add(PlacedPart(tool, Offset((p.dx / 24).round() * 24.0, (p.dy / 24).round() * 24.0))); selected = placed.length - 1; });
  void remove() { if (selected != null) setState(() { placed.removeAt(selected!); selected = null; }); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Row(children: [Icon(Icons.electrical_services), SizedBox(width: 8), Text('ElectroDesign')] ), actions: [
      IconButton(tooltip: 'Nouveau schéma', onPressed: () => setState(() { placed.clear(); selected = null; }), icon: const Icon(Icons.note_add_outlined)),
      IconButton(tooltip: 'Supprimer', onPressed: remove, icon: const Icon(Icons.delete_outline)),
    ]),
    body: LayoutBuilder(builder: (context, c) {
      if (c.maxWidth > 850) {
        return Row(children: [
        SizedBox(width: 245, child: palette()),
        const VerticalDivider(width: 1),
        Expanded(child: canvas()),
        const VerticalDivider(width: 1),
        SizedBox(width: 230, child: properties()),
        ]);
      }
      return Column(children: [SizedBox(height: 185, child: palette()), Expanded(child: canvas()), SizedBox(height: 105, child: properties())]);
    }),
    bottomNavigationBar: BottomAppBar(height: 34, child: Row(children: [
      const Icon(Icons.grid_4x4, size: 15), const SizedBox(width: 6), const Text('Grille activée', style: TextStyle(fontSize: 12)),
      const Spacer(), Text('${placed.length} élément(s)', style: const TextStyle(fontSize: 12)),
    ])),
  );

  Widget palette() => Material(color: Colors.white, child: Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('BIBLIOTHÈQUE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
    const SizedBox(height: 6),
    DropdownButtonFormField<String>(
      initialValue: family, isExpanded: true, decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
      items: ['Toutes', 'Domestique', 'Protection', 'Tertiaire', 'Industriel', 'Nouvelle génération'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
      onChanged: (v) => setState(() => family = v ?? 'Toutes'),
    ),
    Expanded(child: ListView(children: visible.map((p) => ListTile(
      dense: true, selected: tool == p, leading: CircleAvatar(radius: 15, child: Text(p.symbol, style: const TextStyle(fontSize: 10))),
      title: Text(p.name, style: const TextStyle(fontSize: 12)), subtitle: Text(p.family, style: const TextStyle(fontSize: 10)),
      onTap: () => setState(() => tool = p),
    )).toList())),
  ])));

  Widget canvas() => Column(children: [
    Container(height: 38, color: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [
      const Text('Éditeur de schéma', style: TextStyle(fontWeight: FontWeight.w600)), const Spacer(),
      Text('Outil : ${tool.name}', style: const TextStyle(fontSize: 11)),
    ])),
    Expanded(child: GestureDetector(
      behavior: HitTestBehavior.opaque, onTapDown: (d) {
        final point = d.localPosition;
        var hit = -1;
        for (var i = placed.length - 1; i >= 0; i--) {
          if ((placed[i].position - point).distance <= 34) { hit = i; break; }
        }
        if (hit >= 0) {
          setState(() => selected = hit);
        } else {
          add(point);
        }
      },
      child: CustomPaint(painter: GridPainter(placed, selected), child: const SizedBox.expand()),
    )),
    const Padding(padding: EdgeInsets.all(6), child: Text('Touchez un composant de la grille pour le sélectionner, ou une zone vide pour placer l’outil choisi.', style: TextStyle(fontSize: 10))),
  ]);

  Widget properties() {
    final item = selected == null || selected! >= placed.length ? null : placed[selected!];
    return Container(color: Colors.white, padding: const EdgeInsets.all(12), child: item == null
      ? const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('PROPRIÉTÉS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), SizedBox(height: 8), Text('Sélectionnez un élément.', style: TextStyle(fontSize: 12))])
      : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('PROPRIÉTÉS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        Text(item.part.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(item.part.details, style: const TextStyle(fontSize: 11)),
        Text('Symbole : ${item.part.symbol}', style: const TextStyle(fontSize: 11)),
        Align(alignment: Alignment.centerRight, child: TextButton.icon(onPressed: remove, icon: const Icon(Icons.delete_outline), label: const Text('Supprimer'))),
      ]));
  }
}

class GridPainter extends CustomPainter {
  GridPainter(this.items, this.selected);
  final List<PlacedPart> items;
  final int? selected;
  @override
  void paint(Canvas canvas, Size size) {
    const step = 24.0;
    final grid = Paint()..color = const Color(0xFFE3E9EC)..strokeWidth = .6;
    for (double x = 0; x < size.width; x += step) { canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid); }
    for (double y = 0; y < size.height; y += step) { canvas.drawLine(Offset(0, y), Offset(size.width, y), grid); }
    for (var i = 0; i < items.length; i++) {
      final item = items[i]; final c = item.position;
      final p = Paint()..color = (i == selected ? const Color(0xFF087E8B) : const Color(0xFF263746))..style = PaintingStyle.stroke..strokeWidth = 2;
      canvas.drawRect(Rect.fromCenter(center: c, width: 54, height: 40), p);
      final symbol = TextPainter(text: TextSpan(text: item.part.symbol, style: TextStyle(color: p.color, fontSize: 12, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr)..layout(maxWidth: 50);
      symbol.paint(canvas, c - Offset(symbol.width / 2, symbol.height / 2));
      final label = TextPainter(text: TextSpan(text: item.part.name, style: const TextStyle(color: Color(0xFF34495E), fontSize: 9)), textDirection: TextDirection.ltr)..layout(maxWidth: 110);
      label.paint(canvas, c + Offset(-label.width / 2, 23));
    }
  }
  @override
  bool shouldRepaint(covariant GridPainter old) => old.items != items || old.selected != selected;
}
