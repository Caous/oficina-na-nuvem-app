import '../../../../core/network/api_client.dart';
import '../../models/cart_item.dart';
import 'marketplace_order_service.dart';

/// Pedido real em `/marketplace/orders`.
///
/// O carrinho não coleta pagamento nem endereço: a retirada/entrega é
/// combinada direto com a oficina, então o pedido sai como pagamento na
/// entrega, endereçado ao endereço do perfil do cliente.
class ApiMarketplaceOrderService implements MarketplaceOrderService {
  final ApiClient _api;

  ApiMarketplaceOrderService({required ApiClient api}) : _api = api;

  @override
  Future<void> placeOrder(List<CartItem> items) async {
    final profile = await _api.get('/me/profile') as Map<String, dynamic>;

    await _api.post('/marketplace/orders', body: {
      'items': items
          .map(
            (item) => {
              'productId': int.parse(item.product.id),
              'quantity': item.quantity,
            },
          )
          .toList(growable: false),
      'paymentMethod': 'CASH_ON_DELIVERY',
      'deliveryAddress': profile['address'],
    });
  }
}
