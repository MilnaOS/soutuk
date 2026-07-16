import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';
import '../state/conference_provider.dart';

class ConferenceScreen extends ConsumerStatefulWidget {
  const ConferenceScreen({super.key});

  @override
  ConsumerState<ConferenceScreen> createState() => _ConferenceScreenState();
}

class _ConferenceScreenState extends ConsumerState<ConferenceScreen> with TickerProviderStateMixin {
  late AnimationController _radarController;
  final TextEditingController _localSpeechInput = TextEditingController();

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Auto-trigger scanning on entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(conferenceProvider.notifier).startScanning();
    });
  }

  @override
  void dispose() {
    _radarController.dispose();
    _localSpeechInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conferenceProvider);
    final notifier = ref.read(conferenceProvider.notifier);

    return Scaffold(
      body: Stack(
        children: [
          // 1. Premium Dark Neon Background Gradient
          Positioned.fill(child: Container(color: AppTheme.background)),
          Positioned(
            top: -60,
            left: -60,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 95, sigmaY: 95),
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withOpacity(0.06),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.secondary.withOpacity(0.07),
                ),
              ),
            ),
          ),

          // 2. Main Layout Column
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildDemoModeBanner(context),
                _buildHeader(context, state),
                Expanded(
                  child: _buildBody(state, notifier),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Demo Mode Notice
  // ==========================================
  // This whole mode is currently a fully simulated preview — hardcoded fake
  // peers, generated waveform animation (not real microphone levels), and
  // scripted canned "incoming speech" — no real P2P/mesh networking exists
  // yet. This banner exists so that's honestly visible, not just a text-field
  // hint a user could easily miss. Remove once real networking is built.
  Widget _buildDemoModeBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppTheme.warning.withOpacity(0.15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.science_outlined, size: 14, color: AppTheme.warning),
          const SizedBox(width: 6),
          Text(
            'PREVIEW — simulated peers and audio, not a working connection yet',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppTheme.warning,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Header Widget Builder
  // ==========================================
  Widget _buildHeader(BuildContext context, ConferenceState state) {
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
              ref.read(conferenceProvider.notifier).disconnect();
              Navigator.pop(context);
            },
          ),
          Column(
            children: [
              Text(
                'COOPERATIVE CONFERENCE',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: AppTheme.secondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Dual-Handset low-latency mesh link',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11, color: AppTheme.textSecondary),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: state.peerStatus == PeerConnectionStatus.connected
                  ? AppTheme.success.withOpacity(0.12)
                  : AppTheme.textSecondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: state.peerStatus == PeerConnectionStatus.connected
                    ? AppTheme.success.withOpacity(0.3)
                    : Colors.white10,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: state.peerStatus == PeerConnectionStatus.connected
                        ? AppTheme.success
                        : AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  state.peerStatus == PeerConnectionStatus.connected ? 'PAIRED' : 'STANDBY',
                  style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Body Switcher
  // ==========================================
  Widget _buildBody(ConferenceState state, ConferenceNotifier notifier) {
    switch (state.peerStatus) {
      case PeerConnectionStatus.disconnected:
      case PeerConnectionStatus.scanning:
        return _buildDiscoveryRadarView(state, notifier);
      case PeerConnectionStatus.connecting:
        return _buildConnectingHandshakeView(state);
      case PeerConnectionStatus.connected:
        return _buildActivePairedSessionView(state, notifier);
    }
  }

  // ==========================================
  // Radar Scan Screen (BLE Discovery)
  // ==========================================
  Widget _buildDiscoveryRadarView(ConferenceState state, ConferenceNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          // Radar pulse animation
          Center(
            child: SizedBox(
              width: 160,
              height: 160,
              child: AnimatedBuilder(
                animation: _radarController,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Radial expanding circles
                      ...List.generate(3, (index) {
                        final value = (_radarController.value + index / 3.0) % 1.0;
                        return Container(
                          width: 50 + value * 110,
                          height: 50 + value * 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.secondary.withOpacity((1.0 - value) * 0.4),
                              width: 1.5,
                            ),
                          ),
                        );
                      }),
                      // Central target dot
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.secondary.withOpacity(0.12),
                          border: Border.all(color: AppTheme.secondary.withOpacity(0.4), width: 1.5),
                        ),
                        child: const Center(
                          child: Icon(Icons.radar_rounded, color: AppTheme.secondary, size: 28),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Scanning for Nearby Devices...',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Keep your device near the other native speaker\'s phone to automatically detect peer links and begin high-fidelity conference translation.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 24),

          // Nearby Discovered Handsets List
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceGlass.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderGlass.withOpacity(0.08)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: state.nearbyPeers.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final peer = state.nearbyPeers[index];
                    return Container(
                      decoration: AppTheme.glassCardDecoration,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.secondary.withOpacity(0.15),
                          child: const Icon(Icons.phone_iphone, color: AppTheme.secondary, size: 20),
                        ),
                        title: Text(
                          peer.name,
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
                        ),
                        subtitle: Row(
                          children: [
                            const Icon(Icons.language_rounded, size: 12, color: AppTheme.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              "${peer.languageName} (${peer.languageIso.toUpperCase()})",
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.secondary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'LINK',
                            style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ),
                        onTap: () => notifier.connectToPeer(peer),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => notifier.startScanning(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.surfaceGlass,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Refresh Search'),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Handshake Connecting Loading Screen
  // ==========================================
  Widget _buildConnectingHandshakeView(ConferenceState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.secondary),
        ),
        const SizedBox(height: 24),
        Text(
          'Connecting Handshake...',
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          'Linking low-latency duplex channels with ${state.connectedPeer?.name}...',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  // ==========================================
  // Active Duplex Audio Paired Screen
  // ==========================================
  Widget _buildActivePairedSessionView(ConferenceState state, ConferenceNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Connection Info Card
        _buildConnectionDetailsBanner(state, notifier),

        // Double live Waveform visualizers (Local & Remote)
        _buildDuplexWaveformConsole(state),

        // Live scrolled conference translation conversation log
        Expanded(
          child: _buildConversationFeed(state),
        ),

        // Vocal inputs trigger & simulation dashboard
        _buildActiveControlPanel(state, notifier),
      ],
    );
  }

  Widget _buildConnectionDetailsBanner(ConferenceState state, ConferenceNotifier notifier) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGlass.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGlass.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.wifi_tethering_rounded, color: AppTheme.success, size: 20),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.connectedPeer?.name ?? 'Linked Peer',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary),
                      ),
                      Text(
                        'Target Language: ${state.connectedPeer?.languageName} (${state.connectedPeer?.languageIso.toUpperCase()})',
                        style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppTheme.error, size: 20),
                onPressed: () => notifier.disconnect(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 12),

          // Intersective hardware configuration controls
          Row(
            children: [
              // Noise Isolation Toggle
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.background.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        state.isNoiseIsolationEnabled ? Icons.noise_control_off : Icons.noise_aware_outlined,
                        size: 14,
                        color: state.isNoiseIsolationEnabled ? AppTheme.secondary : AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          state.isNoiseIsolationEnabled ? 'Vocal Isolated (98.4%)' : 'Raw Ambient Mic',
                          style: GoogleFonts.outfit(fontSize: 10, color: AppTheme.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Switch(
                        value: state.isNoiseIsolationEnabled,
                        onChanged: (val) => notifier.toggleNoiseIsolation(val),
                        activeColor: AppTheme.secondary,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Headset Audio Output target driver
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.background.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: PopupMenuButton<String>(
                    initialValue: state.audioRoute,
                    onSelected: (val) => notifier.changeAudioRoute(val),
                    color: AppTheme.surface,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.headset_rounded, size: 14, color: AppTheme.secondary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            state.audioRoute.split(' ').first + ' Headset',
                            style: GoogleFonts.outfit(fontSize: 10, color: AppTheme.textPrimary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, size: 12, color: AppTheme.textSecondary),
                      ],
                    ),
                    itemBuilder: (context) {
                      return [
                        'Noise Cancelling Headphones',
                        'Bone Conducting Headset',
                        'Device Speaker',
                      ].map((route) {
                        return PopupMenuItem<String>(
                          value: route,
                          child: Text(route, style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary)),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Waveform Console (Duplex Signals)
  // ==========================================
  Widget _buildDuplexWaveformConsole(ConferenceState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGlass.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          // 1. Local Mic Isolated channel visualizer
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'LOCAL MIC (ISOLATED)',
                      style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primary, letterSpacing: 0.5),
                    ),
                    Icon(
                      state.isNoiseIsolationEnabled ? Icons.check_circle : Icons.warning_amber_rounded,
                      size: 10,
                      color: state.isNoiseIsolationEnabled ? AppTheme.success : AppTheme.warning,
                    )
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  height: 36,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: state.localMicWaveform.map((val) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        width: 2.5,
                        height: val,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 48,
            color: Colors.white10,
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),
          // 2. Remote paired headphone visualizer
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'HEADPHONE FEED (PEER)',
                      style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.secondary, letterSpacing: 0.5),
                    ),
                    Text(
                      state.isPeerSpeaking ? 'SPEAKING' : 'IDLE',
                      style: GoogleFonts.outfit(fontSize: 8, fontWeight: FontWeight.bold, color: state.isPeerSpeaking ? AppTheme.secondary : AppTheme.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  height: 36,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: state.remotePeerWaveform.map((val) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        width: 2.5,
                        height: val,
                        decoration: BoxDecoration(
                          color: AppTheme.secondary,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Conversation Feed Logs
  // ==========================================
  Widget _buildConversationFeed(ConferenceState state) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      reverse: false,
      itemCount: state.conversationFeed.length,
      itemBuilder: (context, index) {
        final msg = state.conversationFeed[index];
        final isSystem = msg.id == "system_init";

        if (isSystem) {
          return Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.success.withOpacity(0.15)),
              ),
              child: Text(
                msg.translatedText,
                style: const TextStyle(color: AppTheme.success, fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return Align(
          alignment: msg.isIncoming ? Alignment.centerLeft : Alignment.centerRight,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: msg.isIncoming ? AppTheme.surfaceGlass : AppTheme.secondary.withOpacity(0.15),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(14),
                topRight: const Radius.circular(14),
                bottomLeft: Radius.circular(msg.isIncoming ? 2 : 14),
                bottomRight: Radius.circular(msg.isIncoming ? 14 : 2),
              ),
              border: Border.all(
                color: msg.isIncoming ? Colors.white10 : AppTheme.secondary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      msg.senderName,
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: msg.isIncoming ? AppTheme.textSecondary : AppTheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}",
                      style: const TextStyle(fontSize: 8, color: Colors.white24),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  msg.translatedText,
                  style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  "Original (${msg.isIncoming ? state.connectedPeer?.languageName : 'English'}): \"${msg.originalText}\"",
                  style: const TextStyle(color: Colors.white30, fontSize: 9, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // Bottom Speech Gating Panel
  // ==========================================
  Widget _buildActiveControlPanel(ConferenceState state, ConferenceNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGlass.withOpacity(0.5),
        border: Border(top: BorderSide(color: AppTheme.secondary.withOpacity(0.1), width: 1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.secondary.withOpacity(0.15)),
                  ),
                  child: TextField(
                    controller: _localSpeechInput,
                    decoration: InputDecoration(
                      hintText: 'Simulate speaking into your handset...',
                      hintStyle: GoogleFonts.inter(color: Colors.white24, fontSize: 12),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 13),
                    onSubmitted: (val) {
                      if (val.trim().isNotEmpty) {
                        final iso = state.connectedPeer?.languageIso ?? 'myn';
                        final simulatedIpa = iso == 'myn' ? "[haʔ-k'iːniʃ]" : "[Simulated Translated Phrase]";
                        notifier.sendLocalSpeech(val, simulatedIpa);
                        _localSpeechInput.clear();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: AppTheme.secondary.withOpacity(0.2),
                child: IconButton(
                  icon: const Icon(Icons.send, color: AppTheme.secondary, size: 16),
                  onPressed: () {
                    final val = _localSpeechInput.text;
                    if (val.trim().isNotEmpty) {
                      final iso = state.connectedPeer?.languageIso ?? 'myn';
                      final simulatedIpa = iso == 'myn' ? "[haʔ-k'iːniʃ]" : "[Simulated Translated Phrase]";
                      notifier.sendLocalSpeech(val, simulatedIpa);
                      _localSpeechInput.clear();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Mock environmental crowds noise indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.headphones_rounded, size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    "Output: ${state.audioRoute}",
                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.nature_people_rounded, size: 14, color: AppTheme.warning),
                  const SizedBox(width: 6),
                  Text(
                    "Noise Filter Active: ${(state.noiseCancellationPercentage * 100).toStringAsFixed(1)}%",
                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
