// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/driver.dart';
import '../../providers/drivers_provider.dart';
import '../../providers/orders_provider.dart';

class AssignDriverScreen extends StatefulWidget {
  final int orderId;

  const AssignDriverScreen({super.key, required this.orderId});

  @override
  State<AssignDriverScreen> createState() => _AssignDriverScreenState();
}

class _AssignDriverScreenState extends State<AssignDriverScreen> {
  int? _selectedDriverId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriversProvider>().loadFreeDrivers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Назначить • Заказ #${widget.orderId}'),
        leading: const BackButton(),
      ),
      body: Consumer<DriversProvider>(
        builder: (context, driversProvider, _) {
          if (driversProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (driversProvider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 56, color: Colors.red.shade300),
                    const SizedBox(height: 12),
                    Text(driversProvider.error!,
                        textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    FilledButton.tonal(
                      onPressed: driversProvider.loadFreeDrivers,
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (driversProvider.freeDrivers.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Нет свободных водителей',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Все водители заняты или недоступны',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  'Свободные водители (${driversProvider.freeDrivers.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: driversProvider.freeDrivers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final driver = driversProvider.freeDrivers[i];
                    return _DriverSelectCard(
                      driver: driver,
                      isSelected: _selectedDriverId == driver.id,
                      onTap: () =>
                          setState(() => _selectedDriverId = driver.id),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Consumer<OrdersProvider>(
                  builder: (context, ordersProvider, _) {
                    return FilledButton(
                      onPressed: _selectedDriverId == null ||
                              ordersProvider.isLoading
                          ? null
                          : () => _assign(context, ordersProvider),
                      child: ordersProvider.isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _selectedDriverId != null
                                  ? 'Назначить выбранного водителя'
                                  : 'Выберите водителя',
                              style: const TextStyle(fontSize: 15),
                            ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _assign(BuildContext context, OrdersProvider provider) async {
    if (_selectedDriverId == null) return;

    final ok = await provider.assignDriver(widget.orderId, _selectedDriverId!);
    final errorMsg = provider.error;

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(
          content: Text('Водитель успешно назначен'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      this.context.pop(true);
    } else {
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text(errorMsg ?? 'Ошибка назначения'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _DriverSelectCard extends StatelessWidget {
  final Driver driver;
  final bool isSelected;
  final VoidCallback onTap;

  const _DriverSelectCard({
    required this.driver,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      color: isSelected ? colorScheme.primaryContainer : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.green.withOpacity(0.15),
                child: Text(
                  driver.fullName.isNotEmpty
                      ? driver.fullName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: isSelected ? colorScheme.onPrimaryContainer : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      driver.phone,
                      style: TextStyle(
                        fontSize: 13,
                        color: isSelected
                            ? colorScheme.onPrimaryContainer.withOpacity(0.7)
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: colorScheme.primary,
                  size: 24,
                )
              else
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
