import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../provider/calculator_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalculatorProvider>();
    final history = provider.engineHistory;

    if (history.isEmpty) {
      return const Center(
        child: Text('Sem histórico ainda', style: AppTextStyles.caption),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: history.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final entry = history[index];
        final success = entry.success;
        final resultText = success
            ? (entry.resultSerialized ?? '')
            : (entry.error?.message ?? 'Erro');

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.expressionRaw, style: AppTextStyles.body),
                    const SizedBox(height: 6),
                    Text(
                      success ? '= $resultText' : 'Erro: $resultText',
                      style: success
                          ? AppTextStyles.caption
                          : AppTextStyles.caption.copyWith(
                              color: CupertinoColors.systemRed,
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                onPressed: () => provider.togglePinHistory(entry.id),
                child: Icon(
                  entry.isPinned ? CupertinoIcons.pin_fill : CupertinoIcons.pin,
                  size: 18,
                  color: entry.isPinned
                      ? AppColors.accent
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
