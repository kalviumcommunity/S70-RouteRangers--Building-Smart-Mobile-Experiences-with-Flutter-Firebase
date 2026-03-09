import 'package:flutter/material.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _locationSharing = true;
  bool _publicProfile = false;
  bool _isLoading = false;

  Future<void> _savePrivacy() async {
    setState(() => _isLoading = true);
    
    // Simulate saving these preferences to backend/Firestore
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Privacy settings updated!'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F3),
      appBar: AppBar(
        title: const Text('Privacy & Safety'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Data Control', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Share Location Data', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Allow RouteHive to collect anonymous path data to improve map safety.', style: TextStyle(fontSize: 12)),
                    value: _locationSharing,
                    activeColor: const Color(0xFFFFC107),
                    onChanged: (val) {
                      setState(() => _locationSharing = val);
                      _savePrivacy();
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Public Profile', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Let others see your saved routes and achievements.', style: TextStyle(fontSize: 12)),
                    value: _publicProfile,
                    activeColor: const Color(0xFFFFC107),
                    onChanged: (val) {
                      setState(() => _publicProfile = val);
                      _savePrivacy();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Safety Features', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: ListTile(
                leading: const Icon(Icons.emergency_rounded, color: Colors.red),
                title: const Text('Emergency Contacts', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Manage your emergency SOS contacts.'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Emergency Contacts functionality coming soon.')));
                },
              ),
            ),
            if (_isLoading)
               const Padding(
                 padding: EdgeInsets.only(top: 24),
                 child: Center(child: CircularProgressIndicator(color: Color(0xFFFFC107))),
               ),
          ],
        ),
      ),
    );
  }
}
