import 'package:flutter/material.dart';

import '../../../../shared/address_lookup/presentation/address_form_controller.dart';
import '../../models/account_registration.dart';
import '../view_models/account_registration_view_model.dart';
import 'client_register_page.dart';
import 'workshop_register_page.dart';

/// Alterna entre os cadastros de cliente e de oficina.
///
/// O tipo de conta vive no view model, então trocar de aba é uma mudança de
/// estado — não uma nova rota. Isso preserva a pilha de navegação e evita o
/// empilhamento de telas de cadastro.
class RegistrationFlowPage extends StatefulWidget {
  final AccountRegistrationViewModel viewModel;

  /// Fábrica do controlador de endereço, resolvida pelo composition root.
  final AddressFormController Function() addressControllerFactory;

  const RegistrationFlowPage({
    super.key,
    required this.viewModel,
    required this.addressControllerFactory,
  });

  @override
  State<RegistrationFlowPage> createState() => _RegistrationFlowPageState();
}

class _RegistrationFlowPageState extends State<RegistrationFlowPage> {
  /// Um controlador por tipo de conta, criados uma única vez: recriá-los a
  /// cada rebuild apagaria o endereço no meio da digitação, e separá-los
  /// impede que o endereço de um tipo de conta vaze para o outro.
  late final _clientAddress = widget.addressControllerFactory();
  late final _workshopAddress = widget.addressControllerFactory();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        void backToLogin() => Navigator.of(context).maybePop();

        return switch (widget.viewModel.accountType) {
          AccountType.client => ClientRegisterPage(
            viewModel: widget.viewModel,
            addressController: _clientAddress,
            onSwitchToWorkshop: () =>
                widget.viewModel.selectAccountType(AccountType.workshop),
            onBackToLogin: backToLogin,
          ),
          AccountType.workshop => WorkshopRegisterPage(
            viewModel: widget.viewModel,
            addressController: _workshopAddress,
            onSwitchToClient: () =>
                widget.viewModel.selectAccountType(AccountType.client),
            onBackToLogin: backToLogin,
          ),
        };
      },
    );
  }
}
