import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../shared/providers/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final settings = ref.watch(settingsStreamProvider).valueOrNull;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Ayarlar',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),

            // Hesap
            _SectionHeader(title: 'Hesap'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (user?.photoURL != null)
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(user!.photoURL!),
                      )
                    else
                      const CircleAvatar(
                        radius: 24,
                        child: Icon(Icons.person),
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.displayName ?? 'Kullanıcı',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            user?.email ?? '',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => _signOut(context, ref),
                      child: const Text('Çıkış',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Senkronizasyon
            _SectionHeader(title: 'Senkronizasyon'),
            _SettingsTile(
              icon: Icons.sync,
              title: 'Senkron durumu',
              subtitle: 'Otomatik senkronizasyon aktif',
              trailing: Icon(Icons.check_circle,
                  color: AppColors.success, size: 20),
            ),
            _SettingsTile(
              icon: Icons.backup,
              title: 'Son yedekleme',
              subtitle: settings?.lastBackupAt != null
                  ? AppDateUtils.formatDateTime(settings!.lastBackupAt!)
                  : 'Henüz yedekleme yapılmadı',
            ),
            const SizedBox(height: 20),

            // Google Export/Import
            _SectionHeader(title: 'Google Veri Yönetimi'),
            _SettingsTile(
              icon: Icons.table_chart,
              title: 'Google Sheets Export',
              subtitle: 'Tüm verileri Sheets\'e aktar',
              trailing: const Icon(Icons.upload, size: 20),
              onTap: () => _exportToSheets(context, ref),
            ),
            _SettingsTile(
              icon: Icons.table_chart_outlined,
              title: 'Google Sheets Import',
              subtitle: 'Sheets\'ten verileri al',
              trailing: const Icon(Icons.download, size: 20),
              onTap: () => _importFromSheets(context, ref),
            ),
            _SettingsTile(
              icon: Icons.drive_folder_upload,
              title: 'Google Drive Export',
              subtitle: 'JSON yedekleme Drive\'a aktar',
              trailing: const Icon(Icons.upload, size: 20),
              onTap: () => _exportToDrive(context, ref),
            ),
            _SettingsTile(
              icon: Icons.cloud_download,
              title: 'Google Drive Import',
              subtitle: 'Drive\'dan yedeği geri yükle',
              trailing: const Icon(Icons.download, size: 20),
              onTap: () => _importFromDrive(context, ref),
            ),
            const SizedBox(height: 20),

            // Bildirimler
            _SectionHeader(title: 'Bildirimler'),
            _SettingsTile(
              icon: Icons.notifications,
              title: 'Bildirim izinleri',
              subtitle: 'Bildirim ayarlarını yönet',
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => _manageNotifications(context),
            ),
            const SizedBox(height: 20),

            // Görünüm
            _SectionHeader(title: 'Görünüm'),
            _SettingsTile(
              icon: Icons.palette,
              title: 'Tema',
              subtitle: _themeLabel(settings?.themeMode ?? 'system'),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => _showThemePicker(context, ref),
            ),
            _SettingsTile(
              icon: Icons.language,
              title: 'Dil',
              subtitle: 'Türkçe',
              trailing: const Icon(Icons.chevron_right, size: 20),
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'Notlarım v1.0.0',
                style: TextStyle(
                  color: AppColors.textDisabled,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _themeLabel(String mode) {
    switch (mode) {
      case 'light':
        return 'Açık';
      case 'dark':
        return 'Koyu';
      default:
        return 'Sistem';
    }
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Çıkış yapmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('İptal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text('Çıkış', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(authRepositoryProvider).signOut();
      if (context.mounted) context.go('/login');
    }
  }

  void _showThemePicker(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Tema Seçin'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              _updateTheme(ref, 'system');
              Navigator.pop(ctx);
            },
            child: const Text('Sistem'),
          ),
          SimpleDialogOption(
            onPressed: () {
              _updateTheme(ref, 'light');
              Navigator.pop(ctx);
            },
            child: const Text('Açık'),
          ),
          SimpleDialogOption(
            onPressed: () {
              _updateTheme(ref, 'dark');
              Navigator.pop(ctx);
            },
            child: const Text('Koyu'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateTheme(WidgetRef ref, String mode) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    final current =
        ref.read(settingsStreamProvider).valueOrNull;
    if (current == null) return;
    await ref
        .read(settingsRepositoryProvider)
        .updateSettings(uid, current.copyWith(themeMode: mode));
  }

  void _exportToSheets(BuildContext context, WidgetRef ref) {
    // TODO: Google Sheets export Cloud Function çağrısı
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content:
              Text('Sheets export Cloud Functions kurulumu ile aktif olacak')),
    );
  }

  void _importFromSheets(BuildContext context, WidgetRef ref) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content:
              Text('Sheets import Cloud Functions kurulumu ile aktif olacak')),
    );
  }

  void _exportToDrive(BuildContext context, WidgetRef ref) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content:
              Text('Drive export Cloud Functions kurulumu ile aktif olacak')),
    );
  }

  void _importFromDrive(BuildContext context, WidgetRef ref) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content:
              Text('Drive import Cloud Functions kurulumu ile aktif olacak')),
    );
  }

  void _manageNotifications(BuildContext context) {
    // TODO: Bildirim ayarları sayfasına yönlendir
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bildirim ayarları açılıyor...')),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, size: 22, color: AppColors.primary),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w500, fontSize: 14)),
        subtitle:
            Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: trailing,
      ),
    );
  }
}
