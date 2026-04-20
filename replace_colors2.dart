
import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    String content = file.readAsStringSync();
    if (content.contains(RegExp(r'AppColors\.primary[1-4]00'))) {
      
      content = content.replaceAll('AppColors.primary100', 'AppColors.primary100');
      content = content.replaceAll('AppColors.primary200', 'AppColors.primary300');
      content = content.replaceAll('AppColors.primary400', 'AppColors.primary500');
      
      file.writeAsStringSync(content);
    }
  }
  print("Secondary replacement done.");
}

