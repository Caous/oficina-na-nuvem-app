import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Opção exibida em um seletor pesquisável.
class SelectOption<T> {
  final T value;
  final String label;
  final String? description;

  const SelectOption({
    required this.value,
    required this.label,
    this.description,
  });
}

/// Campo de seleção que abre uma lista pesquisável.
///
/// Usado onde a lista é longa demais para um dropdown simples (marcas e
/// modelos FIPE, clientes, categorias).
class AppSelectField<T> extends StatelessWidget {
  final String label;
  final String placeholder;
  final IconData icon;
  final String? selectedLabel;
  final List<SelectOption<T>> options;
  final ValueChanged<T> onSelected;
  final String searchHint;
  final String? emptyMessage;
  final bool enabled;
  final String? errorText;

  const AppSelectField({
    super.key,
    required this.label,
    required this.placeholder,
    required this.icon,
    required this.options,
    required this.onSelected,
    this.selectedLabel,
    this.searchHint = 'Buscar...',
    this.emptyMessage,
    this.enabled = true,
    this.errorText,
  });

  Future<void> _openPicker(BuildContext context) async {
    if (!enabled || options.isEmpty) {
      return;
    }

    final selected = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (sheetContext) {
        return _SearchableOptionSheet<T>(
          title: label,
          searchHint: searchHint,
          options: options,
        );
      },
    );

    if (selected != null) {
      onSelected(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = selectedLabel != null && selectedLabel!.isNotEmpty;
    final isDisabled = !enabled || options.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.fieldLabel),
        const SizedBox(height: AppSpacing.xs + 2),
        InkWell(
          onTap: isDisabled ? null : () => _openPicker(context),
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            height: AppSpacing.fieldHeight,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            decoration: BoxDecoration(
              color: isDisabled ? AppColors.gray100 : AppColors.bgCard,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: errorText != null ? AppColors.accentRed : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: hasValue ? AppColors.accentBlue : AppColors.textMuted,
                ),
                const SizedBox(width: AppSpacing.sm + 2),
                Expanded(
                  child: Text(
                    hasValue
                        ? selectedLabel!
                        : (isDisabled && emptyMessage != null
                              ? emptyMessage!
                              : placeholder),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: hasValue
                        ? AppTypography.fieldValue
                        : const TextStyle(
                            fontSize: 14,
                            color: AppColors.textMuted,
                          ),
                  ),
                ),
                const Icon(
                  Icons.expand_more,
                  size: 18,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.xs + 2),
          Text(
            errorText!,
            style: const TextStyle(fontSize: 12, color: AppColors.accentRed),
          ),
        ],
      ],
    );
  }
}

class _SearchableOptionSheet<T> extends StatefulWidget {
  final String title;
  final String searchHint;
  final List<SelectOption<T>> options;

  const _SearchableOptionSheet({
    required this.title,
    required this.searchHint,
    required this.options,
  });

  @override
  State<_SearchableOptionSheet<T>> createState() =>
      _SearchableOptionSheetState<T>();
}

class _SearchableOptionSheetState<T> extends State<_SearchableOptionSheet<T>> {
  final _searchController = TextEditingController();

  late List<SelectOption<T>> _visibleOptions = widget.options;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filter(String query) {
    final normalized = query.trim().toLowerCase();

    setState(() {
      _visibleOptions = normalized.isEmpty
          ? widget.options
          : widget.options
                .where(
                  (option) => option.label.toLowerCase().contains(normalized),
                )
                .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.92,
        builder: (context, scrollController) {
          return Column(
            children: [
              const SizedBox(height: AppSpacing.md),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.xl,
                  AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, style: AppTypography.sectionTitle),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _searchController,
                      autofocus: true,
                      onChanged: _filter,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.searchHint,
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textMuted,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 18,
                          color: AppColors.accentBlue,
                        ),
                        filled: true,
                        fillColor: AppColors.bgCard,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.lg,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: const BorderSide(
                            color: AppColors.border,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: const BorderSide(
                            color: AppColors.border,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: const BorderSide(
                            color: AppColors.accentBlue,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${_visibleOptions.length} de ${widget.options.length} '
                      'resultados',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: _visibleOptions.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.xxl),
                          child: Text(
                            'Nenhum resultado para a busca.',
                            style: AppTypography.body,
                          ),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        itemCount: _visibleOptions.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final option = _visibleOptions[index];

                          return ListTile(
                            title: Text(
                              option.label,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            subtitle: option.description == null
                                ? null
                                : Text(
                                    option.description!,
                                    style: AppTypography.caption,
                                  ),
                            onTap: () =>
                                Navigator.of(context).pop(option.value),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
