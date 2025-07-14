import 'dart:math';

class HelperGen {

   String generateUniqueToken() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random.secure();
    return List.generate(
      18,
      (index) => chars[rand.nextInt(chars.length)],
    ).join();
  }
  
}