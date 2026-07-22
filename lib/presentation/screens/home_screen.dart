import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';
import '../../feature_flags.dart';
import '../state/translation_providers.dart';
import 'widgets/speech_bubble.dart';
import 'widgets/warning_banner.dart';
import 'discovery_screen.dart';
import 'conference_screen.dart';
import 'conversation_mode_screen.dart';
import 'settings_screen.dart';
import '../../domain/dtos/language_option_dto.dart';

enum _HeaderMenuAction { discovery, conference, settings }

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with WidgetsBindingObserver {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _sigController = TextEditingController();
  final TextEditingController _langSearchController = TextEditingController();

  static const List<LanguageOption> _fallbackLanguages = [
    LanguageOption(name: 'English', iso: 'eng'),
    LanguageOption(name: 'Spanish', iso: 'spa'),
    LanguageOption(name: 'French', iso: 'fra'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _textController.dispose();
    _scrollController.dispose();
    _sigController.dispose();
    _langSearchController.dispose();
    super.dispose();
  }

  // Screen lock and backgrounding both fire AppLifecycleState.paused —
  // invalidate any cached high-stakes signature so stepping away requires a
  // fresh one next time, rather than trusting a signature from before the
  // interruption. See ConversationNotifier.invalidateSignature().
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(conversationProvider.notifier).invalidateSignature();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conversationProvider);
    final notifier = ref.read(conversationProvider.notifier);
    final languagesAsync = ref.watch(languageCatalogProvider);
    final languages = languagesAsync.when(
      data: (langs) => langs,
      loading: () => _fallbackLanguages,
      error: (_, __) => _fallbackLanguages,
    );

    return Scaffold(
      body: Stack(
        children: [
          // 1. Premium Glowing Background Gradient
          Positioned.fill(
            child: Container(
              color: AppTheme.background,
            ),
          ),
          Positioned(
            top: -100,
            left: -100,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withOpacity(0.08),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.secondary.withOpacity(0.06),
                ),
              ),
            ),
          ),

          // 2. Main Content Area
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Premium Header Widget
                _buildHeader(context, state, notifier, languages),

                // Active High-Stakes Warn Banner
                if (state.activeWarning != null)
                  WarningBanner(state: state, notifier: notifier),

                // Conversation History
                Expanded(
                  child: state.utterances.isEmpty
                      ? _buildEmptyState(context)
                      : _buildConversationList(state),
                ),

                if (state.isTranslating)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                        ),
                      ),
                    ),
                  ),

                // Input Action Triggers Bar
                _buildInputBar(state, notifier),
              ],
            ),
          ),

          // 3. Signature Override Gating Modal Overlay
          if (state.requiresSignature)
            _buildSignatureModal(state, notifier),
        ],
      ),
    );
  }

  // ==========================================
  // Header Widget Builder
  // ==========================================
  Widget _buildHeader(
    BuildContext context,
    ConversationState state,
    ConversationNotifier notifier,
    List<LanguageOption> languages,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGlass.withOpacity(0.4),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.primary.withOpacity(0.08),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Soutuk',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontSize: 28,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.5,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: state.isOnlineMode ? AppTheme.success : AppTheme.secondary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        state.isOnlineMode ? 'Online (VM Translate)' : 'Offline (On-Device Artaxia)',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Mode Toggle Button (Online vs Offline) — hidden while
                    // offline mode is retired, see feature_flags.dart
                    if (kOfflineModeEnabled)
                      IconButton(
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          state.isOnlineMode ? Icons.cloud_queue : Icons.cloud_off_outlined,
                          size: 20,
                          color: state.isOnlineMode ? AppTheme.primary : AppTheme.textSecondary,
                        ),
                        tooltip: state.isOnlineMode ? 'Switch to Offline On-Device Artaxia' : 'Switch to Online Cloud Translate',
                        onPressed: () => notifier.toggleOnlineMode(),
                      ),
                    // Clear History Button
                    IconButton(
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.refresh, size: 20, color: AppTheme.textSecondary),
                      tooltip: 'Reset Conversation',
                      onPressed: () => notifier.clearHistory(),
                    ),
                    // Conversation Mode Trigger — two-person interpreter
                    IconButton(
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.record_voice_over_rounded, color: AppTheme.primary, size: 22),
                      tooltip: 'Conversation Mode',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ConversationModeScreen()),
                        );
                      },
                    ),
                    // Overflow menu — less-frequent actions. Kept as a
                    // discoverable three-dot menu rather than a horizontally
                    // scrollable icon row: a hidden swipe-to-reveal affordance
                    // is easy to miss (confirmed on real hardware — the
                    // Settings/API-key icon was invisible until told to swipe).
                    PopupMenuButton<_HeaderMenuAction>(
                      padding: const EdgeInsets.all(6),
                      icon: const Icon(Icons.more_vert, size: 20, color: AppTheme.textSecondary),
                      tooltip: 'More',
                      onSelected: (action) {
                        switch (action) {
                          case _HeaderMenuAction.discovery:
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const DiscoveryScreen()),
                            );
                            break;
                          case _HeaderMenuAction.conference:
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ConferenceScreen()),
                            );
                            break;
                          case _HeaderMenuAction.settings:
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SettingsScreen()),
                            );
                            break;
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: _HeaderMenuAction.discovery,
                          child: ListTile(
                            leading: Icon(Icons.travel_explore_rounded, color: AppTheme.primary),
                            title: Text('Hands-Free Discovery Mode'),
                          ),
                        ),
                        PopupMenuItem(
                          value: _HeaderMenuAction.conference,
                          child: ListTile(
                            leading: Icon(Icons.headset_mic_outlined, color: AppTheme.secondary),
                            title: Text('Cooperative Conference Mode'),
                          ),
                        ),
                        PopupMenuItem(
                          value: _HeaderMenuAction.settings,
                          child: ListTile(
                            leading: Icon(Icons.vpn_key_outlined, color: AppTheme.textSecondary),
                            title: Text('API Key & Model Settings'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Language Pair Selector Bar
          _buildLanguageSelectors(state, notifier, languages),
        ],
      ),
    );
  }

  Widget _buildLanguageSelectors(
    ConversationState state,
    ConversationNotifier notifier,
    List<LanguageOption> languages,
  ) {
    // Two known languages, not one auto-detected + one picked: on-device
    // speech recognition needs to be told which language to listen for, so
    // there's no more auto-detection to lean on. Each mic button below
    // routes translation in one direction between these two.
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLangDropdown(
          activeIso: state.languageOneIso,
          languages: languages,
          onChanged: (val) {
            if (val != null) notifier.changeLanguageOne(val);
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Icon(Icons.swap_horiz_rounded, color: AppTheme.textSecondary, size: 18),
        ),
        _buildLangDropdown(
          activeIso: state.languageTwoIso,
          languages: languages,
          onChanged: (val) {
            if (val != null) notifier.changeLanguageTwo(val);
          },
        ),
      ],
    );
  }

  Widget _buildLangDropdown({
    required String activeIso,
    required List<LanguageOption> languages,
    required ValueChanged<String?> onChanged,
  }) {
    // Guard against the active ISO not being present in the resolved list yet
    // (e.g. still on the small fallback list while the real catalog loads).
    final hasActive = languages.any((lang) => lang.iso == activeIso);
    final items = hasActive
        ? languages
        : [...languages, LanguageOption(name: activeIso, iso: activeIso)];
    final activeLabel = items.firstWhere((lang) => lang.iso == activeIso).name;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _showLanguageSearchPicker(items, onChanged),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceGlass,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primary.withOpacity(0.12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              activeLabel,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, color: AppTheme.primary, size: 18),
          ],
        ),
      ),
    );
  }

  void _showLanguageSearchPicker(List<LanguageOption> languages, ValueChanged<String?> onChanged) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final query = _langSearchController.text.toLowerCase().trim();
            final filtered = query.isEmpty
                ? languages
                : languages.where((l) => l.name.toLowerCase().startsWith(query)).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: AppTheme.borderGlass.withOpacity(0.2), width: 1.5),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.textSecondary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      Text(
                        'Select Language',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextField(
                          controller: _langSearchController,
                          autofocus: true,
                          onChanged: (val) => setModalState(() {}),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
                            hintText: 'Search ${languages.length} languages...',
                            filled: true,
                            fillColor: AppTheme.background.withOpacity(0.5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppTheme.borderGlass.withOpacity(0.1)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppTheme.primary),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: filtered.isEmpty
                            ? Center(
                                child: Text(
                                  'No matches',
                                  style: GoogleFonts.inter(color: AppTheme.textSecondary),
                                ),
                              )
                            : ListView.builder(
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final lang = filtered[index];
                                  return ListTile(
                                    contentPadding:
                                        const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                                    title: Text(lang.name,
                                        style: const TextStyle(color: AppTheme.textPrimary)),
                                    trailing: Container(
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        lang.iso.toUpperCase(),
                                        style: GoogleFonts.outfit(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primary),
                                      ),
                                    ),
                                    onTap: () {
                                      onChanged(lang.iso);
                                      _langSearchController.clear();
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).then((_) => _langSearchController.clear());
  }

  // ==========================================
  // Warnings & Guardrails Bar
  // ==========================================
  // Private inline builders deleted; extracted to modular widget files.

  // ==========================================
  // Bottom Inputs Control Panel
  // ==========================================
  Widget _buildInputBar(ConversationState state, ConversationNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGlass.withOpacity(0.5),
        border: Border(
          top: BorderSide(
            color: AppTheme.primary.withOpacity(0.08),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Keyboard text input trigger fallback
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.primary.withOpacity(0.12)),
                  ),
                  child: TextField(
                    key: const Key('translateInputField'),
                    controller: _textController,
                    enabled: !state.isTranslating,
                    decoration: InputDecoration(
                      hintText: 'Type text to translate...',
                      hintStyle: GoogleFonts.inter(color: Colors.white24, fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 14),
                    onSubmitted: (val) {
                      if (val.trim().isNotEmpty) {
                        notifier.translateMessage(val);
                        _textController.clear();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                backgroundColor: AppTheme.primary.withOpacity(0.15),
                child: IconButton(
                  key: const Key('translateSendButton'),
                  icon: const Icon(Icons.send, color: AppTheme.primary, size: 16),
                  onPressed: state.isTranslating
                      ? null
                      : () {
                          final val = _textController.text;
                          if (val.trim().isNotEmpty) {
                            notifier.translateMessage(val);
                            _textController.clear();
                          }
                        },
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          // Two mic buttons, one per direction — no auto-detection, the
          // mic you tap tells the app which of the two known languages is
          // about to be spoken.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMicButton(
                label: 'Mic 1 → 2',
                isListening: state.isListening && state.activeMicDirection == MicDirection.oneToTwo,
                color: AppTheme.primary,
                onPressed: state.isTranslating || (state.isListening && state.activeMicDirection != MicDirection.oneToTwo)
                    ? null
                    : () => state.isListening
                        ? notifier.stopListening()
                        : notifier.startListening(MicDirection.oneToTwo),
              ),
              const SizedBox(width: 16),
              _buildMicButton(
                label: 'Mic 2 → 1',
                isListening: state.isListening && state.activeMicDirection == MicDirection.twoToOne,
                color: AppTheme.secondary,
                onPressed: state.isTranslating || (state.isListening && state.activeMicDirection != MicDirection.twoToOne)
                    ? null
                    : () => state.isListening
                        ? notifier.stopListening()
                        : notifier.startListening(MicDirection.twoToOne),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMicButton({
    required String label,
    required bool isListening,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    final disabled = onPressed == null;
    return Opacity(
      opacity: disabled ? 0.4 : 1.0,
      child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isListening ? color.withOpacity(0.2) : AppTheme.surfaceGlass,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isListening ? color : color.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
              color: color,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              isListening ? 'Streaming...' : label,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  // ==========================================
  // Signature Informed Consent Overlay Drawer
  // ==========================================
  Widget _buildSignatureModal(
    ConversationState state,
    ConversationNotifier notifier,
  ) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.85),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.glassCardDecoration,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.security, color: AppTheme.error, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      'Liability Signature Required',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'The translation agent has triggered high-stakes medical or legal context. Silent translation inaccuracies in these domains can cause physical or liability hazards.\n\nYou must enter your typed signature below to confirm that you are validating these statements with on-site, qualified professionals.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        height: 1.5,
                        fontSize: 13,
                      ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.error.withOpacity(0.2)),
                  ),
                  child: Text(
                    state.activeWarning ?? 'No pending alerts.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                        ),
                  ),
                ),
                const SizedBox(height: 20),
                // Typed signature entry
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.error.withOpacity(0.3)),
                  ),
                  child: TextField(
                    controller: _sigController,
                    decoration: InputDecoration(
                      hintText: 'Type your full name to sign...',
                      hintStyle: GoogleFonts.inter(color: Colors.white24, fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    style: GoogleFonts.yellowtail(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          _sigController.clear();
                          notifier.clearWarning();
                        },
                        child: Text(
                          'Cancel & Discard',
                          style: GoogleFonts.outfit(color: AppTheme.textSecondary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.error,
                          foregroundColor: AppTheme.textPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          final name = _sigController.text;
                          if (name.trim().isNotEmpty) {
                            notifier.captureSignature(name);
                            _sigController.clear();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter your typed signature to agree.'),
                              ),
                            );
                          }
                        },
                        child: Text(
                          'Agree & Sign',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // Empty State Layout
  // ==========================================
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withOpacity(0.05),
                border: Border.all(color: AppTheme.primary.withOpacity(0.15), width: 1.5),
              ),
              child: const Icon(
                Icons.translate_rounded,
                size: 40,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Conversation History',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 20,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Set both languages above, then tap the matching mic to speak in that direction — or type below.\n\nTip: Type "hospital" or "lawyer" to test risk guardrails.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // Conversation List Scroll View
  // ==========================================
  Widget _buildConversationList(ConversationState state) {
    _scrollToBottom();
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      itemCount: state.utterances.length,
      itemBuilder: (context, idx) {
        final item = state.utterances[idx];
        return Align(
          alignment: item.isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: 0.85,
            child: SpeechBubble(item: item),
          ),
        );
      },
    );
  }
}
