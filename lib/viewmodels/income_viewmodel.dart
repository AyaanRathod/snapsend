import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../data/models/income_model.dart';
import '../data/repositories/income_repository.dart';

const _uuid = Uuid();

class IncomeViewModel extends ChangeNotifier {
  final IncomeRepository _repo;

  List<IncomeModel> _incomeList = [];
  bool _isLoading = false;

  IncomeViewModel({required IncomeRepository repository})
      : _repo = repository {
    _loadIncome();
  }

  bool get isLoading => _isLoading;
  List<IncomeModel> get incomeList => List.unmodifiable(_incomeList);

  double get totalIncomeThisMonth {
    final now = DateTime.now();
    return _repo.getTotalIncomeForMonth(now.year, now.month);
  }

  void addIncome({
    required String source,
    required double amount,
    required DateTime date,
  }) {
    final income = IncomeModel(
      id: _uuid.v4(),
      source: source,
      amount: amount,
      date: date,
    );
    _repo.addIncome(income);
    _loadIncome();
  }

  void deleteIncome(String id) {
    _repo.deleteIncome(id);
    _loadIncome();
  }

  void _loadIncome() {
    _isLoading = true;
    _incomeList = _repo.getAllIncome();
    _isLoading = false;
    notifyListeners();
  }
}
