import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';
import '../state/discovery_provider.dart';

class DiscoveryScreen extends ConsumerStatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  ConsumerState<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends ConsumerState<DiscoveryScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _waveController;

  // The 153 languages from the core registry
  static const List<String> _allLanguages = [
    "Akkadian", "Albanian", "Amharic", "Anufo", "Arabic", "Aramaic", "Armenian", "Awyi", "Ayiwo", 
    "Bai", "Bantu", "Baragaunle", "Basque", "Bengali", "Bilua", "Boko", "Bulgarian", "Burmese", 
    "Cantonese", "Choctaw", "Cocama", "Czech", "Dhaasanac", "Dhargari", "Dravidian", "Dutch", 
    "English", "Epena Pedee", "Finnish", "French", "Ga'anda", "Georgian", "German", "Gooniyandi", 
    "Grebo", "Greek", "Greenlandic", "Guajajara", "Gujarati", "Gula", "Hebrew", "Hidatsa", 
    "Hindi", "Hmar", "Hopi", "Hungarian", "Iban", "Icelandic", "Ika", "Inanwatan", "Indonesian", 
    "Italian", "Japanese", "Kaluli", "Kanakuru", "Kanashi", "Kanuri", "Karok", "Kasong", 
    "Kewa", "Khalkha", "Kiliwa", "Kirghiz", "Konni", "Korean", "Koromfe", "Labu", "Ladakhi", 
    "Lahu", "Lakhota", "Latin", "Lavukaleve", "Lega", "Makah", "Malay", "Mandarin", "Mangap-Mbula", 
    "Marathi", "Maru", "Mayan", "Mian", "Mien", "Mongolian", "Mumuye", "Mungaka", "Nahuatl", 
    "Nama", "Navajo", "Ndumu", "Newari", "Ngadjumaja", "Nias", "Nilotic", "Nung", "Orokaiva", 
    "Osage", "Paamese", "Paiute", "Persian", "Polish", "Portuguese", "Quechua", "Runyankore", 
    "Russian", "Sango", "Sanskrit", "Sema", "Seme", "Shona", "Simeulue", "Somali", "Soninke", 
    "Spanish", "Suki", "Sumerian", "Supyire", "Swahili", "Swedish", "Taiof", "Tausug", 
    "Tepehua", "Thai", "Tibetan", "Tirmaga", "Tiwi", "Tonkawa", "Turkish", "Tutelo", "Twi", 
    "Udmurt", "Una", "Ura", "Urdu", "Vietnamese", "Wakhi", "Warluwara", "Wedau", "Wichi", 
    "Wichita", "Wolof", "Xam", "Xhosa", "Yagaria", "Yao", "Yaruro", "Yiddish", "Yimas", 
    "Yoruba", "Yucuna", "Yulu", "Zapotec", "Zulu", "rGyalrong"
  ];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showLanguageSearchPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final query = _searchController.text.toLowerCase().trim();
            final filtered = _allLanguages.where((l) => l.toLowerCase().contains(query)).toList();

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
                      // Handle bar
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
                        'Select Discovery Language',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Search bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) {
                            setModalState(() {});
                          },
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
                            hintText: 'Search 153 languages...',
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
                        child: ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final lang = filtered[index];
                            final iso = lang.substring(0, 3).toLowerCase(); // simulated iso mapping

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                              title: Text(lang, style: const TextStyle(color: AppTheme.textPrimary)),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  iso.toUpperCase(),
                                  style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primary),
                                ),
                              ),
                              onTap: () {
                                ref.read(discoveryProvider.notifier).changeTargetLanguage(lang, iso);
                                _searchController.clear();
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(discoveryProvider);
    final notifier = ref.read(discoveryProvider.notifier);

    return Scaffold(
      body: Stack(
        children: [
          // 1. Premium Glowing Background Gradient
          Positioned.fill(child: Container(color: AppTheme.background)),
          Positioned(
            top: -50,
            right: -50,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.secondary.withOpacity(0.06),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 95, sigmaY: 95),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withOpacity(0.07),
                ),
              ),
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Area
                _buildHeader(context, state),

                // Active Elicitation Area or Intro State
                Expanded(
                  child: state.isSessionActive
                      ? _buildActiveSessionView(state, notifier)
                      : _buildIntroView(context, state, notifier),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // UI Builder Helpers
  // ==========================================

  Widget _buildHeader(BuildContext context, DiscoveryState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGlass.withOpacity(0.3),
        border: Border(bottom: BorderSide(color: AppTheme.primary.withOpacity(0.05), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary, size: 20),
            onPressed: () {
              if (state.isSessionActive) {
                ref.read(discoveryProvider.notifier).stopSession();
              }
              Navigator.pop(context);
            },
          ),
          Column(
            children: [
              Text(
                'TURING DISCOVERY',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Hands-Free Elicitation',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11, color: AppTheme.textSecondary),
              ),
            ],
          ),
          // Language Search Trigger
          GestureDetector(
            onTap: () => _showLanguageSearchPicker(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.language, size: 14, color: AppTheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    state.targetLanguageName,
                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroView(
    BuildContext context,
    DiscoveryState state,
    DiscoveryNotifier notifier,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          // Central illustration logo
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: AppTheme.glassCardDecoration,
              child: const Center(child: Text('🌐', style: TextStyle(fontSize: 48))),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Passive Cognitive Elicitation',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 16),
          Text(
            'Hold the device between yourself and the native speaker. Soutuk will speak a reference template prompt in your language and automatically listen for the response. No screen interaction required.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceGlass.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderGlass.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppTheme.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Target Discovery ISO',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Mapping translation matrix directly for ${state.targetLanguageName} (${state.targetLanguageIso.toUpperCase()})',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () => notifier.startSession(),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 8,
              shadowColor: AppTheme.primary.withOpacity(0.4),
            ),
            child: Text(
              'Start Hands-Free Session',
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildActiveSessionView(
    DiscoveryState state,
    DiscoveryNotifier notifier,
  ) {
    final activeCrib = state.currentCribItem;
    final isFlagged = state.flaggedSymbolIds.contains(activeCrib.symbolId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Progress HUD
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CONCEPT ${state.currentIndex + 1}/${state.cribs.length}',
                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'ACTIVE ELICITATION: ${state.targetLanguageName.toUpperCase()}',
                      style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (state.currentIndex + 1) / state.cribs.length,
                  minHeight: 6,
                  backgroundColor: AppTheme.surfaceGlass,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                ),
              ),
            ],
          ),
        ),

        // 2. Giant Pictogram Card (Centered)
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: AspectRatio(
                aspectRatio: 0.85,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceGlass,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: isFlagged 
                          ? AppTheme.warning.withOpacity(0.5) 
                          : AppTheme.borderGlass.withOpacity(0.15),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isFlagged 
                            ? AppTheme.warning.withOpacity(0.1) 
                            : AppTheme.primary.withOpacity(0.05),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Big Emoji Pictogram
                            AnimatedScale(
                              scale: state.isListening ? 1.15 : 1.0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.elasticOut,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.background.withOpacity(0.4),
                                  border: Border.all(
                                    color: isFlagged 
                                        ? AppTheme.warning.withOpacity(0.3) 
                                        : AppTheme.primary.withOpacity(0.2),
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    activeCrib.emoji,
                                    style: const TextStyle(fontSize: 54),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              activeCrib.title,
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Prompt Template:',
                              style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, letterSpacing: 0.5),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '"${activeCrib.referencePrompt}"',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: AppTheme.textPrimary,
                                height: 1.4,
                              ),
                            ),
                            const Spacer(),

                            // 3. Status Soundwave Visualizer Area
                            _buildSoundwaveConsole(state),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // 4. Interviewer Control Panel (Override Button)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => notifier.toggleOverrideFlag(),
                  icon: Icon(
                    isFlagged ? Icons.report_gmailerrorred : Icons.outlined_flag,
                    color: Colors.white,
                  ),
                  label: Text(
                    isFlagged ? 'FLAGGED (DOT LOCKED)' : 'OVERRIDE & FLAG',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: isFlagged ? AppTheme.warning : AppTheme.surfaceGlass,
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: isFlagged ? AppTheme.warning : AppTheme.warning.withOpacity(0.4),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.error.withOpacity(0.3)),
                ),
                child: IconButton(
                  icon: const Icon(Icons.stop_circle_outlined, color: AppTheme.error),
                  onPressed: () => notifier.stopSession(),
                  iconSize: 32,
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSoundwaveConsole(DiscoveryState state) {
    if (state.isPrompting) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 6,
                height: 12.0 + (i * 4),
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            'Soutuk is prompting speaker...',
            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary, fontStyle: FontStyle.italic),
          ),
        ],
      );
    }

    if (state.isListening) {
      // Return beautiful pulsing soundwave lines
      return AnimatedBuilder(
        animation: _waveController,
        builder: (context, child) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(8, (i) {
                  // Calculate dynamic wave amplitude
                  final pulse = (0.5 + 0.5 * (1.0 + (i - 4).abs() * 0.1)).clamp(0.0, 1.0);
                  final height = 10.0 + (pulse * 30.0 * (1.0 + _waveController.value * pulse));

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 4,
                    height: height.clamp(5, 45),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),
              Text(
                'PASSIVE MONITOR ACTIVE',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: AppTheme.primary,
                ),
              ),
            ],
          );
        },
      );
    }

    // Capture Result state
    final lastCrib = state.lastCapturedCrib;
    if (lastCrib != null) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
            ),
            child: Column(
              children: [
                Text(
                  'Transcribed Phonemes (IPA):',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, letterSpacing: 0.5),
                ),
                const SizedBox(height: 4),
                Text(
                  lastCrib.transcribedPhonemes ?? '[Inferred]',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Word boundaries
          Wrap(
            spacing: 6,
            children: lastCrib.inferredWordBoundaries.map((word) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  word,
                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                ),
              );
            }).toList(),
          ),
        ],
      );
    }

    return const SizedBox(height: 45);
  }
}
