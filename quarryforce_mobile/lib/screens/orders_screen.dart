import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../utils/error_handling.dart';
import '../utils/logger.dart';

/// Orders Screen - Create and manage orders with multiple items
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late ApiService _apiService;
  List<Customer> _customers = [];
  List<Order> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService.instance;
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      if (!mounted) return;

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final repId = authProvider.currentUser?.id ?? 0;

      if (repId == 0) {
        throw AppException(
          message: 'User ID not available',
          userMessage: 'Error loading user information',
        );
      }

      // Load customers and orders in parallel
      final results = await Future.wait([
        _apiService.getRepCustomers(repId),
        _apiService.getRepOrders(repId),
      ]);
      final customersData = results[0];
      final ordersData = results[1];
      final customers = customersData
          .map((c) => Customer.fromJson(c as Map<String, dynamic>))
          .toList();
      final orders = ordersData
          .map((o) => Order.fromJson(o as Map<String, dynamic>))
          .toList();

      if (mounted) {
        setState(() {
          _customers = customers;
          _orders = orders;
          _isLoading = false;
        });
      }

      AppLogger.info(
          'Loaded ${customers.length} customers and ${orders.length} orders for rep $repId');
    } on AppException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.userMessage ?? e.message;
          _isLoading = false;
        });
      }
      AppLogger.error('Failed to load orders data', e);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load data: $e';
          _isLoading = false;
        });
      }
      AppLogger.error('Unexpected error loading orders', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: _selectedTabIndex,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Orders'),
          centerTitle: true,
          elevation: 0,
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            onTap: (index) {
              setState(() {
                _selectedTabIndex = index;
              });
            },
            tabs: const [
              Tab(icon: Icon(Icons.add_circle_outline), text: 'Create Order'),
              Tab(icon: Icon(Icons.receipt_long), text: 'My Orders'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Create Order Tab
            _buildCreateOrderTab(),
            // My Orders Tab
            _buildMyOrdersTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateOrderTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    if (_customers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business_center_outlined,
                size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No customers found',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Reload'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(0),
      child: _buildCreateOrderForm(),
    );
  }

  Widget _buildCreateOrderForm() {
    return CreateOrderForm(
      customers: _customers,
      repId: Provider.of<AuthProvider>(context, listen: false).currentUser?.id,
      onOrderCreated: (order) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order created successfully!')),
        );
        _loadData();
        setState(() {
          _selectedTabIndex = 1;
        });
      },
    );
  }

  Widget _buildMyOrdersTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No orders yet',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first order in the Create Order tab',
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    Color statusColor;
    switch (order.status.toLowerCase()) {
      case 'confirmed':
        statusColor = Colors.green;
        break;
      case 'delivered':
        statusColor = Colors.blue;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _showOrderDetails(order),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id}',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      order.status.toUpperCase(),
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.business, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      order.customerName ?? 'Unknown Customer',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (order.productDetails != null &&
                  order.productDetails!.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.inventory_2, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        order.productDetails!,
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.orderDate != null
                        ? '${order.orderDate!.day.toString().padLeft(2, '0')}/${order.orderDate!.month.toString().padLeft(2, '0')}/${order.orderDate!.year}'
                        : '',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  Text(
                    '₹${(order.orderAmount ?? 0).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderDetails(Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    'Order #${order.id}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Status: ${order.status.toUpperCase()}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const Divider(height: 24),
                  _detailRow('Customer', order.customerName ?? 'N/A'),
                  _detailRow(
                      'Order Date',
                      order.orderDate != null
                          ? '${order.orderDate!.day.toString().padLeft(2, '0')}/${order.orderDate!.month.toString().padLeft(2, '0')}/${order.orderDate!.year}'
                          : 'N/A'),
                  _detailRow('Total Amount',
                      '₹${(order.orderAmount ?? 0).toStringAsFixed(2)}'),
                  if (order.productDetails != null &&
                      order.productDetails!.isNotEmpty)
                    _detailRow('Products', order.productDetails!),
                  if (order.items.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Line Items',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...order.items.map((item) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.productName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        'Qty: ${item.quantity} ${item.volumeUnit ?? ''}'),
                                    Text(
                                        '₹${item.unitPrice.toStringAsFixed(2)} each'),
                                  ],
                                ),
                                if (item.boomPumpAmount != null &&
                                    item.boomPumpAmount! > 0)
                                  Text(
                                      'Boom/Pump: ₹${item.boomPumpAmount!.toStringAsFixed(2)}'),
                                if (item.requiredDate != null)
                                  Text(
                                    'Required: ${item.requiredDate!.day.toString().padLeft(2, '0')}/${item.requiredDate!.month.toString().padLeft(2, '0')}/${item.requiredDate!.year}',
                                    style: TextStyle(
                                        color: Colors.orange[700],
                                        fontSize: 12),
                                  ),
                              ],
                            ),
                          ),
                        )),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.grey[700])),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Error loading data',
            style: TextStyle(fontSize: 14, color: Colors.red[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

/// Create Order Form Widget
class CreateOrderForm extends StatefulWidget {
  final List<Customer> customers;
  final int? repId;
  final Function(Order)? onOrderCreated;

  const CreateOrderForm({
    Key? key,
    required this.customers,
    this.repId,
    this.onOrderCreated,
  }) : super(key: key);

  @override
  State<CreateOrderForm> createState() => _CreateOrderFormState();
}

class _CreateOrderFormState extends State<CreateOrderForm> {
  late ApiService _apiService;
  Customer? _selectedCustomer;
  Order? _currentOrder;

  // Material type & product
  String? _selectedMaterialType; // 'RMC' or 'Aggregates'
  String? _selectedProduct;

  // Form controllers
  final TextEditingController _volumeController = TextEditingController();
  final TextEditingController _amountPerM3Controller = TextEditingController();
  final TextEditingController _boomPumpController = TextEditingController();
  DateTime? _requiredDate;

  static const List<String> _rmcGrades = [
    'Grade 10',
    'Grade 15',
    'Grade 20',
    'Grade 25',
    'Grade 30',
    'Grade 35',
    'Grade 40',
  ];

  static const List<String> _aggregateTypes = [
    'M Sand',
    '40 mm',
    '20 mm',
    '12 mm',
    '06 mm',
    'P Sand',
  ];

  @override
  void initState() {
    super.initState();
    _apiService = ApiService.instance;
    _currentOrder = Order(repId: widget.repId);
  }

  @override
  void dispose() {
    _volumeController.dispose();
    _amountPerM3Controller.dispose();
    _boomPumpController.dispose();
    super.dispose();
  }

  void _onCustomerSelected(Customer customer) {
    setState(() {
      _selectedCustomer = customer;
      _currentOrder = Order(
        repId: widget.repId,
        customerId: customer.id,
        customerName: customer.name,
      );
      _resetItemFields();
    });
  }

  void _resetItemFields() {
    _selectedMaterialType = null;
    _selectedProduct = null;
    _volumeController.clear();
    _amountPerM3Controller.clear();
    _boomPumpController.clear();
    _requiredDate = null;
  }

  List<String> get _currentProducts {
    if (_selectedMaterialType == 'RMC') return _rmcGrades;
    if (_selectedMaterialType == 'Aggregates') return _aggregateTypes;
    return [];
  }

  String get _volumeUnit {
    if (_selectedMaterialType == 'RMC') return 'm³';
    if (_selectedMaterialType == 'Aggregates') return 'Units';
    return '';
  }

  void _addItem() {
    if (_selectedMaterialType == null || _selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select material type and product')),
      );
      return;
    }

    final volume = double.tryParse(_volumeController.text) ?? 0.0;
    final amountPerM3 = double.tryParse(_amountPerM3Controller.text) ?? 0.0;
    final boomPump = double.tryParse(_boomPumpController.text) ?? 0.0;

    if (volume <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid volume')),
      );
      return;
    }

    if (_requiredDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a required date')),
      );
      return;
    }

    final productLabel = '$_selectedMaterialType - $_selectedProduct';

    setState(() {
      final item = OrderItem(
        productName: productLabel,
        quantity: volume,
        unitPrice: amountPerM3,
        boomPumpAmount: boomPump,
        materialType: _selectedMaterialType!,
        volumeUnit: _volumeUnit,
        requiredDate: _requiredDate,
      );
      _currentOrder?.addItem(item);

      // Reset item fields for next entry
      _selectedProduct = null;
      _volumeController.clear();
      _amountPerM3Controller.clear();
      _boomPumpController.clear();
      _requiredDate = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item added to order')),
    );
  }

  void _removeItem(int index) {
    setState(() {
      _currentOrder?.removeItem(index);
    });
  }

  Future<void> _submitOrder() async {
    if (_currentOrder?.isValid() != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a customer and add items')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Order?'),
        content: Text(
          'Order Total: ₹${_currentOrder!.calculateTotalAmount().toStringAsFixed(2)}\n'
          'Items: ${_currentOrder!.getItemCount()}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitOrderToServer();
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitOrderToServer() async {
    try {
      if (_selectedCustomer == null ||
          _currentOrder == null ||
          _currentOrder!.items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a customer and add at least one item'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      final itemsForSubmission = _currentOrder!.items
          .map((item) => {
                'product_name': item.productName,
                'material_type': item.materialType,
                'quantity': item.quantity,
                'volume_unit': item.volumeUnit,
                'unit_price': item.unitPrice,
                'boom_pump_amount': item.boomPumpAmount,
                'required_date':
                    item.requiredDate?.toIso8601String().split('T')[0],
              })
          .toList();

      final response = await _apiService.createOrder(
        repId: widget.repId ?? 0,
        customerId: _selectedCustomer!.id ?? 0,
        items: itemsForSubmission,
      );

      if (context.mounted) {
        Navigator.pop(context);
      }

      if (response['success'] == true) {
        AppLogger.info('Order submitted successfully');

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(response['message'] ?? 'Order submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        widget.onOrderCreated?.call(_currentOrder!);

        if (mounted) {
          setState(() {
            _selectedCustomer = null;
            _currentOrder = Order(repId: widget.repId);
            _resetItemFields();
          });
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to submit order'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.error('Failed to submit order', e);

      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Customer Selection
        const Text(
          'Select Customer',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<Customer>(
            value: _selectedCustomer,
            hint: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('Choose a customer...'),
            ),
            isExpanded: true,
            itemHeight: 60,
            items: widget.customers.map((customer) {
              return DropdownMenuItem(
                value: customer,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(customer.name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(customer.location ?? 'N/A',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
              );
            }).toList(),
            onChanged: (customer) {
              if (customer != null) {
                _onCustomerSelected(customer);
              }
            },
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () async {
            final result =
                await Navigator.of(context).pushNamed('/add-customer');
            if (result == true && mounted) {
              AppLogger.info(
                  'New customer created, please reload the orders screen');
            }
          },
          icon: const Icon(Icons.person_add),
          label: const Text('Add New Customer'),
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.primary,
          ),
        ),

        if (_selectedCustomer != null) ...[
          const Divider(height: 32),
          const Text(
            'Add Item',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Material Type Selection
          const Text('Material Needs',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildMaterialChip('RMC', Icons.local_shipping),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMaterialChip('Aggregates', Icons.terrain),
              ),
            ],
          ),

          if (_selectedMaterialType != null) ...[
            const SizedBox(height: 16),

            // Product Dropdown
            Text(
              _selectedMaterialType == 'RMC' ? 'RMC Grade' : 'Aggregate Type',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: _selectedProduct,
                hint: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(_selectedMaterialType == 'RMC'
                      ? 'Select grade...'
                      : 'Select type...'),
                ),
                isExpanded: true,
                underline: const SizedBox(),
                items: _currentProducts.map((product) {
                  return DropdownMenuItem(
                    value: product,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(product),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProduct = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 16),

            // Volume
            TextField(
              controller: _volumeController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Volume',
                suffixText: _volumeUnit,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),

            const SizedBox(height: 16),

            // Required Date
            const Text('Required Date',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _requiredDate ??
                      DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() {
                    _requiredDate = picked;
                  });
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _requiredDate != null
                          ? '${_requiredDate!.day.toString().padLeft(2, '0')}/${_requiredDate!.month.toString().padLeft(2, '0')}/${_requiredDate!.year}'
                          : 'Select required date...',
                      style: TextStyle(
                        color: _requiredDate != null
                            ? Colors.black
                            : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    Icon(Icons.calendar_today,
                        size: 20, color: Colors.grey[600]),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Amount per m³
            TextField(
              controller: _amountPerM3Controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText:
                    'Amount concluded per ${_selectedMaterialType == 'RMC' ? 'm³' : 'unit'}',
                prefixText: '₹ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),

            const SizedBox(height: 16),

            // Boom / Pump amount
            TextField(
              controller: _boomPumpController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Boom / Pump Amount',
                prefixText: '₹ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),

            const SizedBox(height: 20),

            // Add Item Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addItem,
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Add Item to Order'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Order Items List
          if (_currentOrder!.getItemCount() > 0) ...[
            const Text(
              'Order Items',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._buildOrderItemsList(),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.primary),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Order Total:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '₹${_currentOrder!.calculateTotalAmount().toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitOrder,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.green,
                ),
                child: const Text('Submit Order',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No items added yet',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildMaterialChip(String label, IconData icon) {
    final isSelected = _selectedMaterialType == label;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedMaterialType = label;
          _selectedProduct = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color:
              isSelected ? AppTheme.primary.withOpacity(0.1) : Colors.grey[50],
          border: Border.all(
            color: isSelected ? AppTheme.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 20,
                color: isSelected ? AppTheme.primary : Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppTheme.primary : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOrderItemsList() {
    return List.generate(_currentOrder!.getItemCount(), (index) {
      final item = _currentOrder!.items[index];
      return Dismissible(
        key: Key('item_$index'),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => _removeItem(index),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        child: Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.productName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '₹${item.calculateTotal().toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Vol: ${item.quantity} ${item.volumeUnit}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      'Rate: ₹${item.unitPrice.toStringAsFixed(2)}/${item.volumeUnit}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                if (item.boomPumpAmount != null &&
                    item.boomPumpAmount! > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Boom/Pump: ₹${item.boomPumpAmount!.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
                if (item.requiredDate != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Required: ${item.requiredDate!.day.toString().padLeft(2, '0')}/${item.requiredDate!.month.toString().padLeft(2, '0')}/${item.requiredDate!.year}',
                    style: TextStyle(fontSize: 12, color: Colors.orange[700]),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }
}
