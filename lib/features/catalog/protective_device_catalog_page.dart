import 'package:material_ui/material_ui.dart';

import '../../domain/calculations/protective_device_catalog_importer.dart';

class ProtectiveDeviceCatalogPage extends StatefulWidget {
  const ProtectiveDeviceCatalogPage({super.key});
  @override
  State<ProtectiveDeviceCatalogPage> createState() => _ProtectiveDeviceCatalogPageState();
}

class _ProtectiveDeviceCatalogPageState extends State<ProtectiveDeviceCatalogPage> {
  final searchController = TextEditingController();
  final importer = const ProtectiveDeviceCatalogImporter();
  late Future<List<ImportedProtectiveDeviceRecord>> recordsFuture = importer.loadBundledRecords();
  String manufacturer = 'Tous';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<ImportedProtectiveDeviceRecord> _filter(List<ImportedProtectiveDeviceRecord> records) {
    final query = searchController.text.trim().toLowerCase();
    return records.where((record) {
      final matchesManufacturer = manufacturer == 'Tous' || record.manufacturer == manufacturer;
      final matchesQuery = query.isEmpty ||
          record.manufacturer.toLowerCase().contains(query) ||
          record.productReference.toLowerCase().contains(query) ||
          record.productFamily.toLowerCase().contains(query);
      return matchesManufacturer && matchesQuery;
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Catalogue des protections'),
      actions: [
        IconButton(
          tooltip: 'Recharger les fiches',
          onPressed: () => setState(() => recordsFuture = importer.loadBundledRecords()),
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: FutureBuilder<List<ImportedProtectiveDeviceRecord>>(
      future: recordsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.error_outline, size: 40),
                const SizedBox(height: 12),
                const Text('Impossible de charger le catalogue.'),
                const SizedBox(height: 8),
                Text('${snapshot.error}', textAlign: TextAlign.center),
                TextButton(
                  onPressed: () => setState(() => recordsFuture = importer.loadBundledRecords()),
                  child: const Text('Réessayer'),
                ),
              ]),
            ),
          );
        }
        final records = snapshot.data!;
        final filtered = _filter(records);
        return Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Rechercher une marque ou une référence',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              children: [
                for (final name in ['Tous', ...records.map((r) => r.manufacturer).toSet()])
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(name),
                      selected: manufacturer == name,
                      onSelected: (_) => setState(() => manufacturer = name),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(children: [
              Text('${filtered.length} fiche(s)'),
              const Spacer(),
              const Icon(Icons.verified_user_outlined, size: 16),
              const SizedBox(width: 5),
              const Flexible(
                child: Text('Données documentaires — validation avant calcul',
                  overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11)),
              ),
            ]),
          ),
          Expanded(
            child: filtered.isEmpty
              ? const Center(child: Text('Aucun résultat.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final record = filtered[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(child: Text(record.manufacturer.substring(0, record.manufacturer.length >= 2 ? 2 : 1).toUpperCase())),
                        title: Text(record.productReference),
                        subtitle: Text('${record.manufacturer} • ${record.ratedCurrentA?.toStringAsFixed(0) ?? '—'} A • ${record.poleCount?.toString() ?? '—'}P'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showDetails(record),
                      ),
                    );
                  },
                ),
          ),
        ]);
      },
    ),
  );

  void _showDetails(ImportedProtectiveDeviceRecord record) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(record.productReference, style: Theme.of(context).textTheme.titleLarge),
              Text(record.manufacturer, style: Theme.of(context).textTheme.titleMedium),
              const Divider(height: 24),
              _detail('Famille', record.productFamily),
              _detail('Calibre', '${record.ratedCurrentA ?? 'Non renseigné'} A'),
              _detail('Tension opérationnelle', '${record.operationalVoltageV ?? 'Non qualifiée'} V'),
              _detail('Nombre de pôles', record.poleCount?.toString() ?? 'Non renseigné'),
              const SizedBox(height: 12),
              Text('Pouvoirs de coupure déclarés', style: Theme.of(context).textTheme.titleSmall),
              if (record.breakingRatings.isEmpty) const Text('Aucune valeur transcrite.')
              else for (final rating in record.breakingRatings)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text('${rating.rating} • ${rating.currentA.toStringAsFixed(0)} A'),
                  subtitle: Text('${rating.standard ?? 'Norme non précisée'} • ${rating.voltageV?.toStringAsFixed(0) ?? 'Tension non précisée'} V'),
                  trailing: Icon(
                    rating.isQualified ? Icons.verified_outlined : Icons.warning_amber_outlined,
                    color: rating.isQualified ? Colors.green : Theme.of(context).colorScheme.error,
                  ),
                ),
              const SizedBox(height: 8),
              _detail('Document', record.document.title),
              _detail('Révision', record.document.documentRevision),
              _detail('Langue', record.document.language),
              _detail('Consulté le', record.document.retrievedOn),
              _detail('Preuves', record.document.pageReferences.join('\n')),
              const SizedBox(height: 12),
              SelectableText(record.document.sourceUrl, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              const Text(
                'Attention : une valeur qualifiée dans cette fiche ne suffit pas, à elle seule, à valider une installation. Vérifier le modèle, la configuration, le réseau et la norme applicable.',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _detail(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 125, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
      Expanded(child: Text(value)),
    ]),
  );
}
