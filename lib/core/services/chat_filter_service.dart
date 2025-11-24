import 'package:amayalert/core/constant/constant.dart';
import 'package:flutter/foundation.dart';

/// Service to filter inappropriate content from chat messages
/// Supports English, Tagalog, and Bisaya profanity and inappropriate language
class ChatFilterService {
  // English profanity and inappropriate words
  static const List<String> _englishProfanity = [
    'fuck',
    'shit',
    'damn',
    'hell',
    'bitch',
    'asshole',
    'bastard',
    'crap',
    'piss',
    'slut',
    'whore',
    'motherfucker',
    'cocksucker',
    'dickhead',
    'pussy',
    'cock',
    'dick',
    'penis',
    'vagina',
    'tits',
    'boobs',
    'ass',
    'stupid',
    'idiot',
    'moron',
    'retard',
    'dumb',
    'loser',
    'ugly',
    'kill yourself',
    'kys',
    'suicide',
    'die',
    'death',
    'murder',
  ];

  // Tagalog profanity and inappropriate words
  static const List<String> _tagalogProfanity = [
    'putang ina',
    'putangina',
    'gago',
    'gaga',
    'bobo',
    'tanga',
    'ulol',
    'hudas',
    'lintik',
    'peste',
    'bwisit',
    'kingina',
    'pakyu',
    'fuck you',
    'tangina',
    'punyeta',
    'pakingshet',
    'pakshet',
    'leche',
    'kupal',
    'puta',
    'patay',
    'mamatay',
    'walang kwenta',
    'walang utak',
    'animal',
    'hayop',
    'demonyong',
    'demonyo',
    'diablo',
    'satanas',
    'bruha',
    'tarantado',
    'hinayupak',
    'anak ng puta',
    'putang',
    'yawa',
    'panget',
    'pangit',
    'mukha mong',
    'mukha mo',
    'amputa',
    'amp',
  ];

  // Bisaya/Cebuano profanity and inappropriate words
  static const List<String> _bisayaProfanity = [
    'yawa',
    'yawaa',
    'pisti',
    'pisteng yawa',
    'atay',
    'ay sus',
    'buang',
    'buogo',
    'boang',
    'tarantado',
    'animal ka',
    'hayop ka',
    'putang',
    'puta',
    'pucha',
    'pakyu',
    'fuck you ka',
    'gago ka',
    'ulol ka',
    'bobo ka',
    'tanga ka',
    'buwisit',
    'bwisit ka',
    'lintian',
    'lintik',
    'anak sa yawa',
    'anak sa demonyo',
    'demonyo ka',
    'yudiputa',
    'yudeputa',
    'pesteng',
    'peste ka',
    'pangit mo',
    'panget mo',
    'unya',
    'unsa man',
    'unsaon ta ka',
    'patyon tika',
    'patay ka',
    'mamatay ka',
    'way kwenta',
  ];

  // Variations and common misspellings/leetspeak
  static const List<String> _variations = [
    'f*ck',
    'f**k',
    'sh*t',
    'sh**',
    'd*mn',
    'b*tch',
    'a**hole',
    'fck',
    'fuk',
    'shyt',
    'sht',
    'dmn',
    'btch',
    'asz',
    'azz',
    '4ss',
    'a55',
    'fvck',
    'shiet',
    'sheyt',
    'bych',
    'beyotch',
    'p*ta',
    'p**a',
    'g*go',
    'b*bo',
    't*nga',
    'ul*l',
    'put*ng',
    'y*wa',
    'bu*ng',
    'p*sti',
    'dem*nyo',
    'an*mal',
    'h*yop',
    'fv<k',
    'sh!t',
    'd@mn',
    'b!tch',
    '@sshole',
    'gag0',
    'bob0',
    'tang@',
    'ul0l',
    'put@ng',
    'y@wa',
    'bu@ng',
    'p!sti',
  ];

  // Combine all profanity lists
  static final List<String> _allProfanity = [
    ..._englishProfanity,
    ..._tagalogProfanity,
    ..._bisayaProfanity,
    ..._variations,
  ];

