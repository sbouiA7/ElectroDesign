import 'package:flutter/material.dart';

import '../../data/catalog/component_library.dart';
import '../catalog/protective_device_catalog_page.dart';
import '../../domain/models/electrical_part.dart';
import '../../domain/models/electrical_terminal.dart';
import '../../domain/models/project_document.dart';
import '../../domain/calculations/protective_device_catalog_importer.dart';
import '../../services/project_file_service.dart';
import 'widgets/grid_painter.dart';

class EditorPage extends StatefulWidget {
  const EditorPage({super.key});
  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  final placed = <PlacedPart>[];
  final connections = <ProjectConnection>[];
  bool wiringMode = false;
  int? wireStart;
  String? wireStartTerminal;
  Part tool = library.first;
  int? selected;
  String family = 'Toutes';
  DateTime projectCreatedAt = DateTime.now().toUtc();
  String projectId = 'project-${DateTime.now().microsecondsSinceEpoch}';
  String projectName = 'Mon schéma';

  List<Part> get visible =>
      library.where((p) => family == 'Toutes' || p.family == family).toList();

  void add(Offset p) => setState(() {
        placed.add(PlacedPart(
          tool,
          Offset((p.dx / 24).round() * 24.0, (p.dy / 24).round() * 24.0),
        ));
        selected = placed.length - 1;
      });

  Future<void> _handleCanvasTap(Offset point) async {
    var hit = -1;
    for (var i = placed.length - 1; i >= 0; i--) {
      if ((placed[i].position - point).distance <= 34) {
        hit = i;
        break;
      }
    }

    if (wiringMode) {
      if (hit < 0) {
        setState(() {
          wireStart = null;
          wireStartTerminal = null;
        });
        _showMessage('Choisissez un composant pour commencer le câble.');
        return;
      }
      final target = placed[hit];
      if (target.part.terminals.isEmpty) {
        setState(() => selected = hit);
        _showMessage('Aucune borne configurée pour « ${target.part.name} ». Ajoutez ses bornes dans Propriétés, puis reprenez le câblage.');
        return;
      }
      final terminal = await _chooseTerminal(target);
      if (!mounted || terminal == null) return;

      if (wireStart == null) {
        setState(() {
          wireStart = hit;
          wireStartTerminal = terminal.id;
          selected = hit;
        });
        _showMessage('Borne de départ choisie. Sélectionnez le composant d’arrivée.');
        return;
      }
      if (wireStart == hit && wireStartTerminal == terminal.id) {
        setState(() {
          wireStart = null;
          wireStartTerminal = null;
        });
        return;
      }

      final fromId = placed[wireStart!].id;
      final toId = target.id;
      final exists = connections.any((connection) =>
          connection.fromComponentId == fromId &&
              connection.fromTerminal == wireStartTerminal &&
              connection.toComponentId == toId &&
              connection.toTerminal == terminal.id ||
          connection.fromComponentId == toId &&
              connection.fromTerminal == terminal.id &&
              connection.toComponentId == fromId &&
              connection.toTerminal == wireStartTerminal);
      if (exists) {
        setState(() {
          wireStart = null;
          wireStartTerminal = null;
        });
        _showMessage('Cette liaison existe déjà.');
        return;
      }
      setState(() {
        connections.add(ProjectConnection(
          id: 'connection-${DateTime.now().microsecondsSinceEpoch}',
          fromComponentId: fromId,
          fromTerminal: wireStartTerminal!,
          toComponentId: toId,
          toTerminal: terminal.id,
        ));
        selected = hit;
        wireStart = null;
        wireStartTerminal = null;
      });
      _showMessage('Liaison ajoutée entre deux bornes réelles.');
      return;
    }

    if (hit >= 0) {
      setState(() => selected = hit);
    } else {
      add(point);
    }
  }

