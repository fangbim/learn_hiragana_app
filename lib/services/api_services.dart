import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:learn_hiragana_app/model/model_factories.dart';

class ApiService {
  final String baseUrl = 'https://kosakata-hiragana-api.vercel.app/';

  Future<List<HiraganaCharacters>> fetchHuruf() async {
    final response = await http.get(Uri.parse('${baseUrl}huruf'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => HiraganaCharacters.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<List<Vocab>> fetchHiragana() async{
    final response = await http.get(Uri.parse('${baseUrl}hiragana'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Vocab.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<List<dynamic>> fetchDataShuffle() async {
    final response = await http.get(Uri.parse('https://kosakata-hiragana-api.vercel.app/hiragana'));
    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Vocab.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load words');
    }
  }
}
