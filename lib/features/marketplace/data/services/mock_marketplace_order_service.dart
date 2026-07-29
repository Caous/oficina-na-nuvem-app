import 'marketplace_order_service.dart';
import '../../models/cart_item.dart';

/// Pedido em memória: aceita qualquer carrinho depois de uma pequena latência.
class MockMarketplaceOrderService implements MarketplaceOrderService {
  static const Duration _latency = Duration(milliseconds: 300);

  @override
  Future<void> placeOrder(List<CartItem> items) {
    return Future<void>.delayed(_latency);
  }
}
