# Sample Reels


## 📌 概要
技育ハッカソンにて開発中のアプリ。  
サンプルをリール形式で表示する機能を提供。


## 🛠 使用技術
- Flutter
- Dart
- Firebase (予定)
- GitHub (チーム開発)


## 🚀 開発環境セットアップ
### 1. リポジトリをクローン
```
git clone https://github.com/taishi29/sample-reels.git
```


## GitHub 運用ルール
### 1. ブランチ運用
- `main`：リリース用（直接push禁止）
- `develop`：開発ブランチ（各featureブランチをここにマージ）
- `feature/xxx`：画面ごとの開発ブランチ

#### ブランチの作り方と切り替え方
```
git branch \\ 現在のブランチを確認
git checkout -b 新しいブランチ名 \\ 新しいブランチを作成＆現在のブランチをそのブランチに切り替える
（例："git checkout -b feature/top" は TOP画面のブランチを作って、現在のブランチから、feature/topブランチに切り替えるって意味。)

git push -u origin ブランチ名 \\ 作ったブランチをリモートリポジトリに反映
```
---
### 2. コミットメッセージルール

#### フォーマット 
```
git commit -m "<タイプ>: #<Issu番号> <タイトル>"  
```
#### 例 
```
git commit -m "feat: #123 ログイン機能の実装をする"  
```
※ コメント内容は、現在形が正しいらしい。"何々した"ではなくて  
### Type（コミットの種類）一覧  

| Type       | 説明                          | 
|------------|-------------------------------| 
| `feat`     | 新機能追加                     | 
| `fix`      | バグ修正                       | 
| `update`   | 機能修正                       | 
| `remove`   | ファイル削除                   | 
| `doc`      | README等の更新                 | 
