# Position Size Calculator - 要件定義書

## プロジェクト概要

USD/JPY 為替取引のリスク管理ツール。チャート上でエントリー・損切り・利確ラインをドラッグ操作し、ポジションサイズをリアルタイムで計算する Web アプリケーション。

---

## 機能要件

### 画面構成

```
┌────────────────────────────────────┬──────────────────────┐
│                                    │  Position Size       │
│   TradingView Lightweight Charts   │  Calculator          │
│   (USD/JPY チャート)                 ├──────────────────────┤
│                                    │  口座残高 (JPY)       │
│   ─────────── Entry (青)           │  リスク (%)          │
│   - - - - - - SL (赤)              │  エントリー          │
│   ············ TP (緑)             │  損切り (SL)         │
│                                    ├──────────────────────┤
│                                    │  ロットサイズ        │
│                                    │  リスク金額          │
│                                    │  リワード金額        │
│                                    │  RR比                │
└────────────────────────────────────┴──────────────────────┘
```

### チャート機能

- **ライブラリ**: TradingView Lightweight Charts（オープンソース）
  - TradingView の iframe Widget はカスタムオーバーレイ不可のため、同社が提供するオープンソースライブラリを使用
  - CDN 経由で読み込み、外部 API キー不要
- **通貨ペア**: USD/JPY 固定
- **データ**: デモ用ローソク足データ（自動生成）

### ドラッグライン機能

- エントリー・SL・TP の 3 本のラインをチャート上に表示
- **マウスドラッグで価格を変更可能**
- カーソルをライン上に乗せると `ns-resize` カーソルに変化
- ドラッグ中はチャートのスクロール・スケールを無効化

### 双方向同期

| 操作 | 動作 |
|------|------|
| Entry または SL を動かす | RR を維持したまま TP を自動再計算 |
| TP を動かす | RR を再計算 |
| フォーム入力値を変更 | ラインが即時移動 |
| ライン操作 | フォーム入力値が即時更新 |

### 計算ロジック（USD/JPY）

```
SL pips     = |entry - sl| / 0.01
Risk Amount = balance × (riskPercent / 100)          [JPY]
Lot Size    = riskAmount / (slPips × 1000)            [lot]
TP (Entry/SL変更時) = entry + (entry - sl) × rr
TP pips     = |tp - entry| / 0.01
Reward      = lotSize × tpPips × 1000                [JPY]
RR (TP変更時) = |tp - entry| / |entry - sl|
```

- **前提**: 1 pip = 1,000 JPY（標準ロット 100,000 通貨 × 0.01）
- **デフォルト RR**: 2.0

### 認証機能（Devise）

- ユーザー登録 / ログイン / ログアウト
- 認証済みユーザーのみ計算画面にアクセス可能

### ユーザー設定の保存

- 口座残高・リスク% を DB に保存（User モデル）
- ログイン時に自動読み込み

---

## 非機能要件

- **レスポンシブ**: デスクトップ優先（最低幅 1024px）
- **リアルタイム**: 入力・ライン操作に対してリアルタイム計算更新
- **デプロイ先**: Render（PostgreSQL 使用）

---

## 技術スタック

| 種別 | 技術 |
|------|------|
| バックエンド | Ruby on Rails 7.2.3 |
| データベース | PostgreSQL |
| 認証 | Devise 5.x |
| チャート | TradingView Lightweight Charts v4（CDN） |
| フロントエンド | Vanilla HTML / CSS / JavaScript |
| デプロイ | Render |

---

## データモデル（概要）

### users テーブル

| カラム | 型 | 説明 |
|--------|-----|------|
| id | bigint | PK |
| email | string | Devise 標準 |
| encrypted_password | string | Devise 標準 |
| account_balance | decimal | 口座残高（JPY） |
| risk_percent | decimal | リスク許容率（%） |
| created_at | datetime | - |
| updated_at | datetime | - |

---

## 開発フェーズ

| フェーズ | 内容 |
|----------|------|
| Phase 1 | 初期セットアップ・ドキュメント・Git 連携 |
| Phase 2 | Devise 認証（User モデル・ビュー） |
| Phase 3 | コアレイアウト（チャート＋サイドパネル） |
| Phase 4 | TradingView Lightweight Charts 統合 |
| Phase 5 | ドラッグライン＆双方向同期・計算ロジック |
| Phase 6 | ユーザー設定保存（DB 永続化） |
| Phase 7 | デプロイ最終確認（Render） |
