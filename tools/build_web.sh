#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
version=4.7.2
template_version="$version.stable"
platform="$(uname -s)"
godot_bin="${GODOT_BIN:-$(command -v godot || command -v godot4 || true)}"

case "$platform" in
	Darwin)
		templates="$HOME/Library/Application Support/Godot/export_templates/$template_version"
		if [[ -z "$godot_bin" && -x /Applications/Godot.app/Contents/MacOS/Godot ]]; then
			godot_bin=/Applications/Godot.app/Contents/MacOS/Godot
		fi
		;;
	Linux)
		templates="${XDG_DATA_HOME:-$HOME/.local/share}/godot/export_templates/$template_version"
		;;
	*)
		echo "Run this build on macOS or Linux." >&2
		exit 1
		;;
esac

build_dir="$project_dir/build"
mkdir -p "$build_dir"
touch "$build_dir/.gdignore"
staging="$(mktemp -d "$build_dir/.web.XXXXXX")"
trap 'rm -rf "$staging"' EXIT

if [[ -z "$godot_bin" && "$platform" == Linux && "$(uname -m)" == x86_64 ]]; then
	engine_name="Godot_v$version-stable_linux.x86_64"
	engine_url="https://github.com/godotengine/godot-builds/releases/download/$version-stable/$engine_name.zip"
	engine_sha=cadd3204e728a35d3f13adb7fd0d7902636b79f6b95c40c265eb73b6c35329e4
	godot_bin="$build_dir/$engine_name"
	if [[ ! -x "$godot_bin" ]]; then
		echo "Downloading Godot $version for the Linux build image"
		curl -fsSL --retry 2 --connect-timeout 15 --max-time 240 "$engine_url" -o "$staging/engine.zip"
		(cd "$staging" && printf '%s  engine.zip\n' "$engine_sha" | sha256sum --check)
		unzip -q "$staging/engine.zip" "$engine_name" -d "$staging"
		mv "$staging/$engine_name" "$godot_bin"
		chmod +x "$godot_bin"
		rm "$staging/engine.zip"
	fi
fi

if [[ -z "$godot_bin" ]]; then
	echo "Godot $version is required. Install it or set GODOT_BIN to the editor executable." >&2
	exit 1
fi

installed_version="$("$godot_bin" --version)"
if [[ "$installed_version" != "$template_version".* ]]; then
	echo "Expected Godot $template_version, found $installed_version. Set GODOT_BIN to the matching editor." >&2
	exit 1
fi

python3 "$project_dir/tools/fetch_godot_web_templates.py" "$version" "$templates"
"$godot_bin" --headless --path "$project_dir" --import
"$godot_bin" --headless --path "$project_dir" --export-release Web "$staging/index.html"
for file in index.html index.js index.wasm index.pck; do
	if [[ ! -s "$staging/$file" ]]; then
		echo "Godot did not generate $file." >&2
		exit 1
	fi
done

rm -rf "$build_dir/web"
mv "$staging" "$build_dir/web"
echo "Godot Web build ready in build/web/"
