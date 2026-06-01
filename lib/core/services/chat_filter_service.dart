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
    'tits',
    'boobs',
    'ass',
    'kill yourself',
    'kys',
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

  /// Returns true if the text contains the blocked word/phrase as a whole word.
  /// Phrases (with spaces) use substring match; single words use \b boundary.
  static bool _containsWord(String text, String blocked) {
    final w = blocked.toLowerCase();
    if (w.contains(' ')) return text.contains(w);
    try {
      return RegExp(r'\b' + RegExp.escape(w) + r'\b', caseSensitive: false)
          .hasMatch(text);
    } catch (_) {
      return text.contains(w);
    }
  }

  /// Check if the message contains inappropriate content.
  /// Returns true if message is clean, false if it contains profanity.
  static bool isMessageClean(String message) {
    if (message.trim().isEmpty) return true;

    final lower = message.toLowerCase();

    for (final word in _allProfanity) {
      if (_containsWord(lower, word)) {
        debugPrint('Chat Filter: Blocked word detected: $word');
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

    final lower = message.toLowerCase();

    if (_englishProfanity.any((w) => _containsWord(lower, w))) {
      return 'Your message contains inappropriate language and cannot be sent.';
    }
    if (_tagalogProfanity.any((w) => _containsWord(lower, w))) {
      return 'Ang inyong mensahe ay naglalaman ng hindi angkop na wika at hindi maipadadala.';
    }
    if (_bisayaProfanity.any((w) => _containsWord(lower, w))) {
      return 'Ang imong mensahe adunay dili angay nga pulong ug dili ma-send.';
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

    final lower = message.toLowerCase();
    return threats.any((t) => _containsWord(lower, t));
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

    final lower = message.toLowerCase();
    return harassment.any((w) => _containsWord(lower, w));
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
    final lower = message.toLowerCase();
    for (final word in customWords) {
      if (_containsWord(lower, word.toLowerCase())) {
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
