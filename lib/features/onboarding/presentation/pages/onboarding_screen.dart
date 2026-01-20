import 'package:flutter/material.dart';
import '../../../../models/onboarding_model.dart';
import '../../../../core/widgets/onboarding_page_widget.dart';
import '../../../../core/widgets/page_indicator_widget.dart';
import '../../../../core/services/storage/user_session_service.dart';
import '../../../../app/routes/app_routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final UserSessionService _sessionService = UserSessionService();

  // indexing of the current page done
  int _currentPage = 0;
  // total number of pages imported from the model
  final int _pageCount = OnboardingData.pages.length;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pageCount - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    await _sessionService.markOnboardingComplete();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button at the top
            _buildSkipButton(),
            // PageView with onboarding pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pageCount,
                itemBuilder: (context, index) {
                  return OnboardingPageWidget(
                    page: OnboardingData.pages[index],
                  );
                },
              ),
            ),

            // Page indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: PageIndicatorWidget(
                currentPage: _currentPage,
                pageCount: _pageCount,
                activeColor: Colors.blue,
                inactiveColor: Colors.grey.shade300,
              ),
            ),

            // Next/Get Started button
            _buildNavigationButton(),

            const SizedBox(height: 31),
          ],
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextButton(
          onPressed: _skipOnboarding,
          child: const Text(
            "Skip",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButton() {
    bool isLastPage = _currentPage == _pageCount - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _nextPage,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(
            isLastPage ? 'Get Started ' : "Next",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
