import 'package:flutter/material.dart';
import 'package:oficina_app/features/employees/models/employee.dart';
import 'package:oficina_app/shared/address_lookup/models/address.dart';
import 'package:oficina_app/shared/address_lookup/presentation/address_form_controller.dart';
import 'package:oficina_app/features/employees/presentation/pages/employee_form_page.dart';
import 'package:oficina_app/features/employees/presentation/view_models/employee_form_view_model.dart';
import 'package:oficina_app/features/employees/presentation/view_models/employees_view_model.dart';

import '../../../../core/state/view_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_icon_button.dart';
import '../../../../core/widgets/app_screen_header.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/confirm_dialog.dart';

const _avatarPalette = [
  (AppColors.accentBlueLight, AppColors.accentBlue),
  (AppColors.accentGreenLight, AppColors.accentGreen),
  (AppColors.accentPurpleLight, AppColors.accentPurple),
  (AppColors.accentAmberLight, AppColors.accentAmber),
];

/// Listagem de funcionários da oficina.
class EmployeesPage extends StatefulWidget {
  final EmployeesViewModel viewModel;
  final EmployeeFormViewModel Function(Employee? employee) formViewModelBuilder;
  final AddressFormController Function({Address? initial})
  addressControllerFactory;

  const EmployeesPage({
    super.key,
    required this.viewModel,
    required this.formViewModelBuilder,
    required this.addressControllerFactory,
  });

  @override
  State<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.viewModel.load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openForm({Employee? employee}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EmployeeFormPage(
          viewModel: widget.formViewModelBuilder(employee),
          addressController: widget.addressControllerFactory(
            initial: employee?.address,
          ),
        ),
      ),
    );

    if (saved == true) {
      widget.viewModel.load();
    }
  }

  Future<void> _delete(Employee employee) async {
    final confirmed = await ConfirmDialog.askDeletion(
      context,
      title: 'Excluir funcionário',
      message: 'Deseja realmente excluir ${employee.name}?',
    );

    if (!confirmed) {
      return;
    }

    final success = await widget.viewModel.delete(employee.id);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Funcionário excluído com sucesso.'
              : 'Não foi possível excluir o funcionário.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accentBlue,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add, color: AppColors.bgWhite),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            return Column(
              children: [
                AppScreenHeader(
                  title: 'Funcionários',
                  subtitle: '${widget.viewModel.totalCount} membros na equipe',
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenHorizontal,
                    AppSpacing.lg,
                    AppSpacing.screenHorizontal,
                    0,
                  ),
                  child: AppSearchField(
                    hint: 'Buscar funcionário...',
                    controller: _searchController,
                    onChanged: widget.viewModel.search,
                  ),
                ),
                Expanded(child: _buildBody(widget.viewModel.state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(ViewState<List<Employee>> state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ViewStateFailure<List<Employee>>) {
      return AppEmptyState(
        icon: Icons.error_outline,
        title: 'Erro ao carregar',
        message: state.message,
        actionLabel: 'Tentar novamente',
        onAction: widget.viewModel.load,
      );
    }

    final employees = widget.viewModel.visibleEmployees;

    if (employees.isEmpty) {
      return const AppEmptyState(
        icon: Icons.people_outline,
        title: 'Nenhum funcionário encontrado',
        message: 'Cadastre um funcionário para vê-lo aqui.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.lg,
        AppSpacing.screenHorizontal,
        AppSpacing.xxl,
      ),
      itemCount: employees.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final employee = employees[index];
        final (background, foreground) = _avatarPalette[index % _avatarPalette.length];

        return AppCard(
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: background,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  employee.initials,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: foreground,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      employee.role.label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.accentBlue,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      employee.phone,
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  AppIconActionButton.edit(
                    onPressed: () => _openForm(employee: employee),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AppIconActionButton.delete(
                    onPressed: () => _delete(employee),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
