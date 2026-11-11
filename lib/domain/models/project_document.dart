import 'electrical_terminal.dart';

/// Versioned, platform-independent project document for ElectroDesign.
class ProjectComponent {
  const ProjectComponent({
    required this.id,
    required this.name,
    required this.family,
    required this.symbol,
    required this.details,
    required this.x,
    required this.y,
    this.terminals = const [],
  });

  final String id;
  final String name;
  final String family;
  final String symbol;
  final String details;
  final double x;
  final double y;

  /// Empty means that no verified or user-configured terminal layout is known.
  final List<ElectricalTerminal> terminals;

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'family': family,
        'symbol': symbol,
        'details': details,
        'x': x,
        'y': y,
        'terminals': terminals.map((item) => item.toJson()).toList(),
      };

  factory ProjectComponent.fromJson(Map<String, dynamic> json) {
    final rawTerminals = json['terminals'] ?? const [];
    if (rawTerminals is! List) {
      throw const FormatException('Component terminals must be a list');
    }
    return ProjectComponent(
      id: _requiredString(json, 'id'),
      name: _requiredString(json, 'name'),
      family: _requiredString(json, 'family'),
      symbol: _requiredString(json, 'symbol'),
      details: _requiredString(json, 'details'),
      x: _requiredNumber(json, 'x'),
      y: _requiredNumber(json, 'y'),
      terminals: rawTerminals
          .map((item) => ElectricalTerminal.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(),
    );
  }
}

/// A logical connection between two component terminals.
class ProjectConnection {
  const ProjectConnection({
    required this.id,
    required this.fromComponentId,
    required this.fromTerminal,
    required this.toComponentId,
    required this.toTerminal,
    this.conductor = '',
  });

  final String id;
  final String fromComponentId;
  final String fromTerminal;
  final String toComponentId;
  final String toTerminal;
  final String conductor;

  Map<String, Object?> toJson() => {
        'id': id,
        'fromComponentId': fromComponentId,
        'fromTerminal': fromTerminal,
        'toComponentId': toComponentId,
        'toTerminal': toTerminal,
        'conductor': conductor,
      };

  factory ProjectConnection.fromJson(Map<String, dynamic> json) {
    return ProjectConnection(
      id: _requiredString(json, 'id'),
      fromComponentId: _requiredString(json, 'fromComponentId'),
      fromTerminal: _requiredString(json, 'fromTerminal'),
      toComponentId: _requiredString(json, 'toComponentId'),
      toTerminal: _requiredString(json, 'toTerminal'),
      conductor: json['conductor'] as String? ?? '',
    );
  }
}

/// Portable project data with backwards-compatible schema migration.
class ProjectDocument {
  ProjectDocument({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    List<ProjectComponent> components = const [],
    List<ProjectConnection> connections = const [],
    this.schemaVersion = currentSchemaVersion,
  })  : components = List.unmodifiable(components),
        connections = List.unmodifiable(connections) {
    validate();
  }

  static const currentSchemaVersion = 2;

  final int schemaVersion;
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ProjectComponent> components;
  final List<ProjectConnection> connections;

  Map<String, Object?> toJson() => {
        'schemaVersion': currentSchemaVersion,
        'id': id,
        'name': name,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'updatedAt': updatedAt.toUtc().toIso8601String(),
        'components': components.map((item) => item.toJson()).toList(),
        'connections': connections.map((item) => item.toJson()).toList(),
      };

  factory ProjectDocument.fromJson(Map<String, dynamic> json) {
    final version = json['schemaVersion'];
    if (version != 1 && version != currentSchemaVersion) {
      throw FormatException('Unsupported project schema version: $version');
    }

    final rawComponents = json['components'];
    final rawConnections = json['connections'];
    if (rawComponents is! List || rawConnections is! List) {
      throw const FormatException('Project components and connections must be lists');
    }

    return ProjectDocument(
      schemaVersion: currentSchemaVersion,
      id: _requiredString(json, 'id'),
      name: _requiredString(json, 'name'),
      createdAt: DateTime.parse(_requiredString(json, 'createdAt')),
      updatedAt: DateTime.parse(_requiredString(json, 'updatedAt')),
      components: rawComponents
          .map((item) => ProjectComponent.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(),
      connections: rawConnections
          .map((item) => ProjectConnection.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(),
    );
  }

  void validate() {
    if (id.trim().isEmpty || name.trim().isEmpty) {
      throw const FormatException('Project id and name are required');
    }
    if (updatedAt.isBefore(createdAt)) {
      throw const FormatException('Project update date cannot precede creation date');
    }

    final componentIds = components.map((item) => item.id).toSet();
    if (componentIds.length != components.length ||
        componentIds.any((value) => value.trim().isEmpty)) {
      throw const FormatException('Component ids must be unique and non-empty');
    }

    for (final component in components) {
      final terminalIds = component.terminals.map((terminal) => terminal.id).toSet();
      if (terminalIds.length != component.terminals.length ||
          terminalIds.any((id) => id.trim().isEmpty)) {
        throw const FormatException('Terminal ids must be unique and non-empty per component');
      }
      final labels = component.terminals.map((terminal) => terminal.label).toSet();
      if (labels.length != component.terminals.length ||
          labels.any((label) => label.trim().isEmpty)) {
        throw const FormatException('Terminal labels must be unique and non-empty per component');
      }
      for (final terminal in component.terminals) {
        if (!terminal.x.isFinite || !terminal.y.isFinite ||
            terminal.x < 0 || terminal.x > 1 ||
            terminal.y < 0 || terminal.y > 1) {
          throw const FormatException('Terminal coordinates must be normalized between 0 and 1');
        }
      }
    }

    final connectionIds = connections.map((item) => item.id).toSet();
    if (connectionIds.length != connections.length ||
        connectionIds.any((value) => value.trim().isEmpty)) {
      throw const FormatException('Connection ids must be unique and non-empty');
    }

    final componentsById = {for (final item in components) item.id: item};
    for (final connection in connections) {
      final from = componentsById[connection.fromComponentId];
      final to = componentsById[connection.toComponentId];
      if (from == null || to == null) {
        throw const FormatException('Connection references an unknown component');
      }
      if (connection.fromTerminal.trim().isEmpty ||
          connection.toTerminal.trim().isEmpty) {
        throw const FormatException('Connection terminals are required');
      }
      // If terminal metadata is present, references must match it. Empty
      // metadata remains valid for legacy projects and unconfigured parts.
      if (from.terminals.isNotEmpty &&
          !from.terminals.any((terminal) => terminal.id == connection.fromTerminal)) {
        throw const FormatException('Connection references an unknown source terminal');
      }
      if (to.terminals.isNotEmpty &&
          !to.terminals.any((terminal) => terminal.id == connection.toTerminal)) {
        throw const FormatException('Connection references an unknown destination terminal');
      }
    }
  }
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Missing or invalid project field: $key');
  }
  return value;
}

double _requiredNumber(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! num || !value.toDouble().isFinite) {
    throw FormatException('Missing or invalid project field: $key');
  }
  return value.toDouble();
}
