# claude-code-toolkit

**「できました」を、証拠なしでは通さない。** Claude Code で毎日使っているエージェントとスキルを、プラグインとしてまとめたものです。

Japanese-language agents and skills for Claude Code, packaged as a plugin marketplace. The core idea: never let the agent that wrote the code grade its own work.

## なぜ作ったか

AI に実装を任せると、本人（実装したエージェント）が「完了しました」と言っても、要件の一部が抜けていることがよくあります。作った本人が自分の作業を採点すると、自分の見落としには気づけないからです。

そこで、**実装とは別のコンテキストで、要件を満たした証拠だけを確かめる検証役（`verifier`）** を作りました。調査・レビュー・大きな変更も役割ごとにエージェントを分け、モデルとできることを最小限に絞っています。ここにあるのは、個人の開発で実際に使い、改善を重ねてきたものだけです。

## 実際の出力例

このリポジトリ自身の変更（使わなくなったスキルを1つ外す作業）を `verifier` に確かめさせたときの出力です。設定ファイルの更新と検証は通っていましたが、**README の表に、外したスキルの行が残っていること**を見つけています。

```
判定: 一部完了。基準1〜4は満たしています。基準5は満たしていません。
      README.md に実在しないスキルが1件残っています。

証拠:
- 基準1: OK  git status は「D plugins/dev-toolkit/skills/html-monochrome/SKILL.md」。
             find でも 0 件
- 基準3: OK  plugin.json の version は 0.2.0（HEAD では 0.1.0）
- 基準4: OK  claude plugin validate . → ✔ Validation passed
- 基準5: NG

欠落:
- README.md:35 の「スキル」表に html-monochrome の行が残っている。
  このスキルは plugins/dev-toolkit/skills/ に無い。この行を削除すれば基準5を満たす

未検証: なし
スコープ外変更: なし
```

（実際の出力から基準2の行を省き、表示用に短くしています。指摘を受けて、この README を直しました。）

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
| `verifier` | Sonnet | 実装した本人とは別の立場で、要件を満たした「証拠」があるかだけを判定する。テストやコマンドを実際に実行し、推測では OK にしない |
| `code-reviewer` | Sonnet | 差分を読み取り専用でレビューし、CRITICAL / HIGH / MEDIUM / LOW の重要度を付けて報告する |
| `researcher` | Haiku | Web・ドキュメント・コードを読み取り専用で調べ、要点と出典だけを返す。メインの会話を汚さない |
| `heavy-refactor` | Opus | worktree などの隔離環境で、複数ファイルにまたがる大きな変更を段階的に検証しながら進める |

`verifier` と `code-reviewer` は役割が違います。`code-reviewer` はコードの品質全般を見ます。`verifier` は「頼まれたことが本当にできているか」だけを見ます。

### スキル

| 名前 | 使う場面 |
|---|---|
| `consult-3views` | 相談・意思決定を、客観・肯定・批判の3つの立場から同じ深さで検討する |
| `plan-with-opus` | 設計・計画の工程は Opus、実装は Sonnet に振り分ける手順 |
| `youtube-summary` | YouTube の URL を、図解・タイムライン・結論の3部構成で要約する |
| `swiftui-macos-app` | SwiftUI で macOS アプリを作るときの既定値（設定画面・メニュー・ショートカット・日本語 UI など）。コピーして使えるコード集付き |

## 設計の考え方

- **作った本人に採点させない**：`verifier` は実装とは別のコンテキストで動かす。証拠のない「完了」は通さない
- **指摘の数を成果にしない**：`verifier` は、正しさ・要件・データ損失・セキュリティに関わる問題だけを報告する。好みやスタイルには口を出さない
- **できることを絞る**：レビュー・調査・検証のエージェントは読み取り専用にする。ファイルの変更や外部への送信はしない
- **モデルは工程で使い分ける**：調査は Haiku、レビューと検証は Sonnet、設計と大きな変更は Opus

## ライセンス

[MIT](LICENSE)
