import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/app/theme/app_colors.dart';
import 'package:tapto/features/admin/presentation/providers/admin_order_provider.dart';
import 'package:tapto/features/orders/data/models/order_model.dart';
import 'package:tapto/features/admin/presentation/providers/driver_provider.dart';
import 'package:tapto/core/utils/currency_formatter.dart';
import 'package:intl/intl.dart';

class ManageOrdersScreen extends ConsumerStatefulWidget {
  const ManageOrdersScreen({super.key});

  @override
  ConsumerState<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends ConsumerState<ManageOrdersScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';

  final List<String> _statusFilters = [
    'All',
    'Pending',
    'Confirmed',
    'Processing',
    'Shipped',
    'Out for Delivery',
    'Delivered',
    'Cancelled',
  ];

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(adminOrdersProvider);
    final currencyFormatter = ref.watch(currencyFormatterProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Manage Orders',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: () => ref.invalidate(adminOrdersProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search orders by ID or customer...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
                const SizedBox(height: 12),
                // Filter Chips
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _statusFilters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final filter = _statusFilters[index];
                      return _FilterChip(
                        label: filter,
                        isSelected: _selectedFilter == filter,
                        onTap: () => setState(() => _selectedFilter = filter),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Orders List
          Expanded(
            child: ordersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load orders',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(error.toString()),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => ref.invalidate(adminOrdersProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (orders) {
                final filteredOrders = _filterOrders(orders);

                if (filteredOrders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No orders found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return _OrderCard(
                      order: order,
                      onUpdateStatus: () => _showUpdateStatusDialog(order),
                      onViewDetails: () => _showOrderDetails(order),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<OrderModel> _filterOrders(List<OrderModel> orders) {
    return orders.where((order) {
      // Filter by status
      if (_selectedFilter != 'All') {
        final statusMatch =
            order.status.name.toLowerCase() ==
            _selectedFilter.toLowerCase().replaceAll(' ', '');
        if (!statusMatch) return false;
      }

      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesId = order.id.toLowerCase().contains(query);
        final matchesCustomer = order.shippingAddress.fullName
            .toLowerCase()
            .contains(query);
        if (!matchesId && !matchesCustomer) return false;
      }

      return true;
    }).toList();
  }

  void _showUpdateStatusDialog(OrderModel order) {
    String selectedStatus = order.status.name;
    String? selectedDriverId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Update Order Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Order #${order.id.substring(order.id.length - 8)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              ...[
                'PENDING',
                'CONFIRMED',
                'PROCESSING',
                'SHIPPED',
                'OUTFORDELIVERY',
                'DELIVERED',
                'CANCELLED',
                'REFUNDED',
              ].map((status) {
                return RadioListTile<String>(
                  title: Text(_formatStatusLabel(status)),
                  value: status,
                  groupValue: selectedStatus,
                  onChanged: (value) {
                    setDialogState(() => selectedStatus = value!);
                  },
                );
              }),
              if (_isOutForDelivery(selectedStatus)) ...[
                const SizedBox(height: 16),
                Consumer(
                  builder: (context, ref, _) {
                    final driversAsync = ref.watch(driversProvider);
                    return driversAsync.when(
                      loading: () => const CircularProgressIndicator(),
                      error: (e, _) => Text('Failed to load drivers'),
                      data: (drivers) => DropdownButtonFormField<String>(
                        initialValue: selectedDriverId,
                        hint: const Text('Select Delivery Driver'),
                        items: drivers.map<DropdownMenuItem<String>>((driver) {
                          return DropdownMenuItem(
                            value: driver.id,
                            child: Text('${driver.name} (${driver.vehicleNumber})'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() => selectedDriverId = value);
                        },
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedStatus.toLowerCase() == 'outfordelivery' && (selectedDriverId == null || selectedDriverId!.isEmpty)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a delivery driver.')),
                  );
                  return;
                }
                Navigator.pop(context);
                bool success = false;
                if (selectedStatus.toLowerCase() == 'outfordelivery') {
                  // Assign driver first
                  try {
                    final driverDataSource = ref.read(driverRemoteDataSourceProvider);
                    await driverDataSource.assignDriverToOrder(order.id, selectedDriverId!);
                    // Then update status
                    success = await ref.read(adminOrderOperationProvider.notifier).updateOrderStatus(order.id, selectedStatus);
                  } catch (e) {
                    success = false;
                  }
                } else {
                  success = await ref.read(adminOrderOperationProvider.notifier).updateOrderStatus(order.id, selectedStatus);
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Order status updated successfully!'
                            : 'Failed to update order status',
                      ),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  bool _isOutForDelivery(String status) {
    final normalized = status.replaceAll(RegExp(r'[^a-zA-Z]'), '').toLowerCase();
    return normalized == 'outfordelivery';
  }

  String _formatStatusLabel(String status) {
    final normalized = status.replaceAll(RegExp(r'[^a-zA-Z]'), '').toLowerCase();
    if (normalized == 'outfordelivery') return 'Out for Delivery';
    if (normalized == 'cancelled') return 'Cancelled';
    if (normalized == 'refunded') return 'Refunded';
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }

  void _showOrderDetails(OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Order Details',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailSection(
                      title: 'Order Information',
                      children: [
                        _DetailRow('Order ID', order.id),
                        _DetailRow('Status', order.status.name.toUpperCase()),
                        _DetailRow(
                          'Date',
                          DateFormat(
                            'MMM dd, yyyy HH:mm',
                          ).format(order.createdAt),
                        ),
                        _DetailRow(
                          'Total',
                          '\$${order.total.toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _DetailSection(
                      title: 'Customer Details',
                      children: [
                        _DetailRow('Name', order.shippingAddress.fullName),
                        _DetailRow('Phone', order.shippingAddress.phone),
                        _DetailRow(
                          'Address',
                          '${order.shippingAddress.street}, ${order.shippingAddress.city}, ${order.shippingAddress.state} ${order.shippingAddress.zipCode}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _DetailSection(
                      title: 'Items (${order.items.length})',
                      children: order.items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.shopping_bag_outlined),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Qty: ${item.quantity} • \$${item.price.toStringAsFixed(2)} each',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'x${item.quantity}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    _DetailSection(
                      title: 'Payment Summary',
                      children: [
                        _DetailRow(
                          'Subtotal',
                          '\$${order.subtotal.toStringAsFixed(2)}',
                        ),
                        _DetailRow(
                          'Shipping',
                          '\$${order.shippingFee.toStringAsFixed(2)}',
                        ),
                        _DetailRow('Tax', '\$${order.tax.toStringAsFixed(2)}'),
                        const Divider(),
                        _DetailRow(
                          'Total',
                          '\$${order.total.toStringAsFixed(2)}',
                          isBold: true,
                        ),
                      ],
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onUpdateStatus;
  final VoidCallback onViewDetails;

  const _OrderCard({
    required this.order,
    required this.onUpdateStatus,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${order.id.length > 8 ? order.id.substring(order.id.length - 8) : order.id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat(
                          'MMM dd, yyyy HH:mm',
                        ).format(order.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: order.status.name),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    order.shippingAddress.fullName.isNotEmpty
                        ? order.shippingAddress.fullName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.shippingAddress.fullName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${order.items.length} item(s) • \$${order.total.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onViewDetails,
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('View Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onUpdateStatus,
                    icon: const Icon(Icons.update, size: 18),
                    label: const Text('Update Status'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'confirmed':
        color = Colors.blue;
        break;
      case 'processing':
        color = Colors.purple;
        break;
      case 'shipped':
        color = Colors.indigo;
        break;
      case 'outfordelivery':
        color = Colors.teal;
        break;
      case 'delivered':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    String displayStatus = status;
    if (status.toLowerCase() == 'outfordelivery') {
      displayStatus = 'Out for Delivery';
    } else {
      displayStatus = status[0].toUpperCase() + status.substring(1);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        displayStatus,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DetailSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _DetailRow(this.label, this.value, {this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
