<img src="./assets/GM-dotEnv-logo.png" width="256" height="256">

# GameMaker-dotEnv

![GameMaker Version](https://img.shields.io/badge/GameMaker-v2023+-039e5c?logo=gamemaker&labelColor=000)
![License](https://img.shields.io/badge/license-MIT-blue?labelColor=000)

GM-dotEnv is a library that loads environment variables from a .env file into GameMaker, storing configuration in the environment separate from code.

> It's completely based on [dotenv](https://www.npmjs.com/package/dotenv) on NPM and works in a very similar way with a few differences.

---

- [GameMaker-dotEnv](#gamemaker-dotenv)
  - [🌱 Installation](#-installation)
  - [🏗️ Usage](#️-usage)
    - [🚩 Toggling Features](#-toggling-features)
    - [🚀 Quick Start](#-quick-start)
  - [🗃️ Multiple .env files](#️-multiple-env-files)
  - [📖 Docs](#-docs)
    - [dotEnv\_init()](#dotenv_init)
    - [dotEnv\_config()](#dotenv_config)
    - [dotEnv\_load\_file()](#dotenv_load_file)
    - [dotEnv\_get()](#dotenv_get)
    - [dotEnv\_populate()](#dotenv_populate)
  - [📜 License](#-license)
  - [❓ FAQ](#-faq)
    - [Why is the .env file not loading my environment variables successfully?](#why-is-the-env-file-not-loading-my-environment-variables-successfully)
    - [Should I have multiple .env files?](#should-i-have-multiple-env-files)
    - [What rules does the parsing engine follow?](#what-rules-does-the-parsing-engine-follow)

---

## 🌱 Installation

- If you downloaded `GM-dotEnv` on GameMaker's Marketplace, you can import it using menu: Marketplace ➜ My Library.

- If you downloaded from Github, you can import it using menu: Tools ➜ Import Local Asset Package, or by dragging and dropping the `.yymps` file onto the workspace area of the GameMaker window.

- Import the assets (extension, object, and included files) from the package.

---

## 🏗️ Usage

### 🚩 Toggling Features

You can toggle initial features by changing the macros on the `dotEnv_options` script. Here are the available options:

| Macro                    | Description                                                                      | Default  |
| ------------------------ | -------------------------------------------------------------------------------- | -------- |
| `dotEnv_filepath`        | The path to the .env file. The path is relative to `working_directory`.          | `".env"` |
| `dotEnv_enable_debug`    | Enable debug messages and logs. You should disable this before production build. | `true`   |
| `dotEnv_enable_override` | Enable overriding variables if they already exist.                               | `false`  |

### 🚀 Quick Start

Create a .env file in the included files of your project, you can add your environment variables there. Here is an example:

```env
ENVIRONMENT = "LOCAL"
TEXT_VAR = "Lorem Ipsum"
TEXT_VAR_NO_QUOTES = This is a test
TEXT_VAR_SINGLE_QUOTES = 'This is another test'
INT_VAR = 132456
FLOAT_VAR = 123.456
; next line will be skipped

PATH_VAR = "C://MyDocuments/Github"
COLOR_VAR = "#FF0000"
EMPTY_VAR =
; this is a comment
;;; this is another comment
```

> [!NOTE]
> The script `dotEnv_init()` runs automatically before starting your game, just by adding this file to your project you should be able to read your variables.

Once you have your .env file, you can access the variables using the `dotEnv_get()` function. Here is an example:

```gml
var env = dotEnv_get("ENVIRONMENT");
show_debug_message("Environment: " + env);
```

---

## 🗃️ Multiple .env files

You can load multiple .env files by using the `dotEnv_load_file()` function. This function will load the variables from the file and merge them with the current environment.

> [!NOTE]
> If you have `override` disabled (as it is by default) and you load a file with the same variable name, the new value will be ignored. If you want to override the value, you should enable the `override` feature.

```gml
dotEnv_load_file("local.env");
dotEnv_load_file("prod.env");
```

This will load the variables from `local.env` and `prod.env` and merge them with the current environment. If you have the same variable in both files, the value from the last file will be used ONLY if override is enabled.

---

## 📖 Docs

### dotEnv_init()

> [!IMPORTANT]
> This function will also extract the variables from the command line arguments and add them to the environment. When you run it on Windows it will add the variable `game` with the route to the file `data.win`. Variables from your .env file will NOT override the command line arguments unless `override` is enabled.

This function initializes the library, loading the variables from the .env file. It is called automatically before starting your game. You should not need to call this function manually, but you can if you want to reload the variables.

```gml
dotEnv_init();
```

---

### dotEnv_config()

This function allows you to change the configuration of the base props of the dotEnv library. Here's the list of available options:

| Argument | Description                                        | Default  |
| -------- | -------------------------------------------------- | -------- |
| path     | The path to the .env file. The path is absolute.   | `".env"` |
| debug    | Enable debug messages and logs.                    | `true`   |
| override | Enable overriding variables if they already exist. | `false`  |

```gml
dotEnv_config({ path: $"{working_directory}/local.env", override: true });
```

The example above will change the path to the local.env file and enable the override feature. You still will need to call `dotEnv_load_file()` to load the variables from the new file.

---

### dotEnv_load_file()

This function loads the variables from the specified file and merges them with the current environment. If you have the same variable in both files, the value from the last file will be used ONLY if override is enabled.

```gml
dotEnv_load_file("local.env");
```

---

### dotEnv_get()

This function returns the value of the specified variable. If the variable does not exist, it will return a default value if provided.

```gml
var env = dotEnv_get("ENVIRONMENT", "PROD");
show_debug_message("Environment: " + env);
```

The example above will return the value of the `ENVIRONMENT` variable. If the variable does not exist, it will return `PROD`.

---

### dotEnv_populate()

This function adds new variables to the environment. You can use this function to add variables that are not in the .env file.

```gml
dotEnv_populate("NEW_VAR", "New Value");

var newVar = dotEnv_get("NEW_VAR");
show_debug_message("New Var: " + newVar);
```

The example above will add a new variable called `NEW_VAR` with the value `New Value`. Then it will get the value of the variable and show it in the debug console.

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## ❓ FAQ

### Why is the .env file not loading my environment variables successfully?

Most likely your `.env` file is not in the correct place. The file should be in the included files of your project. If you are using multiple `.env` files, make sure you are naming and calling them correctly.

### Should I have multiple .env files?

It's better to have multiple `.env` files for different environments. This way you can have different configurations for each environment. Personally, I like to have a `.env` file for local/development, `.env.dev` for production, and so on.

### What rules does the parsing engine follow?

The parsing algorithm doesn't follow the exact same rules as the original `dotenv` library. Here are the rules it follows:

- BASIC=basic becomes {BASIC: 'basic'}.
- Empty lines are skipped.
- Lines beginning with # are treated as comments.
- Lines beginning with ; are treated as comments.
- "#" and ";" marks the beginning of a comment (unless when the value is wrapped in quotes).
- Empty values become empty strings:
  - `EMPTY=` becomes `{EMPTY: ''}`
- Cannot load JSON objects:
  - `JSON={"key": "value"}` will be loaded as `{JSON: '{"key": "value"}'}`
- Whitespace is removed from both ends of unquoted values:
  - `FOO=   some value   ` becomes `{FOO: 'some value'}`
- Single and double quoted values are escaped:
  - `SINGLE_QUOTE='quoted'` becomes `{SINGLE_QUOTE: "quoted"}`
- Single and double quoted values maintain whitespace from both ends:
  - `FOO=" some value "` becomes `{FOO: ' some value '}`
- Double quoted values expand new lines:
  - `MULTILINE="new\nline"` becomes `{MULTILINE: 'new\nline'}`
- Backticks are not supported.
- Multi-line values are not supported.
