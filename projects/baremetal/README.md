# 内容

Anthos Clusters on Baremetal 用プロジェクト

# 作成方法

プロジェクト作成

```sh
terraform init -backend-config=../backend.hcl
terraform apply -target=google_project.main
```

出力 ID を元に VPC SC への設定を実施後 (本フォルダ外) に、全体適用する

```sh
terraform apply
```

# ドキュメント
<https://cloud.google.com/anthos/clusters/docs/bare-metal/latest/installing/configure-sa>
