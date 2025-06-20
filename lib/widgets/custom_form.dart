import 'package:flutter/material.dart';
// For a real image picker, you'd import:
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';

// --- Data Models (Optional but good practice) ---
class SelectOption {
  final String value;
  final String label;
  SelectOption({required this.value, required this.label});
}

class CheckboxOption {
  final String id;
  final String label;
  bool isChecked;
  CheckboxOption({required this.id, required this.label, this.isChecked = false});
}

// --- The Form Widget ---
class CustomFormWidget extends StatefulWidget {
  final Function(Map<String, dynamic> formData) onSubmit;

  const CustomFormWidget({super.key, required this.onSubmit});

  @override
  State<CustomFormWidget> createState() => _CustomFormWidgetState();
}

class _CustomFormWidgetState extends State<CustomFormWidget> {
  final _formKey = GlobalKey<FormState>();

  // --- Form Field States ---
  // 1. Select Box
  SelectOption? _selectedCategory;
  final List<SelectOption> _categoryOptions = [
    SelectOption(value: 'tech', label: 'Technology'),
    SelectOption(value: 'health', label: 'Healthcare'),
    SelectOption(value: 'finance', label: 'Finance'),
    SelectOption(value: 'art', label: 'Art & Design'),
  ];

  // 2. Checkboxes
  final List<CheckboxOption> _featureOptions = [
    CheckboxOption(id: 'feat_a', label: 'Enable Feature A'),
    CheckboxOption(id: 'feat_b', label: 'Include Feature B'),
    CheckboxOption(id: 'feat_c', label: 'Activate Feature C (Premium)'),
  ];

  // 3. Text Input
  final TextEditingController _descriptionController = TextEditingController();

  // 4. Image Uploader (Conceptual)
  String? _imagePath; // In a real app, this might be File or XFile
  String? _imageName;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _pickImage() async {
    // --- Conceptual Image Picking ---
    // In a real app, use image_picker:
    // final ImagePicker picker = ImagePicker();
    // final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    // if (image != null) {
    //   setState(() {
    //     _imagePath = image.path;
    //     _imageName = image.name;
    //   });
    // }
    setState(() {
      _imagePath = "dummy_path/image_preview.png"; // Simulate image selection
      _imageName = "image_preview.png";
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Simulated Image Picked!')),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Collect form data
      List<String> selectedFeatures = _featureOptions
          .where((opt) => opt.isChecked)
          .map((opt) => opt.id)
          .toList();

      Map<String, dynamic> formData = {
        'category': _selectedCategory?.value,
        'features': selectedFeatures,
        'description': _descriptionController.text,
        'imageName': _imageName,
        'imagePath': _imagePath, // In real scenario, you'd upload the File at _imagePath
      };

      widget.onSubmit(formData); // Pass data to the callback

      // Optional: Clear form after submission
      // _clearForm();
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    setState(() {
      _selectedCategory = null;
      for (var opt in _featureOptions) {
        opt.isChecked = false;
      }
      _descriptionController.clear();
      _imagePath = null;
      _imageName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column( // Use ListView for scrollability if form is long
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- 1. Select Box (Dropdown) ---
            Text('Select Category:', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<SelectOption>(
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                hintText: 'Choose a category',
              ),
              value: _selectedCategory,
              isExpanded: true,
              items: _categoryOptions.map((SelectOption option) {
                return DropdownMenuItem<SelectOption>(
                  value: option,
                  child: Text(option.label),
                );
              }).toList(),
              onChanged: (SelectOption? newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a category.';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
        
            // --- 2. Checkboxes ---
            Text('Select Features:', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            ..._featureOptions.map((CheckboxOption option) { // Using spread operator to add list of widgets
              return CheckboxListTile(
                title: Text(option.label),
                value: option.isChecked,
                onChanged: (bool? newValue) {
                  setState(() {
                    option.isChecked = newValue ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading, // Checkbox on left
                contentPadding: EdgeInsets.zero,
              );
            }).toList(),
            const SizedBox(height: 20),
        
            // --- 3. Text Input ---
            Text('Description:', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter a detailed description...',
                labelText: 'Project Description',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description.';
                }
                if (value.length < 10) {
                  return 'Description must be at least 10 characters long.';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
        
            // --- 4. Image Uploader (Conceptual) ---
            Text('Upload Image:', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                border: Border.all(color: theme.dividerColor),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_imagePath != null) ...[ // If image is "selected"
                    // In a real app, use Image.file(File(_imagePath!))
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4.0),
                        // image: DecorationImage(
                        //   image: AssetImage("assets/placeholder_image.png"), // Placeholder if path is dummy
                        //   fit: BoxFit.cover,
                        // ),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image, size: 50, color: Colors.grey[600]),
                          const SizedBox(height: 8),
                          Text(_imageName ?? 'No image selected', style: TextStyle(color: Colors.grey[700])),
                          TextButton.icon(
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: const Text('Remove'),
                            onPressed: () => setState(() {
                              _imagePath = null;
                              _imageName = null;
                            }),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.cloud_upload_outlined),
                    label: Text(_imagePath == null ? 'Select Image' : 'Change Image'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _imagePath == null ? theme.colorScheme.primary : theme.colorScheme.secondary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                  ),
                  if (_imagePath == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('No image selected.', style: theme.textTheme.bodySmall),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 30),
        
            // --- Submit Button ---
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: const Text('Submit Project'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _clearForm,
              child: const Text('Clear Form'),
            )
          ],
        ),
      ),
    );
  }
}