import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

// Definimos los scopes que necesitamos
const List<String> scopes = <String>[
  'email',
  'https://www.googleapis.com/auth/userinfo.profile',
];

// Inicializamos GoogleSignIn con tu clientId
final GoogleSignIn googleSignIn = GoogleSignIn(
  clientId:
      '540563155539-lj9eqt4sb0273h1luu4ulugubkio7m6o.apps.googleusercontent.com',
  scopes: scopes,
);

class GoogleAuthService {
  // Método para iniciar sesión
  Future<GoogleSignInAccount?> signIn() async {
    try {
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account != null) {
        // Obtener token de autenticación para enviar al backend
        final GoogleSignInAuthentication auth = await account.authentication;
        print('ID Token: ${auth.idToken}'); // Este token se envía al backend
        print('Access Token: ${auth.accessToken}');

        // Imprimir datos del usuario
        printUserData(account);

        return account;
      }
      return null;
    } catch (error) {
      print('Error al iniciar sesión con Google: $error');
      return null;
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

  // Método para imprimir los datos del usuario
  void printUserData(GoogleSignInAccount account) {
    print('Usuario autenticado:');
    print('ID: ${account.id}');
    print('Email: ${account.email}');
    print('Nombre: ${account.displayName}');
    print('Foto URL: ${account.photoUrl}');

    // Puedes enviar estos datos al backend en formato JSON
    final Map<String, dynamic> userData = {
      'id': account.id,
      'email': account.email,
      'name': account.displayName,
      'photoUrl': account.photoUrl,
    };

    print('Datos para enviar al backend: $userData');
  }

  // Método para obtener los datos del usuario en formato Map
  Map<String, dynamic> getUserData(GoogleSignInAccount account) {
    return {
      'id': account.id,
      'email': account.email,
      'name': account.displayName,
      'photoUrl': account.photoUrl,
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
