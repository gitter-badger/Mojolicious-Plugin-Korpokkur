##フォルダの構成
- public(静的ファイル）
- templates(テンプレート)
- stash(各ページ用データディレクトリ）
- lib（perlライブラリ プラグインなど）
- korpokkur.yaml（設定ファイル）
- sitemap.yaml（ページ生成メタファイル）

## サーバーの起動
ターミナルからこのディレクトリに移動してkpokkurを起動

■ publish（静的ファイルの生成）
pokkur publish

##制作フロー
1. kpokkurコマンドでサーバーを起動する
2. korpokkur.yamlで共通設定を編集
3. sitemap.yamlを編集して生成するページを設定する
5. publicフォルダにcssやjs、画像などサイトに必要な静的ファイルを配置する
4. templateを編集、追加
6. ページに必要な本文などの情報をstashフォルダに作成
7. サーバーで確認しならがし終えたらpokkur publishでサイト生成



