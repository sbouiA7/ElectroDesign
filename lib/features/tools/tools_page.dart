import 'package:flutter/material.dart';

import '../../data/catalog/tool_library.dart';
import '../../domain/models/electrical_tool.dart';

class ToolsPage extends StatefulWidget {
  const ToolsPage({super.key});

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  String category = 'Toutes';
  String query = '';

  List<ElectricalTool> get visible => toolLibrary.where((tool) {
        final matchesCategory = category == 'Toutes' || tool.category == category;
        final searchable = '${tool.name} ${tool.description} ${tool.calibres.join(' ')}'.toLowerCase();
        return matchesCategory && searchable.contains(query.toLowerCase());
      }).toList();

  @override
  Widget build(BuildContext context) {
    final categories = ['Toutes', ...toolLibrary.map((item) => item.category).toSet()];
    return Scaffold(
      appBar: AppBar(title: const Text('Outils et instruments')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: 'Rechercher un outil, calibre ou mesure',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() => query = value.trim()),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: categories.map((item) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(item),
                selected: category == item,
                onSelected: (_) => setState(() => category = item),
              ),
            )).toList(),
          ),
        ),
        Expanded(
          child: visible.isEmpty
              ? const Center(child: Text('Aucun outil trouvé.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: visible.length,
                  itemBuilder: (context, index) => _ToolCard(tool: visible[index]),
                ),
        ),
      ]),
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({required this.tool});
  final ElectricalTool tool;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ExpansionTile(
          leading: const CircleAvatar(child: Icon(Icons.handyman_outlined)),
          title: Text(tool.name),
          subtitle: Text(tool.category),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            Align(alignment: Alignment.centerLeft, child: Text(tool.description)),
            if (tool.calibres.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Align(alignment: Alignment.centerLeft, child: Text('Calibres / plages indicatives', style: TextStyle(fontWeight: FontWeight.bold))),
              ...tool.calibres.map((value) => Align(alignment: Alignment.centerLeft, child: Text('• $value'))),
            ],
            if (tool.measurements.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Align(alignment: Alignment.centerLeft, child: Text('Mesures et fonctions', style: TextStyle(fontWeight: FontWeight.bold))),
              ...tool.measurements.map((value) => Align(alignment: Alignment.centerLeft, child: Text('• $value'))),
            ],
            if (tool.safetyCategory != null) ...[
              const SizedBox(height: 8),
              Align(alignment: Alignment.centerLeft, child: Text('Sécurité : ${tool.safetyCategory}')),
            ],
            const SizedBox(height: 8),
            Align(alignment: Alignment.centerLeft, child: Text(tool.selectionNote, style: Theme.of(context).textTheme.bodySmall)),
          ],
        ),
      );
}
