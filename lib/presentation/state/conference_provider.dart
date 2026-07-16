import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ==========================================
// 1. Cooperative Conference Models
// ==========================================

enum PeerConnectionStatus {
  disconnected,
  scanning,
  connecting,
  connected,
}

class ConferenceMessage {
  final String id;
  final String senderName;
  final String originalText;
  final String translatedText;
  final DateTime timestamp;
  final bool isIncoming;

  ConferenceMessage({
    required this.id,
    required this.senderName,
    required this.originalText,
    required this.translatedText,
    required this.isIncoming,
  }) : timestamp = DateTime.now();
}

class DiscoveredPeer {
  final String name;
  final String languageName;
  final String languageIso;
  final double signalStrength; // 0.0 (weak) to 1.0 (strong)

  const DiscoveredPeer({
    required this.name,
    required this.languageName,
    required this.languageIso,
    required this.signalStrength,
  });
}

class ConferenceState {
  final PeerConnectionStatus peerStatus;
  final List<DiscoveredPeer> nearbyPeers;
  final DiscoveredPeer? connectedPeer;
  final bool isNoiseIsolationEnabled;
  final double noiseCancellationPercentage; // e.g. 0.982 for 98.2%
  final String audioRoute; // 'Device Speaker', 'Noise Cancelling Headphones', 'Bone Conducting Headset'
  final List<ConferenceMessage> conversationFeed;
  final List<double> localMicWaveform;
  final List<double> remotePeerWaveform;
  final bool isPeerSpeaking;

  const ConferenceState({
    this.peerStatus = PeerConnectionStatus.disconnected,
    this.nearbyPeers = const [],
    this.connectedPeer,
    this.isNoiseIsolationEnabled = true,
    this.noiseCancellationPercentage = 0.984,
    this.audioRoute = 'Noise Cancelling Headphones',
    this.conversationFeed = const [],
    this.localMicWaveform = const [],
    this.remotePeerWaveform = const [],
    this.isPeerSpeaking = false,
  });

  ConferenceState copyWith({
    PeerConnectionStatus? peerStatus,
    List<DiscoveredPeer>? nearbyPeers,
    DiscoveredPeer? Function()? connectedPeer,
    bool? isNoiseIsolationEnabled,
    double? noiseCancellationPercentage,
    String? audioRoute,
    List<ConferenceMessage>? conversationFeed,
    List<double>? localMicWaveform,
    List<double>? remotePeerWaveform,
    bool? isPeerSpeaking,
  }) {
    return ConferenceState(
      peerStatus: peerStatus ?? this.peerStatus,
      nearbyPeers: nearbyPeers ?? this.nearbyPeers,
      connectedPeer: connectedPeer != null ? connectedPeer() : this.connectedPeer,
      isNoiseIsolationEnabled: isNoiseIsolationEnabled ?? this.isNoiseIsolationEnabled,
      noiseCancellationPercentage: noiseCancellationPercentage ?? this.noiseCancellationPercentage,
      audioRoute: audioRoute ?? this.audioRoute,
      conversationFeed: conversationFeed ?? this.conversationFeed,
      localMicWaveform: localMicWaveform ?? this.localMicWaveform,
      remotePeerWaveform: remotePeerWaveform ?? this.remotePeerWaveform,
      isPeerSpeaking: isPeerSpeaking ?? this.isPeerSpeaking,
    );
  }
}

// ==========================================
// 2. Cooperative Conference Notifier
// ==========================================

class ConferenceNotifier extends StateNotifier<ConferenceState> {
  Timer? _scanTimer;
  Timer? _waveformTimer;
  Timer? _speechSimulationTimer;
  final Random _random = Random();

  static const List<DiscoveredPeer> _mockDiscoveredPeers = [
    DiscoveredPeer(name: "Jeremy's Galaxy (Z Fold)", languageName: "Mayan", languageIso: "myn", signalStrength: 0.94),
    DiscoveredPeer(name: "Sarah's iPhone Pro", languageName: "Spanish", languageIso: "spa", signalStrength: 0.88),
    DiscoveredPeer(name: "Antoine's Pixel 8", languageName: "French", languageIso: "fra", signalStrength: 0.72),
    DiscoveredPeer(name: "Lao's OnePlus Node", languageName: "Mandarin", languageIso: "cmn", signalStrength: 0.55),
  ];

  ConferenceNotifier() : super(const ConferenceState()) {
    _startWaveformLoop();
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _waveformTimer?.cancel();
    _speechSimulationTimer?.cancel();
    super.dispose();
  }

  // Starts short-range BLE/P2P signal scanning
  void startScanning() {
    _scanTimer?.cancel();
    state = state.copyWith(
      peerStatus: PeerConnectionStatus.scanning,
      nearbyPeers: [],
      connectedPeer: () => null,
    );

    // Simulate progressive near-field signal discovery
    _scanTimer = Timer(const Duration(seconds: 1), () {
      state = state.copyWith(
        nearbyPeers: [_mockDiscoveredPeers[0], _mockDiscoveredPeers[1]],
      );
      _scanTimer = Timer(const Duration(seconds: 1), () {
        state = state.copyWith(
          nearbyPeers: _mockDiscoveredPeers,
        );
      });
    });
  }

