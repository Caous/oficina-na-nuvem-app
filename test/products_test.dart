import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:oficina_app/core/di/app_dependencies.dart';
import 'package:oficina_app/core/theme/app_theme.dart';
import 'package:oficina_app/core/widgets/app_toggle_switch.dart';
import 'package:oficina_app/features/inventory/presentation/pages/inventory_page.dart';
import 'package:oficina_app/features/marketplace/presentation/pages/marketplace_page.dart';
import 'package:oficina_app/features/marketplace/presentation/pages/cart_page.dart';
import 'package:oficina_app/features/marketplace/presentation/pages/product_detail_page.dart';
import 'package:oficina_app/features/marketplace/presentation/view_models/marketplace_view_model.dart';
import 'package:oficina_app/shared/products/data/repositories/product_repository.dart';
import 'package:oficina_app/shared/products/data/services/mock_product_service.dart';
import 'package:oficina_app/shared/products/models/product.dart';

Future<void> _pumpScreen(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(402 * 3, 1200 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MaterialApp(theme: AppTheme.build(), home: child));
  await _settle(tester);
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
}

MarketplacePage _marketplacePage(MarketplaceViewModel viewModel) {
  return MarketplacePage(
    viewModel: viewModel,
    onOpenProduct: (_) {},
    onOpenCart: () {},
  );
}

