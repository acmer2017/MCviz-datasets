# MCviz datasets

用于 [MCviz](https://github.com/acmer2017/MCviz) 构建静态索引的分层图输入快照。
数据文件放在 GitHub Release 附件中；Git 仓库保存下载脚本、说明和 SHA-256 清单。

## 下载

固定版本：[`static-v2026.10.15`](https://github.com/acmer2017/MCviz-datasets/releases/tag/static-v2026.10.15)。
压缩包 `k-partite-graph-static.tar.gz` 为 **217,779,268 bytes（207.69 MiB）**，解压后的 11 个图文件共 **1,034,967,899 bytes（987.02 MiB）**。

在另一台 Linux 服务器上，将数据与 MCviz 源码放在同一个父目录：

```bash
cd /path/to/workspace
git clone https://github.com/acmer2017/MCviz-datasets.git
bash MCviz-datasets/download.sh "$PWD"
```

脚本下载固定版本，校验压缩包 SHA-256，解压并校验每个图文件；已有 `k-partite-graph/` 时拒绝覆盖。下载缓存位于父目录下的 `.mcviz-datasets-cache/static-v2026.10.15/`，可在成功后删除。无需 Git LFS 或 GitHub 登录。

目录布局：

```text
workspace/
├── MCviz/                 # 程序源码
├── MCviz-datasets/        # 本仓库：下载脚本和清单
└── k-partite-graph/        # 解压后的静态输入
```

也可以从 Release 页面手动下载压缩包、`SHA256SUMS`、`MANIFEST.tsv` 和 `DATASET_SHA256SUMS` 到一个空目录，执行：

```bash
sha256sum -c SHA256SUMS
tar -xzf k-partite-graph-static.tar.gz
sha256sum -c k-partite-graph/SHA256SUMS
```

GitHub 自动生成的 `Source code (zip)` / `Source code (tar.gz)` 只包含本仓库的小文件；图数据在命名为 `k-partite-graph-static.tar.gz` 的附件中。

## 输入与版本

每条边一行，字段为 `part_u vertex_id_u part_v vertex_id_v`；层号从 0 开始，`#` 行为注释。完整规范及来源记录见 [MCviz datasets/Readme.md](https://github.com/acmer2017/MCviz/blob/main/datasets/Readme.md)。

| 文件 | 字节数 | test1 primary（0-based） |
| --- | ---: | ---: |
| `DBLP_k2.txt` | 229,644,533 | — |
| `WikiPedia_k2.txt` | 65,085,916 | 0 |
| `acm_k4.txt` | 3,980,529 | 0 |
| `aminer_k3.txt` | 237,191,826 | 1 |
| `bibsonomy_k3.txt` | 63,571,415 | 0 |
| `dblp_hgb_k4.txt` | 1,583,900 | 1 |
| `imdb_hgb_k4.txt` | 588,036 | 0 |
| `lastfm_hetrec_k3.txt` | 2,841,111 | 0 |
| `marvel_k2.txt` | 1,393,885 | 0 |
| `movielens25m_k3.txt` | 426,875,022 | 0 |
| `writer_k2.txt` | 2,211,726 | — |

`—` 表示未列入当前 test1 默认矩阵。`DBLP_k2.txt` 与 `dblp_hgb_k4.txt` 是不同输入，不能互相替代。

这个版本原样保存打包时 `k-partite-graph/` 的全部 11 个顶层 `.txt`，未采样、重编号或转换。具体输入身份以 [MANIFEST.tsv](MANIFEST.tsv) 中的字节数和 SHA-256 为准。

**BibSonomy 版本说明：**本快照的 `bibsonomy_k3.txt` 是 63,571,415-byte 版本，SHA-256 为 `8267e76e7cf3198da8a44c4cfe0580e11362dfcbe9ff82621bf28f6da4d3e6dc`；它不是历史说明中 117,421,794-byte 的重建版本。实验对比应核对清单，不仅比较文件名。

## 构建静态索引

下面以 ACM、primary=0、MESC、阈值 `(2,2,2,2)` 演示普通 `opt/` 静态入口。具体论文实验参数请使用 MCviz 当前实验协议。

```bash
cd /path/to/workspace/MCviz
make -C opt
mkdir -p Index
./opt/mcviz_opt construct ../k-partite-graph/acm_k4.txt MESC \
  --primary 0 2 2 2 2 --index-output Index/acm-MESC-static.idx
```

`../k-bipartite-graph/` 是实验生成与缓存目录，包含 `dynamic/` 中的 full/base/delta 图、`Index/` 中的旧图索引、`coh/` 中的配对边值缓存，以及 `new-Index/` 中的更新后索引。
从静态输入重新构建索引不需要搬运该目录。旧 test1 的 `--prepare-only` / `--search-only` 仍可能准备动态派生文件；纯静态构建可直接使用上面的 `construct` 入口。

本快照不含 `raw/` 上游下载包、旧索引、动态派生图或边值缓存。原始文件保留在来源机器。

## 来源

AMiner 来自 metapath2vec / PyG 数据来源；ACM、DBLP HGB、IMDB HGB 来自 [HGB](https://github.com/THUDM/HGB)；MovieLens-25M 来自 [GroupLens](https://grouplens.org/datasets/movielens/25m/)；Last.fm 来自 [HetRec 2011](https://grouplens.org/datasets/hetrec-2011/)；BibSonomy 来自 KONECT。
其他二部图保留现有本地转换文件，本仓库尚未补齐其上游来源记录。数据的来源及转换说明以 MCviz 项目记录为准；本仓库不为上游数据重新授予许可证，使用时应遵循相应来源条款。
