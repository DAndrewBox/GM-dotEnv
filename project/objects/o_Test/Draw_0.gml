/// @description Test
var _color = dotEnv_get("COLOR_VAR", c_white);
draw_set_color(_color);
draw_rectangle(x, y, x + 200, y + 200, false);

draw_set_color(c_black);
draw_text(x + 12, y + 12, dotEnv_get("TEXT_VAR", ""));
draw_text(x + 12, y + 32, dotEnv_get("FLOAT_VAR", ""));