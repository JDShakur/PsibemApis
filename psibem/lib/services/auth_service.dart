import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lista de e-mails administradores (backup caso Firestore falhe)
  static const List<String> _adminEmails = [
    'jennytestes@gmail.com',
    'admin@exemplo.com'
  ];

  // Método de registro de usuário
  Future<UserCredential> registerUser(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Cria documento do usuário na coleção 'usuarios'
      await _firestore
          .collection('usuarios')
          .doc(userCredential.user?.uid)
          .set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'isAdmin': false, // Por padrão, novos usuários não são admin
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _getFirebaseErrorMessage(e);
    } catch (e) {
      throw 'Erro desconhecido: $e';
    }
  }

  // Método de login com verificação de admin
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Verificação redundante de admin (Firestore + e-mail)
      final isAdmin = await _checkAdminStatus(userCredential.user!);

      return {
        'user': userCredential.user,
        'isAdmin': isAdmin,
      };
    } on FirebaseAuthException catch (e) {
      throw _getFirebaseErrorMessage(e);
    } catch (e) {
      throw 'Erro ao fazer login: $e';
    }
  }

  // Verificação robusta de status de admin
  Future<bool> _checkAdminStatus(User user) async {
    // 1. Verificação por e-mail (fallback rápido)
    if (_adminEmails.contains(user.email?.toLowerCase().trim())) {
      return true;
    }

    // 2. Verificação no Firestore
    try {
      final doc =
          await _firestore.collection('admin_users').doc(user.uid).get();
      return doc.exists &&
          ['admin', 'superadmin', 'crp_validator']
              .contains(doc.data()?['level']?.toString().toLowerCase());
    } catch (e) {
      debugPrint('Erro ao verificar admin no Firestore: $e');
      return false;
    }
  }

  // Método para logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Stream para verificar estado de autenticação
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Tratamento de erros
  String _getFirebaseErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return "E-mail inválido.";
      case 'user-disabled':
        return "Esta conta foi desativada.";
      case 'user-not-found':
        return "Nenhuma conta encontrada para este e-mail.";
      case 'wrong-password':
        return "Senha incorreta.";
      case 'weak-password':
        return "Senha fraca. Use pelo menos 6 caracteres.";
      case 'email-already-in-use':
        return "E-mail já cadastrado.";
      case 'network-request-failed':
        return "Falha na conexão. Verifique sua internet.";
      default:
        return "Erro de autenticação: ${error.message}";
    }
  }
}
