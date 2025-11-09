# Energy-Dia

[English version](README.md)

**Energy-Dia**は、化学・物理学の専門的なエネルギー図を作成するための、パワフルで直感的なTypstライブラリです。CeTZをベースに構築され、原子軌道図、分子軌道図、バンド構造図を簡単かつ美しく描画できます。

## 特徴

- **原子軌道図 (AO)**: 縮退度やスピン状態に対応したエネルギー準位と電子配置を視覚化
- **分子軌道図 (MO)**: 軌道の混成と電子分布を含む包括的なMO図を作成
- **バンド構造図**: 最小限のコードで素早くバンド構造をプロット
- **カスタマイズ可能**: 図のサイズ、ラベル、スタイルを完全にコントロール
- **シンプルな構文**: 学習しやすく使いやすい直感的なAPI

## クイックスタート

### インストール

```typst
#import "@preview/energy-dia:0.1.0": *
```

### 基本例

```typst
#ao(
  width: 10,
  height: 10,
  (energy: -10, electrons: 2, caption: "1s"),
  (energy: -3, electrons: 2, caption: "2s"),
  (energy: -1, electrons: 4, degeneracy: 3, up: 3, caption: "2p"),
)
```

## 使用ガイド

### 原子軌道図 (AO)

電子配置を含む原子軌道のエネルギー準位図を作成します。

#### 基本構文

```typst
#ao(
  width: 10,
  height: 10,
  name: "C",
  exclude_energy: false,
  (energy: -10, electrons: 2, caption: "1s"),
  (energy: -3, electrons: 2, caption: "2s"),
  (energy: -1, electrons: 4, degeneracy: 3, up: 3, caption: "2p"),
)
```

#### パラメータ

**図の設定:**
- `width` (length): 図の幅（デフォルト: 5）
- `height` (length): 図の高さ（デフォルト: 5）
- `name` (string): 表示する原子名（デフォルト: none）
- `exclude_energy` (boolean): エネルギー値を非表示（デフォルト: false）

**軌道準位**（位置引数、各々を辞書として指定）:
- `energy` (number): 軌道のエネルギー値
- `electrons` (number): 電子数（デフォルト: 0）
- `degeneracy` (number): 軌道の縮退度（デフォルト: 1）
- `caption` (string): 軌道のラベル（デフォルト: none）
- `up` (number): スピンアップ電子の数（オプション; 指定しない場合、電子はアップとダウンのスピンが交互に配置されます）

---

### 分子軌道図 (MO)

原子軌道から分子軌道が形成される過程を軌道混成とともに視覚化します。

#### 基本構文

```typst
#mo(
  width: 15,
  height: 10,
  names: ("O", $"O"_2$ , "O"),
  exclude_energy: false,
  atom1: (
    (energy: -14, electrons: 2, label: 1, caption: "2s"),
    (energy: -5, electrons: 4, degeneracy: 3, up: 3, label: 2, caption: "2p"),
  ),
  molecule: (
    (energy: -16, electrons: 2, label: 3, caption: [$1sigma$]),
    (energy: -12, electrons: 2, label: 4, caption: [$1sigma^*$]),
    (energy: -8, electrons: 2, label: 5, caption: [$2sigma$]),
    (energy: -6, electrons: 4, degeneracy: 2, label: 7, caption: [$pi$]),
    (energy: -4, electrons: 2, degeneracy: 2, up: 2, label: 8, caption: [$pi^*$]),
    (energy: -2, electrons: 0, label: 6, caption: [$2sigma^*$]),
  ),
  atom2: (
    (energy: -14, electrons: 2, label: 9, caption: "2s"),
    (energy: -5, electrons: 4, degeneracy: 3, up: 3, label: 10, caption: "2p"),
  ),
  (1, 3), (1, 4), (2, 5), (2, 7), (2, 8), (2, 6),
  (9, 3), (9, 4), (10, 5), (10, 7), (10, 8), (10, 6)
)
```

#### パラメータ

**図の設定:**
- `width` (length): 図の幅（デフォルト: 5）
- `height` (length): 図の高さ（デフォルト: 5）
- `names` (array): 左側原子、分子、右側原子の名前（デフォルト: ()）
- `exclude_energy` (boolean): エネルギーラベルを非表示（デフォルト: false）

**軌道データ:**
- `atom1` (array): 左側原子の軌道
- `molecule` (array): 分子軌道
- `atom2` (array): 右側原子の軌道

各軌道は以下のキーを持つ辞書:
- `energy` (number): エネルギー値
- `electrons` (number): 電子数（デフォルト: 0）
- `degeneracy` (number): 縮退度（デフォルト: 1）
- `caption` (string): ラベル（デフォルト: none）
- `up` (number): スピンアップ電子の数（オプション）
- `label` (number): 接続用の一意識別子

**接続**（位置引数）:
`(1, 3)`のようなタプルで、ラベル1と3の軌道を点線で接続します。

**重要:** 各軌道配列（`atom1`、`atom2`、`molecule`）は、単一の軌道でも配列でなければなりません。末尾のカンマを忘れずに: `((energy: -5, electrons: 1),)`

---

### バンド構造図

最小限の構文でエネルギー準位図をプロット-バンド構造など軌道の数が多いときに最適

#### 基本構文

```typst
#band(
  width: 5,
  height: 5,
  name: "Si",
  include_energy_labels: true,
  -5, -4, -3, 0, 1, 2
)
```

#### CSVデータから読み込み

```typst
#let data = csv("test.csv")
#let energies = data.map(row => float(row.at(0))).flatten()
#band(
  include_energy_labels: false,
  ..energies
)
```

#### パラメータ

- `width` (length): 図の幅（デフォルト: 5）
- `height` (length): 図の高さ（デフォルト: 5）
- `name` (string): 表示する物質名（デフォルト: none）
- `include_energy_labels` (boolean): エネルギー値を表示（デフォルト: false）
- 位置引数: エネルギー準位の値

## 例

### 原子軌道図

![原子軌道図](img/atomic_orbital.png)

### 分子軌道図

![分子軌道図](img/molecular_orbital.png)

### バンド構造図

![バンド構造図](img/band.png)

**完全な実例は[demo.typ](demo/demo.typ)をご覧ください！**

## 依存関係

- **[CeTZ](https://github.com/cetz-package/cetz)** v0.4.2 - 描画ライブラリ（LGPL-3.0）

## ライセンス

このプロジェクトは**GNU General Public License v3.0**の下でライセンスされています。詳細は[LICENSE](LICENSE)を参照してください。

## 貢献

貢献を歓迎します！issueを開いたり、プルリクエストを送信したりしてください。