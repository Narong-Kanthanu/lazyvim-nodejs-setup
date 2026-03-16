#!/bin/bash

install_config() {
  local -r source_file=$(pwd)
  local -r destination_file=$HOME/.config/nvim

  # Remove existing Neovim config if presen
  if [ -e "$destination_file" ]; then
    read -p "Existing Neovim config found at $destination_file. Remove it and continue to install? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo "Installation cancelled."
      return 1
    fi
    rm -rf "$destination_file"
  fi

  ln -s "$source_file" "$destination_file"
  echo "Install success, please press re-open Neovim"
}

# run install
install_config
