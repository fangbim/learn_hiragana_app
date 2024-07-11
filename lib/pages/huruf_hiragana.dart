import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learn_hiragana_app/components/card_huruf.dart';
import 'package:learn_hiragana_app/bloc/hiragana_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class HurufHiragana extends StatelessWidget {
  const HurufHiragana({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(right: 16, left: 16, top: 32, bottom: 0),
        child: Column(
          children: [
            Center(
              child: Text('Huruf Hiragana',
                  style: GoogleFonts.bebasNeue(
                      textStyle: const TextStyle(
                          color: Colors.white, fontSize: 36))),
            ),
            const SizedBox(height: 24),
            BlocBuilder<HiraganaBloc, HiraganaState>(
              builder: (context, state) {
                if (state is HiraganaLoading) {
                  return Center(
                    child: LoadingAnimationWidget.inkDrop(
                      color: Colors.white,
                      size: 50,
                    ),
                  );
                } else if (state is HiraganaLoaded) {
                  return Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: GridView.builder(
                        padding: EdgeInsets.zero,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: state.hiraganaCharacters.length,
                        itemBuilder: (context, index) {
                          final character = state.hiraganaCharacters[index];
                          return CardHuruf(
                            karakter: character.karakter,
                            latin: character.latin,
                          );
                        },
                      ),
                    ),
                  );
                } else if (state is HiraganaError) {
                  return Center(
                    child: Text(
                      'Failed to load Hiragana characters: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
