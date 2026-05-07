// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/order.dart';
import '../../providers/orders_provider.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().loadOrder(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrdersProvider>(
      builder: (context, provider, _) {
        final order = provider.selectedOrder;
        final isCurrentOrder = order?.id == widget.orderId;

        return Scaffold(
          appBar: AppBar(
            title: Text('Заказ #${widget.orderId}'),
            leading: const BackButton(),
          ),
          body: provider.isLoading && !isCurrentOrder
              ? const Center(child: CircularProgressIndicator())
              : order == null || !isCurrentOrder
                  ? const Center(child: Text('Заказ не найден'))
                  : _OrderDetailBody(
                      order: order,
                      isLoading: provider.isLoading,
                      onAssign: () => _navigateToAssign(context, provider),
                      onCancel: () => _cancelOrder(context, provider, order),
                      onComplete: () =>
                          _completeOrder(context, provider, order),
                    ),
        );
      },
    );
  }

  Future<void> _navigateToAssign(
    BuildContext context,
    OrdersProvider provider,
  ) async {
    final success =
        await context.push<bool>('/orders/${widget.orderId}/assign');
    if (success == true && mounted) {
      await provider.loadOrder(widget.orderId);
    }
  }

  Future<void> _cancelOrder(
    BuildContext context,
    OrdersProvider provider,
    Order order,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Отменить заказ?'),
        content: const Text(
          'Заказ будет отменён. Это действие нельзя отменить.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Нет'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Да, отменить'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final ok = await provider.updateStatus(widget.orderId, 'CANCELLED');
      final errMsg = provider.error;
      if (!mounted) return;
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'Заказ отменён' : (errMsg ?? 'Ошибка')),
          backgroundColor: ok ? Colors.orange : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _completeOrder(
    BuildContext context,
    OrdersProvider provider,
    Order order,
  ) async {
    final ok = await provider.updateStatus(widget.orderId, 'DONE');
    final errMsg = provider.error;
    if (!mounted) return;
    ScaffoldMessenger.of(this.context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Заказ завершён' : (errMsg ?? 'Ошибка')),
        backgroundColor: ok ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _OrderDetailBody extends StatelessWidget {
  final Order order;
  final bool isLoading;
  final VoidCallback onAssign;
  final VoidCallback onCancel;
  final VoidCallback onComplete;

  const _OrderDetailBody({
    required this.order,
    required this.isLoading,
    required this.onAssign,
    required this.onCancel,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.statusBadgeColor(order.status);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status + Cost
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withOpacity(0.4)),
                    ),
                    child: Text(
                      AppTheme.statusLabel(order.status),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (order.cost != null)
                    Text(
                      '${order.cost!.toStringAsFixed(0)} ₽',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Route
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Маршрут',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  _RouteRow(
                    icon: Icons.radio_button_checked,
                    iconColor: Colors.green,
                    label: 'Откуда',
                    value: order.addressFrom,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 2, bottom: 2),
                    child: Container(
                      height: 20,
                      width: 2,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  _RouteRow(
                    icon: Icons.location_on,
                    iconColor: Colors.red,
                    label: 'Куда',
                    value: order.addressTo,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Client
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Клиент',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.person_outline,
                    value: order.clientName,
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    value: order.clientPhone,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Date
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _InfoRow(
                icon: Icons.access_time,
                value: _formatDate(order.createdAt),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Actions
          if (order.status == 'NEW') ...[
            FilledButton.icon(
              onPressed: isLoading ? null : onAssign,
              icon: const Icon(Icons.person_add_outlined),
              label: const Text('Назначить водителя'),
            ),
            const SizedBox(height: 10),
          ],
          if (order.status == 'ASSIGNED' || order.status == 'ON_WAY') ...[
            FilledButton.icon(
              onPressed: isLoading ? null : onComplete,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Завершить заказ'),
              style:
                  FilledButton.styleFrom(backgroundColor: Colors.green.shade600),
            ),
            const SizedBox(height: 10),
          ],
          if (order.status == 'NEW' ||
              order.status == 'ASSIGNED' ||
              order.status == 'ON_WAY')
            OutlinedButton.icon(
              onPressed: isLoading ? null : onCancel,
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Отменить заказ'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(String raw) {
    if (raw.isEmpty) return '—';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return DateFormat('dd.MM.yyyy HH:mm').format(dt);
    } catch (_) {
      return raw;
    }
  }
}

class _RouteRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _RouteRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 1),
              Text(value,
                  style: const TextStyle(fontSize: 14,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String value;

  const _InfoRow({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade500),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
