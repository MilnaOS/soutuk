import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app_theme.dart';
import '../../state/translation_providers.dart';

class WarningBanner extends StatelessWidget {
  final ConversationState state;
  final ConversationNotifier notifier;

  const WarningBanner({
    Key? key,
    required this.state,
    required this.notifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (state.activeWarning == null) return const SizedBox.shrink();

    // Determine category from the warning text. Three categories, not two —
    // treating "not medical" as "must be legal" mislabeled anything else
    // (e.g. TRANSLATION_DISAGREEMENT from the ancient-language arbitration
    // path) as a legal guardrail, gavel icon and all.
    final warningLower = state.activeWarning!.toLowerCase();
    final isMedical = warningLower.contains('medical');
    final isLegal = !isMedical && warningLower.contains('legal');
    final activeColor = isMedical
        ? AppTheme.error
        : (isLegal ? AppTheme.warning : AppTheme.secondary);

    return Container(
      decoration: BoxDecoration(
        color: activeColor.withOpacity(0.12),
        border: Border(
          bottom: BorderSide(color: activeColor.withOpacity(0.3), width: 1.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: activeColor.withOpacity(0.15),
            ),
            child: Icon(
              isMedical
                  ? Icons.medical_services_outlined
                  : (isLegal ? Icons.gavel_outlined : Icons.info_outline),
              color: activeColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMedical
                      ? 'MEDICAL PROTECTION GUARDRAIL'
                      : (isLegal ? 'LEGAL PROTECTION GUARDRAIL' : 'TRANSLATION NOTICE'),
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: activeColor,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  state.activeWarning!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12.5,
                        color: AppTheme.textPrimary,
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: AppTheme.textSecondary),
            tooltip: 'Dismiss Warning',
            onPressed: () => notifier.clearWarning(),
          )
        ],
      ),
    );
  }
}