void main() {
  late AppDependencies dependencies;

  setUp(() {
    dependencies = AppDependencies.bootstrap();
  });

  group('repositório de produtos', () {
    late ProductRepository repository;

    setUp(() {
      repository = ProductRepository(service: MockProductService());
    });

    test('marketplace mostra só publicados e com estoque', () async {
      final published = await repository.fetchPublished();

      expect(published, isNotEmpty);
      expect(published.every((product) => product.isPublished), isTrue);
      expect(published.every((product) => !product.isOutOfStock), isTrue);
    });

    test('baixa de estoque nunca deixa saldo negativo', () async {
      final all = await repository.fetchAll();
      final product = all.firstWhere((item) => item.stockQuantity == 0);

      final updated = await repository.adjustStock(product.id, -5);

      expect(updated.stockQuantity, 0);
    });

    test('publicar item sem estoque não o leva ao marketplace', () async {
      final all = await repository.fetchAll();
      final outOfStock = all.firstWhere((item) => item.isOutOfStock);

      await repository.setPublished(outOfStock.id, true);
      final published = await repository.fetchPublished();

      expect(
        published.any((product) => product.id == outOfStock.id),
        isFalse,
        reason: 'sem estoque o cliente não pode comprar',
      );
    });

    test('produto criado entra no estoque', () async {
      const novo = Product(
        id: '',
        name: 'Palheta Limpador 24"',
        description: 'Par de palhetas silicone.',
        category: ProductCategory.accessories,
        sku: '0200',
        price: 79.90,
        stockQuantity: 7,
        isPublished: true,
      );

      await repository.create(novo);
      final all = await repository.fetchAll();

      expect(all.any((product) => product.sku == '0200'), isTrue);
    });
  });

  group('estoque da oficina', () {
    testWidgets('lista produtos com preço e chave de marketplace', (
      tester,
    ) async {
      await _pumpScreen(
        tester,
        InventoryPage(
          viewModel: dependencies.inventoryViewModel,
          onOpenProductForm: (_) async => null,
        ),
      );

      expect(find.text('Estoque e Produtos'), findsOneWidget);
      expect(find.text('Óleo Motor 5W30 Sintético 1L'), findsOneWidget);
      expect(find.text('R\$ 49,90'), findsOneWidget);
      expect(find.text('NO MARKETPLACE'), findsWidgets);
      expect(find.text('FORA DO AR'), findsWidgets);
      expect(find.byType(AppToggleSwitch), findsWidgets);
    });

    testWidgets('botão de baixa reduz a quantidade em estoque', (tester) async {
      await _pumpScreen(
        tester,
        InventoryPage(
          viewModel: dependencies.inventoryViewModel,
          onOpenProductForm: (_) async => null,
        ),
      );

      // Primeiro produto do seed começa com 24 unidades.
      expect(find.text('24'), findsOneWidget);

      await tester.tap(find.byTooltip('Dar baixa').first);
      await _settle(tester);

      expect(find.text('23'), findsOneWidget);
      expect(find.text('24'), findsNothing);
    });

    testWidgets('toggle publica o produto no marketplace', (tester) async {
      final viewModel = dependencies.inventoryViewModel;

      await _pumpScreen(
        tester,
        InventoryPage(
          viewModel: viewModel,
          onOpenProductForm: (_) async => null,
        ),
      );

      final pneu = viewModel.visibleProducts.firstWhere(
        (product) => product.name.startsWith('Pneu'),
      );
      expect(pneu.isPublished, isFalse);

      await tester.tap(find.text('Pneu Aro 15 185/65 R15'), warnIfMissed: false);
      await tester.tap(
        find
            .byType(AppToggleSwitch)
            .at(viewModel.visibleProducts.indexOf(pneu)),
      );
      await _settle(tester);

      final updated = viewModel.visibleProducts.firstWhere(
        (product) => product.id == pneu.id,
      );
      expect(updated.isPublished, isTrue);
    });
  });

  testWidgets('produto publicado na oficina aparece na loja do cliente', (
    tester,
  ) async {
    final inventory = dependencies.inventoryViewModel;
    final marketplace = dependencies.createMarketplaceViewModel();

    // O pneu começa fora do marketplace.
    await _pumpScreen(
      tester,
      _marketplacePage(marketplace),
    );
    expect(find.text('Pneu Aro 15 185/65 R15'), findsNothing);

    // Dentro de `testWidgets` o relógio é falso: disparamos a chamada e
    // deixamos o `_settle` avançar o tempo, em vez de `await` (que travaria).
    unawaited(inventory.load());
    await _settle(tester);

    // A oficina publica pelo estoque...
    final pneu = inventory.visibleProducts.firstWhere(
      (product) => product.name.startsWith('Pneu'),
    );
    unawaited(inventory.setPublished(pneu.id, true));
    await _settle(tester);

    // ...e o cliente passa a ver na loja, porque o estoque é o mesmo.
    unawaited(marketplace.load());
    await _settle(tester);

    expect(find.text('Pneu Aro 15 185/65 R15'), findsOneWidget);
  });

  group('detalhe e carrinho', () {
    testWidgets('detalhe mostra produto e adiciona a quantidade escolhida', (
      tester,
    ) async {
      final viewModel = dependencies.createMarketplaceViewModel();
      unawaited(viewModel.load());

      final published = (await tester.runAsync(
        () => dependencies.productRepository.fetchPublished(),
      ))!;
      final oleo = published.firstWhere(
        (product) => product.name.startsWith('Óleo'),
      );

      await _pumpScreen(
        tester,
        ProductDetailPage(
          product: oleo,
          viewModel: viewModel,
          onOpenCart: () {},
        ),
      );

      expect(find.text('Detalhe do Produto'), findsOneWidget);
      expect(find.text(oleo.name), findsOneWidget);
      expect(find.textContaining('em estoque'), findsOneWidget);
      expect(find.text('Descrição'), findsOneWidget);

      // Sobe a quantidade para 3 e adiciona.
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      await tester.tap(find.text('Adicionar ao carrinho'));
      await _settle(tester);

      expect(viewModel.cartCount, 3);
      expect(viewModel.cartItems.single.quantity, 3);
    });

    testWidgets('carrinho agrupa por produto e respeita o estoque', (
      tester,
    ) async {
      final viewModel = dependencies.createMarketplaceViewModel();
      final published = (await tester.runAsync(
        () => dependencies.productRepository.fetchPublished(),
      ))!;
      final central = published.firstWhere(
        (product) => product.name.startsWith('Central'),
      );

      // Central tem 6 em estoque; pedir 10 não pode passar de 6.
      viewModel.addToCart(central, quantity: 4);
      viewModel.addToCart(central, quantity: 10);

      expect(viewModel.cartItems.single.quantity, 6);

      await _pumpScreen(tester, CartPage(viewModel: viewModel));

      expect(find.text('Carrinho'), findsOneWidget);
      expect(find.text(central.name), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
      // 6 × R$ 899,00 = R$ 5.394,00 (total do item e total geral).
      expect(find.text('R\$ 5.394,00'), findsWidgets);
    });

    testWidgets('stepper do carrinho altera quantidade e trash remove', (
      tester,
    ) async {
      final viewModel = dependencies.createMarketplaceViewModel();
      final published = (await tester.runAsync(
        () => dependencies.productRepository.fetchPublished(),
      ))!;
      final oleo = published.firstWhere(
        (product) => product.name.startsWith('Óleo'),
      );

      viewModel.addToCart(oleo, quantity: 2);

      await _pumpScreen(tester, CartPage(viewModel: viewModel));

      await tester.tap(find.byIcon(Icons.remove).first);
      await _settle(tester);
      expect(viewModel.cartItems.single.quantity, 1);

      // Abaixo de 1 não desce; remover é ação explícita.
      await tester.tap(find.byIcon(Icons.remove).first, warnIfMissed: false);
      await _settle(tester);
      expect(viewModel.cartItems.single.quantity, 1);

      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await _settle(tester);

      expect(viewModel.cartItems, isEmpty);
      expect(find.text('Carrinho vazio'), findsOneWidget);
    });

    testWidgets('finalizar pedido limpa o carrinho', (tester) async {
      final viewModel = dependencies.createMarketplaceViewModel();
      final published = (await tester.runAsync(
        () => dependencies.productRepository.fetchPublished(),
      ))!;

      viewModel.addToCart(published.first, quantity: 2);

      await _pumpScreen(tester, CartPage(viewModel: viewModel));

      await tester.tap(find.text('Finalizar pedido'));
      await _settle(tester);

      expect(find.textContaining('Pedido enviado'), findsOneWidget);

      await tester.tap(find.text('Combinado'));
      await _settle(tester);

      expect(viewModel.cartItems, isEmpty);
    });
  });

  group('marketplace do cliente', () {
    testWidgets('mostra produtos publicados com preço', (tester) async {
      await _pumpScreen(
        tester,
        _marketplacePage(dependencies.createMarketplaceViewModel()),
      );

      expect(find.text('Marketplace'), findsOneWidget);
      expect(find.text('Óleo Motor 5W30 Sintético 1L'), findsOneWidget);
      expect(find.text('R\$ 49,90'), findsOneWidget);

      // Pneu não está publicado; filtro de ar está sem estoque.
      expect(find.text('Pneu Aro 15 185/65 R15'), findsNothing);
      expect(find.text('Filtro de Ar Esportivo'), findsNothing);
    });

    testWidgets('busca filtra os produtos pelo nome', (tester) async {
      await _pumpScreen(
        tester,
        _marketplacePage(dependencies.createMarketplaceViewModel()),
      );

      await tester.enterText(find.byType(TextField).first, 'filtro');
      await _settle(tester);

      expect(find.text('Filtro de Óleo Original Honda'), findsOneWidget);
      expect(find.text('Óleo Motor 5W30 Sintético 1L'), findsNothing);
    });

    testWidgets('filtro por categoria restringe a lista', (tester) async {
      final viewModel = dependencies.createMarketplaceViewModel();

      await _pumpScreen(tester, _marketplacePage(viewModel));

      viewModel.filterByCategory(ProductCategory.sound);
      await _settle(tester);

      expect(
        viewModel.visibleProducts.every(
          (product) => product.category == ProductCategory.sound,
        ),
        isTrue,
      );
    });

    testWidgets('ordenação por menor preço vem aplicada por padrão', (
      tester,
    ) async {
      final viewModel = dependencies.createMarketplaceViewModel();

      await _pumpScreen(tester, _marketplacePage(viewModel));

      final prices = viewModel.visibleProducts
          .map((product) => product.price)
          .toList();

      expect(prices, orderedEquals([...prices]..sort()));
    });

    testWidgets('adicionar ao carrinho incrementa o contador', (tester) async {
      final viewModel = dependencies.createMarketplaceViewModel();

      await _pumpScreen(tester, _marketplacePage(viewModel));

      expect(viewModel.cartCount, 0);

      await tester.tap(find.byIcon(Icons.add).first);
      await _settle(tester);

      expect(viewModel.cartCount, 1);
    });
  });
}
