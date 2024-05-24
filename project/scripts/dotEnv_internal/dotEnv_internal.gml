/// @func	__dotEnv_internal_log(message)
/// @param	{String}	message
/// @desc	INTERNAL USAGE ONLY, DO NOT CALL OR USE ON YOUR GAME
function __dotEnv_internal_log(_msg = "") {
	if (!variable_global_exists("__gm_dotenv")) {
		__dotEnv_internal_error($"Cannot log message! dotEnv is not defined nor initialized.");
		return;
	}
	
	if !(dotEnv.debug) return;
	show_debug_message($"(GM-dotEnv) - {_msg}");
}

/// @func	__dotEnv_internal_warn(message)
/// @param	{String}	message
/// @desc	INTERNAL USAGE ONLY, DO NOT CALL OR USE ON YOUR GAME
function __dotEnv_internal_warn(_msg = "") {
	__dotEnv_internal_log($"⚠️ WARNING: {_msg}");
}

/// @func	__dotEnv_internal_error(message)
/// @param	{String}	message
/// @desc	INTERNAL USAGE ONLY, DO NOT CALL OR USE ON YOUR GAME
function __dotEnv_internal_error(_msg = "") {
	__dotEnv_internal_log($"️❌ ERROR: {_msg}");
}

/// @func	__dotEnv_internal_info(message)
/// @param	{String}	message
/// @desc	INTERNAL USAGE ONLY, DO NOT CALL OR USE ON YOUR GAME
function __dotEnv_internal_info(_msg = "") {
	__dotEnv_internal_log($"️❓ INFO: {_msg}");
}


/// @func	__dotEnv_internal_get_config()
/// @desc	Returns dotEnv variables as a new struct. INTERNAL USAGE ONLY, DO NOT CALL OR USE ON YOUR GAME.
function __dotEnv_internal_get_config() {
	try {
		if (!variable_global_exists("__gm_dotenv")) throw "";
		
		var _dotenv_struct = {
			parsed: variable_clone(dotEnv),
			error: false,
		}
		return _dotenv_struct;
	} catch (e) {
		static _error_struct = {
			parsed: {},
			error: true,
			message: e.longMessage,
		};
		__dotEnv_internal_error("dotEnv is not defined nor initialized.");
		return _error_struct;
	}
}

/// @func	__dotEnv_internal_set_config(params)
/// @param	{struct}	params
/// @desc	Set dotEnv variables if compatible. INTERNAL USAGE ONLY, DO NOT CALL OR USE ON YOUR GAME
function __dotEnv_internal_set_config(_params = noone) {
	static _valid_options = [
		{ name: "path", type: "string"},
		{ name: "debug", type: "bool"},
		{ name: "override", type: "bool"},
	];
	static _valid_options_len = array_length(_valid_options);
	var _param_keys = variable_struct_get_names(_params);
	var _param_keys_len = array_length(_param_keys);
	
	for (var i = 0; i < _param_keys_len; i++) {
		var _key_name = _param_keys[i];
		var _valid_option_index = -1;
		
		for (var j = 0; j < _valid_options_len; j++) {
			if (_valid_options[j].name == _key_name) {
				_valid_option_index = j;
				break;
			}
		}
		
		var _is_valid = dotEnv.override || _valid_option_index > -1;
		if (!_is_valid) continue;
		
		var _is_same_type = typeof(_params[$ _key_name]) == _valid_option_index.type;
		if (!_is_same_type) continue;

		dotEnv[$ _key_name] = _params[$ _key_name];
	}
}


