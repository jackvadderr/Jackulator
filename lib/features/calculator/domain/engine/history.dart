import 'errors.dart';
import 'values.dart';

/// Entrada do histórico
class HistoryEntry {
  final String id;
  final DateTime timestamp;
  final String expressionRaw;
  final String? astSerialized;
  final String? resultSerialized;
  final ValueType? resultType;
  final bool success;
  final EvaluationError? error;
  final String? contextSnapshotId;
  final List<String> tags;
  final bool isPinned;

  HistoryEntry({
    String? id,
    DateTime? timestamp,
    required this.expressionRaw,
    this.astSerialized,
    this.resultSerialized,
    this.resultType,
    required this.success,
    this.error,
    this.contextSnapshotId,
    this.tags = const [],
    this.isPinned = false,
  }) : id = id ?? _generateId(),
       timestamp = timestamp ?? DateTime.now();

  static String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch % 1000}';
  }

  /// Cria uma cópia com campos modificados
  HistoryEntry copyWith({
    String? expressionRaw,
    String? astSerialized,
    String? resultSerialized,
    ValueType? resultType,
    bool? success,
    EvaluationError? error,
    String? contextSnapshotId,
    List<String>? tags,
    bool? isPinned,
  }) {
    return HistoryEntry(
      id: id,
      timestamp: timestamp,
      expressionRaw: expressionRaw ?? this.expressionRaw,
      astSerialized: astSerialized ?? this.astSerialized,
      resultSerialized: resultSerialized ?? this.resultSerialized,
      resultType: resultType ?? this.resultType,
      success: success ?? this.success,
      error: error ?? this.error,
      contextSnapshotId: contextSnapshotId ?? this.contextSnapshotId,
      tags: tags ?? this.tags,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  /// Serializa para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'expressionRaw': expressionRaw,
      'astSerialized': astSerialized,
      'resultSerialized': resultSerialized,
      'resultType': resultType?.name,
      'success': success,
      'error': error?.toString(),
      'contextSnapshotId': contextSnapshotId,
      'tags': tags,
      'isPinned': isPinned,
    };
  }

  /// Deserializa de JSON
  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      expressionRaw: json['expressionRaw'] as String,
      astSerialized: json['astSerialized'] as String?,
      resultSerialized: json['resultSerialized'] as String?,
      resultType: json['resultType'] != null
          ? ValueType.values.firstWhere((e) => e.name == json['resultType'])
          : null,
      success: json['success'] as bool,
      contextSnapshotId: json['contextSnapshotId'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      isPinned: json['isPinned'] as bool? ?? false,
    );
  }

  @override
  String toString() => '$expressionRaw = ${resultSerialized ?? error?.message}';
}

/// Filtro de histórico
class HistoryFilter {
  final bool? successOnly;
  final List<String>? tags;
  final String? searchText;
  final bool? pinnedOnly;
  final DateTime? startDate;
  final DateTime? endDate;

  const HistoryFilter({
    this.successOnly,
    this.tags,
    this.searchText,
    this.pinnedOnly,
    this.startDate,
    this.endDate,
  });

  bool matches(HistoryEntry entry) {
    if (successOnly != null && entry.success != successOnly) return false;
    if (pinnedOnly != null && entry.isPinned != pinnedOnly) return false;

    if (tags != null && tags!.isNotEmpty) {
      if (!tags!.any((tag) => entry.tags.contains(tag))) return false;
    }

    if (searchText != null && searchText!.isNotEmpty) {
      final search = searchText!.toLowerCase();
      if (!entry.expressionRaw.toLowerCase().contains(search) &&
          !(entry.resultSerialized?.toLowerCase().contains(search) ?? false)) {
        return false;
      }
    }

    if (startDate != null && entry.timestamp.isBefore(startDate!)) return false;
    if (endDate != null && entry.timestamp.isAfter(endDate!)) return false;

    return true;
  }
}

/// Gerenciador de histórico
class History {
  final List<HistoryEntry> _entries = [];
  final int maxEntries;

  History({this.maxEntries = 1000});

  /// Adiciona uma entrada ao histórico
  void add(HistoryEntry entry) {
    _entries.insert(0, entry); // Mais recente primeiro

    // Manter apenas as não-pinned dentro do limite
    while (_entries.where((e) => !e.isPinned).length > maxEntries) {
      final index = _entries.lastIndexWhere((e) => !e.isPinned);
      if (index != -1) {
        _entries.removeAt(index);
      } else {
        break;
      }
    }
  }

  /// Lista todas as entradas
  List<HistoryEntry> list({int? limit, HistoryFilter? filter}) {
    var result = _entries.where((e) => filter?.matches(e) ?? true).toList();

    if (limit != null && limit > 0) {
      result = result.take(limit).toList();
    }

    return result;
  }

  /// Obtém uma entrada por ID
  HistoryEntry? getById(String id) {
    try {
      return _entries.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Remove uma entrada
  bool remove(String id) {
    final index = _entries.indexWhere((e) => e.id == id);
    if (index != -1) {
      _entries.removeAt(index);
      return true;
    }
    return false;
  }

  /// Alterna o estado de pin
  bool togglePin(String id) {
    final index = _entries.indexWhere((e) => e.id == id);
    if (index != -1) {
      _entries[index] = _entries[index].copyWith(
        isPinned: !_entries[index].isPinned,
      );
      return true;
    }
    return false;
  }

  /// Adiciona tag a uma entrada
  bool addTag(String id, String tag) {
    final index = _entries.indexWhere((e) => e.id == id);
    if (index != -1) {
      final newTags = [..._entries[index].tags, tag];
      _entries[index] = _entries[index].copyWith(tags: newTags);
      return true;
    }
    return false;
  }

  /// Remove tag de uma entrada
  bool removeTag(String id, String tag) {
    final index = _entries.indexWhere((e) => e.id == id);
    if (index != -1) {
      final newTags = _entries[index].tags.where((t) => t != tag).toList();
      _entries[index] = _entries[index].copyWith(tags: newTags);
      return true;
    }
    return false;
  }

  /// Limpa todo o histórico (exceto pinned)
  void clear({bool includePinned = false}) {
    if (includePinned) {
      _entries.clear();
    } else {
      _entries.removeWhere((e) => !e.isPinned);
    }
  }

  /// Busca por texto
  List<HistoryEntry> search(String query) {
    return list(filter: HistoryFilter(searchText: query));
  }

  /// Exporta para JSON
  List<Map<String, dynamic>> toJson() {
    return _entries.map((e) => e.toJson()).toList();
  }

  /// Importa de JSON
  void fromJson(List<dynamic> json) {
    _entries.clear();
    for (final item in json) {
      _entries.add(HistoryEntry.fromJson(item as Map<String, dynamic>));
    }
  }

  /// Número total de entradas
  int get length => _entries.length;

  /// Última entrada
  HistoryEntry? get last => _entries.isEmpty ? null : _entries.first;
}
