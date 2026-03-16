# CONTRIBUTING.md

Thank you for your interest in contributing to this internal project. To maintain code quality and ensure a smooth development process, please adhere to the following guidelines.

---

## 🛠 Prerequisites

Before you begin, ensure you have completed the following steps:
1.  **Fork or Branch**: Create a new branch from `main`.
2.  **Environment Setup**: Follow the instructions in `README.md` to set up your local development environment.
3.  **Check Issues**: Verify if there is an existing Issue related to your proposed changes. For major architectural changes, please open an Issue for discussion before implementation.

---

## 🚀 Development Workflow

⚠️ **The development of this repository takes place entirely in the browser. You do not need to set up a local environment unless otherwise specified.**  

* [Operation Guide](https://docs.google.com/spreadsheets/d/1Mi7VOu7Ye6K5CWXbYOl2g46yuMOJuSqoJoiT8gq5T0c/edit?gid=1450391040#gid=1450391040)  

If you want to develop out of the guide scope, you need follow under rule.  

### 1. Branch Naming Convention
Please use the following prefixes for branch names to maintain clarity:
* `feat/` : New features or functional enhancements.
* `fix/` : Bug fixes.
* `docs/` : Documentation updates.
* `refactor/` : Code changes that neither fix a bug nor add a feature.

### 2. Coding Standards
* **Testing**: Ensure that your changes do not break existing functionality. Adding unit tests for new features is highly encouraged.
* **Documentation**: Update the internal documentation or inline comments if your changes affect the logic or API.

### 3. Commit Messages
Commit messages should be concise and descriptive. 

---

## 💻 Production environment release procedure

### 1. git pull
First, retrieve the latest code from the repository.
```
git pull
```

### 2. Check for differences between production and development environment code.

For the production environment SPARQList code (under `repository`), output a message if there are differences between the production environment code and the development environment code.
If only the SPARQL endpoint URL is different, it is considered that there are no differences.

```
sh bin/diff_with_dev.sh
```

If there are differences, the following message will be displayed for each file.
```
開発環境のコードとEndpoint以外の差異があります. 'pcf_get_omim_data_by_omim_id.md'.
次のコマンドで本番環境にコピーしてリリースできます。 sh bin/release_product_from_dev.sh pcf_get_omim_data_by_omim_id.md
```

If you want to check what the differences are, you can check the diff results with the following command.

`tmp/repository/***.md.diff`

```
cat tmp/repository/pcf_get_omim_data_by_omim_id.md.diff
```

If a file exists in the production environment but not in the development environment, the following message will be displayed:
```
開発環境にはない md ファイルです. 'test_pubtator3.md'
```

### 3. Release Execution with Specified MD Files  
Specify the MD files you wish to release. This copies the code from the development environment and releases it to the production environment.  
During release, the development SARQL endpoint is replaced with the production environment endpoint.  
Before: https://dev-pubcasefinder.dbcls.jp/sparql  
After: https://pubcasefinder.dbcls.jp/sparql

```
sh bin/release_product_from_dev.sh pcf_get_omim_data_by_omim_id.md
```
If the release succeeds, the following message will appear. Push to git as needed.  
You may release multiple files before performing a git commit & push.
```
ファイルが置換されました。次のコマンドで gitに反映して下さい
git add .
git commit -m'ここにコメントを入力'
git push origin main
```

### 4. Checking for Access to the Development Environment's SPARQL Endpoint
Check if there are any instances in the production environment accessing the development environment's SPARQL endpoint.

```
sh bin/check_dev_endopoint.sh
```

If there are lines containing "/sparql" and "dev", the following message will be displayed.

```
本番環境の SPARQList に開発環境用 Endpoint が書かれている可能性があります.
pcf_get_omim_data_by_omim_id.md, pcf_get_orpha_data_by_orpha_id.md,
```

---

## 📮 Pull Request (PR) Procedure

1.  **Submission**: Push your changes and create a Pull Request to the `main` branch.
2.  **PR Description**: Include the following details in your PR description:
    * **Overview**: A brief summary of the changes.
    * **Related Issues**: Reference any relevant Issue numbers (e.g., `Closes #123`).
    * **Verification**: Confirmation that the code has been tested in a local environment.
3.  **Review Process**: At least one approval from a maintainer is required for merging. After creating the PR, please notify the team in the designated Slack channel.

---

## 📝 Reporting Issues

If you encounter bugs or have suggestions for improvements:
* Open a new **Issue** with a clear title.
* Provide detailed steps to reproduce the bug.
* Attach logs or screenshots if applicable.
