import 'dart:convert';

/// Lokalno dekodira JWT payload bez vanjskog paketa.
/// Ne verificira potpis — samo čita claims za UI prikaz.
class JwtDecoder {
  JwtDecoder._();

  static Map<String, dynamic>? decode(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Base64url → Base64 → decode
      String payload = parts[1];
      payload = payload.replaceAll('-', '+').replaceAll('_', '/');
      switch (payload.length % 4) {
        case 2: payload += '==';
        case 3: payload += '=';
      }
      final decoded = utf8.decode(base64Decode(payload));
      return json.decode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // .NET ClaimTypes.Name → http://schemas.xmlsoap.org/.../name
  static String? getName(String token) {
    final claims = decode(token);
    return claims?['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name']
        as String?;
  }

  static String? getEmail(String token) {
    final claims = decode(token);
    return claims?['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress']
        as String?;
  }
}