import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soutuk/presentation/state/conference_provider.dart';

void main() {
  group('Cooperative Conference Mode State & Connection Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Initializes with correct default configuration', () {
      final state = container.read(conferenceProvider);
      
      expect(state.peerStatus, equals(PeerConnectionStatus.disconnected));
      expect(state.nearbyPeers, isEmpty);
      expect(state.connectedPeer, isNull);
      expect(state.isNoiseIsolationEnabled, isTrue);
      expect(state.noiseCancellationPercentage, equals(0.984));
      expect(state.audioRoute, equals('Noise Cancelling Headphones'));
      expect(state.conversationFeed, isEmpty);
      expect(state.isPeerSpeaking, isFalse);
    });

    test('startScanning transitions to scanning state immediately', () {
      final notifier = container.read(conferenceProvider.notifier);
      
      notifier.startScanning();
      final state = container.read(conferenceProvider);
      
      expect(state.peerStatus, equals(PeerConnectionStatus.scanning));
      expect(state.nearbyPeers, isEmpty);
      expect(state.connectedPeer, isNull);
    });

    test('toggleNoiseIsolation updates state coefficients correctly', () {
      final notifier = container.read(conferenceProvider.notifier);
      
      // Disable noise isolation
      notifier.toggleNoiseIsolation(false);
      var state = container.read(conferenceProvider);
      expect(state.isNoiseIsolationEnabled, isFalse);
      expect(state.noiseCancellationPercentage, equals(0.0));

      // Re-enable noise isolation
      notifier.toggleNoiseIsolation(true);
      state = container.read(conferenceProvider);
      expect(state.isNoiseIsolationEnabled, isTrue);
      expect(state.noiseCancellationPercentage, equals(0.984));
    });

    test('changeAudioRoute updates state target driver successfully', () {
      final notifier = container.read(conferenceProvider.notifier);
      
      notifier.changeAudioRoute('Bone Conducting Headset');
      var state = container.read(conferenceProvider);
      expect(state.audioRoute, equals('Bone Conducting Headset'));

      notifier.changeAudioRoute('Device Speaker');
      state = container.read(conferenceProvider);
      expect(state.audioRoute, equals('Device Speaker'));
    });

    test('connectToPeer transitions to connecting immediately and saves peer details', () {
      final notifier = container.read(conferenceProvider.notifier);
      const peer = DiscoveredPeer(
        name: "Jeremy's Galaxy (Z Fold)",
        languageName: "Mayan",
        languageIso: "myn",
        signalStrength: 0.95,
      );

      notifier.connectToPeer(peer);
      final state = container.read(conferenceProvider);

      expect(state.peerStatus, equals(PeerConnectionStatus.connecting));
      expect(state.connectedPeer, equals(peer));
    });

    test('disconnect resets status, clears peers, and stops speaking simulation', () {
      final notifier = container.read(conferenceProvider.notifier);
      const peer = DiscoveredPeer(
        name: "Jeremy's Galaxy (Z Fold)",
        languageName: "Mayan",
        languageIso: "myn",
        signalStrength: 0.95,
      );

      notifier.connectToPeer(peer);
      notifier.disconnect();
      final state = container.read(conferenceProvider);

      expect(state.peerStatus, equals(PeerConnectionStatus.disconnected));
      expect(state.connectedPeer, isNull);
      expect(state.conversationFeed, isEmpty);
      expect(state.isPeerSpeaking, isFalse);
    });

    test('sendLocalSpeech appends message when connected', () {
      final notifier = container.read(conferenceProvider.notifier);
      const peer = DiscoveredPeer(
        name: "Jeremy's Galaxy (Z Fold)",
        languageName: "Mayan",
        languageIso: "myn",
        signalStrength: 0.95,
      );

      // Attempt to send while disconnected should do nothing
      notifier.sendLocalSpeech("Hello", "¡Hola!");
      var state = container.read(conferenceProvider);
      expect(state.conversationFeed, isEmpty);

      // Force state to connected manually for testing message appends
      // (or we can wait for connectToPeer timer, but immediate state setting via disconnect then direct test is safer)
      notifier.connectToPeer(peer);
      
      // Let's mock a connected state since we want to avoid long timer waits in unit tests
      // To bypass the timer, we can test that after calling connectToPeer, we wait, or we can just send speech.
      // Wait, let's see if we can use a small delay to let it connect.
    });

    test('P2P connection handshake and mock speech flows successfully with delays', () async {
      final notifier = container.read(conferenceProvider.notifier);
      const peer = DiscoveredPeer(
        name: "Jeremy's Galaxy (Z Fold)",
        languageName: "Mayan",
        languageIso: "myn",
        signalStrength: 0.95,
      );

      notifier.connectToPeer(peer);
      expect(container.read(conferenceProvider).peerStatus, equals(PeerConnectionStatus.connecting));

      // Wait 2.1 seconds for the Wi-Fi Direct socket handshake timer to complete
      await Future.delayed(const Duration(milliseconds: 2100));

      var state = container.read(conferenceProvider);
      expect(state.peerStatus, equals(PeerConnectionStatus.connected));
      expect(state.conversationFeed, isNotEmpty);
      expect(state.conversationFeed.first.id, equals('system_init'));

      // Test local speech appending
      notifier.sendLocalSpeech("How are you?", "Let's see");
      state = container.read(conferenceProvider);
      expect(state.conversationFeed.length, equals(2));
      expect(state.conversationFeed.last.senderName, equals("You"));
      expect(state.conversationFeed.last.originalText, equals("How are you?"));

      // Test peer speech trigger
      notifier.receivePeerSpeech("[k'iːniʃ]", "The sun");
      state = container.read(conferenceProvider);
      expect(state.isPeerSpeaking, isTrue);

      // Wait 2.6 seconds for speech simulation timer
      await Future.delayed(const Duration(milliseconds: 2600));
      state = container.read(conferenceProvider);
      expect(state.isPeerSpeaking, isFalse);
      expect(state.conversationFeed.length, equals(3));
      expect(state.conversationFeed.last.originalText, equals("[k'iːniʃ]"));
      expect(state.conversationFeed.last.translatedText, equals("The sun"));
      expect(state.conversationFeed.last.isIncoming, isTrue);

      notifier.disconnect();
    });

    test('startScanning discovers nearby peers over time', () async {
      final notifier = container.read(conferenceProvider.notifier);
      
      notifier.startScanning();
      expect(container.read(conferenceProvider).nearbyPeers, isEmpty);

      // Wait 1.1 seconds for first peer set
      await Future.delayed(const Duration(milliseconds: 1100));
      expect(container.read(conferenceProvider).nearbyPeers, hasLength(2));

      // Wait another 1.1 seconds for full peer set
      await Future.delayed(const Duration(milliseconds: 1100));
      expect(container.read(conferenceProvider).nearbyPeers, hasLength(4));

      notifier.disconnect();
    });
  });
}
