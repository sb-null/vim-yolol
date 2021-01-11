# vim-yolol

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/sb-null/vim-yolol/blob/master/LICENSE)

vim integration for starbase yolol programming language and uses [yodk](https://github.com/dbaumgarten/yodk) for formating, code checking and as language server

# Features

This plugin adds yolol language support for Vim:

- (/) Format your code `YololFmt`
- (/) Code optimization using `YololOptimize`
- (/) compile nolol code into yolol using `Nolol2Yolol`
- (/) Run tests with `YololTest`
- (x) debug yolol/nolol code with `YololDebug`
- (x) Syntax highliting for yolol and nolol

# Install

vim-yolol requires at lest Vim 8.0.1453

vim-yolol follows the standard runtime path structure. Below are some helper lines for popular package managers:

- [Vim 8 packages](http://vimhelp.appspot.com/repeat.txt.html#packages)
  - `git clone https://github.com/sb-null/vim-yolol.git ~/.vim/pack/plugins/start/vim-yolol`
- [Pathogen](https://github.com/tpope/vim-pathogen)
  - `git clone https://github.com/sb-null/vim-yolol.git ~/.vim/bundle/vim-yolol`
- [Vundle](https://github.com/VundleVim/Vundle.vim)
  - `Plugin 'sb-null/vim-yolol'`

You will also need to install all necessary binarys. vim-yolol makes it easy to install them by using `:YololInstallBinaries`, using `curl` to donwload the required binarys.

# Usage

The full documentation cann be found at [doc/vim-yolol.txt](doc/vim-yolol.txt) and can be diesplayed from within Vim with `:help vim-yolol`.

Depending on your installation method, you may have to generate the plugin's `help tags` manually (e.g. `:helptags ALL`).

# Contributing

If you want to add features, have suggestions or found a bug feel free to open an [issue](https://github.com/sb-null/vim-yolol/issues/new) or create a [pull request](https://github.com/sb-null/vim-yolol/compare).

