import 'dart:io';
import 'package:flutter/material.dart';

/// Resolves a stored avatar reference into an [ImageProvider].
///
/// Supports remote URLs (Google photos) and locally-saved file paths
/// (photos a phone user picks from their gallery). Returns null when there
/// is no usable image so callers can show a fallback icon.
ImageProvider? avatarProvider(String? photoUrl) {
  final value = photoUrl?.trim() ?? '';
  if (value.isEmpty) return null;
  if (value.startsWith('http://') || value.startsWith('https://')) {
    return NetworkImage(value);
  }
  final file = File(value);
  if (file.existsSync()) return FileImage(file);
  return null;
}
