import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import 'signup_state.dart';

// Step 3: Name + Birthdate
class NameBirthdateStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;

  const NameBirthdateStep({super.key, required this.onNext});

  @override
  ConsumerState<NameBirthdateStep> createState() => _NameBirthdateStepState();
}

class _NameBirthdateStepState extends ConsumerState<NameBirthdateStep> {
  final _nameController = TextEditingController();
  DateTime _selectedDate = DateTime(2000, 1, 1);

  @override
  void initState() {
    super.initState();
    _nameController.text = ref.read(signupStateProvider).name;
    _selectedDate = ref.read(signupStateProvider).birthdate ?? DateTime(2000, 1, 1);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isValid => _nameController.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameController,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  onChanged: (value) {
                    ref.read(signupStateProvider.notifier).setName(value);
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Update',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'Enter your birthdate',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: _selectedDate,
              minimumYear: 1900,
              maximumYear: DateTime.now().year,
              onDateTimeChanged: (DateTime newDate) {
                setState(() {
                  _selectedDate = newDate;
                });
                ref.read(signupStateProvider.notifier).setBirthdate(newDate);
              },
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Knowing your age helps keep Pinterest safe for everyone. It won\'t be visible to others.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isValid ? widget.onNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isValid ? AppTheme.pinterestRed : Colors.grey[300],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: Text(
                'Next',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _isValid ? Colors.white : Colors.grey[600],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// Step 4: Gender
class GenderStep extends ConsumerWidget {
  final VoidCallback onNext;

  const GenderStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Text(
            'What gender do you identify as?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'This will influence the content you see. It won\'t be visible to others.',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 32),
          _GenderButton(
            label: 'Female',
            onTap: () {
              ref.read(signupStateProvider.notifier).setGender('Female');
              Future.delayed(const Duration(milliseconds: 200), onNext);
            },
          ),
          const SizedBox(height: 16),
          _GenderButton(
            label: 'Male',
            onTap: () {
              ref.read(signupStateProvider.notifier).setGender('Male');
              Future.delayed(const Duration(milliseconds: 200), onNext);
            },
          ),
          const SizedBox(height: 16),
          _GenderButton(
            label: 'Specify another',
            onTap: () {
              ref.read(signupStateProvider.notifier).setGender('Other');
              Future.delayed(const Duration(milliseconds: 200), onNext);
            },
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _GenderButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _GenderButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

// Step 5: Location
class LocationStep extends ConsumerWidget {
  final VoidCallback onNext;

  const LocationStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(signupStateProvider).location;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Text(
            'Where do you live?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'This helps us find more relevant content for you. We won\'t show it on your profile.',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 32),
          InkWell(
            onTap: () {
              // TODO: Show country picker
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    location,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.pinterestRed,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'Next',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
