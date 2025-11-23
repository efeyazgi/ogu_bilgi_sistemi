import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:http/http.dart' as http;
import '../models/cafeteria_menu.dart';

class CafeteriaService {
  static const String _url = 'https://yemekhane.ogu.edu.tr';

  Future<List<CafeteriaMenu>> fetchMenus() async {
    try {
      final response = await http.get(Uri.parse(_url));
      
      if (response.statusCode != 200) {
        throw Exception('Failed to load cafeteria page');
      }

      // Fix encoding if needed, usually utf-8 is fine but sometimes Turkish chars need windows-1254
      // However, modern http package handles charset from content-type usually.
      // We'll assume utf-8 or auto-detection works.
      
      final soup = BeautifulSoup(response.body);
      final List<CafeteriaMenu> menus = [];

      // Based on the markdown conversion seen:
      // Headers are dates.
      // We need to find the HTML structure. 
      // Usually it's <h3>Date</h3> followed by content.
      // Let's look for h3 tags.
      
      final panels = soup.findAll('div', class_: 'panel panel-default yemek-menu-panel');

      for (var panel in panels) {
        // Extract Date
        final dateElement = panel.find('h3', class_: 'panel-title');
        if (dateElement == null) continue;
        
        final date = dateElement.text.trim();
        final List<String> items = [];

        // Extract Menu Items
        final panelBody = panel.find('div', class_: 'panel-body');
        if (panelBody != null) {
          final listItems = panelBody.findAll('li');
          for (var li in listItems) {
            // Skip empty or clearfix list items
            if (li.classes.contains('clearfix')) continue;

            final foodNameElement = li.find('a');
            final calorieElement = li.find('span', class_: 'yemek-menu-kalori');
            
            if (foodNameElement != null) {
              String foodName = foodNameElement.text.trim();
              // Optional: Add calories to the name if available
              if (calorieElement != null) {
                foodName += ' ${calorieElement.text.trim()}';
              }
              items.add(foodName);
            } else {
              // Fallback for non-link items (e.g. "Hafta Sonu" text in p tag)
              final pTag = li.find('p');
              if (pTag != null) {
                 items.add(pTag.text.trim());
              } else {
                 // Just get text if structure is different
                 final text = li.text.trim();
                 if (text.isNotEmpty) items.add(text);
              }
            }
          }
          
          // Check for "Hafta Sonu" or "Menü hazır değil" text directly in panel-body
          if (items.isEmpty) {
             final pTags = panelBody.findAll('p');
             for (var p in pTags) {
               final text = p.text.trim();
               if (text.isNotEmpty) items.add(text);
             }
          }
        }

        if (items.isNotEmpty) {
          menus.add(CafeteriaMenu(date: date, items: items));
        }
      }

      return menus;
    } catch (e) {
      print('Error fetching menus: $e');
      // Return empty list or rethrow
      return [];
    }
  }
}