  /// Check if the message contains inappropriate content
  /// Returns true if message is clean, false if it contains profanity
  static bool isMessageClean(String message) {
    if (message.trim().isEmpty) return true;

    // Convert to lowercase for case-insensitive matching
    final lowerMessage = message.toLowerCase();

    // Remove common punctuation and spaces for better detection
    final cleanMessage = lowerMessage
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // Check for exact matches
    for (final word in _allProfanity) {
      if (cleanMessage.contains(word.toLowerCase())) {
        debugPrint('Chat Filter: Blocked word detected: $word');
        return false;
      }
    }

    // Check for variations with numbers/symbols
    final noSpaceMessage = lowerMessage.replaceAll(RegExp(r'[\s\-_\.]'), '');
    for (final word in _allProfanity) {
      final noSpaceWord = word.replaceAll(RegExp(r'[\s\-_\.]'), '');
      if (noSpaceMessage.contains(noSpaceWord)) {
        debugPrint('Chat Filter: Blocked variation detected: $word');
        return false;
      }
    }

    return true;
  }

  /// Get a cleaned version of the message (replaces profanity with asterisks)
  /// This is an alternative to blocking - you can choose to clean instead
  static String cleanMessage(String message) {
    if (message.trim().isEmpty) return message;

    String cleanedMessage = message;

    for (final word in _allProfanity) {
      final regex = RegExp(word.replaceAll(' ', r'\s*'), caseSensitive: false);

      final replacement = '*' * word.replaceAll(' ', '').length;
      cleanedMessage = cleanedMessage.replaceAll(regex, replacement);
    }

    return cleanedMessage;
  }

  /// Get the reason why the message was blocked (for user feedback)
  static String getBlockReason(String message) {
    if (isMessageClean(message)) return '';

    final lowerMessage = message.toLowerCase();

    // Check what type of inappropriate content was detected
    for (final word in _englishProfanity) {
      if (lowerMessage.contains(word)) {
        return 'Your message contains inappropriate language and cannot be sent.';
      }
    }

    for (final word in _tagalogProfanity) {
      if (lowerMessage.contains(word)) {
        return 'Ang inyong mensahe ay naglalaman ng hindi angkop na wika at hindi maipadadala.';
      }
    }

    for (final word in _bisayaProfanity) {
      if (lowerMessage.contains(word)) {
        return 'Ang imong mensahe adunay dili angay nga pulong ug dili ma-send.';
      }
    }

    return 'Your message contains inappropriate content and cannot be sent.';
  }

  /// Check if message contains threats or harassment
  static bool containsThreats(String message) {
    const threats = [
      'kill you',
      'murder you',
      'hurt you',
      'beat you up',
      'fight you',
      'patyon ka',
      'patay ka',
      'mamatay ka',
      'bugbugin kita',
      'away tayo',
      'patyon tika',
      'bugbugin ta ka',
      'away ta',
      'sampalon tika',
    ];

    final lowerMessage = message.toLowerCase();
    return threats.any((threat) => lowerMessage.contains(threat));
  }

  /// Check if message contains harassment or bullying language
  static bool containsHarassment(String message) {
    const harassment = [
      'ugly',
      'stupid',
      'worthless',
      'useless',
      'nobody likes you',
      'pangit',
      'bobo',
      'walang kwenta',
      'walang silbi',
      'walang mahal sa iyo',
      'panget',
      'buang',
      'way kwenta',
      'way pulos',
      'way love nimo',
    ];

    final lowerMessage = message.toLowerCase();
    return harassment.any((word) => lowerMessage.contains(word));
  }

  /// Comprehensive check - combines all filters
  static bool isAppropriateMessage(String message) {
    return isMessageClean(message) &&
        !containsThreats(message) &&
        !containsHarassment(message);
  }

  Future<bool> filterMessage(String message) async {
    final data = await supabase.from('word_filters').select();
    debugPrint(
      'Chat Filter: Loaded ${data.length} custom blocked words from database.: $data',
    );
    final List<String> customWords = data
        .map((e) => e['word'] as String)
        .toList();
    for (final word in customWords) {
      if (message.toLowerCase().contains(word.toLowerCase())) {
        debugPrint('Chat Filter: Custom blocked word detected: $word');
        return false;
      }
    }
    return true;
  }

  /// Get detailed feedback for blocked messages
  static String getDetailedBlockReason(String message) {
    if (containsThreats(message)) {
      return 'Messages containing threats or violence are not allowed.';
    }

    if (containsHarassment(message)) {
      return 'Messages containing harassment or bullying language are not allowed.';
    }

    if (!isMessageClean(message)) {
      return getBlockReason(message);
    }

    return 'Your message contains inappropriate content.';
  }
}
