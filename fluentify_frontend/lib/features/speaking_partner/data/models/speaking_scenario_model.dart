import '../../domain/entities/speaking_scenario_entity.dart';

class SpeakingScenarioModel extends SpeakingScenarioEntity {
  SpeakingScenarioModel({
    required super.id,
    required super.title,
    required super.description,
    required super.aiRole,
    required super.userRole,
    required super.difficulty,
    required super.image,
  });

  factory SpeakingScenarioModel.fromJson(Map<String, dynamic> json) {
    return SpeakingScenarioModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      aiRole: json['aiRole'],
      userRole: json['userRole'],
      difficulty: json['difficulty'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'aiRole': aiRole,
      'userRole': userRole,
      'difficulty': difficulty,
      'image': image,
    };
  }
}
