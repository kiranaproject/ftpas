#!/usr/bin/env bash
set -euo pipefail

# Build script for ftpas supporting compile, test, examples, and clean

TARGET="${1:-compile}"

case "${TARGET}" in
  compile)
    echo "==> Compiling ftpas library..."
    pasbuild compile
    echo "==> Compiling ftpas tools (ftml_embed)..."
    pasbuild compile -f tools/ftml-embed/project.xml
    ;;
  tools)
    echo "==> Compiling ftpas tools (ftml_embed)..."
    pasbuild compile -f tools/ftml-embed/project.xml
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
    echo "==> Compiling and installing ftml_embed tool..."
    pasbuild compile -f tools/ftml-embed/project.xml
    mkdir -p "${HOME}/.local/bin"
    cp -f bin/ftml_embed "${HOME}/.local/bin/ftml_embed"
    mkdir -p "${HOME}/.pasbuild/repository/ftpas/0.0.1-SNAPSHOT/x86_64-linux-3.2.3/bin"
    cp -f bin/ftml_embed "${HOME}/.pasbuild/repository/ftpas/0.0.1-SNAPSHOT/x86_64-linux-3.2.3/bin/ftml_embed"
    echo "==> ftml_embed installed to ${HOME}/.local/bin/ftml_embed"
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
    rm -rf bin target tools/ftml-embed/target
    rm -f examples/hello_world examples/form_controls examples/floating_navbar examples/creative_canvas examples/ftml_declarative_demo
    ;;
  *)
    echo "Usage: $0 [compile|tools|test|install|examples|clean]"
    exit 1
    ;;
esac
