import '../../models/cart_item.dart';

/// Envio do pedido do carrinho à(s) oficina(s).
abstract class MarketplaceOrderService {
  Future<void> placeOrder(List<CartItem> items);
}
