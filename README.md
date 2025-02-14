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
git clone https://github.com/your-team/sample-reels.git

## GitHub 運用ルール
### 1. ブランチ運用
- `main`：リリース用（直接push禁止）
- `develop`：開発ブランチ（各featureブランチをここにマージ）
- `feature/xxx`：機能ごとの開発ブランチ

---

### 2. コミットメッセージルール

#### フォーマット   
git commit -m "<タイプ>: <Issu番号> <タイトル>"  
#### 例  
git commit -m "feat: 123 ログイン機能の実装をする"  
※ コメント内容は、現在形が正しいらしい。"何々した"ではなくて  
### Type（コミットの種類）一覧  

| Type       | 説明                          | 
|------------|-------------------------------| 
| `feat`     | 新機能追加                     | 
| `fix`      | バグ修正                       | 
| `update`   | 機能修正                       | 
| `remove`   | ファイル削除                   | 
| `doc`      | README等の更新                 | 
