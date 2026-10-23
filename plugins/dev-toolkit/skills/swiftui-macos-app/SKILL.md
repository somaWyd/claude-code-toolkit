---
name: swiftui-macos-app
description: "SwiftUIでmacOSネイティブアプリを新規作成・設計・機能追加するときの標準規約（Command+,設定画面、メニュー/ショートカット、フォント選択、日本語UI、ログイン起点導線、可読性優先）。「Macアプリ」「macOSアプリ」で必ず参照。使わない：iOS/iPadOS、Web/Electron/Tauri。"
---

# SwiftUI macOS アプリ 標準規約

「Macアプリを作って」と頼んだときに毎回同じ前提を指定しなくて済むよう、
**指定がなくても常に適用するデフォルト**をここにまとめる。ユーザーが明示的に上書きした項目だけ従い、
それ以外はこの表のとおりに作る。

| 項目 | デフォルト | 理由 |
|---|---|---|
| 最小デプロイ | macOS 14 (Sonoma) 以上 | `Settings` scene・String Catalog・最新API前提で分岐を減らす |
| 表示言語 | 日本語（開発言語 = ja、String Catalog `.xcstrings`） | 日本語話者向けを既定にする（英語が要るなら上書き） |
| 設定画面 | `Settings` scene を標準装備（⌘, で起動） | 毎回頼まれなくても付ける |
| ショートカット | 標準メニューコマンド + 主要操作にキー割当を標準装備 | ネイティブらしい操作性をデフォルト化 |
| フォント | ユーザーが設定画面で選択・サイズ変更でき、`@AppStorage` で永続化 | 可読性は人によって最適が違う |
| 外部サービス連携 | Google/Notion等は**ログイン画面を起点**にした導線から始める | 認証してから作成に進む自然な順序 |
| 設計の優先度 | **可読性 > 情報密度 > 装飾** | UI/UXをユーザー中心にする |

> 迷ったら「可読性を最優先」に倒す。密度・装飾・凝ったアニメーションは、読みやすさを損なうなら削る。

詳細なコピペ用ボイラープレートは [references/boilerplate.md](references/boilerplate.md) に置いてある。
実装時はまずこのファイルで方針を掴み、必要なコード全文だけそちらを開くこと。

---

## 1. プロジェクト初期設定

新規アプリの `App` は最初からこの骨組みで作る。`WindowGroup` に本体、`Settings` に設定画面を並べるのが基本形。

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands { AppCommands() }   // ← セクション2

        Settings {
            SettingsView()            // ← セクション3。これだけで ⌘, が有効になる
        }
    }
}
```

- **デプロイターゲット**は macOS 14 以上。古い環境の要望が明示されたときだけ下げる。
- **日本語をデフォルト**にする：Xcodeプロジェクトの Development Language を日本語にし、
  文言は `Text("保存")` のようにベースを日本語で書く。ローカライズは String Catalog（`.xcstrings`）で管理し、
  ハードコードした英語UIを残さない。将来英語対応する余地としてカタログは用意しておく。

## 2. キーボードショートカット & メニューコマンド

「毎回ショートカットを有効にして」という要望への回答がここ。**アプリ生成時に必ずメニューコマンド群を定義**し、
主要操作にキー割当を付ける。ボタンにも `.keyboardShortcut` を添える。

```swift
struct AppCommands: Commands {
    var body: some Commands {
        // 標準のFileメニュー先頭に「新規」を追加
        CommandGroup(after: .newItem) {
            Button("新規作成") { /* … */ }
                .keyboardShortcut("n", modifiers: .command)
        }
        // 独自メニュー
        CommandMenu("操作") {
            Button("更新") { /* … */ }
                .keyboardShortcut("r", modifiers: .command)
        }
    }
}
```

指針：

- **⌘, （設定）は自作しない。** `Settings` scene を置けばSwiftUIが自動で割り当て＆メニュー項目を追加する。
  自前で ⌘, を `keyboardShortcut` に割り当てると二重定義になるので禁止。
- よく使う操作（新規=⌘N、保存=⌘S、更新=⌘R、検索=⌘F、削除=⌘⌫ など）には**macOS慣習に沿った**割当を付ける。
  独自キーを発明する前に標準慣習を確認する（慣習外は学習コストになり、可読性・操作性を下げる）。
- 破壊的操作（削除など）にショートカットを付けるときは、確認ダイアログや取り消し（Undo）を併せて用意する。

## 3. 設定（Settings）画面

`Settings` scene に置く。タブが複数になるなら `TabView` + `.tabItem` で整理する。
最低限「一般」タブに**外観（フォント）**設定を入れる。

```swift
struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem { Label("一般", systemImage: "gearshape") }
            AppearanceSettingsView()
                .tabItem { Label("外観", systemImage: "textformat") }
        }
        .frame(width: 480)   // 設定ウィンドウは固定幅で読みやすく
    }
}
```

## 4. フォントを選べるようにする

「フォントを自由に選べるように」への回答。**フォント種別とサイズをユーザーが設定画面で変更でき、
`@AppStorage` で永続化**し、アプリ全体へ反映させる。

方針：

1. 設定を `@AppStorage("fontName")` / `@AppStorage("fontSize")` で保持する。
2. 選択肢は `NSFontManager.shared.availableFontFamilies` から取得して `Picker` に流す（AppKit）。
   「システムデフォルト」を先頭に必ず入れ、初期値にする。
3. 適用は `Font.custom(name, size:, relativeTo:)` を使う。`relativeTo:` を付けるとDynamic Type/
   アクセシビリティのサイズ変更に追従でき、可読性が上がる。カスタム未選択時は `.system` に戻す。
4. 反映はルートで `.environment(\.font, …)` か共有 `@Observable` 設定オブジェクト経由で全画面に伝播させる。

具体コードは [references/boilerplate.md](references/boilerplate.md) の「フォント設定」節に全文がある。

> 可読性の観点：フォントサイズの下限（例: 11pt相当）を設け、極端に小さくできないようにする。
> プレビュー（サンプル文＝日本語＋英数字）を設定画面に置き、選択結果をその場で確認できるようにする。

## 5. 外部サービス連携（Google / Notion 等）はログイン起点で

「Google/Notionを使うときはログイン画面をまず持ってきて、そこから作成に進む」への回答。

順序の原則：**未認証なら、機能画面ではなくログイン画面を最初に見せる。認証が済んで初めて作成・操作フローに入る。**

```
起動 → 認証状態を確認
  ├─ 未ログイン → ログイン画面（サービス名・「◯◯でログイン」ボタン・何ができるかの説明）
  │                   → 認証成功 → 作成/操作フローへ
  └─ ログイン済み → そのまま作成/操作フローへ
