// lib/utils/appwrite_constants.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppwriteConstants {
  static String get projectId => dotenv.env['APPWRITE_PROJECT_ID']!;
  static String get endpoint => dotenv.env['APPWRITE_ENDPOINT']!;
  static String get databaseId => dotenv.env['APPWRITE_DATABASE_ID']!;
  static String get usersCollectionId => dotenv.env['APPWRITE_USERS_COLLECTION_ID']!;
  static String get meetingsCollectionId => dotenv.env['APPWRITE_MEETINGS_COLLECTION_ID']!;
  static String get notesCollectionId => dotenv.env['APPWRITE_NOTES_COLLECTION_ID']!;
}

class HuggingFaceConstants {
  static String get apiToken => dotenv.env['HUGGINGFACE_API_TOKEN']!;
  static String get modelEndpoint => dotenv.env['HUGGINGFACE_API_ENDPOINT']!;
}