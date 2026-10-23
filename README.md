# claude-code-toolkit

Claude Code で毎日使っているエージェントとスキルを、プラグインとしてまとめたものです。
個人の開発で実際に使い、改善を重ねてきたものだけを入れています。

Japanese-language agents and skills for Claude Code, packaged as a plugin marketplace.

## インストール

Claude Code のセッションで次の2つを実行します。

```
/plugin marketplace add somaWyd/claude-code-toolkit
/plugin install dev-toolkit@somawyd-plugins
```

## 入っているもの

### エージェント（サブエージェント）

| 名前 | モデル | 役割 |
|---|---|---|
| `verifier` | Sonnet | 実装した本人とは別の立場で、要件を満たした「証拠」があるかだけを判定する。推測では OK にしない |
| `code-reviewer` | Sonnet | 差分を読み取り専用でレビューし、CRITICAL / HIGH / MEDIUM / LOW の重要度を付けて報告する |
| `researcher` | Haiku | Web・ドキュメント・コードを読み取り専用で調べ、要点と出典だけを返す。メインの会話を汚さない |
| `heavy-refactor` | Opus | worktree などの隔離環境で、複数ファイルにまたがる大きな変更を段階的に検証しながら進める |

### スキル

| 名前 | 使う場面 |
|---|---|
| `consult-3views` | 相談・意思決定を、客観・肯定・批判の3つの立場から同じ深さで検討する |
| `plan-with-opus` | 設計・計画の工程は Opus、実装は Sonnet に振り分ける手順 |
| `youtube-summary` | YouTube の URL を、図解・タイムライン・結論の3部構成で要約する |
| `html-monochrome` | HTML のレポートやダッシュボードを、白基調のモノトーンで作る規約 |
| `swiftui-macos-app` | SwiftUI で macOS アプリを作るときの既定値（設定画面・メニュー・ショートカット・日本語 UI など） |

## 設計の考え方

- **作った本人に採点させない**：`verifier` は実装とは別のコンテキストで動かし、証拠のない「完了」を通さない
- **読み取り専用を既定にする**：レビュー・調査のエージェントは、ファイルの変更や外部への送信をしない
- **モデルは工程で使い分ける**：調査は Haiku、レビューは Sonnet、設計と大きな変更は Opus

## ライセンス

[MIT](LICENSE)