```

実装指針：

- OAuthは `ASWebAuthenticationSession`（`AuthenticationServices`）を使う。Google・NotionともOAuth 2.0。
- **トークンはUserDefaultsに平文で置かない。** Keychainに保存する（アクセストークン/リフレッシュトークン）。
- ログイン画面には「そのサービスで何をするのか」を一文で示し、いきなり権限同意に飛ばさない。
- 認証状態は共有の `@Observable` に持たせ、ビュー側は状態で分岐（未ログイン→ログイン、済→本体）。
- **セキュリティ境界**：client secret などの秘密情報はハードコードしない。トークンやAPI応答は必ず検証してから使う。
  認証・トークン処理を実装したら `code-reviewer` エージェントでレビューする。

> 注意：OAuthのclient ID/secret発行や同意画面の承認はユーザー自身の操作。こちらで代行しない。

## 6. UI/UX ― 可読性を最優先する設計原則

「画面の可読性を最重要に」への回答。判断に迷う場面では、以下を根拠に**読みやすい側へ倒す**。

- **タイポグラフィ**：本文は十分な行間（line spacing）を確保。1行を長くしすぎない。
  情報の階層（見出し/本文/補足）をサイズと太さで明確に分ける。`Font.TextStyle`（`.title`, `.body` 等）を基準にする。
- **コントラスト**：文字と背景のコントラストを確保する（WCAG AA: 本文4.5:1目安）。
  薄いグレー文字を情報の主役にしない。色は必ずセマンティックカラー（`.primary`/`.secondary`/`Color(nsColor:)`）で、
  ライト/ダーク両対応。色だけで意味を伝えない（アイコン・ラベルを併用）。
- **余白とグルーピング**：詰め込まない。関連要素は近づけ、無関係な要素は離す（近接の法則）。
  余白は可読性のための機能であって、削る対象ではない。
- **アクセシビリティ**：Dynamic Type / サイズ変更に追従（セクション4の `relativeTo:`）。
  各コントロールに `accessibilityLabel`。VoiceOverで意味が通るか意識する。
- **ネイティブに従う**：macOSの標準コンポーネント・標準の配置（ツールバー、サイドバー、`Form` など）を優先。
  独自の見た目を作る前に、標準で解けないか確認する。テンプレ然とした無個性UIも、逆に奇抜すぎるUIも避け、
  「読みやすさ」という一貫した方向性を先に決めてから作る。
- **フィードバック**：操作の結果（保存済み・読み込み中・エラー）を必ず可視化。エラーは握りつぶさず、
  ユーザーに次の行動が分かる日本語メッセージで示す。

---

## 実装後のチェックリスト

アプリ（または画面）を作り終えたら、以下を自己確認してからユーザーに渡す。

- [ ] ⌘, で設定画面が開く（`Settings` scene を使っている）
- [ ] 主要操作にmacOS慣習準拠のショートカットが付いている
- [ ] 設定画面でフォント種別・サイズを変更でき、全体に反映＆再起動後も保持される
- [ ] UIの初期表示が日本語で、文言はString Catalogで管理されている
- [ ] 外部サービスは未認証時にログイン画面が起点になる／トークンはKeychain
- [ ] 本文コントラスト・行間・余白が確保され、ダークモードでも読める
- [ ] 認証・入力処理・APIクエリを触ったら `code-reviewer` でレビュー済み
