#!/bin/bash
# Capafy にドロップする1フォルダ版（SKILL.md が1つ）を plugins/dev-toolkit から組み立てる。
# 出力: dist/claude-code-toolkit/（git 管理外）。プラグイン側を直したら、これを実行し直す。
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
src="$root/plugins/dev-toolkit"
out="$root/dist/claude-code-toolkit"

[ -e "$out" ] && mv "$out" "$out.old.$(date +%Y%m%d%H%M%S)"
mkdir -p "$out/references"

strip_frontmatter() { awk 'NR==1 && /^---$/ {fm=1; next} fm && /^---$/ {fm=0; next} !fm' "$1"; }

cp "$root/capafy/SKILL.md" "$out/SKILL.md"
for a in verifier code-reviewer researcher heavy-refactor; do
  strip_frontmatter "$src/agents/$a.md" > "$out/references/$a.md"
done
for s in consult-3views plan-with-opus youtube-summary swiftui-macos-app; do
  strip_frontmatter "$src/skills/$s/SKILL.md" > "$out/references/$s.md"
done
cp "$src/skills/swiftui-macos-app/references/boilerplate.md" "$out/references/swiftui-boilerplate.md"
# 平らに並べたので、SwiftUI のコード集へのリンク先を付け替える
sed -i '' 's#(references/boilerplate\.md)#(swiftui-boilerplate.md)#g; s#\[references/boilerplate\.md\]#[swiftui-boilerplate.md]#g' "$out/references/swiftui-macos-app.md"

echo "$out"
