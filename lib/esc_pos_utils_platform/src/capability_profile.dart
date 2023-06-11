/*
 * esc_pos_utils
 * Created by Andrey U.
 * 
 * Copyright (c) 2019-2020. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'dart:convert' show json;
import 'package:flutter/services.dart' show rootBundle;

class CodePage {
  CodePage(this.id, this.name);
  int id;
  String name;
}

class CapabilityProfile {
  CapabilityProfile._internal(this.name, this.codePages);

  /// Public factory
  static Future<CapabilityProfile> load({String name = 'default', String capabilityPath = 'packages/flutter_pos_printer_platform/resources/capabilities.json'}) async {
    final content = await rootBundle.loadString(capabilityPath);
    Map capabilities = json.decode(content);
    return await loadMap(capabilities,name);
  }
  
  static Future<CapabilityProfile> loadMap(Map capabilities,String name = 'default') async {

    var profile = capabilities['profiles'][name];

    if (profile == null) {
      throw Exception("The CapabilityProfile '$name' does not exist");
    }

    List<CodePage> list = [];
    profile['codePages'].forEach((k, v) {
      list.add(CodePage(int.parse(k), v));
    });

    // Call the private constructor
    return CapabilityProfile._internal(name, list);
  }

  String name;
  List<CodePage> codePages;

  int getCodePageId(String? codePage) {
    if (codePages.isEmpty) {
      throw Exception("The CapabilityProfile isn't initialized");
    }

    return codePages
        .firstWhere((cp) => cp.name == codePage, orElse: () => throw Exception("Code Page '$codePage' isn't defined for this profile"))
        .id;
  }

  static Future<List<dynamic>> getAvailableProfiles(String capabilityPath = 'packages/flutter_pos_printer_platform/resources/capabilities.json') async {
    final content = await rootBundle.loadString(capabilityPath);
    Map capabilities = json.decode(content);
    return await getAvailableMapProfiles(capabilities);
  }
  
  static Future<List<dynamic>> getAvailableMapProfiles(Map capabilities) async {

    var profiles = capabilities['profiles'];

    List<dynamic> res = [];

    profiles.forEach((k, v) {
      res.add({
        'key': k,
        'vendor': v['vendor'] is String ? v['vendor'] : '',
        'model': v['model'] is String ? v['model'] : '',
        'description': v['description'] is String ? v['description'] : '',
      });
    });

    return res;
  }
}
