# claude-code-toolkit

Claude Code のプラグインマーケットプレイス（エージェントとスキル）。

- 検証: `claude plugin validate .` と `claude plugin validate ./plugins/dev-toolkit`
- エージェントは `plugins/dev-toolkit/agents/`、スキルは `plugins/dev-toolkit/skills/<名前>/SKILL.md`
- 変更したら `plugins/dev-toolkit/.claude-plugin/plugin.json` の `version` を上げる
- 個人のパス・アカウント・業務の情報を書かない（公開リポジトリ）- Capafy 用の1フォルダ版は `capafy/build.sh` で `dist/claude-code-toolkit/` に組み立てる（入口は `capafy/SKILL.md`。dist は git 管理外）