/// @func	__dotEnv_internal_load_file(filepath)
/// @param	{String}	filepath
/// @desc	INTERNAL USAGE ONLY, DO NOT CALL OR USE ON YOUR GAME
function __dotEnv_internal_load_file(_filepath = "") {
	if (!variable_global_exists("__gm_dotenv")) {
		__dotEnv_internal_error($"Cannot open file \"{_filepath}\"! dotEnv is not defined nor initialized.");
		return;
	}
	
	if (_filepath = "") _filepath = dotEnv.path;
	
	try {
		var _file = file_text_open_read(_filepath);
		var _content = "";
		
		while (!file_text_eof(_file)) {
			_content += file_text_readln(_file);
		}
		
		file_text_close(_file);
		
		var _lines = string_split(_content, "\n");
		var _lines_len = array_length(_lines);
		
		for (var i = 0; i < _lines_len; i++) {
			var _line = _lines[i];
			_line = string_trim(_line);
			if (string_length(_line) == 0) continue; // Skip if empty line
			if (string_starts_with(_line, ";") || string_starts_with(_line, "#")) continue; // Skip if comment
			
			// Get key and value
			var _key = string_trim(string_split(_line, "=")[0]);
			var _value = string_trim(string_split(_line, "=", false, 2)[1]);
			
			if (string_length(_value) == 0) {
				__dotEnv_internal_info($"Skipped key \"{_key}\". Value appears to not be defined.")
			}
			
			_value = __dotEnv_internal_get_value_parsed(_value);	
			struct_set(dotEnv, _key, _value);
		}
		
		__dotEnv_internal_log($"Loaded file {_filepath} successfully!");
	} catch (e) {
		__dotEnv_internal_error($"Something happened while opening file \"{_filepath}\". Please ensure the file formatting is correct.")
	}
}

/// @func	__dotEnv_internal_get_start_params()
/// @desc	INTERNAL USAGE ONLY, DO NOT CALL OR USE ON YOUR GAME
function __dotEnv_internal_get_start_params() {
	static _p_num = parameter_count();
	var _count = 0;
	
	if (_p_num <= 0) return;
	
	while (_count < _p_num) {
		var _key = parameter_string(_count);
		var _value = parameter_string(_count + 1);
		
		if (_count == _p_num - 1 || (string_starts_with(_key, "-") && string_starts_with(_value, "-"))) {
			_value = true;
		} else if (string_starts_with(_key, "-") && !string_starts_with(_value, "-")) {
			_count += 1;
		} else if (string_pos("=", _key) > 0) {
			_key = string_split(_key, "=", false, 2)[0];
			_value = string_split(_key, "=", false, 2)[1];
		} else {
			_count += 1;
			continue;
		}
		
		_key = string_trim(_key, ["-"]);
		
		dotEnv[$ _key] = __dotEnv_internal_get_value_parsed(_value);
		_count += 1;
	}
}

/// @func	__dotEnv_internal_get_value_parsed(value)
/// @param	{any}	value
/// @desc	INTERNAL USAGE ONLY, DO NOT CALL OR USE ON YOUR GAME
function __dotEnv_internal_get_value_parsed(_value) {
	// Identify variable type
	var _is_str = string_pos("\"", _value) || string_pos("'", _value) || string_length(string_letters(_value)) > 0;
	var _is_number = string_letters(_value) == "" && string_length(string_digits(_value)) > 0;
	var _is_float = _is_number && string_pos(".", _value) && string_count(".", _value) == 1;
	var _is_color = string_length(_value) == 9 && string_pos("#", _value) == 2;
			
	// Modify value as type
	if (_is_color) {
		_value = string_upper(string_lettersdigits(_value));
				
		/* Hex to dec script from: https://www.gmlscripts.com/script/hex_to_dec */
		static _digits	= "0123456789ABCDEF";
		var _decimal	= 0;
		var _value_len	= string_length(_value);
		for (var _pos = 1; _pos <= _value_len; _pos += 1) {
			_decimal = _decimal << 4 | (string_pos(string_char_at(_value, _pos), _digits) - 1);
		}
 
		// Invert BBGGRR to RRGGBB
		_value =  ((_decimal & $FF) << 16) | (_decimal & $FF00) | (_decimal >> 16);
	} else if (_is_float || _is_number) {
		_value = real(_value);
	} else if (_is_str) {
		if (string_starts_with(_value, "\"") || string_starts_with(_value, "'")) {
			_value = string_delete(_value, 1, 1);
		}
				
		if (string_ends_with(_value, "\"") || string_ends_with(_value, "'")) {
			_value = string_delete(_value, string_length(_value), 1);
		}
				
		_value = string(_value);
	} else {
		__dotEnv_internal_warn($"Couldn't identify type of value \"{_value}\". Value parsed as string by default.");
		_value = string(_value);
	}
	
	return _value;
}