import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream para escuchar el estado del usuario (login/logout)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Registrar usuario
  Future<String?> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // Éxito
    } on FirebaseAuthException catch (e) {
      return e.message; // Error específico
    } catch (e) {
      return 'Error inesperado: $e';
    }
  }

  // Iniciar sesión
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // Éxito
    } on FirebaseAuthException catch (e) {
      return e.message; // Error específico
    } catch (e) {
      return 'Error inesperado: $e';
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Obtener usuario actual
  User? get currentUser => _auth.currentUser;

  // Método para enviar un correo de recuperación de contraseña
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Éxito
    } on FirebaseAuthException catch (e) {
      return e.message; // Error específico
    } catch (e) {
      return 'Error inesperado: $e';
    }
  }

}


