import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';
import '../state/conversation_mode_providers.dart';
import '../state/translation_providers.dart';
import '../../domain/dtos/language_option_dto.dart';

class ConversationModeScreen extends ConsumerWidget {
  const ConversationModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(conversationModeProvider);
    final notifier = ref.read(conversationModeProvider.notifier);
    final languagesAsync = ref.watch(languageCatalogProvider);
    final languages = languagesAsync.when(
      data: (langs) => langs,
      loading: () => const <LanguageOption>[],
      error: (_, __) => const <LanguageOption>[],
    );

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Conversation Mode', style: GoogleFonts.outfit(color: AppTheme.textPrimary)),
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildV1Banner(context),
            Expanded(
              child: switch (state.phase) {
                ConversationPhase.ownerSetup => _buildOwnerSetup(context, state, notifier, languages),
                _ => _buildConversationBody(context, state, notifier),
              },
            ),
          ],
        ),
      ),
    );
  }

  // What's actually live here: the language-ID handshake and turn-based
  // translation both really work. What's not built yet: continuous
  // background listening (no tap needed) and muting the mic during the
  // app's own TTS playback — that needs proper server-side infrastructure
  // this app doesn't have yet. Say so plainly rather than let the UI imply
  // more than what's actually running.
  Widget _buildV1Banner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppTheme.warning.withOpacity(0.15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.science_outlined, size: 14, color: AppTheme.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'LIVE: language ID + turn-based translation. Tap to capture each line — '
              'always-on background listening is coming once I can turn on the lights (proper server hosting).',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.warning,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerSetup(
    BuildContext context,
    ConversationModeState state,
    ConversationModeNotifier notifier,
    List<LanguageOption> languages,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.record_voice_over_rounded, size: 48, color: AppTheme.primary),
            const SizedBox(height: 16),
            Text(
              'What language are you speaking?',
              style: GoogleFonts.outfit(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'The other person doesn\'t need to pick anything — the app will identify their language once they start talking.',
              style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            DropdownButton<String>(
              value: languages.any((l) => l.iso == state.ownerLanguageIso) ? state.ownerLanguageIso : null,
              hint: Text('Select your language', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
              dropdownColor: AppTheme.surface,
              items: languages
                  .map((l) => DropdownMenuItem(value: l.iso, child: Text(l.name, style: const TextStyle(color: AppTheme.textPrimary))))
                  .toList(),
              onChanged: (val) {
                if (val != null) notifier.setOwnerLanguage(val);
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.background,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text('Start Conversation', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              onPressed: () => notifier.startConversation(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationBody(
    BuildContext context,
    ConversationModeState state,
    ConversationModeNotifier notifier,
  ) {
    return Column(
      children: [
        _buildPhaseStatus(context, state),
        Expanded(
          child: state.turns.isEmpty
              ? Center(
                  child: Text(
                    'No turns yet',
                    style: GoogleFonts.inter(color: AppTheme.textSecondary),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: state.turns.length,
                  itemBuilder: (context, idx) {
                    final t = state.turns[idx];
                    return Align(
                      alignment: t.isOwner ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: (t.isOwner ? AppTheme.primary : AppTheme.secondary).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: (t.isOwner ? AppTheme.primary : AppTheme.secondary).withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.text, style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(t.translated, style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 15)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        _buildTurnButton(context, state, notifier),
      ],
    );
  }

  Widget _buildPhaseStatus(BuildContext context, ConversationModeState state) {
    if (state.statusMessage == null) return const SizedBox.shrink();
    final isBlocking = state.phase == ConversationPhase.needsMoreSample ||
        state.phase == ConversationPhase.noConsensus ||
        state.phase == ConversationPhase.noDotCard;
    final color = isBlocking ? AppTheme.warning : AppTheme.textSecondary;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        state.statusMessage!,
        style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 12.5),
      ),
    );
  }

  Widget _buildTurnButton(
    BuildContext context,
    ConversationModeState state,
    ConversationModeNotifier notifier,
  ) {
    final disabled = state.isProcessing;
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: disabled
            ? null
            : () => state.isListening ? notifier.endTurn() : notifier.startTurn(),
        child: Opacity(
          opacity: disabled ? 0.5 : 1.0,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: state.isListening ? AppTheme.error.withOpacity(0.15) : AppTheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: state.isListening ? AppTheme.error : AppTheme.primary, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  state.isListening ? Icons.stop_circle_outlined : Icons.mic_none_rounded,
                  color: state.isListening ? AppTheme.error : AppTheme.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  state.isProcessing
                      ? 'Processing...'
                      : state.isListening
                          ? 'Tap to finish line'
                          : 'Tap to capture next line',
                  style: GoogleFonts.outfit(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
