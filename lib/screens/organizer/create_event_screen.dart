import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/event.dart';
import '../../models/ticket_type.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';

class CreateEventScreen extends StatefulWidget {
  final Event? event;

  const CreateEventScreen({
    super.key,
    this.event,
  });

  bool get isEditing => event != null;

  @override
  State<CreateEventScreen> createState() =>
      _CreateEventScreenState();
}

class _CreateEventScreenState
    extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _venueController;
  late final TextEditingController _capacityController;
  late final TextEditingController _bannerUrlController;

  String? _selectedCategory;
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  bool _isPublished = false;

  final List<TicketType> _draftTicketTypes = [];

  final List<String> _categories = [
    'Conference',
    'Workshop',
    'Competition',
    'Concert',
    'Seminar',
    'Sports',
    'Other',
  ];

  @override
  void initState() {
    super.initState();

    final event = widget.event;

    _titleController = TextEditingController(
      text: event?.title ?? '',
    );

    _descriptionController =
        TextEditingController(
      text: event?.description ?? '',
    );

    _venueController = TextEditingController(
      text: event?.venue ?? '',
    );

    _capacityController = TextEditingController(
      text: event != null
          ? event.capacity.toString()
          : '',
    );

    _bannerUrlController =
        TextEditingController(
      text: event?.bannerUrl ?? '',
    );

    if (event != null) {
      _selectedCategory = event.category;
      _selectedDate = event.date;

      _startTime = _parseTime(
        event.startTime,
      );

      _endTime = _parseTime(
        event.endTime,
      );

      _isPublished =
          event.status == 'published';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    _capacityController.dispose();
    _bannerUrlController.dispose();

    super.dispose();
  }

  TimeOfDay? _parseTime(String time) {
    try {
      final parts = time.split(':');

      if (parts.length != 2) {
        return null;
      }

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      return TimeOfDay(
        hour: hour,
        minute: minute,
      );
    } catch (_) {
      return null;
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour =
        time.hour.toString().padLeft(2, '0');

    final minute =
        time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  String _displayTime(TimeOfDay? time) {
    if (time == null) {
      return 'Select time';
    }

    return time.format(context);
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final initialDate =
        _selectedDate ?? now;

    final date = await showDatePicker(
      context: context,
      initialDate:
          initialDate.isBefore(now)
              ? now
              : initialDate,
      firstDate: now,
      lastDate: DateTime(
        now.year + 5,
        now.month,
        now.day,
      ),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectStartTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime:
          _startTime ?? TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        _startTime = time;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime:
          _endTime ?? TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        _endTime = time;
      });
    }
  }

  bool _validateDateAndTime() {
    if (_selectedDate == null) {
      _showMessage(
        'Please select an event date.',
      );

      return false;
    }

    if (_startTime == null) {
      _showMessage(
        'Please select a start time.',
      );

      return false;
    }

    if (_endTime == null) {
      _showMessage(
        'Please select an end time.',
      );

      return false;
    }

    final startMinutes =
        _startTime!.hour * 60 +
            _startTime!.minute;

    final endMinutes =
        _endTime!.hour * 60 +
            _endTime!.minute;

    if (endMinutes <= startMinutes) {
      _showMessage(
        'End time must be after start time.',
      );

      return false;
    }

    return true;
  }

  Future<void> _addTicketType() async {
    final ticketType =
        await showDialog<TicketType>(
      context: context,
      builder: (dialogContext) {
        return const _TicketTypeDialog();
      },
    );

    if (ticketType == null || !mounted) {
      return;
    }

    setState(() {
      _draftTicketTypes.add(ticketType);
    });
  }

  Future<void> _editTicketType(
    int index,
  ) async {
    final existing =
        _draftTicketTypes[index];

    final updated =
        await showDialog<TicketType>(
      context: context,
      builder: (dialogContext) {
        return _TicketTypeDialog(
          ticketType: existing,
        );
      },
    );

    if (updated == null || !mounted) {
      return;
    }

    setState(() {
      _draftTicketTypes[index] =
          updated.copyWith(
        eventId: '',
      );
    });
  }

  Future<void> _deleteTicketType(
    int index,
  ) async {
    final ticketType =
        _draftTicketTypes[index];

    final shouldDelete =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Ticket Type?',
          ),
          content: Text(
            'Are you sure you want to remove '
            '"${ticketType.name}"?',
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

    if (shouldDelete == true && mounted) {
      setState(() {
        _draftTicketTypes.removeAt(index);
      });
    }
  }

  Future<void> _saveEvent() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_validateDateAndTime()) {
      return;
    }

    final organizerId =
        context
            .read<AuthProvider>()
            .appUser
            ?.uid;

    if (organizerId == null) {
      _showMessage(
        'Unable to identify the organizer. '
        'Please log in again.',
      );

      return;
    }

    final capacity =
        int.tryParse(
      _capacityController.text.trim(),
    );

    if (capacity == null || capacity <= 0) {
      _showMessage(
        'Please enter a valid capacity.',
      );

      return;
    }

    final eventProvider =
        context.read<EventProvider>();

    final isEditing =
        widget.event != null;

    final event = Event(
      eventId:
          widget.event?.eventId ?? '',
      title:
          _titleController.text.trim(),
      description:
          _descriptionController.text.trim(),
      category:
          _selectedCategory!,
      date:
          _selectedDate!,
      startTime:
          _formatTime(_startTime!),
      endTime:
          _formatTime(_endTime!),
      venue:
          _venueController.text.trim(),
      organizerId:
          widget.event?.organizerId ??
              organizerId,
      capacity:
          capacity,
      status:
          _isPublished
              ? 'published'
              : 'draft',
      bannerUrl:
          _bannerUrlController.text.trim(),
      createdAt:
          widget.event?.createdAt,
      updatedAt:
          widget.event?.updatedAt,
    );

    bool success;

    if (isEditing) {
      success =
          await eventProvider.updateEvent(
        event,
      );
    } else {
      success =
          await eventProvider
              .createEventWithTicketTypes(
        event: event,
        ticketTypes:
            _draftTicketTypes,
      );
    }

    if (!mounted) {
      return;
    }

    if (success) {
      _showMessage(
        isEditing
            ? 'Event updated successfully!'
            : _isPublished
                ? 'Event and ticket types '
                    'published successfully!'
                : 'Event and ticket types '
                    'saved as draft!',
      );

      Navigator.pop(context);
    } else {
      _showMessage(
        eventProvider.errorMessage ??
            'Something went wrong. '
                'Please try again.',
      );
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider =
        context.watch<EventProvider>();

    final isEditing =
        widget.event != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? 'Edit Event'
              : 'Create Event',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding:
              const EdgeInsets.all(20),
          children: [
            Text(
              isEditing
                  ? 'Update your event details'
                  : 'Create a new event',
              style:
                  const TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              isEditing
                  ? 'Make changes to your event '
                      'and save them.'
                  : 'Add the details of your '
                      'event below.',
              style: TextStyle(
                color:
                    Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 28),

            // EVENT TITLE
            TextFormField(
              controller:
                  _titleController,
              textInputAction:
                  TextInputAction.next,
              decoration:
                  const InputDecoration(
                labelText: 'Event Title',
                hintText:
                    'Enter event title',
                prefixIcon: Icon(
                  Icons.event_outlined,
                ),
                border:
                    OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null ||
                    value
                        .trim()
                        .isEmpty) {
                  return 'Please enter an event title.';
                }

                if (value
                        .trim()
                        .length <
                    3) {
                  return 'Title must be at least 3 characters.';
                }

                return null;
              },
            ),

            const SizedBox(height: 18),

            // DESCRIPTION
            TextFormField(
              controller:
                  _descriptionController,
              maxLines: 4,
              textInputAction:
                  TextInputAction.next,
              decoration:
                  const InputDecoration(
                labelText:
                    'Description',
                hintText:
                    'Describe your event',
                prefixIcon: Icon(
                  Icons
                      .description_outlined,
                ),
                border:
                    OutlineInputBorder(),
                alignLabelWithHint:
                    true,
              ),
              validator: (value) {
                if (value == null ||
                    value
                        .trim()
                        .isEmpty) {
                  return 'Please enter a description.';
                }

                if (value
                        .trim()
                        .length <
                    10) {
                  return 'Description must be at least 10 characters.';
                }

                return null;
              },
            ),

            const SizedBox(height: 18),

            // CATEGORY
            DropdownButtonFormField<
                String>(
              initialValue:
                  _selectedCategory,
              decoration:
                  const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(
                  Icons
                      .category_outlined,
                ),
                border:
                    OutlineInputBorder(),
              ),
              items:
                  _categories
                      .map(
                (category) {
                  return DropdownMenuItem<
                      String>(
                    value: category,
                    child:
                        Text(category),
                  );
                },
              ).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory =
                      value;
                });
              },
              validator: (value) {
                if (value == null ||
                    value.isEmpty) {
                  return 'Please select a category.';
                }

                return null;
              },
            ),

            const SizedBox(height: 18),

            // VENUE
            TextFormField(
              controller:
                  _venueController,
              textInputAction:
                  TextInputAction.next,
              decoration:
                  const InputDecoration(
                labelText: 'Venue',
                hintText:
                    'Enter event venue',
                prefixIcon: Icon(
                  Icons
                      .location_on_outlined,
                ),
                border:
                    OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null ||
                    value
                        .trim()
                        .isEmpty) {
                  return 'Please enter the venue.';
                }

                return null;
              },
            ),

            const SizedBox(height: 18),

            // CAPACITY
            TextFormField(
              controller:
                  _capacityController,
              keyboardType:
                  TextInputType.number,
              textInputAction:
                  TextInputAction.done,
              decoration:
                  const InputDecoration(
                labelText: 'Capacity',
                hintText: 'e.g. 100',
                prefixIcon: Icon(
                  Icons
                      .people_outline,
                ),
                border:
                    OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null ||
                    value
                        .trim()
                        .isEmpty) {
                  return 'Please enter capacity.';
                }

                final capacity =
                    int.tryParse(
                  value.trim(),
                );

                if (capacity == null ||
                    capacity <= 0) {
                  return 'Enter a valid capacity.';
                }

                return null;
              },
            ),

            const SizedBox(height: 24),

            // DATE & TIME
            const Text(
              'Date & Time',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _SelectionTile(
              icon: Icons
                  .calendar_today_outlined,
              title: 'Event Date',
              value:
                  _selectedDate == null
                      ? 'Select date'
                      : '${_selectedDate!.day}/'
                          '${_selectedDate!.month}/'
                          '${_selectedDate!.year}',
              onTap: _selectDate,
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child:
                      _SelectionTile(
                    icon: Icons
                        .access_time_outlined,
                    title:
                        'Start Time',
                    value:
                        _displayTime(
                      _startTime,
                    ),
                    onTap:
                        _selectStartTime,
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child:
                      _SelectionTile(
                    icon: Icons
                        .access_time_filled_outlined,
                    title:
                        'End Time',
                    value:
                        _displayTime(
                      _endTime,
                    ),
                    onTap:
                        _selectEndTime,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // BANNER
            const Text(
              'Banner',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller:
                  _bannerUrlController,
              keyboardType:
                  TextInputType.url,
              decoration:
                  const InputDecoration(
                labelText:
                    'Banner URL (Optional)',
                hintText:
                    'https://example.com/banner.jpg',
                prefixIcon: Icon(
                  Icons
                      .image_outlined,
                ),
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'You can add an image URL later. '
              'No file upload is required.',
              style: TextStyle(
                fontSize: 12,
                color:
                    Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 28),

            // TICKET TYPES
            _buildTicketTypesSection(
              isEditing,
            ),

            const SizedBox(height: 28),

            // PUBLISH
            Card(
              child:
                  SwitchListTile(
                title:
                    const Text(
                  'Publish Event',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
                subtitle:
                    Text(
                  _isPublished
                      ? 'Participants can see this event.'
                      : 'Save this event as a draft.',
                ),
                value:
                    _isPublished,
                onChanged:
                    (value) {
                  setState(() {
                    _isPublished =
                        value;
                  });
                },
              ),
            ),

            const SizedBox(height: 28),

            // SAVE BUTTON
            SizedBox(
              height: 52,
              child:
                  FilledButton.icon(
                onPressed:
                    eventProvider
                            .isLoading
                        ? null
                        : _saveEvent,
                icon:
                    eventProvider
                            .isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth:
                                  2,
                            ),
                          )
                        : Icon(
                            isEditing
                                ? Icons
                                    .save_outlined
                                : Icons
                                    .publish_outlined,
                          ),
                label: Text(
                  eventProvider
                          .isLoading
                      ? 'Saving...'
                      : isEditing
                          ? 'Save Changes'
                          : _isPublished
                              ? 'Publish Event'
                              : 'Save Draft',
                ),
              ),
            ),

            const SizedBox(height: 12),

            if (isEditing)
              SizedBox(
                height: 52,
                child:
                    OutlinedButton(
                  onPressed:
                      eventProvider
                              .isLoading
                          ? null
                          : () {
                              Navigator.pop(
                                context,
                              );
                            },
                  child:
                      const Text(
                    'Cancel',
                  ),
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketTypesSection(
    bool isEditing,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ticket Types',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Add the tickets participants can purchase.',
                    style: TextStyle(
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed:
                  isEditing
                      ? null
                      : _addTicketType,
              icon: const Icon(
                Icons.add,
              ),
              label:
                  const Text('Add'),
            ),
          ],
        ),

        const SizedBox(height: 14),

        if (isEditing)
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.all(14),
            decoration:
                BoxDecoration(
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
              border: Border.all(
                color:
                    Colors.grey.shade400,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    'For an existing event, '
                    'manage ticket types from '
                    'My Events → Tickets.',
                    style: TextStyle(
                      color: Colors
                          .grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          )
        else if (_draftTicketTypes
            .isEmpty)
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.all(20),
            decoration:
                BoxDecoration(
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
              border: Border.all(
                color:
                    Colors.grey.shade400,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons
                      .confirmation_number_outlined,
                  size: 42,
                  color:
                      Colors.grey.shade500,
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'No ticket types added',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  'Add Student, General, VIP, '
                  'or any ticket type for this event.',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors
                        .grey.shade600,
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: List.generate(
              _draftTicketTypes.length,
              (index) {
                final ticket =
                    _draftTicketTypes[
                        index];

                return _DraftTicketCard(
                  ticketType: ticket,
                  onEdit: () {
                    _editTicketType(
                      index,
                    );
                  },
                  onDelete: () {
                    _deleteTicketType(
                      index,
                    );
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}

class _SelectionTile
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _SelectionTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final isSelected =
        value != 'Select date' &&
        value != 'Select time';

    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(12),
      child: Container(
        padding:
            const EdgeInsets.all(16),
        decoration:
            BoxDecoration(
          border: Border.all(
            color:
                Colors.grey.shade400,
          ),
          borderRadius:
              BorderRadius.circular(
            12,
          ),
        ),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors
                          .grey.shade600,
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          isSelected
                              ? FontWeight
                                  .w600
                              : FontWeight
                                  .normal,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
            ),
          ],
        ),
      ),
    );
  }
}

class _DraftTicketCard
    extends StatelessWidget {
  final TicketType ticketType;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DraftTicketCard({
    required this.ticketType,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    ticketType.name,
                    style:
                        const TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  'Rs. ${ticketType.price.toStringAsFixed(0)}',
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),

            if (ticketType
                .description
                .isNotEmpty) ...[
              const SizedBox(
                height: 6,
              ),
              Text(
                ticketType
                    .description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors
                      .grey.shade700,
                ),
              ),
            ],

            const SizedBox(
              height: 10,
            ),

            Row(
              children: [
                const Icon(
                  Icons
                      .inventory_2_outlined,
                  size: 17,
                ),
                const SizedBox(
                  width: 6,
                ),
                Text(
                  'Quantity: '
                  '${ticketType.quantity}',
                  style:
                      const TextStyle(
                    fontSize: 13,
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                Icon(
                  ticketType.isActive
                      ? Icons
                          .check_circle_outline
                      : Icons
                          .pause_circle_outline,
                  size: 17,
                ),
                const SizedBox(
                  width: 6,
                ),
                Text(
                  ticketType.isActive
                      ? 'Active'
                      : 'Inactive',
                  style:
                      const TextStyle(
                    fontSize: 13,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 10,
            ),

            const Divider(),

            Row(
              children: [
                Expanded(
                  child:
                      OutlinedButton.icon(
                    onPressed:
                        onEdit,
                    icon: const Icon(
                      Icons
                          .edit_outlined,
                      size: 18,
                    ),
                    label:
                        const Text(
                      'Edit',
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child:
                      OutlinedButton.icon(
                    onPressed:
                        onDelete,
                    icon: const Icon(
                      Icons
                          .delete_outline,
                      size: 18,
                    ),
                    label:
                        const Text(
                      'Remove',
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

class _TicketTypeDialog
    extends StatefulWidget {
  final TicketType? ticketType;

  const _TicketTypeDialog({
    this.ticketType,
  });

  @override
  State<_TicketTypeDialog> createState() =>
      _TicketTypeDialogState();
}

class _TicketTypeDialogState
    extends State<_TicketTypeDialog> {
  final _formKey =
      GlobalKey<FormState>();

  late final TextEditingController
      _nameController;

  late final TextEditingController
      _descriptionController;

  late final TextEditingController
      _priceController;

  late final TextEditingController
      _quantityController;

  bool _isActive = true;

  bool get isEditing =>
      widget.ticketType != null;

  @override
  void initState() {
    super.initState();

    final ticket =
        widget.ticketType;

    _nameController =
        TextEditingController(
      text: ticket?.name ?? '',
    );

    _descriptionController =
        TextEditingController(
      text:
          ticket?.description ?? '',
    );

    _priceController =
        TextEditingController(
      text: ticket != null
          ? ticket.price
              .toStringAsFixed(0)
          : '',
    );

    _quantityController =
        TextEditingController(
      text: ticket != null
          ? ticket.quantity
              .toString()
          : '',
    );

    _isActive =
        ticket?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController
        .dispose();
    _priceController.dispose();
    _quantityController
        .dispose();

    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    final price =
        double.tryParse(
      _priceController.text
          .trim(),
    );

    final quantity =
        int.tryParse(
      _quantityController.text
          .trim(),
    );

    if (price == null ||
        quantity == null) {
      return;
    }

    final existing =
        widget.ticketType;

    final ticketType =
        TicketType(
      ticketTypeId:
          existing?.ticketTypeId ??
              '',
      eventId:
          existing?.eventId ?? '',
      name:
          _nameController.text
              .trim(),
      description:
          _descriptionController
              .text
              .trim(),
      price: price,
      quantity: quantity,
      sold:
          existing?.sold ?? 0,
      isActive:
          _isActive,
      createdAt:
          existing?.createdAt,
      updatedAt:
          existing?.updatedAt,
    );

    Navigator.pop(
      context,
      ticketType,
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
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
            mainAxisSize:
                MainAxisSize.min,
            children: [
              TextFormField(
                controller:
                    _nameController,
                textInputAction:
                    TextInputAction.next,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Ticket Name',
                  hintText:
                      'e.g. Student',
                  prefixIcon: Icon(
                    Icons
                        .confirmation_number_outlined,
                  ),
                  border:
                      OutlineInputBorder(),
                ),
                validator:
                    (value) {
                  if (value ==
                          null ||
                      value
                          .trim()
                          .isEmpty) {
                    return 'Enter ticket name.';
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 16,
              ),

              TextFormField(
                controller:
                    _descriptionController,
                maxLines: 2,
                textInputAction:
                    TextInputAction.next,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Description',
                  hintText:
                      'e.g. Valid student ID required',
                  prefixIcon: Icon(
                    Icons
                        .description_outlined,
                  ),
                  border:
                      OutlineInputBorder(),
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              TextFormField(
                controller:
                    _priceController,
                keyboardType:
                    const TextInputType
                        .numberWithOptions(
                  decimal: true,
                ),
                textInputAction:
                    TextInputAction.next,
                decoration:
                    const InputDecoration(
                  labelText: 'Price',
                  hintText: 'e.g. 500',
                  prefixIcon: Icon(
                    Icons
                        .payments_outlined,
                  ),
                  prefixText:
                      'Rs. ',
                  border:
                      OutlineInputBorder(),
                ),
                validator:
                    (value) {
                  final price =
                      double.tryParse(
                    value?.trim() ??
                        '',
                  );

                  if (price ==
                          null ||
                      price < 0) {
                    return 'Enter a valid price.';
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 16,
              ),

              TextFormField(
                controller:
                    _quantityController,
                keyboardType:
                    TextInputType.number,
                textInputAction:
                    TextInputAction.done,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Quantity',
                  hintText:
                      'e.g. 100',
                  prefixIcon: Icon(
                    Icons
                        .inventory_2_outlined,
                  ),
                  border:
                      OutlineInputBorder(),
                ),
                validator:
                    (value) {
                  final quantity =
                      int.tryParse(
                    value?.trim() ??
                        '',
                  );

                  if (quantity ==
                          null ||
                      quantity <= 0) {
                    return 'Enter a valid quantity.';
                  }

                  final existing =
                      widget
                          .ticketType;

                  if (existing !=
                          null &&
                      quantity <
                          existing
                              .sold) {
                    return 'Cannot be less than '
                        'tickets sold '
                        '(${existing.sold}).';
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 8,
              ),

              SwitchListTile(
                contentPadding:
                    EdgeInsets.zero,
                title:
                    const Text(
                  'Active',
                ),
                subtitle:
                    const Text(
                  'Participants can purchase this ticket.',
                ),
                value:
                    _isActive,
                onChanged:
                    (value) {
                  setState(() {
                    _isActive =
                        value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(
              context,
            );
          },
          child:
              const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(
            isEditing
                ? 'Save Changes'
                : 'Add Ticket',
          ),
        ),
      ],
    );
  }
}