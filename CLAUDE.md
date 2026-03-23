# CLAUDE.md - Position Size Calculator

## 技術スタック

| 種別 | 技術 | バージョン |
|------|------|-----------|
| 言語 | Ruby | 3.4.x |
| フレームワーク | Ruby on Rails | 7.2.3 |
| データベース | PostgreSQL | 18.x |
| 認証 | Devise | 5.x |
| チャート | TradingView Lightweight Charts | 4.x（CDN） |
| フロントエンド | Vanilla JS / HTML / CSS | - |
| デプロイ | Render | - |

---

## 開発コマンド

```bash
# サーバー起動
bundle exec rails server

# データベース操作
bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails db:seed

# マイグレーション生成
bundle exec rails generate migration MigrationName

# Devise
bundle exec rails generate devise:install
bundle exec rails generate devise User

# コンソール
bundle exec rails console

# テスト
bundle exec rails test
```

> **注意**: `vendor/bundle` にインストールしているため、必ず `bundle exec` を付けること。

---

## ディレクトリ構成（主要ファイル）

```
position_size_calculator/
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb
│   │   └── calculator_controller.rb     # メイン画面
│   ├── models/
│   │   └── user.rb                      # Devise + 設定カラム
│   ├── views/
│   │   ├── layouts/
│   │   │   └── application.html.erb     # LightweightCharts CDN読み込み
│   │   ├── calculator/
│   │   │   └── index.html.erb           # チャート＋パネル
│   │   └── devise/                      # 認証ビュー
│   └── assets/
│       ├── stylesheets/
│       │   └── application.css
│       └── javascripts/
│           └── calculator.js            # チャート・計算ロジック
├── config/
│   ├── routes.rb
│   └── database.yml
├── .env                                 # ローカル環境変数（git 除外）
├── REQUIREMENTS.md
├── CLAUDE.md
└── render.yaml
```

---

## 環境変数

### 開発環境（`.env`）

```
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=your_password_here
```

### 本番環境（Render）

| 変数名 | 説明 |
|--------|------|
| `DATABASE_URL` | Render が PostgreSQL 作成時に自動設定 |
| `RAILS_MASTER_KEY` | `config/master.key` の内容をコピー |
| `RAILS_ENV` | `production` |

---

## 計算ロジック仕様

### USD/JPY 固定

```javascript
// pip計算（USD/JPY: 小数点第2位）
const slPips      = Math.abs(entry - sl) / 0.01;
const tpPips      = Math.abs(tp - entry) / 0.01;

// リスク・リワード
const riskAmount  = balance * (riskPercent / 100);    // JPY
const lotSize     = riskAmount / (slPips * 1000);     // lot
const rewardAmount = lotSize * tpPips * 1000;         // JPY

// TP自動計算（Entry/SL変更時）
const direction   = entry > sl ? 1 : -1;
const tp          = entry + direction * Math.abs(entry - sl) * rr;

// RR再計算（TP変更時）
const rr          = Math.abs(tp - entry) / Math.abs(entry - sl);
```

- 1 lot = 100,000 通貨 → 1 pip = 1,000 JPY
- デフォルト RR: 2.0

---

## コーディング規約

- **Ruby**: Rails 標準スタイル（rubocop-rails-omakase 準拠）
- **JavaScript**: ES6+、フレームワークなし（Vanilla JS）
- **CSS**: カスタム CSS、ダークテーマ（トレーディングツール向け）
- コメントは英語または日本語どちらでも可

---

## Git ブランチ戦略

```
main      ← 本番リリースのみマージ
develop   ← 開発ベースブランチ
feature/* ← 各フェーズの機能開発
```

### コミットメッセージ規約

```
Phase N: 短い説明（日本語可）

例:
Phase 2: Add Devise authentication
Phase 3: Add calculator layout with chart panel
```

---

## デプロイ（Render）

1. GitHub リポジトリを Render に接続
2. `render.yaml` を元に Web Service + PostgreSQL を自動作成
3. Environment Variables に `RAILS_MASTER_KEY` を設定
4. Deploy

詳細は `render.yaml` を参照。
