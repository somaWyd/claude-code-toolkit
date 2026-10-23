---
name: claude-code-toolkit
description: 「できました」を証拠なしでは通さないための、検証・レビュー・調査・大規模変更・相談・設計・YouTube要約・SwiftUI(macOS)の8つの道具をまとめたスキル。実装後に要件を満たしたか確かめたいとき、差分をレビューしたいとき、出典付きで調べたいとき、複数ファイルの大きな変更をするとき、相談に多角的に答えるとき、設計の工程を分けたいとき、YouTube の URL を要約するとき、SwiftUI で Mac アプリを作るときに使う。
---

# claude-code-toolkit

作った本人に自分の作業を採点させると、自分の見落としには気づけません。このスキルの中心は、**実装とは別の立場で、要件を満たした証拠だけを確かめる検証役**です。そのほかの道具も、役割ごとに「何をして、何をしないか」を決めてあります。

依頼に合う道具を下の表から1つ選び、その道具のファイルを読んでから、そこに書かれた手順どおりに進めてください。複数に当てはまるときは、上の行を優先します。

## 道具の一覧

### 役割（別の立場で動く道具）

| 道具 | 使う場面 | ファイル |
|---|---|---|
| 検証役 | 実装のあと、「要件を本当に満たしたか」を証拠で確かめる。テストやコマンドを実際に実行し、推測では OK にしない | [references/verifier.md](references/verifier.md) |
| レビュー役 | コードの差分を読み取り専用でレビューし、重要度（CRITICAL / HIGH / MEDIUM / LOW）を付けて報告する | [references/code-reviewer.md](references/code-reviewer.md) |
| 調査役 | Web・ドキュメント・コードを読み取り専用で調べ、要点と出典だけを返す | [references/researcher.md](references/researcher.md) |
| 大規模変更役 | 複数ファイルにまたがる大きな変更を、隔離した環境で1段ずつ検証しながら進める | [references/heavy-refactor.md](references/heavy-refactor.md) |

役割の道具は、**作業した本人とは別のコンテキストで動かす**のが前提です。サブエージェントを起動できる環境なら、ファイルの内容をそのままサブエージェントへの指示にして、別のコンテキストで実行してください。起動できない環境では、それまでの作業の経緯にとらわれず、ファイルに書かれた立場と制約だけに従って実行してください。

### 手順（そのまま使う道具）

| 道具 | 使う場面 | ファイル |
|---|---|---|
| 3つの立場で相談に答える | 相談・意思決定・アイデアの評価に、客観・肯定・批判の3つの立場から同じ深さで答える | [references/consult-3views.md](references/consult-3views.md) |
| 設計と実装でモデルを分ける | 設計・計画の工程は上位のモデル、実装は標準のモデルに振り分ける | [references/plan-with-opus.md](references/plan-with-opus.md) |
| YouTube 要約 | YouTube の URL を、図解・タイムライン・結論の3部構成で要約する | [references/youtube-summary.md](references/youtube-summary.md) |
| SwiftUI で Mac アプリを作る | macOS アプリの既定値（設定画面・メニュー・ショートカット・日本語 UI・可読性優先）に沿って作る。コード集は [references/swiftui-boilerplate.md](references/swiftui-boilerplate.md) | [references/swiftui-macos-app.md](references/swiftui-macos-app.md) |

## 共通の決まり

- **証拠のない「完了」を出さない**：完了を報告するときは、実行したコマンドとその結果を添える。確かめられなかったことは「未検証」と書く
- **指摘の数を成果にしない**：正しさ・要件・データ損失・セキュリティに関わる問題だけを指摘する。好みやスタイルには口を出さない
- **読み取り専用の道具は書き込まない**：検証役・レビュー役・調査役は、ファイルの変更・コミット・外部への送信をしない

同じ内容を Claude Code のプラグインとして MIT ライセンスで公開しています: https://github.com/somaWyd/claude-code-toolkit