  // Toggles active microphone noise isolation coefficient
  void toggleNoiseIsolation(bool enabled) {
    state = state.copyWith(
      isNoiseIsolationEnabled: enabled,
      noiseCancellationPercentage: enabled ? 0.984 : 0.0,
    );
  }

  // Updates audio output target driver
  void changeAudioRoute(String route) {
    state = state.copyWith(audioRoute: route);
  }

  // Initiates peer handshake & P2P socket stream initialization
  void connectToPeer(DiscoveredPeer peer) {
    _scanTimer?.cancel();
    state = state.copyWith(
      peerStatus: PeerConnectionStatus.connecting,
      connectedPeer: () => peer,
    );

    // Simulate multi-channel Wi-Fi Direct socket handshaking delay
    _scanTimer = Timer(const Duration(seconds: 2), () {
      state = state.copyWith(
        peerStatus: PeerConnectionStatus.connected,
        conversationFeed: [
          ConferenceMessage(
            id: "system_init",
            senderName: "Soutuk Core",
            originalText: "Linked with ${peer.name}.",
            translatedText: "P2P duplex audio link established. Low-latency, vocal noise-cancellation isolation enabled.",
            isIncoming: false,
          )
        ],
      );

      // Start automatic simulated peer speech cycle
      _scheduleMockPeerSpeech();
    });
  }

  // Closes P2P session
  void disconnect() {
    _scanTimer?.cancel();
    _speechSimulationTimer?.cancel();
    state = state.copyWith(
      peerStatus: PeerConnectionStatus.disconnected,
      connectedPeer: () => null,
      conversationFeed: [],
      isPeerSpeaking: false,
    );
  }

  // Simulates local user speaking into their microphone
  void sendLocalSpeech(String text, String translation) {
    if (state.peerStatus != PeerConnectionStatus.connected) return;

    final newMessage = ConferenceMessage(
      id: "msg_local_${DateTime.now().millisecondsSinceEpoch}",
      senderName: "You",
      originalText: text,
      translatedText: translation,
      isIncoming: false,
    );

    state = state.copyWith(
      conversationFeed: [...state.conversationFeed, newMessage],
    );
  }

  // Simulates a low-latency translation incoming stream from Person B's handset
  void receivePeerSpeech(String originalText, String translatedText) {
    if (state.peerStatus != PeerConnectionStatus.connected) return;

    // Trigger visual speaking state (and light up the remote wave)
    state = state.copyWith(isPeerSpeaking: true);

    _speechSimulationTimer = Timer(const Duration(milliseconds: 2500), () {
      final newMessage = ConferenceMessage(
        id: "msg_peer_${DateTime.now().millisecondsSinceEpoch}",
        senderName: state.connectedPeer?.name.split("'").first ?? "Peer",
        originalText: originalText,
        translatedText: translatedText,
        isIncoming: true,
      );

      state = state.copyWith(
        conversationFeed: [...state.conversationFeed, newMessage],
        isPeerSpeaking: false,
      );
    });
  }

  // Periodic automatic simulated peer phrases
  void _scheduleMockPeerSpeech() {
    _speechSimulationTimer?.cancel();
    _speechSimulationTimer = Timer(const Duration(seconds: 6), () {
      if (state.peerStatus != PeerConnectionStatus.connected) return;

      final iso = state.connectedPeer?.languageIso ?? 'myn';
      if (iso == 'myn') {
        receivePeerSpeech("[k'iːniʃ-baːʔal-wah]", "The sun is hot, we need food.");
      } else if (iso == 'spa') {
        receivePeerSpeech("¡Hola! Me alegro mucho de verte en esta conferencia.", "Hello! I am very glad to see you at this conference.");
      } else {
        receivePeerSpeech("[Bonjour mon ami, bon travail!]", "Hello my friend, great job!");
      }

      // Re-schedule
      _scheduleMockPeerSpeech();
    });
  }

  // High-frequency UI simulation waveform tick
  void _startWaveformLoop() {
    _waveformTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) return;

      // 1. Generate local microphone waveform levels
      // If noise isolation is enabled, background noise is filtered, so wave level is low/dormant unless speaking
      final localBase = state.isNoiseIsolationEnabled ? 3.0 : 12.0;
      final localFluctuation = _random.nextDouble() * (state.isNoiseIsolationEnabled ? 4.0 : 18.0);
      final newLocalWave = List<double>.generate(15, (index) {
        return (localBase + localFluctuation * sin(index * 0.4)).clamp(2.0, 45.0);
      });

      // 2. Generate remote peer waveform levels (high when peer is speaking, low otherwise)
      final peerBase = state.isPeerSpeaking ? 15.0 : 2.0;
      final peerFluctuation = state.isPeerSpeaking ? (_random.nextDouble() * 25.0) : (_random.nextDouble() * 2.0);
      final newRemoteWave = List<double>.generate(15, (index) {
        return (peerBase + peerFluctuation * cos(index * 0.5)).clamp(1.5, 45.0);
      });

      state = state.copyWith(
        localMicWaveform: newLocalWave,
        remotePeerWaveform: newRemoteWave,
      );
    });
  }
}

final conferenceProvider =
    StateNotifierProvider<ConferenceNotifier, ConferenceState>((ref) {
  return ConferenceNotifier();
});
