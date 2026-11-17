/// Modelo que representa la información de personalización del perfil del usuario.
/// Persistido en Cloud Firestore en la ruta: usuarios/{uid}/perfil/datos
class PerfilUsuario {
  final String? avatarId;
  final String? fotoBase64;

  const PerfilUsuario({
    this.avatarId,
    this.fotoBase64,
  });

  /// Crea una instancia de [PerfilUsuario] a partir de los datos en Firestore.
  factory PerfilUsuario.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const PerfilUsuario();
    }
    return PerfilUsuario(
      avatarId: map['avatarId'] as String?,
      fotoBase64: map['fotoBase64'] as String?,
    );
  }

  /// Convierte la instancia en un mapa serializable para Firestore.
  Map<String, dynamic> toMap() {
    return {
      'avatarId': avatarId,
      'fotoBase64': fotoBase64,
    };
  }

  /// Crea una copia del modelo con valores actualizados.
  PerfilUsuario copyWith({
    String? avatarId,
    String? fotoBase64,
    bool eliminarFoto = false,
  }) {
    return PerfilUsuario(
      avatarId: avatarId ?? this.avatarId,
      fotoBase64: eliminarFoto ? null : (fotoBase64 ?? this.fotoBase64),
    );
  }
}
