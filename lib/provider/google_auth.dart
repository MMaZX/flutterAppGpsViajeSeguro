import 'package:app_viaje_seguro/config/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

// Definimos los scopes que necesitamos
const List<String> scopes = <String>[
  'email',
  'https://www.googleapis.com/auth/userinfo.profile',
  'https://www.googleapis.com/auth/contacts.readonly',
];

// Inicializamos GoogleSignIn con tu clientId
final GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: scopes,
);

class GoogleAuthService {
  final WidgetRef ref;
  GoogleAuthService(this.ref);
  // Método para iniciar sesión
  Future<GoogleSignInAccount?> signIn() async {
    try {
      // signOut();
      // return null;
      final GoogleSignInAccount? account = await googleSignIn.signIn();

      if (account != null) {
        // Obtener token de autenticación para enviar al backend
        // final GoogleSignInAuthentication auth = await account.authentication;
        // Map<String, dynamic> userData = getUserData(account);

        return account;
      }
      throw Exception('Error al iniciar sesión con Google');
    } catch (error) {
      throw ExceptionsUtils(error).toString();
    }
  }

  // Método para cerrar sesión
  Future<void> signOut() async {
    try {
      await googleSignIn.signOut();
      print('Sesión cerrada');
    } catch (error) {
      print('Error al cerrar sesión: $error');
    }
  }

  Map<String, dynamic> getUserData(
    GoogleSignInAccount account, {
    required String user,
    required String password,
    required String rol,
    required String country,
    required String address,
    required int age,
    required String genre,
    required String phone,
    required String identification,
  }) {
    return {
      'id': account.id,
      'email': account.email,
      'name': account.displayName,
      'photoUrl': account.photoUrl,
      'user': user,
      'password': password,
      'rol': rol,
      'country': country,
      'address': address,
      'age': age,
      'genre': genre,
      'phone': phone,
      'identification': identification,
    };
  }
}

// Widget botón de inicio de sesión con Google
class GoogleSignInButton extends StatelessWidget {
  final Function() onPressed;

  const GoogleSignInButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ShadButton.destructive(
      width: double.maxFinite,
      onPressed: onPressed,
      child: const Expanded(
        child: Text(
          'Iniciar sesión con Google',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
