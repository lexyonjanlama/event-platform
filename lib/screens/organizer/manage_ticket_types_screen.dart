import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/event.dart';
import '../../models/ticket_type.dart';
import '../../providers/ticket_type_provider.dart';

class ManageTicketTypesScreen extends StatefulWidget {
  final Event event;

  const ManageTicketTypesScreen({
    super.key,
    required this.event,
  });

  @override
  State<ManageTicketTypesScreen> createState() =>
      _ManageTicketTypesScreenState();
}

class _ManageTicketTypesScreenState
    extends State<ManageTicketTypesScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<TicketTypeProvider>()
          .startListening(widget.event.eventId);
    });
  }

  Future<void> _openTicketTypeForm({
    TicketType? ticketType,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return _TicketTypeDialog(
          eventId: widget.event.eventId,
          ticketType: ticketType,
        );
      },
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              ticketType == null
                  ? 'Ticket type added successfully.'
                  : 'Ticket type updated successfully.',
            ),
          ),
        );
    }
  }

  Future<void> _confirmDelete(
    TicketType ticketType,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Ticket Type?'),
          content: Text(
            'Are you sure you want to delete '
            '"${ticketType.name}"?\n\n'
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    final provider =
        context.read<TicketTypeProvider>();

    final success =
        await provider.deleteTicketType(
      ticketType.ticketTypeId,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Ticket type deleted successfully.'
                : provider.errorMessage ??
                    'Unable to delete ticket type.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        context.watch<TicketTypeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Types'),
      ),
      body: _buildBody(provider),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: provider.isLoading
            ? null
            : () {
                _openTicketTypeForm();
              },
        icon: const Icon(Icons.add),
        label: const Text('Add Ticket'),
      ),
    );
  }

  Widget _buildBody(
    TicketTypeProvider provider,
  ) {
    if (provider.isLoading &&
        provider.ticketTypes.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.errorMessage != null &&
        provider.ticketTypes.isEmpty) {
      return _buildErrorState(provider);
    }

    if (provider.ticketTypes.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        provider.startListening(
          widget.event.eventId,
        );

        await Future.delayed(
          const Duration(milliseconds: 300),
        );
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          100,
        ),
        itemCount: provider.ticketTypes.length,
        itemBuilder: (context, index) {
          final ticketType =
              provider.ticketTypes[index];

          return _TicketTypeCard(
            ticketType: ticketType,
            onEdit: () {
              _openTicketTypeForm(
                ticketType: ticketType,
              );
            },
            onDelete: () {
              _confirmDelete(ticketType);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.confirmation_number_outlined,
              size: 72,
              color: Colors.grey.shade500,
            ),
            const SizedBox(height: 20),
            const Text(
              'No ticket types yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add ticket types such as Student, '
              'General, or VIP.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                _openTicketTypeForm();
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Ticket Type'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    TicketTypeProvider provider,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 56,
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                provider.startListening(
                  widget.event.eventId,
                );
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketTypeCard extends StatelessWidget {
  final TicketType ticketType;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TicketTypeCard({
    required this.ticketType,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    ticketType.name,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _StatusBadge(
                  isActive: ticketType.isActive,
                  isSoldOut: ticketType.isSoldOut,
                ),
              ],
            ),

            if (ticketType.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                ticketType.description,
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),
            ],

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _TicketInfo(
                    icon: Icons.payments_outlined,
                    label: 'Price',
                    value:
                        'Rs. ${ticketType.price.toStringAsFixed(0)}',
                  ),
                ),
                Expanded(
                  child: _TicketInfo(
                    icon: Icons.inventory_2_outlined,
                    label: 'Quantity',
                    value:
                        ticketType.quantity.toString(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _TicketInfo(
                    icon: Icons.shopping_cart_outlined,
                    label: 'Sold',
                    value:
                        ticketType.sold.toString(),
                  ),
                ),
                Expanded(
                  child: _TicketInfo(
                    icon: Icons.event_seat_outlined,
                    label: 'Remaining',
                    value:
                        ticketType.remaining.toString(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(
                      Icons.edit_outlined,
                    ),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(
                      Icons.delete_outline,
                    ),
                    label: const Text('Delete'),
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

class _TicketInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _TicketInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  final bool isSoldOut;

  const _StatusBadge({
    required this.isActive,
    required this.isSoldOut,
  });

  @override
  Widget build(BuildContext context) {
    String text;

    if (!isActive) {
      text = 'Inactive';
    } else if (isSoldOut) {
      text = 'Sold Out';
    } else {
      text = 'Active';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey.shade200,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TicketTypeDialog extends StatefulWidget {
  final String eventId;
  final TicketType? ticketType;

  const _TicketTypeDialog({
    required this.eventId,
    this.ticketType,
  });

  @override
  State<_TicketTypeDialog> createState() =>
      _TicketTypeDialogState();
}

class _TicketTypeDialogState
    extends State<_TicketTypeDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController
      _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController
      _quantityController;

  bool _isActive = true;
  bool _isSaving = false;

  bool get isEditing => widget.ticketType != null;

  @override
  void initState() {
    super.initState();

    final ticketType = widget.ticketType;

    _nameController = TextEditingController(
      text: ticketType?.name ?? '',
    );

    _descriptionController =
        TextEditingController(
      text: ticketType?.description ?? '',
    );

    _priceController = TextEditingController(
      text: ticketType != null
          ? ticketType.price.toStringAsFixed(0)
          : '',
    );

    _quantityController = TextEditingController(
      text: ticketType != null
          ? ticketType.quantity.toString()
          : '',
    );

    _isActive = ticketType?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();

    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final price =
        double.tryParse(_priceController.text.trim());

    final quantity =
        int.tryParse(_quantityController.text.trim());

    if (price == null || quantity == null) {
      return;
    }

    final provider =
        context.read<TicketTypeProvider>();

    setState(() {
      _isSaving = true;
    });

    final existing = widget.ticketType;

    final ticketType = TicketType(
      ticketTypeId:
          existing?.ticketTypeId ?? '',
      eventId: widget.eventId,
      name: _nameController.text.trim(),
      description:
          _descriptionController.text.trim(),
      price: price,
      quantity: quantity,
      sold: existing?.sold ?? 0,
      isActive: _isActive,
      createdAt: existing?.createdAt,
      updatedAt: existing?.updatedAt,
    );

    final success = isEditing
        ? await provider.updateTicketType(
            ticketType,
          )
        : await provider.createTicketType(
            ticketType,
          );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              provider.errorMessage ??
                  'Unable to save ticket type.',
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        isEditing
            ? 'Edit Ticket Type'
            : 'Add Ticket Type',
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                textInputAction:
                    TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Ticket Name',
                  hintText: 'e.g. Student',
                  prefixIcon: Icon(
                    Icons.confirmation_number_outlined,
                  ),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Enter ticket name.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller:
                    _descriptionController,
                maxLines: 2,
                textInputAction:
                    TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText:
                      'e.g. Valid student ID required',
                  prefixIcon: Icon(
                    Icons.description_outlined,
                  ),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _priceController,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction:
                    TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  hintText: 'e.g. 500',
                  prefixIcon: Icon(
                    Icons.payments_outlined,
                  ),
                  prefixText: 'Rs. ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final price =
                      double.tryParse(
                    value?.trim() ?? '',
                  );

                  if (price == null ||
                      price < 0) {
                    return 'Enter a valid price.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller:
                    _quantityController,
                keyboardType:
                    TextInputType.number,
                textInputAction:
                    TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  hintText: 'e.g. 100',
                  prefixIcon: Icon(
                    Icons.inventory_2_outlined,
                  ),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final quantity =
                      int.tryParse(
                    value?.trim() ?? '',
                  );

                  if (quantity == null ||
                      quantity <= 0) {
                    return 'Enter a valid quantity.';
                  }

                  final existing =
                      widget.ticketType;

                  if (existing != null &&
                      quantity < existing.sold) {
                    return 'Cannot be less than tickets sold '
                        '(${existing.sold}).';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 8),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Active'),
                subtitle: const Text(
                  'Participants can purchase this ticket.',
                ),
                value: _isActive,
                onChanged: _isSaving
                    ? null
                    : (value) {
                        setState(() {
                          _isActive = value;
                        });
                      },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving
              ? null
              : () {
                  Navigator.pop(context);
                },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  isEditing
                      ? 'Save Changes'
                      : 'Add Ticket',
                ),
        ),
      ],
    );
  }
}

