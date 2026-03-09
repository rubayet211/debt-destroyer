import '../../../shared/models/debt.dart';
import '../../../shared/models/strategy_models.dart';
import 'portfolio_projection_service.dart';

class StrategyEngine {
  const StrategyEngine([
    PortfolioProjectionService projectionService =
        const PortfolioProjectionService(),
  ]) : _projectionService = projectionService;

  final PortfolioProjectionService _projectionService;

  StrategyResult simulate({
    required List<Debt> debts,
    required StrategyRequest request,
  }) {
    return _projectionService.projectPortfolio(debts: debts, request: request);
  }
}
