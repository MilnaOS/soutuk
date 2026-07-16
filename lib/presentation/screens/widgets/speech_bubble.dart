import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app_theme.dart';
import '../../state/translation_providers.dart';

class SpeechBubble extends StatelessWidget {
  final UtteranceItem item;

  const SpeechBubble({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMedical = item.flags.contains('MEDICAL_DOMAIN');
    final isLegal = item.flags.contains('LEGAL_DOMAIN');
    final isDisputed = item.flags.contains('TRANSLATION_DISAGREEMENT');

    // Base colors on domain safety levels
    final borderCol = isMedical
        ? AppTheme.error.withOpacity(0.5)
        : (isLegal
            ? AppTheme.warning.withOpacity(0.5)
            : (isDisputed ? AppTheme.secondary.withOpacity(0.5) : AppTheme.primary.withOpacity(0.12)));

    final shadowCol = isMedical
        ? AppTheme.error.withOpacity(0.12)
        : (isLegal
            ? AppTheme.warning.withOpacity(0.12)
            : (isDisputed ? AppTheme.secondary.withOpacity(0.12) : AppTheme.primary.withOpacity(0.04)));

    // Determine confidence tier colors
    Color confidenceColor;
    if (item.confidence >= 0.90) {
      confidenceColor = AppTheme.success;
    } else if (item.confidence >= 0.80) {
      confidenceColor = AppTheme.warning;
    } else {
      confidenceColor = AppTheme.error;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGlass,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(item.isMe ? 16 : 4),
          bottomRight: Radius.circular(item.isMe ? 4 : 16),
        ),
        border: Border.all(color: borderCol, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: shadowCol,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    item.isMe ? 'LOCAL' : 'TARGET',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: item.isMe ? AppTheme.accent : AppTheme.secondary,
                      letterSpacing: 1.0,
                    ),
                  ),
                  if (isMedical || isLegal || isDisputed) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: (isMedical
                                ? AppTheme.error
                                : (isLegal ? AppTheme.warning : AppTheme.secondary))
                            .withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: (isMedical
                                  ? AppTheme.error
                                  : (isLegal ? AppTheme.warning : AppTheme.secondary))
                              .withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isMedical
                                ? Icons.medical_services_outlined
                                : (isLegal ? Icons.gavel_outlined : Icons.rule_folder_outlined),
                            size: 10,
                            color: isMedical
                                ? AppTheme.error
                                : (isLegal ? AppTheme.warning : AppTheme.secondary),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            isMedical ? 'MEDICAL' : (isLegal ? 'LEGAL' : 'DISPUTED'),
                            style: GoogleFonts.outfit(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: isMedical
                                  ? AppTheme.error
                                  : (isLegal ? AppTheme.warning : AppTheme.secondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: confidenceColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: confidenceColor.withOpacity(0.3), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: confidenceColor,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${(item.confidence * 100).toStringAsFixed(0)}% Conf',
                      style: GoogleFonts.outfit(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: confidenceColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  height: 1.3,
                ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(height: 1, color: Colors.white10),
          ),
          Text(
            item.translated,
            style: GoogleFonts.outfit(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
