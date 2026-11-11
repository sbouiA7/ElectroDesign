import 'package:flutter/material.dart';

import '../../data/catalog/component_library.dart';
import '../../domain/models/electrical_part.dart';
import '../../domain/models/project_document.dart';
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

  String _componentId(int index) => 'component-${index + 1}';

  void _handleCanvasTap(Offset point) {
    var hit = -1;
    for (var i = placed.length - 1; i >= 0; i--) {
      if ((placed[i].position - point).distance <= 34) {
        hit = i;
        break;
      }
    }

    if (wiringMode) {
      if (hit < 0) {
        setState(() => wireStart = null);
        _showMessage('Choisissez un composant pour commencer le câble.');
        return;
      }
      if (wireStart == null) {
        setState(() {
          wireStart = hit;
          selected = hit;
        });
        _showMessage('Point de départ choisi. Touchez le composant d’arrivée.');
        return;
      }
      if (wireStart == hit) {
        setState(() => wireStart = null);
        return;
      }
      final fromId = _componentId(wireStart!);
      final toId = _componentId(hit);
      final exists = connections.any((connection) =>
          (connection.fromComponentId == fromId && connection.toComponentId == toId) ||
          (connection.fromComponentId == toId && connection.toComponentId == fromId));
      if (exists) {
        setState(() => wireStart = null);
        _showMessage('Une liaison existe déjà entre ces composants.');
        return;
      }
      setState(() {
        connections.add(ProjectConnection(
          id: 'connection-${DateTime.now().microsecondsSinceEpoch}',
          fromComponentId: fromId,
          fromTerminal: 'A',
          toComponentId: toId,
          toTerminal: 'B',
        ));
        selected = hit;
        wireStart = null;
      });
      _showMessage('Liaison ajoutée.');
      return;
    }

    if (hit >= 0) {
      setState(() => selected = hit);
    } else {
      add(point);
    }
  }

  void remove() {
    if (selected == null) return;
    final removedId = _componentId(selected!);
    setState(() {
      connections.removeWhere((connection) =>
          connection.fromComponentId == removedId ||
          connection.toComponentId == removedId);
      placed.removeAt(selected!);
      for (var i = 0; i < connections.length; i++) {
        final connection = connections[i];
        int remap(String id) {
          final oldIndex = int.parse(id.substring('component-'.length)) - 1;
          return _componentId(oldIndex > selected! ? oldIndex - 1 : oldIndex);
        }
        connections[i] = ProjectConnection(
          id: connection.id,
          fromComponentId: remap(connection.fromComponentId),
          fromTerminal: connection.fromTerminal,
          toComponentId: remap(connection.toComponentId),
          toTerminal: connection.toTerminal,
          conductor: connection.conductor,
        );
      }
      selected = null;
      wireStart = null;
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
          for (var i = 0; i < placed.length; i++)
            ProjectComponent(
              id: 'component-${i + 1}',
              name: placed[i].part.name,
              family: placed[i].part.family,
              symbol: placed[i].part.symbol,
              details: placed[i].part.details,
              x: placed[i].position.dx,
              y: placed[i].position.dy,
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
                component.details);
        return PlacedPart(part, Offset(component.x, component.y));
      }).toList();

      setState(() {
        placed
          ..clear()
          ..addAll(restored);
        connections
          ..clear()
          ..addAll(document.connections);
        wiringMode = false;
        wireStart = null;
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
            SizedBox(height: 105, child: properties())
          ]);
        }),
        bottomNavigationBar: BottomAppBar(
          height: 34,
          child: Row(children: [
            const Icon(Icons.grid_4x4, size: 15),
            const SizedBox(width: 6),
            Text(wiringMode ? 'Mode câblage actif' : 'Grille activée', style: const TextStyle(fontSize: 12)),
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
              IconButton(
                tooltip: 'Mode câblage',
                onPressed: () => setState(() {
                  wiringMode = !wiringMode;
                  wireStart = null;
                }),
                icon: Icon(wiringMode ? Icons.close : Icons.cable),
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
        const Padding(
            padding: EdgeInsets.all(6),
            child: Text(
                wiringMode
                    ? 'Mode câblage : touchez deux composants successivement pour créer une liaison.'
                    : 'Touchez un composant pour le sélectionner, ou une zone vide pour placer l’outil choisi.',
                style: TextStyle(fontSize: 10))),
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
                    Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                            onPressed: remove,
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Supprimer'))),
                  ]));
  }
}
