import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class AppBarFeatures extends StatelessWidget {
  final String title;
  final int currentIndex;
  final int questionLength;
  const AppBarFeatures({Key? key, required this.title, required this.currentIndex, required this.questionLength}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle
                  ),
                  child: const Icon(
                    IconlyLight.arrow_left,
                    color: Colors.black,
                    size: 32,
                  ),
                ),
              ),
              Text(title,
                  style: GoogleFonts.sansita(
                      textStyle: const TextStyle(
                          color: Colors.white, fontSize: 22))),
              CircularStepProgressIndicator(
                totalSteps: questionLength + 1,
                currentStep: currentIndex + 2,
                stepSize: 3,
                selectedColor: Colors.green,
                unselectedColor: Colors.black,
                width: 50,
                height: 50,
                selectedStepSize: 5,
                roundedCap: (_, __) => true,
                padding: 0,
                child: Center(
                    child: Text(
                      '${currentIndex + 1}',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    )),
              )
            ],
          );
  }
}