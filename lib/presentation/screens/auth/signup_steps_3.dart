import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import 'signup_state.dart';

// Step 6: Interests
class InterestsStep extends ConsumerWidget {
  final VoidCallback onNext;

  const InterestsStep({super.key, required this.onNext});

  static const List<Map<String, String>> interests = [
    {'name': 'Sneakers', 'emoji': '👟'},
    {'name': 'Anime and comics', 'emoji': '📚'},
    {'name': 'Nail trends', 'emoji': '💅'},
    {'name': 'Travel', 'emoji': '✈️'},
    {'name': 'Plants', 'emoji': '🌿'},
    {'name': 'Weddings', 'emoji': '💒'},
    {'name': 'Outfit ideas', 'emoji': '👗'},
    {'name': 'Classroom ideas', 'emoji': '📝'},
    {'name': 'Hair inspiration', 'emoji': '💇'},
    {'name': 'Beauty', 'emoji': '💄'},
    {'name': 'Food', 'emoji': '🍕'},
    {'name': 'Home decor', 'emoji': '🏠'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedInterests = ref.watch(signupStateProvider).interests;
    final isValid = selectedInterests.length >= 3;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'What are you in the mood to do?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Pick 3 or more to curate your experience',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: interests.length,
              itemBuilder: (context, index) {
                final interest = interests[index];
                final isSelected = selectedInterests.contains(interest['name']);

                return InkWell(
                  onTap: () {
                    ref.read(signupStateProvider.notifier).toggleInterest(interest['name']!);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppTheme.pinterestRed : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                interest['emoji']!,
                                style: const TextStyle(fontSize: 40),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  interest['name']!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppTheme.pinterestRed,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isValid ? onNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isValid ? AppTheme.pinterestRed : Colors.grey[300],
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
                  color: isValid ? Colors.white : Colors.grey[600],
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

// Step 7: Loading
class LoadingStep extends ConsumerStatefulWidget {
  const LoadingStep({super.key});

  @override
  ConsumerState<LoadingStep> createState() => _LoadingStepState();
}

class _LoadingStepState extends ConsumerState<LoadingStep> {
  bool _showTuning = false;

  @override
  void initState() {
    super.initState();
    // Show "Great Picks!" for 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showTuning = true;
        });
        // Then show "Tuning your feed..." for 2 seconds before navigating
        Future.delayed(const Duration(milliseconds: 2000), () {
          if (mounted) {
            context.go('/');
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final interests = ref.watch(signupStateProvider).interests;

    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_showTuning) ...[
              // Great Picks screen
              const Text(
                'Great Picks!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 40),
              // Show selected interests as cards
              SizedBox(
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    for (int i = 0; i < (interests.length > 3 ? 3 : interests.length); i++)
                      Transform.rotate(
                        angle: (i - 1) * 0.15,
                        child: Container(
                          width: 140,
                          height: 180,
                          margin: EdgeInsets.only(left: i * 20.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              interests[i],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Image.asset(
                'assets/logo.png',
                width: 60,
                height: 60,
              ),
            ] else ...[
              // Tuning your feed screen
              const Text(
                'Tuning your feed...',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 40),
              // Animated cards
              SizedBox(
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    for (int i = 0; i < (interests.length > 3 ? 3 : interests.length); i++)
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: Duration(milliseconds: 500 + (i * 200)),
                        builder: (context, double value, child) {
                          return Transform.rotate(
                            angle: (i - 1) * 0.15 * value,
                            child: Opacity(
                              opacity: value,
                              child: Container(
                                width: 140,
                                height: 180,
                                margin: EdgeInsets.only(left: i * 20.0 * value),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    interests[i],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Image.asset(
                'assets/logo.png',
                width: 60,
                height: 60,
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.pinterestRed),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
