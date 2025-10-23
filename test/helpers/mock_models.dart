import 'package:BIBOL/models/topic/topic_model.dart';
import 'package:BIBOL/models/user/user_model.dart';

class MockModels {
  /// Create a mock User object
  static User createMockUser({
    int id = 1,
    String name = 'Test User',
    String href = '/users/1',
  }) {
    return User(id: id, name: name, href: href);
  }

  /// Create a mock Topic object for testing
  static Topic createMockTopic({
    int id = 1,
    String title = 'Test News Title',
    String details = 'Test news details',
    String photoFile = '',
    int visits = 100,
    User? user,
  }) {
    return Topic(
      id: id,
      title: title,
      details: details,
      date: DateTime.now(),
      videoType: null,
      videoFile: '',
      photoFile: photoFile,
      audioFile: null,
      icon: null,
      visits: visits,
      href: '',
      fieldsCount: 0,
      fields: [],
      joinedCategoriesCount: 0,
      joinedCategories: [],
      user: user ?? createMockUser(),
      sectionTitle: null,
      sectionId: null,
    );
  }
}
