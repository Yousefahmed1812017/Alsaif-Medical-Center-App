
import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    String content = file.readAsStringSync();
    if (content.contains('AppColors.primaryGreen') || 
        content.contains('AppColors.accentBlue') || 
        content.contains('AppColors.softGreen') || 
        content.contains('AppColors.primary600') || 
        content.contains(RegExp(r'AppColors\.primary50\b')) || 
        content.contains('AppColors.greenDark') || 
        content.contains('AppColors.accentBlueDark') || 
        content.contains('AppColors.softBlue')) {
      
      content = content.replaceAll('AppColors.primaryGreen', 'AppColors.primary500');
      content = content.replaceAll('AppColors.accentBlueDark', 'AppColors.primary900');
      content = content.replaceAll('AppColors.accentBlue', 'AppColors.primary700');
      content = content.replaceAll('AppColors.softGreen', 'AppColors.primary100');
      content = content.replaceAll('AppColors.primary600', 'AppColors.primary700');
      content = content.replaceAllMapped(RegExp(r'AppColors\.primary50\b'), (m) => 'AppColors.primary100');
      content = content.replaceAll('AppColors.greenDark', 'AppColors.primary900');
      content = content.replaceAll('AppColors.softBlue', 'AppColors.primary100');
      
      file.writeAsStringSync(content);
    }
  }
  print("Replacement done via Dart.");
}

