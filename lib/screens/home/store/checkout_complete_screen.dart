import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_desktop_loop/constants/app_colors.dart';
import 'package:pos_desktop_loop/db/tables/shop/shop_table.dart';
import 'package:pos_desktop_loop/providers/cart_provider.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompleteCheckoutScreen extends StatefulWidget {
  final int shopId; // Changed from String to int to match CartProvider

  const CompleteCheckoutScreen({required this.shopId, super.key});

  
  @override
  State<CompleteCheckoutScreen> createState() => _CompleteCheckoutScreenState();
}

class _CompleteCheckoutScreenState extends State<CompleteCheckoutScreen> {
  String _paymentMethod = 'cash';
  final TextEditingController _amountReceivedController =
      TextEditingController();
  bool _isProcessing = false;
  bool _printReceipt = true;
  bool _connectionStatus = false;
  String _branchName = '';
  String _shopName = '';

  @override
  void initState() {
    super.initState();
    _loadPrintReceiptPreference();
    _checkPrinterConnection();
    _initVariables();
  }

  Future<void> _loadPrintReceiptPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _printReceipt = prefs.getBool('printReceipt_${widget.shopId}') ?? true;
    });
  }

  Future<void> _savePrintReceiptPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('printReceipt_${widget.shopId}', value);
  }

  Future<void> _checkPrinterConnection() async {
    final prefs = await SharedPreferences.getInstance();
    final printerId = prefs.getString('selectedBluetoothPrinterId');

    if (printerId != null && printerId.isNotEmpty) {
      final connected = await PrintBluetoothThermal.connectionStatus;
      setState(() {
        _connectionStatus = connected;
      });
    }
  }

  Future<void> _processPayment() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final shopCart = cartProvider.getCartForShop(widget.shopId) ?? {};

    if (shopCart.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cart is empty')));
      return;
    }

    if (_paymentMethod == 'cash' &&
        num.tryParse(_amountReceivedController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount received')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Process payment and save to database
      await _saveTransactionToDatabase(cartProvider);

      // Print receipt if enabled
      if (_printReceipt && _connectionStatus) {
        await _printReceiptFn(cartProvider);
      }

      // Clear only this shop's cart
      cartProvider.clearCartForShop(widget.shopId);

      // Navigate back with success
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error completing sale: $e')));
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _saveTransactionToDatabase(CartProvider cartProvider) async {
    // Implement your database saving logic here
    // Access shop-specific cart with cartProvider.getCartForShop(widget.shopId)
    // Include shopId in the transaction data
  }

  Future<void> _printReceiptFn(CartProvider cartProvider) async {
    try {
      final now = DateTime.now();
      final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(now);
      final buffer = StringBuffer();
      final shopCart = cartProvider.getCartForShop(widget.shopId) ?? {};
      final subtotal = cartProvider.getSubtotalForShop(widget.shopId);

      const maxChars = 32;
      const dividerChar = '-';
      const doubleDividerChar = '=';

      String centerText(String text) {
        if (text.length >= maxChars) return text.substring(0, maxChars);
        final padding = (maxChars - text.length) ~/ 2;
        return ' ' * padding + text + ' ' * (maxChars - text.length - padding);
      }

      String alignRight(String label, String value) {
        final combinedLength = label.length + value.length;
        if (combinedLength >= maxChars) {
          return '${label.substring(0, maxChars - value.length - 1)} $value';
        }
        return label + ' ' * (maxChars - combinedLength) + value;
      }

      // HEADER
      buffer.writeln(centerText(_shopName)); // Added shop ID
      buffer.writeln(centerText('$_branchName Branch'));
      buffer.writeln(doubleDividerChar * maxChars);

      // RECEIPT INFO
      buffer.writeln('Date: $formattedDate');
      buffer.writeln(dividerChar * maxChars);

      // ITEMS SECTION
      buffer.writeln(centerText('ITEMS'));
      buffer.writeln(dividerChar * maxChars);

      for (var item in shopCart.values) {
        final name = item.product.name;
        final qty = item.quantity;
        final price = item.unitPrice.toStringAsFixed(2);
        final totalPrice = item.itemTotal.toStringAsFixed(2);

        if (name.length > maxChars) {
          buffer.writeln(name.substring(0, maxChars));
          buffer.writeln(name.substring(maxChars));
        } else {
          buffer.writeln(name);
        }
        buffer.writeln(alignRight('$qty x $price', totalPrice));
        buffer.writeln('');
      }

      // TOTALS SECTION
      buffer.writeln(doubleDividerChar * maxChars);
      buffer.writeln(alignRight('TOTAL:', subtotal.toStringAsFixed(2)));
      buffer.writeln(doubleDividerChar * maxChars);

      // PAYMENT SECTION
      buffer.writeln(centerText('PAYMENT'));
      buffer.writeln(dividerChar * maxChars);
      buffer.writeln(alignRight('Method:', _paymentMethod));

      if (_paymentMethod == 'cash') {
        final received = num.tryParse(_amountReceivedController.text) ?? 0;
        buffer.writeln(alignRight('Received:', received.toStringAsFixed(2)));
        buffer.writeln(
          alignRight('Change:', (received - subtotal).toStringAsFixed(2)),
        );
      }

      buffer.writeln(doubleDividerChar * maxChars);
      buffer.writeln(centerText('Thank you!'));
      buffer.writeln('\n\n\n');

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(size: 2, text: buffer.toString()),
      );
    } catch (e) {
      debugPrint('Error printing receipt: $e');
      // Continue with checkout even if printing fails
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error printing receipt: $e')));
      // dont leave the checkout process ask user to reconnect printer
      _checkPrinterConnection();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final shopCart = cartProvider.getCartForShop(widget.shopId) ?? {};
    final subtotal = cartProvider.getSubtotalForShop(widget.shopId);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout - Shop $_shopName'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.primaryColor,
        actions: [
          IconButton(
            icon:
                _connectionStatus
                    ? const Icon(Icons.print, color: Colors.white)
                    : const Icon(Icons.print_disabled, color: Colors.white),
            tooltip:
                'Printer ${_connectionStatus ? 'Connected' : 'Disconnected'}',
            onPressed: _checkPrinterConnection,
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Card
          _buildSummaryCard(theme, subtotal, shopCart),

          // Payment Method Section
          _buildPaymentMethodSection(),

          // Amount Received (for cash payments)
          if (_paymentMethod == 'cash') _buildAmountReceivedSection(subtotal),

          // Print Receipt Toggle
          _buildPrintReceiptToggle(),

          // Complete Sale Button
          _buildCompleteSaleButton(cartProvider),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    ThemeData theme,
    double subtotal,
    Map<int, CartItem> shopCart,
  ) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal', style: theme.textTheme.titleMedium),
                Text(
                  'Ksh ${NumberFormat("#,##0.00").format(subtotal)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (shopCart.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Cart is empty',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.amber[800],
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height: 150,
                child: ListView.builder(
                  itemCount: shopCart.length,
                  itemBuilder: (context, index) {
                    final item = shopCart.values.elementAt(index);
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: theme.primaryColor.withOpacity(0.1),
                        child: Text(
                          item.quantity.toString(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                      title: Text(
                        item.product.name,
                        style: theme.textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        'Ksh ${(item.itemTotal).toStringAsFixed(2)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildPaymentMethodOption(
                  'Cash',
                  Icons.money,
                  _paymentMethod == 'cash',
                  () => setState(() => _paymentMethod = 'cash'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPaymentMethodOption(
                  'MPesa',
                  Icons.phone_android,
                  _paymentMethod == 'mpesa',
                  () => setState(() => _paymentMethod = 'mpesa'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPaymentMethodOption(
                  'Credit',
                  Icons.credit_card,
                  _paymentMethod == 'credit',
                  () => setState(() => _paymentMethod = 'credit'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOption(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                  : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color:
                  isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color:
                    isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountReceivedSection(double subtotal) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _amountReceivedController,
            decoration: InputDecoration(
              labelText: 'Amount Received',
              prefixText: 'Ksh ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.attach_money),
                onPressed: () {
                  _amountReceivedController.text = subtotal.toStringAsFixed(2);
                  setState(() {});
                },
              ),
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) => setState(() {}),
          ),
          if (_amountReceivedController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Change Due',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Ksh ${NumberFormat("#,##0.00").format((num.tryParse(_amountReceivedController.text) ?? 0) - subtotal)}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPrintReceiptToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SwitchListTile(
        title: Text(
          'Print Receipt',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          _connectionStatus ? 'Printer ready' : 'Printer not connected',
          style: TextStyle(
            color: _connectionStatus ? Colors.green : Colors.red,
          ),
        ),
        value: _printReceipt,
        onChanged: (value) {
          setState(() => _printReceipt = value);
          _savePrintReceiptPreference(value);
        },
        secondary: Icon(Icons.receipt, color: Theme.of(context).primaryColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildCompleteSaleButton(CartProvider cartProvider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
        child:
            _isProcessing
                ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                : Text(
                  'COMPLETE SALE',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
      ),
    );
  }

  void _initVariables() async {
    // GET business and shop names from database
    await ShopTable.getShopById(widget.shopId)
        .then((shop) {
          if (shop != null) {
            setState(() {
              _shopName = shop.name;
              _branchName = shop.branch;
            });
          }
        })
        .catchError((error) {
          debugPrint('Error fetching shop details: $error');
        });
  }
}
