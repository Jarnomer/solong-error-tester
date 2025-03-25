<h1 align="center">
  <img src="assets/so_long.png" alt="so_long" width="400">
</h1>

<p align="center">
  <b><i>Comprehensive error tester for so-long 🔍</i></b><br>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Tests-30-lightgreen?style=for-the-badge" alt="tests">
  <img src="https://img.shields.io/badge/Compatible-macOS%20%26%20Linux-lightblue?style=for-the-badge" alt="compatibility">
  <img src="https://img.shields.io/badge/Category-Error%20Handling-pink?style=for-the-badge" alt="category">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Type-Unit%20Testing-violet?style=for-the-badge" alt="type">
  <img src="https://img.shields.io/github/last-commit/Jarnomer/pipex-error-tester/main?style=for-the-badge&color=red" alt="GitHub last commit">
</p>

<div align="center">

## Table of Contents
[📝 Overview](#-overview)  
[🛠️ Installation](#️-installation)  
[⚡ Usage](#-usage)  
[🔍 Tests](#-tests)  
[📊 Results](#-results)

</div>

## 📝 Overview

This tester is designed to evaluate the **error handling** capabilities of your so_long project. It focuses on ensuring your program properly handles invalid inputs, malformed maps, and unexpected scenarios.

The tester checks:
- **Logic errors** (invalid arguments, file permissions, etc.)
- **Map validation** (empty maps, non-rectangular maps, invalid characters, etc.)
- **Path validation** (ensuring valid paths exist between player, collectibles, and exit)
- **Memory leaks** (optional, using valgrind)
- **Makefile compliance** (optional check all rules work properly)
- **Norminette compliance** (optional, check for norm errors)

## 🛠️ Installation

Clone the repository into your project directory:

```bash
git clone https://github.com/Jarnomer/so_long-error-tester.git
```

## ⚡ Usage

Run the tester with shell or optionally give execution permissions:

```bash
bash so_long-error-tester/tester.sh [OPTIONS]
```

```bash
chmod +x so_long-error-tester/tester.sh
so_long-error-tester/tester.sh [OPTIONS]
```

The tester supports several command-line options:

```
- `-t, --test ID`   Run specific test by ID
- `-v, --verbose`   Display verbosed error messages
- `-l, --leaks`     Test memory leaks with valgrind
- `-e, --extra`     Run additional tests (norminette, makefile)
- `-h, --help`      Show the help message
```

## 🔍 Tests

The tester evaluates three key aspects of error handling:

1. **Exit code** - Program should exit with non-zero status on error
2. **Stderr output** - Error messages should be written to stderr
3. **Error format** - Messages should include "Error" and a descriptive explanation

### Test Categories

#### Logic Tests
Tests basic command-line argument handling, file access, and extension validation:
- Too few/many arguments
- Directory as argument
- Non-existent files
- Invalid file extensions
- Permission issues

#### Map Tests
Tests map validation and parsing:
- Empty maps
- Maps with empty lines
- Non-rectangular maps
- Maps without properly closed walls
- Missing player/exit/collectibles
- Multiple players/exits
- Invalid characters
- Maps with no valid paths

#### Extra Tests
- Norminette compliance check
- Makefile rule validation

## 📊 Results

Test results are displayed in a clean, color-coded format:

- **Green (OK)**: Test passed
- **Red (KO)**: Test failed
- **Yellow**: Test skipped

## 4️⃣2️⃣ Footer

For my other 42 projects and general information, please refer to the [Hive42](https://github.com/Jarnomer/Hive42) page.

I have also created error handling [unit testers](https://github.com/Jarnomer/42Testers) for other projects like `pipex` and `cub3D`.

### Cheers and good luck with your testing! 🚀
