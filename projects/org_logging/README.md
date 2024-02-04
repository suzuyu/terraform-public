# 内容
組織内ログのシンク先作成

# 作成方法
`main.tf` 内の `bucket` を利用できるバケットに書き換える

プロジェクト作成

```sh
terraform init
terraform apply -target=google_project.main
```

VPC SC 設定 ../../vpc_service_controles.tf

設定

```sh
terraform apply 
```
