import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapto/app/theme/app_colors.dart';
import 'package:tapto/features/addresses/domain/entities/address_entity.dart';
import 'package:tapto/features/addresses/presentation/viewmodel/address_viewmodel.dart';

class AddressesScreen extends ConsumerStatefulWidget {
  const AddressesScreen({super.key});

  @override
  ConsumerState<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends ConsumerState<AddressesScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final addressState = ref.watch(addressViewModelProvider);

    // Load addresses if not loaded yet
    if (addressState.addresses.isEmpty && !addressState.isLoading) {
      Future.microtask(() {
        ref.read(addressViewModelProvider.notifier).loadUserAddresses();
      });
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Addresses'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddAddressModal(context),
            tooltip: 'Add new address',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: addressState.isLoading && addressState.addresses.isEmpty
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : addressState.addresses.isEmpty
                ? _buildEmptyState()
                : _buildAddressesList(addressState),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_on_outlined,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No addresses yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first shipping address to get started',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showAddAddressModal(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Address'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressesList(AddressState addressState) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(addressViewModelProvider.notifier).loadUserAddresses();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: addressState.addresses.length + (addressState.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == addressState.addresses.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            );
          }

          final address = addressState.addresses[index];
          return _AddressCard(
            address: address,
            onEdit: () => _showEditAddressModal(context, address),
            onDelete: () => _showDeleteConfirmation(context, address),
            onSetDefault: address.isDefault ? null : () => _setDefaultAddress(address.id),
          );
        },
      ),
    );
  }

  void _showAddAddressModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddressModal(ref: ref),
    ).then((result) {
      if (result == true) {
        // Address was added, refresh the list
        ref.read(addressViewModelProvider.notifier).loadUserAddresses();
      }
    });
  }

  void _showEditAddressModal(BuildContext context, AddressEntity address) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddressModal(address: address, ref: ref),
    ).then((result) {
      if (result == true) {
        // Address was updated, refresh the list
        ref.read(addressViewModelProvider.notifier).loadUserAddresses();
      }
    });
  }

  void _showDeleteConfirmation(BuildContext context, AddressEntity address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: Text('Are you sure you want to delete the address "${address.shortAddress}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(addressViewModelProvider.notifier).deleteAddress(address.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _setDefaultAddress(String addressId) async {
    HapticFeedback.mediumImpact();
    await ref.read(addressViewModelProvider.notifier).setDefaultAddress(addressId);
  }
}

class _AddressCard extends StatelessWidget {
  final AddressEntity address;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSetDefault;

  const _AddressCard({
    required this.address,
    this.onEdit,
    this.onDelete,
    this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    address.fullName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (address.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Default',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              address.toString(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (onSetDefault != null)
                  TextButton.icon(
                    onPressed: onSetDefault,
                    icon: const Icon(Icons.star_border, size: 16),
                    label: const Text('Set as Default'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      textStyle: const TextStyle(fontSize: 14),
                    ),
                  ),
                const Spacer(),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  color: Colors.grey[600],
                  tooltip: 'Edit address',
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: Colors.red[400],
                  tooltip: 'Delete address',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressModal extends StatefulWidget {
  final AddressEntity? address;
  final WidgetRef ref;

  const _AddressModal({ this.address, required this.ref});

  @override
  State<_AddressModal> createState() => _AddressModalState();
}

class _AddressModalState extends State<_AddressModal> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _countryController = TextEditingController();
  bool _isDefault = false;
  bool _isLoading = false;

  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    ));
    _scaleController.forward();

    // Pre-fill form if editing
    if (widget.address != null) {
      final addr = widget.address!;
      _fullNameController.text = addr.fullName;
      _phoneController.text = addr.phone;
      _streetController.text = addr.street;
      _cityController.text = addr.city;
      _stateController.text = addr.state ?? '';
      _zipController.text = addr.zipCode;
      _countryController.text = addr.country;
      _isDefault = addr.isDefault;
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final viewModel = widget.ref.read(addressViewModelProvider.notifier);

      if (widget.address != null) {
        // Update existing address
        await viewModel.updateAddress(
          addressId: widget.address!.id,
          fullName: _fullNameController.text.trim(),
          phone: _phoneController.text.trim(),
          street: _streetController.text.trim(),
          city: _cityController.text.trim(),
          zipCode: _zipController.text.trim(),
          country: _countryController.text.trim(),
          isDefault: _isDefault,
        );
      } else {
        // Create new address
        await viewModel.createAddress(
          fullName: _fullNameController.text.trim(),
          phone: _phoneController.text.trim(),
          street: _streetController.text.trim(),
          city: _cityController.text.trim(),
          zipCode: _zipController.text.trim(),
          addressState: _stateController.text.trim(),
          country: _countryController.text.trim(),
          isDefault: _isDefault,
        );
      }

      Navigator.pop(context, true);
      HapticFeedback.mediumImpact();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save address: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.address != null ? 'Edit Address' : 'Add New Address',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AddressField(
                          icon: Icons.person_outline,
                          label: 'Full Name',
                          controller: _fullNameController,
                          hint: 'Enter your full name',
                        ),
                        const SizedBox(height: 16),
                        _AddressField(
                          icon: Icons.phone_outlined,
                          label: 'Phone Number',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          hint: '+977 98XXXXXXXX',
                        ),
                        const SizedBox(height: 16),
                        _AddressField(
                          icon: Icons.home_outlined,
                          label: 'Street Address',
                          controller: _streetController,
                          hint: 'House number and street',
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _AddressField(
                                icon: Icons.location_city_outlined,
                                label: 'City',
                                controller: _cityController,
                                hint: 'City',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _AddressField(
                                icon: Icons.map_outlined,
                                label: 'State',
                                controller: _stateController,
                                hint: 'State (optional)',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _AddressField(
                                icon: Icons.local_post_office_outlined,
                                label: 'ZIP Code',
                                controller: _zipController,
                                keyboardType: TextInputType.number,
                                hint: '44600',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _AddressField(
                                icon: Icons.flag_outlined,
                                label: 'Country',
                                controller: _countryController,
                                hint: 'Nepal',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        CheckboxListTile(
                          value: _isDefault,
                          onChanged: (value) => setState(() => _isDefault = value ?? false),
                          title: const Text('Set as default address'),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(widget.address != null ? Icons.save : Icons.check_circle_outline, size: 22),
                                      const SizedBox(width: 8),
                                      Text(
                                        widget.address != null ? 'Update Address' : 'Save Address',
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddressField extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? hint;

  const _AddressField({
    required this.icon,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (v) => v == null || v.trim().isEmpty ? 'This field is required' : null,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }
}