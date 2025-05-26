import 'package:flutter/material.dart';

class ListingForm extends StatefulWidget {
  final void Function(Map<String, dynamic>) onCalculate;
  final void Function(Map<String, dynamic>) onGenerate;

  const ListingForm({
    super.key,
    required this.onCalculate,
    required this.onGenerate,
  });

  @override
  State<ListingForm> createState() => _ListingFormState();
}

class _ListingFormState extends State<ListingForm> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  String _itemTitle = '';
  String _condition = 'Used';
  String _notes = '';
  double _purchasePrice = 0;
  double _supplyCost = 0;
  double _promoRate = 0;
  double _weightLbs = 0;
  double _weightOz = 0;
  bool _buyerPaysShipping = true;
  String _shippingType = 'first_class';

  void _handleSubmit(bool isFullReport) {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      final data = {
        'item_title': _itemTitle,
        'condition': _condition,
        'notes': _notes,
        'purchase_price': _purchasePrice,
        'supply_cost': _supplyCost,
        'promo_rate': _promoRate,
        'weight_lbs': _weightLbs,
        'weight_oz': _weightOz,
        'buyer_pays_shipping': _buyerPaysShipping,
        'shipping_type': _shippingType,
      };
      isFullReport ? widget.onGenerate(data) : widget.onCalculate(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Item title
          TextFormField(
            decoration: const InputDecoration(labelText: 'Item Title'),
            onSaved: (value) => _itemTitle = value ?? '',
            validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
          ),
          // Condition
          DropdownButtonFormField(
            decoration: const InputDecoration(labelText: 'Condition'),
            value: _condition,
            onChanged: (value) => setState(() => _condition = value ?? 'Used'),
            items: ['New', 'Used', 'Like New', 'Very Good', 'Good', 'Acceptable']
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
          ),
          // Notes
          TextFormField(
            decoration: const InputDecoration(labelText: 'Notes'),
            onSaved: (value) => _notes = value ?? '',
          ),
          // Buyer pays shipping
          SwitchListTile(
            title: const Text('Buyer Pays Shipping'),
            value: _buyerPaysShipping,
            onChanged: (val) => setState(() => _buyerPaysShipping = val),
          ),
          // Shipping method
          DropdownButtonFormField(
            decoration: const InputDecoration(labelText: 'Shipping Method'),
            value: _shippingType,
            onChanged: (value) => setState(() => _shippingType = value ?? 'first_class'),
            items: [
              'first_class',
              'ground_advantage',
              'priority_flat',
            ].map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.replaceAll('_', ' ').toUpperCase()),
                )).toList(),
          ),
          // Weight lbs/oz
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(labelText: 'Weight (lbs)'),
                  keyboardType: TextInputType.number,
                  onSaved: (v) => _weightLbs = double.tryParse(v ?? '') ?? 0,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(labelText: 'Weight (oz)'),
                  keyboardType: TextInputType.number,
                  onSaved: (v) => _weightOz = double.tryParse(v ?? '') ?? 0,
                ),
              ),
            ],
          ),
          // Purchase Price
          TextFormField(
            decoration: const InputDecoration(labelText: 'Purchase Price (\$)'),
            keyboardType: TextInputType.number,
            onSaved: (v) => _purchasePrice = double.tryParse(v ?? '') ?? 0,
          ),
          // Supply Cost
          TextFormField(
            decoration: const InputDecoration(labelText: 'Supply Cost (\$)'),
            keyboardType: TextInputType.number,
            onSaved: (v) => _supplyCost = double.tryParse(v ?? '') ?? 0,
          ),
          // Promotion Rate
          TextFormField(
            decoration: const InputDecoration(labelText: 'Promotion Rate (%)'),
            keyboardType: TextInputType.number,
            onSaved: (v) => _promoRate = double.tryParse(v ?? '') ?? 0,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleSubmit(false),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  child: const Text('Calculate'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleSubmit(true),
                  child: const Text('Generate Full Report'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