  Future<ElectricalTerminal?> _chooseTerminal(PlacedPart item) {
    return showDialog<ElectricalTerminal>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Choisir une borne — ${item.part.name}'),
        content: SizedBox(
          width: 320,
          height: 260,
          child: ListView(
            children: item.part.terminals.map((terminal) => ListTile(
              leading: const Icon(Icons.electrical_services),
              title: Text(terminal.label),
              subtitle: Text('Repère : ${terminal.id}'),
              onTap: () => Navigator.of(dialogContext).pop(terminal),
            )).toList(),
          ),
        ),
      ),
    );
  }

  Future<void> _configureTerminals() async {
    if (selected == null || selected! >= placed.length) return;
    final item = placed[selected!];
    final labelController = TextEditingController();
    var position = 'Gauche';
    final terminal = await showDialog<ElectricalTerminal>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, refreshDialog) => AlertDialog(
          title: Text('Ajouter une borne — ${item.part.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Repère / libellé (ex. L, N, 1, 2)',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: position,
                decoration: const InputDecoration(labelText: 'Position sur le symbole'),
                items: const ['Gauche', 'Droite', 'Haut', 'Bas']
                    .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                    .toList(),
                onChanged: (value) => refreshDialog(() => position = value ?? 'Gauche'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                final label = labelController.text.trim();
                if (label.isEmpty) return;
                final coordinates = switch (position) {
                  'Droite' => (1.0, 0.5),
                  'Haut' => (0.5, 0.0),
                  'Bas' => (0.5, 1.0),
                  _ => (0.0, 0.5),
                };
                Navigator.of(dialogContext).pop(ElectricalTerminal(
                  id: 'terminal-${DateTime.now().microsecondsSinceEpoch}',
                  label: label,
                  x: coordinates.$1,
                  y: coordinates.$2,
                ));
              },
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
    labelController.dispose();
    if (!mounted || terminal == null) return;
    if (item.part.terminals.any(
      (existing) => existing.label.toLowerCase() == terminal.label.toLowerCase(),
    )) {
      _showMessage('Ce repère de borne existe déjà sur ce composant.');
      return;
    }
    final updatedPart = Part(
      item.part.name,
      item.part.family,
      item.part.symbol,
      item.part.details,
      terminals: [...item.part.terminals, terminal],
    );
    setState(() {
      placed[selected!] = item.copyWith(part: updatedPart);
      // Keep the palette selection in sync when configuring the selected tool.
      if (tool.name == item.part.name && tool.family == item.part.family) {
        tool = updatedPart;
      }
    });
  }

  Future<void> _assignProtectiveDevice() async {
    if (selected == null || selected! >= placed.length) return;
    final importer = const ProtectiveDeviceCatalogImporter();
    try {
      final records = await importer.loadBundledRecords();
      if (!mounted) return;
      final candidates = records.where((record) =>
          record.hasValidIdentity &&
          record.breakingRatings.any((rating) => rating.isQualified)).toList();
      final chosen = await showDialog<ImportedProtectiveDeviceRecord>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Choisir une protection fabricant'),
          content: SizedBox(
            width: 420,
            height: 320,
            child: ListView(
              children: candidates.map((record) => ListTile(
                title: Text('${record.manufacturer} — ${record.productReference}'),
                subtitle: Text('${record.ratedCurrentA} A • ${record.poleCount ?? '—'}P • ${record.productFamily}'),
                onTap: () => Navigator.of(dialogContext).pop(record),
              )).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annuler'),
            ),
          ],
        ),
      );
      if (!mounted || chosen == null) return;
      final qualifiedRatings = chosen.breakingRatings.where((rating) => rating.isQualified).toList();
      final rating = await showDialog<ImportedBreakingCapacityRating>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('Choisir le pouvoir de coupure — ${chosen.productReference}'),
          content: SizedBox(
            width: 420,
            height: 280,
            child: ListView(
              children: qualifiedRatings.map((value) => ListTile(
                title: Text('${value.rating} • ${value.currentA.toStringAsFixed(0)} A'),
                subtitle: Text('${value.standard} • ${value.voltageV!.toStringAsFixed(0)} V'),
                onTap: () => Navigator.of(dialogContext).pop(value),
              )).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annuler'),
            ),
          ],
        ),
      );
      if (!mounted || rating == null) return;
      final item = placed[selected!];
      setState(() {
        placed[selected!] = item.copyWith(
          protectiveDeviceManufacturer: chosen.manufacturer,
          protectiveDeviceReference: chosen.productReference,
          protectiveDeviceRatingType: rating.rating.trim().toUpperCase(),
          protectiveDeviceBreakingCapacityA: rating.currentA,
          protectiveDeviceBreakingStandard: rating.standard,
          protectiveDeviceBreakingVoltageV: rating.voltageV,
          protectiveDeviceRatedCurrentA: chosen.ratedCurrentA,
        );
      });
      _showMessage('Protection affectée au composant. Enregistrez le projet pour conserver cette affectation.');
    } catch (error) {
      _showMessage('Catalogue indisponible : $error');
    }
  }

  void remove() {
    if (selected == null) return;
    final removedId = placed[selected!].id;
    setState(() {
      connections.removeWhere((connection) =>
          connection.fromComponentId == removedId ||
          connection.toComponentId == removedId);
      placed.removeAt(selected!);
      selected = null;
      wireStart = null;
      wireStartTerminal = null;
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _saveProject() async {
    try {
      final now = DateTime.now().toUtc();
      final document = ProjectDocument(
        id: projectId,
        name: projectName,
        createdAt: projectCreatedAt,
        updatedAt: now.isBefore(projectCreatedAt) ? projectCreatedAt : now,
        components: [
          for (final item in placed)
            ProjectComponent(
              id: item.id,
              name: item.part.name,
              family: item.part.family,
              symbol: item.part.symbol,
              details: item.part.details,
              terminals: item.part.terminals,
              protectiveDeviceManufacturer: item.protectiveDeviceManufacturer,
              protectiveDeviceReference: item.protectiveDeviceReference,
              protectiveDeviceRatingType: item.protectiveDeviceRatingType,
              protectiveDeviceBreakingCapacityA: item.protectiveDeviceBreakingCapacityA,
              protectiveDeviceBreakingStandard: item.protectiveDeviceBreakingStandard,
              protectiveDeviceBreakingVoltageV: item.protectiveDeviceBreakingVoltageV,
              protectiveDeviceRatedCurrentA: item.protectiveDeviceRatedCurrentA,
              x: item.position.dx,
              y: item.position.dy,
            ),
        ],
        connections: connections,
      );
      final saved = await ProjectFileService.saveProject(document);
      if (saved) _showMessage('Projet enregistré.');
    } catch (error) {
      _showMessage('Enregistrement impossible : $error');
    }
  }

  Future<void> _openProject() async {
    try {
      final document = await ProjectFileService.openProject();
      if (document == null) return;
      final restored = document.components.map((component) {
        final matching = library.where((part) =>
            part.name == component.name &&
            part.family == component.family &&
            part.symbol == component.symbol);
        final part = matching.isNotEmpty
            ? matching.first
            : Part(component.name, component.family, component.symbol,
                component.details, terminals: component.terminals);
        final restoredPart = Part(part.name, part.family, part.symbol, part.details,
            terminals: component.terminals.isNotEmpty ? component.terminals : part.terminals);
        return PlacedPart(
          restoredPart,
          Offset(component.x, component.y),
          id: component.id,
          protectiveDeviceManufacturer: component.protectiveDeviceManufacturer,
          protectiveDeviceReference: component.protectiveDeviceReference,
          protectiveDeviceRatingType: component.protectiveDeviceRatingType,
          protectiveDeviceBreakingCapacityA: component.protectiveDeviceBreakingCapacityA,
          protectiveDeviceBreakingStandard: component.protectiveDeviceBreakingStandard,
          protectiveDeviceBreakingVoltageV: component.protectiveDeviceBreakingVoltageV,
          protectiveDeviceRatedCurrentA: component.protectiveDeviceRatedCurrentA,
        );
      }).toList();
      final restoredConnections = document.connections;

      setState(() {
        placed
          ..clear()
          ..addAll(restored);
        connections
          ..clear()
          ..addAll(restoredConnections);
        wiringMode = false;
        wireStart = null;
        wireStartTerminal = null;
        selected = null;
        projectId = document.id;
        projectName = document.name;
        projectCreatedAt = document.createdAt.toUtc();
      });
      _showMessage('Projet « ${document.name} » ouvert.');
    } catch (error) {
      _showMessage('Ouverture impossible : fichier invalide ou incompatible.');
    }
  }

  void _newProject() => setState(() {
        placed.clear();
        connections.clear();
        wiringMode = false;
        wireStart = null;
        wireStartTerminal = null;
        selected = null;
        projectId = 'project-${DateTime.now().microsecondsSinceEpoch}';
        projectName = 'Mon schéma';
        projectCreatedAt = DateTime.now().toUtc();
      });

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Row(children: [
            Icon(Icons.electrical_services),
            SizedBox(width: 8),
            Text('ElectroDesign')
          ]),
          actions: [
            IconButton(
              tooltip: 'Catalogue des protections',
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const ProtectiveDeviceCatalogPage(),
              )),
              icon: const Icon(Icons.inventory_2_outlined),
            ),
            IconButton(
              tooltip: 'Nouveau schéma',
              onPressed: _newProject,
              icon: const Icon(Icons.note_add_outlined),
            ),
            IconButton(
              tooltip: 'Ouvrir un projet',
              onPressed: _openProject,
              icon: const Icon(Icons.folder_open_outlined),
            ),
            IconButton(
              tooltip: 'Enregistrer le projet',
              onPressed: _saveProject,
              icon: const Icon(Icons.save_outlined),
            ),
            IconButton(
              tooltip: wiringMode ? 'Quitter le câblage' : 'Tracer une liaison',
              onPressed: () => setState(() {
                wiringMode = !wiringMode;
                wireStart = null;
                wireStartTerminal = null;
              }),
              icon: Icon(wiringMode ? Icons.close : Icons.cable),
            ),
            IconButton(
              tooltip: 'Supprimer',
              onPressed: remove,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
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
          return Column(children: [
            SizedBox(height: 185, child: palette()),
            Expanded(child: canvas()),
            SizedBox(height: 200, child: properties())
          ]);
        }),
        bottomNavigationBar: BottomAppBar(
          height: 34,
          child: Row(children: [
            const Icon(Icons.grid_4x4, size: 15),
            const SizedBox(width: 6),
            Text(
              wiringMode ? 'Mode câblage actif' : 'Grille activée',
              style: const TextStyle(fontSize: 12),
            ),
            const Spacer(),
            Text('${placed.length} élément(s) • ${connections.length} liaison(s)',
                style: const TextStyle(fontSize: 12)),
          ]),
        ),
      );

  Widget palette() => Material(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('BIBLIOTHÈQUE',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: family,
                  isExpanded: true,
                  decoration: const InputDecoration(
                      isDense: true, border: OutlineInputBorder()),
                  items: [
                    'Toutes',
                    'Domestique',
                    'Protection',
                    'Tertiaire',
                    'Industriel',
                    'Nouvelle génération'
                  ]
                      .map((s) =>
                          DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => family = v ?? 'Toutes'),
                ),
                Expanded(
                    child: ListView(
                        children: visible
                            .map((p) => ListTile(
                                  dense: true,
                                  selected: tool == p,
                                  leading: CircleAvatar(
                                      radius: 15,
                                      child: Text(p.symbol,
                                          style:
                                              const TextStyle(fontSize: 10))),
                                  title: Text(p.name,
                                      style: const TextStyle(fontSize: 12)),
                                  subtitle: Text(p.family,
                                      style: const TextStyle(fontSize: 10)),
                                  onTap: () => setState(() => tool = p),
                                ))
                            .toList())),
              ]),
        ),
      );

  Widget canvas() => Column(children: [
        Container(
            height: 38,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(children: [
              Text(projectName,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              Text(
                wiringMode
                    ? (wireStart == null ? 'Câblage : départ' : 'Câblage : arrivée')
                    : 'Outil : ${tool.name}',
                style: const TextStyle(fontSize: 11),
              ),
            ])),
        Expanded(
            child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => _handleCanvasTap(d.localPosition),
          child: CustomPaint(
              painter: GridPainter(
                placed,
                selected,
                connections: connections,
                pendingWireStart: wireStart,
              ),
              child: const SizedBox.expand()),
        )),
        Padding(
            padding: const EdgeInsets.all(6),
            child: Text(
                wiringMode
                    ? 'Mode câblage : choisissez une borne de départ puis une borne d’arrivée.'
                    : 'Touchez un composant pour le sélectionner, ou une zone vide pour placer l’outil choisi.',
                style: const TextStyle(fontSize: 10))),
      ]);

  Widget properties() {
    final item =
        selected == null || selected! >= placed.length ? null : placed[selected!];
    return Container(
        color: Colors.white,
        padding: const EdgeInsets.all(12),
        child: item == null
            ? const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text('PROPRIÉTÉS',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
                    SizedBox(height: 8),
                    Text('Sélectionnez un élément.',
                        style: TextStyle(fontSize: 12))
                  ])
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    const Text('PROPRIÉTÉS',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
                    Text(item.part.name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(item.part.details,
                        style: const TextStyle(fontSize: 11)),
                    Text('Symbole : ${item.part.symbol}',
                        style: const TextStyle(fontSize: 11)),
                    Text('Bornes configurées : ${item.part.terminals.length}',
                        style: const TextStyle(fontSize: 11)),
                    if (item.protectiveDeviceReference != null)
                      Text(
                        'Protection : ${item.protectiveDeviceManufacturer} ${item.protectiveDeviceReference} — ${item.protectiveDeviceRatingType} ${item.protectiveDeviceBreakingCapacityA?.toStringAsFixed(0) ?? '—'} A',
                        style: const TextStyle(fontSize: 11),
                      ),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                            onPressed: _assignProtectiveDevice,
                            icon: const Icon(Icons.shield_outlined),
                            label: Text(item.protectiveDeviceReference == null
                                ? 'Affecter une protection'
                                : 'Modifier la protection'))),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                            onPressed: _configureTerminals,
                            icon: const Icon(Icons.add_circle_outline),
                            label: const Text('Configurer une borne'))),
                    Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                            onPressed: remove,
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Supprimer'))),
                  ]));
  }
}
