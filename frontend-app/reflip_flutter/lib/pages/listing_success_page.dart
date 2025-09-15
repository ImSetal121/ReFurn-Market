import 'package:flutter/material.dart';

class ListingSuccessPage extends StatelessWidget {
  const ListingSuccessPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.50, 0.00),
            end: Alignment(0.50, 1.00),
            colors: [Color(0xFFDFF9FF), Color(0xFFFFF6E5), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Success illustration
              Positioned(
                left: 11,
                top: 191,
                child: Container(
                  width: 371,
                  height: 371,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        "assets/images/listing_success_illustration.png",
                      ),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              // Bottom button section
              Positioned(
                left: 12,
                bottom: 50,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // View My Posted Orders Button
                      GestureDetector(
                        onTap: () {
                          // Navigate to home page with profile tab selected
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/home',
                            (route) => false,
                            arguments: {'selectedTab': 3}, // Profile tab index
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          height: 48,
                          decoration: ShapeDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment(0.00, 0.50),
                              end: Alignment(1.00, 0.50),
                              colors: [Color(0xFFFFA500), Color(0xFFFFB631)],
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'View My Posted Orders',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Secondary button - Back to Home
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/home',
                            (route) => false,
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          height: 48,
                          decoration: ShapeDecoration(
                            color: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                color: Color(0xFFFFA500),
                                width: 1,
                              ),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Back to Home',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFFFA500),
                                fontSize: 16,
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
 