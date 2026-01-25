#!/bin/bash

install_config() {
  local -r source_file=$(pwd)
  local -r destination_file=$HOME/.config/nvim
  ln -s "$source_file" "$destination_file"
  echo "Install success, please press re-open Neovim"
}

# run install
install_config
