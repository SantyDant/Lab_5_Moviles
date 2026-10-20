/// Error de autenticación con un mensaje listo para mostrar al usuario.
///
/// La capa de datos traduce las excepciones de Supabase a [AuthFailure],
/// así la interfaz nunca depende de los tipos de Supabase.
class AuthFailure implements Exception {
  final String message;

  const AuthFailure(this.message);

  @override
  String toString() => message;
}
