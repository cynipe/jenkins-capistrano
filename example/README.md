# jenkins-capistrano example

jenkins-capistranoを使って、master-slave構成のJenkinsに以下のことを行う設定例

* バッチで必要なジョブ
* バッチを実際に実行するためのスレーブノードの登録
* バッチプログラム(binディレクトリ)のデプロイ

## 前提

* ローカルにruby1.8.7+が入っていること
* 各スレーブノードに`/opt/hello`ディレクトリがあること
* `/opt/hello`ディレクトリにjenkinsユーザが書き込み権限があること
* jenkinsユーザがマスターノードからスレーブノードに公開鍵認証で接続できること

## デプロイの仕方

本番環境:
```
$ script/deploy production
```

ステージング環境:
```
$ script/deploy production
```

開発環境:
```
$ script/deploy
```

