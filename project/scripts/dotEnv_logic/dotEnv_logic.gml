#macro dotEnv	global.__gm_dotenv
gml_pragma("global", "dotEnv_init()");

/// @func	dotEnv_init()
/// @desc	Setup the dotEnv required structs
function dotEnv_init() {
	var _t_init = get_timer();
	dotEnv = {
		path: $"{working_directory}/{dotEnv_filepath}",
		debug: dotEnv_enable_debug,
		override: dotEnv_enable_override,
		cwd: program_directory,
		config: dotEnv_config,
		populate: dotEnv_populate,
	};
	
	__dotEnv_internal_log("Initializing dotEnv. . .");
	/* Load all parameters */
	__dotEnv_internal_get_start_params();
	dotEnv_load_file(dotEnv.path);
	__dotEnv_internal_log($"dotEnv initialized in {(get_timer() - _t_init) / 1000}ms!");
}

/// @func	dotEnv_config(params)
/// @param	{struct}	params
/// @desc	Return dotEnv variables as a new struct or set new values if parameters are given.
function dotEnv_config(_params = noone) {
	if (is_struct(_params)) {
		return __dotEnv_internal_set_config(_params)
	}
	
	return __dotEnv_internal_get_config();
}

/// @func	dotEnv_load_file(filepath)
/// @param	{String}	filepath
/// @desc	Loads new props to the dotEnv struct from a file
function dotEnv_load_file(_filepath = "") {
	__dotEnv_internal_load_file(_filepath);
}

/// @func	dotEnv_get(key, default)
/// @param	{String}	key
/// @param	{any}	default
/// @desc	Returns a value from dotEnv variables, or a default variable if not found.
function dotEnv_get(_key, _default = undefined) {
	if (!variable_global_exists("__gm_dotenv")) {
		__dotEnv_internal_error($"Cannot get variable \"{_key}\"! dotEnv is not defined nor initialized.");
		return;
	}
	
	if !(struct_exists(dotEnv, _key)) {
		__dotEnv_internal_warn($"Variable \"{_key}\" does not exist on dotEnv struct. Using default value: {_default}");
		return _default;
	}
	
	return dotEnv[$ _key];
}

/// @func	dotEnv_populate(params)
/// @param	{struct}	params
/// @desc	Populates dotEnv struct adding new keys and values from the params struct.
function dotEnv_populate(_params) {
	if (!variable_global_exists("__gm_dotenv")) {
		__dotEnv_internal_error($"Cannot populate dotEnv struct! dotEnv is not defined nor initialized.");
		return;
	}
	
	var _keys = struct_get_names(_params);
	var _keys_len = array_length(_keys);
	
	for (var i = 0; i < _keys_len; i++) {
		var _key = _keys[i];
		if (struct_exists(dotEnv, _key) && !dotEnv.override) {
			__dotEnv_internal_warn("Canot populate dotEnv with key {_key}. Key already exists! Try to disable dotEnv.override with dotEnv.config()");
			continue;
		}
		
		dotEnv[$ _key] = _params[$ _key];
	}
}