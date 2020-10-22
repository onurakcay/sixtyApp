import 'package:get_it/get_it.dart';
import 'package:sixtyseconds/Repository/userRepository.dart';
import 'package:sixtyseconds/Services/fake_authentication_service.dart';
import 'package:sixtyseconds/Services/firebase_auth_service.dart';
import 'package:sixtyseconds/Services/firebase_storage_service.dart';
import 'package:sixtyseconds/Services/firestore_db_service.dart';
import 'package:sixtyseconds/Services/send_notification_service.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => FirebaseAuthService());
  locator.registerLazySingleton(() => FakeAuthenticationService());
  locator.registerLazySingleton(() => FireStoreDbService());
  locator.registerLazySingleton(() => FirebaseStorageService());
  locator.registerLazySingleton(() => UserRepository());
  locator.registerLazySingleton(() => SendNotificationService());
}
