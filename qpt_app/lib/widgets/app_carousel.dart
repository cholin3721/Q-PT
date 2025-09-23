// lib/widgets/app_carousel.dart

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'app_button.dart';

// 구형 버전에 맞춰 StatefulWidget으로 변경합니다.
class AppCarousel extends StatefulWidget {
  const AppCarousel({super.key});

  @override
  State<AppCarousel> createState() => _AppCarouselState();
}

class _AppCarouselState extends State<AppCarousel> {
  // 1. 에러 메시지가 말한 대로 CarouselSliderController를 사용합니다.
  final CarouselSliderController _controller = CarouselSliderController();
  // 2. 현재 페이지 번호를 저장할 변수를 추가합니다.
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = List.generate(
      5,
      (index) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text('Slide ${index + 1}', style: const TextStyle(fontSize: 24)),
        ),
      ),
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        CarouselSlider(
          items: items,
          carouselController: _controller,
          options: CarouselOptions(
            height: 200,
            autoPlay: false,
            enlargeCenterPage: true,
            viewportFraction: 0.8,
            // 3. 페이지가 바뀔 때마다 _currentPage 변수를 업데이트합니다.
            onPageChanged: (index, reason) {
              setState(() {
                _currentPage = index;
              });
            },
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppButton(
                    // 4. animateToPage 메소드를 사용해 이전 페이지로 이동합니다.
                    onPressed: () => _controller.animateToPage(_currentPage - 1),
                    variant: AppButtonVariant.outline,
                    size: AppButtonSize.icon,
                    child: const Icon(Icons.arrow_back_ios_new, size: 16),
                  ),
                  AppButton(
                    // 5. animateToPage 메소드를 사용해 다음 페이지로 이동합니다.
                    onPressed: () => _controller.animateToPage(_currentPage + 1),
                    variant: AppButtonVariant.outline,
                    size: AppButtonSize.icon,
                    child: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}