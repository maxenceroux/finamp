import 'package:flutter/material.dart';
import 'package:finamp/l10n/app_localizations.dart';

import '../services/finamp_settings_helper.dart';
import '../services/slskd_api.dart';
import '../components/error_snackbar.dart';

class SlskdSettingsScreen extends StatefulWidget {
  const SlskdSettingsScreen({Key? key}) : super(key: key);

  static const routeName = '/settings/slskd';

  @override
  State<SlskdSettingsScreen> createState() => _SlskdSettingsScreenState();
}

class _SlskdSettingsScreenState extends State<SlskdSettingsScreen> {
  late TextEditingController _hostController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    final settings = FinampSettingsHelper.finampSettings;
    _hostController = TextEditingController(text: settings.slskdHost);
    _usernameController = TextEditingController(text: settings.slskdUsername);
    _passwordController = TextEditingController(text: settings.slskdPassword);
  }

  @override
  void dispose() {
    _hostController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
    });

    try {
      // Save current values temporarily
      final config = SlskdConfig(
        baseUrl: _hostController.text,
        username: _usernameController.text,
        password: _passwordController.text,
      );

      final helper = SlskdApiHelper(config: config);
      final success = await helper.testAuthentication();

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.connectionSuccessful),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.connectionFailed),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        errorSnackbar(e, context);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTesting = false;
        });
      }
    }
  }

  void _saveSettings() {
    FinampSettingsHelper.setSlskdHost(_hostController.text);
    FinampSettingsHelper.setSlskdUsername(_usernameController.text);
    FinampSettingsHelper.setSlskdPassword(_passwordController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.settingsSaved),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('slskd Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Configure your slskd server connection',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _hostController,
              decoration: const InputDecoration(
                labelText: 'Host',
                hintText: 'http://192.168.1.100:5030',
                border: OutlineInputBorder(),
                helperText: 'Full URL including port',
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isTesting ? null : _testConnection,
                    icon: _isTesting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.wifi_protected_setup),
                    label: Text(_isTesting ? 'Testing...' : 'Test Connection'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveSettings,
                    icon: const Icon(Icons.save),
                    label: const Text('Save'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'About slskd',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'slskd is a web-based client for the Soulseek network. '
                      'Configure your connection above to view downloads and searches '
                      'in the Downloads and Searches tabs.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
