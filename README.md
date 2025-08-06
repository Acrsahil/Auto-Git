# Auto-Git 🚀

Auto-Git is a set of command-line utilities for managing GitHub repositories and their contents directly from the terminal. It simplifies common GitHub tasks such as creating, deleting, and listing repositories, as well as listing the contents of those repositories.

<p align="center">
  <a href="https://github.com/Acrsahil/Auto-Git/graphs/contributors"><img src="https://img.shields.io/github/contributors/Acrsahil/Auto-Git?style=for-the-badge" /></a>
  <a href="https://github.com/Acrsahil/Auto-Git/stargazers"><img src="https://img.shields.io/github/stars/Acrsahil/Auto-Git?style=for-the-badge" /></a>
  <a href="https://github.com/Acrsahil/Auto-Git/forks"><img src="https://img.shields.io/github/forks/Acrsahil/Auto-Git?style=for-the-badge&color=gold" /></a>
  <a href="https://github.com/Acrsahil/Auto-Git/blob/main/LICENSE"><img src="https://img.shields.io/github/license/Acrsahil/Auto-Git?style=for-the-badge&color=purple" /></a>
  <a href="https://www.python.org/"><img src="https://img.shields.io/badge/Python-47%25-blue?style=for-the-badge" /></a>
  <a href="https://www.gnu.org/"><img src="https://img.shields.io/badge/Bash-27%25-green?style=for-the-badge&color=green" /></a>
  <a href="https://man.openbsd.org/roff.7"><img src="https://img.shields.io/badge/Roff-25%25-yellow?style=for-the-badge&color=teal" /></a>
</p>

![Banner](guide/banner.png)

## Table of Contents 📚

1. [Installation](#installation-%EF%B8%8F)
2. [Install Dependencies](#step-2-install-dependencies)
3. [Setup](#step-3-run-to-install)
4. [Examples](#examples)
5. [Requirements](#requirements-)
6. [Exit Status Codes](#exit-status-codes-)
7. [Authors](#authors-)
8. [Bugs and Feedback](#bugs-and-feedback-)
9. [Generate Personal Access Token](#guide-)

---

## Commands

Here’s a list of the available commands and their descriptions:

| Command          | Description                                     |
| ---------------- | ----------------------------------------------- |
| `gls`            | Lists the repository.                           |
| `gmkdir`         | Creates a new directory and adds it to Git.     |
| `grmdir`         | Removes a directory and its contents from Git.  |
| `gpush`          | Commits and pushes changes to the remote repo.  |
| `gls + reponame` | Lists the contents of the specified repository. |

## Installation 🛠

Follow these steps to install Auto-Git:

### Step 1: Clone the Repository

Clone this repository to your local machine by running:

    git clone https://github.com/Acrsahil/Auto-Git.git
    cd Auto-Git

## Step 2: Install Dependencies

Make sure you have python3 and pip installed

## Setup Instructions ⚙️

Before using Git-Auto, ensure that you have configured your GitHub access token for authentication.

[Generate GitHub Personal Access Token](#guide-)

    Visit your GitHub Personal Access Tokens page.
    Click Generate new token.
    Select the necessary permissions (e.g., repo for full repository access).
    Save the token securely.

## Step 3: Run to install

    ./install.py

It will ask you to input your GitHub access token.

## Examples

#### Create a Repository:📂

    gmkdir new-awesome-project

This will create a new repository named new-awesome-project.

#### Delete Repositories:🗑

    grmdir repo1 repo2

This will delete the repositories repo1 and repo2 from your GitHub account.

#### List Repositories:📜

    gls

This will list all the repositories in your GitHub account.

#### List Repositories Contents:📁

    gls repo1 repo2

This will list all the contents inside your repo1 and repo2.

## Requirements 📌

    Python 3.x
    GitHub Personal Access Token with appropriate permissions
    requests library (Install with pip install requests)

## Exit Status Codes 🚦

    0: Success ✅
    1: General error ❌
    2: Authentication failure 🔐
    3: Invalid repository name ⚠️

## Authors 👨‍💻👩‍💻

Sahil Acharya : Creator and Lead Developer 💻

## Bugs and Feedback 🐞

If you encounter any issues or have suggestions for improvements, please open an issue on the GitHub Repository. We'd love to hear from you! 😄

Happy automating! 🚀
