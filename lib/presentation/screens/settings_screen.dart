import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';
import '../../data/services/secure_key_store.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SecureKeyStore _keyStore = SecureKeyStore();
  final TextEditingController _keyController = TextEditingController();
  String? _savedKey;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadKey();
  }

  Future<void> _loadKey() async {
    final key = await _keyStore.getOpenAiKey();
    setState(() {
      _savedKey = key;
      _loading = false;
    });
  }

  Future<void> _saveKey() async {
    final value = _keyController.text.trim();
    if (value.isEmpty) return;
    await _keyStore.setOpenAiKey(value);
    _keyController.clear();
    await _loadKey();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API key saved.')),
      );
    }
  }

  Future<void> _clearKey() async {
    await _keyStore.clearOpenAiKey();
    await _loadKey();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API key cleared.')),
      );
    }
  }

  String _maskedPreview(String key) {
    if (key.length <= 6) return '${key.substring(0, 1)}***';
    return '${key.substring(0, 3)}...${key.substring(key.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'OpenAI API Key',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Used for voice transcription (speech-to-text) when you use the '
                    'microphone. Online text translation does not require this key. '
                    'Stored securely on this device only.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: AppTheme.glassCardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _savedKey != null && _savedKey!.isNotEmpty
                                  ? Icons.check_circle_outline
                                  : Icons.error_outline,
                              color: _savedKey != null && _savedKey!.isNotEmpty
                                  ? AppTheme.success
                                  : AppTheme.textSecondary,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _savedKey != null && _savedKey!.isNotEmpty
                                  ? 'Key configured: ${_maskedPreview(_savedKey!)}'
                                  : 'No key set',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textPrimary,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.primary.withOpacity(0.12)),
                          ),
                          child: TextField(
                            controller: _keyController,
                            obscureText: true,
                            style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'sk-...',
                              hintStyle: GoogleFonts.inter(color: Colors.white24, fontSize: 13),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: AppTheme.background,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: _saveKey,
                                child: Text('Save', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextButton(
                                onPressed: _clearKey,
                                child: Text(
                                  'Clear Key',
                                  style: GoogleFonts.outfit(color: AppTheme.error),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
