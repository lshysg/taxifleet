// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/driver.dart';
import '../../providers/drivers_provider.dart';

class DriversScreen extends StatefulWidget {
  const DriversScreen({super.key});

  @override
  State<DriversScreen> createState() => _DriversScreenState();
}

class _DriversScreenState extends State<DriversScreen> {
  String? _filterStatus;

  static const _statuses = ['FREE', 'BUSY', 'UNAVAILABLE'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<DriversProvider>().loadDrivers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DriversProvider>(
      builder: (context, provider, _) {
        final filtered = _filterStatus == null
            ? provider.drivers
            : provider.drivers
                .where((d) => d.status == _filterStatus)
                .toList();

        return Column(
          children: [
            // Filter chips
            SizedBox(
              height: 56,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _StatusChip(
                    label: 'Все',
                    selected: _filterStatus == null,
                    color: Theme.of(context).colorScheme.primary,
                    onSelected: () => setState(() => _filterStatus = null),
                  ),
                  const SizedBox(width: 8),
                  ..._statuses.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _StatusChip(
                        label: AppTheme.statusLabel(s),
                        selected: _filterStatus == s,
                        color: AppTheme.statusBadgeColor(s),
                        onSelected: () => setState(() => _filterStatus = s),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Content
            if (provider.isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.error != null)
              Expanded(child: _ErrorState(provider.error!, provider.loadDrivers))
            else if (filtered.isEmpty)
              const Expanded(
                child: _EmptyState(
                  icon: Icons.people_outline,
                  message: 'Водители не найдены',
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: provider.loadDrivers,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _DriverCard(driver: filtered[i]),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _DriverCard extends StatelessWidget {
  final Driver driver;
  const _DriverCard({required this.driver});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.statusBadgeColor(driver.status);
    final initials = driver.fullName.isNotEmpty
        ? driver.fullName[0].toUpperCase()
        : '?';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color.withOpacity(0.15),
                child: Text(
                  initials,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      driver.phone,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Удост.: ${driver.licenseNumber}',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(status: driver.status),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _DriverDetailSheet(driver: driver),
    );
  }
}

class _DriverDetailSheet extends StatelessWidget {
  final Driver driver;
  const _DriverDetailSheet({required this.driver});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.statusBadgeColor(driver.status);
    final initials = driver.fullName.isNotEmpty
        ? driver.fullName[0].toUpperCase()
        : '?';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Avatar + name
          CircleAvatar(
            radius: 36,
            backgroundColor: color.withOpacity(0.15),
            child: Text(
              initials,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            driver.fullName,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          _StatusBadge(status: driver.status),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 8),
          _DetailRow(icon: Icons.phone_outlined, label: 'Телефон', value: driver.phone),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.badge_outlined,
            label: 'Удостоверение',
            value: driver.licenseNumber,
          ),
          if (driver.hiredAt != null && driver.hiredAt!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.calendar_today_outlined,
              label: 'Принят на работу',
              value: driver.hiredAt!,
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade500),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onSelected;

  const _StatusChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      selectedColor: color.withOpacity(0.2),
      checkmarkColor: color,
      onSelected: (_) => onSelected(),
      labelStyle: TextStyle(
        color: selected ? color : null,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.statusBadgeColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        AppTheme.statusLabel(status),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState(this.message, this.onRetry);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 56, color: Colors.red.shade300),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 20),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
