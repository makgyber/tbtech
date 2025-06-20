import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tbtech/widgets/custom_form.dart';

class JobOrderDetailScreen extends ConsumerStatefulWidget {
  const JobOrderDetailScreen({super.key, required this.id});

  final int id;


  @override
  ConsumerState<JobOrderDetailScreen> createState() => _JobOrderDetailScreenState();
}

class _JobOrderDetailScreenState extends ConsumerState<JobOrderDetailScreen> {
  int _currentStep = 0;
  List<Step> _steps = [];


  void _handleFormSubmission(Map<String, dynamic> formData) {
    // Process the collected form data
    print('Form Submitted:');
    formData.forEach((key, value) {
      print('$key: $value');
    });

    // Example: Show a dialog or navigate
    // Show a snackbar (assuming you have a Scaffold context available)
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text('Form submitted successfully! Category: ${formData['category']}')),
    // );
  }

  @override
  Widget build(BuildContext context) {
    _steps = [
      Step(
        title: Text('Start'),
        content: CustomFormWidget(onSubmit: _handleFormSubmission),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : (_currentStep == 0 ? StepState.editing : StepState.indexed),
      ),
      Step(
        title: Text('Pre-service activities'),
        content:  CustomFormWidget(
        onSubmit: _handleFormSubmission,
        ),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : (_currentStep == 1 ? StepState.editing : StepState.indexed),
      ),
      Step(
        title: Text('Service activities'),
        content:  CustomFormWidget(
                onSubmit: _handleFormSubmission,
            ),
        isActive: _currentStep >= 2,
        state: _currentStep > 2 ? StepState.complete : (_currentStep == 2 ? StepState.editing : StepState.indexed),
      ),
      Step(
        title: Text('Post-service activities'),
        content: CustomFormWidget(
          onSubmit: _handleFormSubmission,
        ),
        isActive: _currentStep >= 3,
        state: _currentStep == 3 ? StepState.editing : StepState.indexed, // Last step might always be 'editing' or 'indexed' until submitted
      ),
    ];
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Amaia Skies Cubao Tower 2"),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                onPressed: () {
                  context.pop();
                },
                icon: const Icon(Icons.backspace, color: Colors.blueGrey,)
              );
            }
          )
        ),
        body: Stepper(
          currentStep: _currentStep,
          onStepTapped: (step) => setState(() => _currentStep = step),
          onStepContinue: () {
              if (_currentStep < _steps.length - 1) {
                setState(() => _currentStep += 1);
              } else {
                // Last step: Submit logic
                print("Workflow Submitted!");
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() => _currentStep -= 1);
              }
            },
          steps: _steps,
        ),
      )
    );
  }

}