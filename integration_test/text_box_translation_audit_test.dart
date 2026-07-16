// Drives the REAL app UI — pumps SoutukApp, toggles online mode via the same
// icon a user taps, enters text into the actual translateInputField, taps
// the actual send button — exercising the exact code path a human using the
// text box triggers (ConversationNotifier.translateMessage ->
// CloudflareWorkerService -> Ollama Cloud). No OpenAI calls at all, so this
// is free to rerun as often as needed. Not a pass/fail suite: it writes a
// report to /home/jeremy/soutuk_test_results/text_box_audit.json for manual
// review of translation validity and guardrail behavior (flags, confidence,
// signature-gate triggers).
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:soutuk/main.dart';
import 'package:soutuk/presentation/screens/home_screen.dart';
import 'package:soutuk/presentation/state/translation_providers.dart';

const String _resultsDir = '/home/jeremy/soutuk_test_results';

const Map<String, String> _targetLanguages = {
  'spa': 'Spanish',
  'fra': 'French',
  'deu': 'German',
  'ita': 'Italian',
  'rus': 'Russian',
  'jpn': 'Japanese',
  'cmn': 'Mandarin',
  'ara': 'Arabic',
  'lat': 'Latin',
  'grc': 'Classical Greek',
};

const List<String> _phrases = [
  'Where is the nearest pharmacy?',
  'The patient needs immediate medical attention.',
  'You have the right to speak with a lawyer.',
  'Can you tell me how to get to the train station?',
  'I would like to order two coffees, please.',
];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('audit translation validity via the real text box', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SoutukApp()));
    await tester.pump(const Duration(milliseconds: 500));

    final container =
        ProviderScope.containerOf(tester.element(find.byType(HomeScreen)));

    // Match the real user gesture for switching into online mode (the
    // Cloudflare Worker / Ollama Cloud path) rather than reaching into the
    // notifier directly.
    if (!container.read(conversationProvider).isOnlineMode) {
      await tester.tap(find.byIcon(Icons.cloud_off_outlined));
      await tester.pump(const Duration(milliseconds: 200));
    }

    final report = <Map<String, dynamic>>[];

    for (final entry in _targetLanguages.entries) {
      // Language selection goes through the same notifier method the search
      // picker's onTap calls — the picker sheet itself is UI chrome around
      // that same call, not part of what this audit needs to exercise.
      // Typed input translates language-one -> language-two by default
      // (see translateMessage's doc comment), so language two is the one
      // this audit varies; language one stays at its 'eng' default.
      await container.read(conversationProvider.notifier).changeLanguageTwo(entry.key);
      await tester.pump(const Duration(milliseconds: 100));

      for (final phrase in _phrases) {
        // On the real (non-fake) integration_test binding, enterText() needs
        // the field to actually be focused first — after the first send the
        // field loses focus and subsequent enterText() calls silently no-op
        // without an explicit tap/focus, leaving the controller empty.
        await tester.tap(find.byKey(const Key('translateInputField')));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.enterText(find.byKey(const Key('translateInputField')), phrase);
        await tester.pump(const Duration(milliseconds: 100));

        await tester.tap(find.byKey(const Key('translateSendButton')));
        await tester.pump(const Duration(milliseconds: 100));

        var waited = Duration.zero;
        const step = Duration(milliseconds: 250);
        while (container.read(conversationProvider).isTranslating && waited < const Duration(seconds: 30)) {
          await tester.pump(step);
          waited += step;
        }

        final state = container.read(conversationProvider);
        final last = state.utterances.isNotEmpty ? state.utterances.last : null;

        report.add({
          'targetLanguage': entry.value,
          'targetIso': entry.key,
          'sourceText': phrase,
          'translatedText': last?.translated ?? '[NO RESULT — check activeWarning]',
          'lastUtteranceSourceText': last?.text,
          'utteranceCount': state.utterances.length,
          'confidence': last?.confidence,
          'flags': last?.flags ?? [],
          'requiresSignature': state.requiresSignature,
          'activeWarning': state.activeWarning,
        });

        // Clear any signature gate so the next phrase isn't blocked behind
        // the modal — this audit cares about whether the gate correctly
        // fired, not about actually signing it.
        if (state.requiresSignature) {
          container.read(conversationProvider.notifier).clearWarning();
          // The signature gate is a full-screen Positioned.fill overlay; a
          // single short pump isn't reliably enough for it to leave the
          // hit-test tree before the next tester.tap(), which would then
          // silently land on nothing. pumpAndSettle is safe here (no
          // isTranslating spinner running at this point to spin forever).
          await tester.pumpAndSettle();
        }
      }
    }

    final dir = Directory(_resultsDir);
    await dir.create(recursive: true);
    final file = File('$_resultsDir/text_box_audit.json');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(report));

    expect(report.length, _targetLanguages.length * _phrases.length);
  }, timeout: const Timeout(Duration(minutes: 15)));
}
