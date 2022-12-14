class BaseObject {
  @override
  String toString() => "<wyze_sdk.${(this).toString()}>";
}

class JsonObject extends BaseObject {
  Set<String> attributes = {};

  /// Extracts a single value by name from a variety of locations in an object.
  extractAttribute(String name, Map others) {
    if (others.containsKey(name)) {
      final value = others.remove(name);
      return value != null && value != '' ? value : null;
    }

    if (others.containsKey('property_list')) {
      for (final property in others['property_list']) {
        if (name == property['pid']) return property['value'];
      }
    }

    if (others.containsKey('data') && others['data'].containsKey('property_list')) {
      for (final property in others['data']['property_list']) {
        if (name == property['pid']) return property['value'];
      }
    }

    if (others.containsKey('device_params') && others['device_params'].containsKey(name)) {
      return extractAttribute(name, others['device_params']);
    }

    if (others.containsKey('device_setting') && others['device_setting'].containsKey(name)) {
      return extractAttribute(name, others['device_setting']);
    }
  }

  /// :raises WyzeObjectFormationError: if the object was not valid
  /// :meta: private
  validateJson() {
    // Just going to ignore for now lol
    return;

    // for (final attribute in (func for func in dir(self) if not func.startswith("__")) {
    //   try {
    //     final method = getattr(attribute, null);
    //     if callable(method) and hasattr(method, "validator"):
    //       method()
    //   } catch WyzeFeatureNotSupportedError {
    //     return;
    //   }
    // }
  }
}

class PropDef {
  late String? _pid;
  get pid => _pid;

  late dynamic _apiType;
  get apiType => _apiType;

  late dynamic _type;
  get type => _type;

  late List<dynamic>? _acceptableValues;

  /// The translation definition to convert between the API data properties and
  /// reasonable python equivalents.
  PropDef(
      String? pid,
      [
        dynamic type,
        dynamic apiType,
        List<dynamic>? acceptableValues,
      ]) {
    _pid = pid;
    _type = type;
    _apiType = apiType;
    _acceptableValues = acceptableValues;
  }

  // TODO
  validate(dynamic values) {}
}
