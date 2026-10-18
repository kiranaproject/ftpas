#!/usr/bin/env bash
set -euo pipefail

# Build script for ftpas supporting compile, test, examples, and clean

TARGET="${1:-compile}"

case "${TARGET}" in
  compile)
    echo "==> Compiling ftpas library..."
    pasbuild compile
    ;;
  test)
    echo "==> Running ftpas tests..."
    shift 1 || true
    pasbuild test "$@"
    ;;
  install)
    echo "==> Installing ftpas library to local repository..."
    shift 1 || true
    pasbuild install "$@"
    ;;
  examples)
    echo "==> Building ftpas examples..."
    shift 1 || true
    ./examples/build_examples.sh "$@"
    ;;
  clean)
    echo "==> Cleaning target artifacts..."
    shift 1 || true
    pasbuild clean "$@"
    rm -f examples/hello_world examples/form_controls examples/floating_navbar examples/creative_canvas examples/ftml_declarative_demo
    ;;
  *)
    echo "Usage: $0 [compile|test|install|examples|clean]"
    exit 1
    ;;
esac
