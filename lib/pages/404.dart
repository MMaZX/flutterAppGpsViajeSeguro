import 'package:flutter/cupertino.dart';

class NotFound404 extends StatelessWidget {
  const NotFound404({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
          padding: EdgeInsets.all(30),
          child: Text("No se ha encontrado esta página. Vuelve a intentarlo.")),
    );
  }
}
