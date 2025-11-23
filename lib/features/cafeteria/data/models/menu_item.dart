import 'package:equatable/equatable.dart';

class MenuItem extends Equatable {
  final String name;
  final String ingredients;
  final int calories;
  final String? carbohydrates;

  const MenuItem({
    required this.name,
    required this.ingredients,
    required this.calories,
    this.carbohydrates,
  });

  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem(
      name: map['name'] ?? '',
      ingredients: map['ingredients'] ?? '',
      calories: map['calories'] ?? 0,
      carbohydrates: map['carbohydrates'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'ingredients': ingredients,
      'calories': calories,
      'carbohydrates': carbohydrates,
    };
  }

  @override
  List<Object?> get props => [name, ingredients, calories, carbohydrates];
}