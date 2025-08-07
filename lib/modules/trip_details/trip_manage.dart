import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:trip_split/styles.dart';
import '../../hive_modal/trip/trip.dart';

class TripFormScreen extends StatefulWidget {
  final Trip? trip;

  const TripFormScreen({Key? key, this.trip}) : super(key: key);

  @override
  State<TripFormScreen> createState() => _TripFormScreenState();
}

class _TripFormScreenState extends State<TripFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _tagController;
  DateTime? _selectedDate;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.trip?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.trip?.description ?? '',
    );
    _tagController = TextEditingController();
    _selectedDate = widget.trip?.date;
    _tags =
        widget.trip?.members?.toList() ??
        []; // Make sure 'tags' is defined in Trip model
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.teal,
              onPrimary: Colors.white,
              onSurface: Colors.white,
              surface: Color(0xFF25334A),
            ),
            dialogBackgroundColor: Color(0xFF25334A),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _addTag(String value) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty && !_tags.contains(trimmed)) {
      setState(() {
        _tags.add(trimmed);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _saveForm() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) return;

    final box = await Hive.openBox<Trip>('tripsBox');

    if (widget.trip == null) {
      final trip = Trip(
        title: _titleController.text,
        description: _descriptionController.text,
        date: _selectedDate!,
        members: _tags,
      );
      await box.add(trip);
    } else {
      widget.trip!
        ..title = _titleController.text
        ..description = _descriptionController.text
        ..date = _selectedDate!
        ..members = _tags;
      await widget.trip!.save();
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.trip != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Trip' : 'Add Trip'),
        backgroundColor: AppStyles.whiteColor,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppStyles.whiteColor, // or any color like Color(0xFF25334A)
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Please enter a title'
                              : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Please enter a description'
                              : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedDate == null
                            ? 'Trip date: mm-dd-yyyy'
                            : 'Trip date: Selected: ${DateFormat.yMMMd().format(_selectedDate!)}',
                      ),
                    ),
                    TextButton(
                      onPressed: _selectDate,
                      child: const Text('Pick Date'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Tag input
                TextFormField(
                  controller: _tagController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                    labelText: "Add Tag",
                    suffixIcon: Container(
                      margin: EdgeInsets.only(right: 6.0), // 🔹 Set your desired margin here
                      child: IconButton(
                        icon: Icon(Icons.add),
                        style: AppStyles.buttonStyle,
                        onPressed: () => _addTag(_tagController.text),
                      ),
                    ),
                  ),
                  onFieldSubmitted: _addTag,
                ),
                const SizedBox(height: 10),

                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children:
                      _tags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          onDeleted: () => _removeTag(tag),
                          deleteIcon: Icon(Icons.close),
                          backgroundColor: Colors.blue.shade100,
                        );
                      }).toList(),
                ),

                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: _saveForm,
                    style: AppStyles.buttonStyle,
                    child: Text(isEditing ? 'Update' : 'Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
