import '../models/income_model.dart';
import '../services/hive_service.dart';

/// Single Source of Truth (SSOT) for all [IncomeModel] data.
class IncomeRepository {
  final HiveService _service;

  IncomeRepository(this._service);

  // ── Write Operations ──────────────────────────────────────────────────

  void addIncome(IncomeModel income) {
    _service.income.put(income.id, income);
  }

  void updateIncome(IncomeModel income) {
    _service.income.put(income.id, income);
  }

  void deleteIncome(String id) {
    _service.income.delete(id);
  }

  // ── Read Operations ───────────────────────────────────────────────────

  List<IncomeModel> getAllIncome() {
    final list = _service.income.values.toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  List<IncomeModel> getIncomeByMonth(int year, int month) {
    return _service.income.values.where((i) {
      final local = i.date.toLocal();
      return local.year == year && local.month == month;
    }).toList();
  }

  double getTotalIncomeForMonth(int year, int month) {
    return getIncomeByMonth(year, month)
        .fold(0.0, (sum, i) => sum + i.amount);
  }
}
