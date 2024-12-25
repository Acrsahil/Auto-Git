# **Auto-Git** 🚀
Auto-Git is a set of command-line utilities for managing GitHub repositories directly from the terminal. It simplifies common GitHub tasks such as creating and deleting repositories.


## **Table of Contents** 📚

1. [Installation](#installation-%EF%B8%8F)
2. [Install Dependencies](#step-2-install-dependencies)
3. [Setup](#step-3-run-to-install)
4. [Examples](#examples)
5. [Requirements](#requirements-)
6. [Exit Status Codes](#exit-status-codes-)
7. [Authors](#authors-)
8. [Bugs and Feedback](#bugs-and-feedback-)

---

## **Installation** 🛠️

Follow these steps to install githubauto:

### **Step 1: Clone the Repository**

Clone this repository to your local machine by running:

```
git clone https://github.com/Acrsahil/Auto-Git.git
cd Auto-Git
```


## Step 2: Install Dependencies

Make sure you have python3 and pip installed



## Setup Instructions ⚙️

Before using githubauto, ensure that you have configured your GitHub access token for authentication.
Step 1: Generate GitHub Personal Access Token

    Visit your GitHub Personal Access Tokens page.
    Click Generate new token.
    Select the necessary permissions (e.g., repo for full repository access).
    Save the token securely.

## Step 3: Run to install
    ./install.py

It will ask you to input your GitHub username and access token.

## Examples


Create a Repository:📂

    gmkdir new-awesome-project

This will create a new repository named new-awesome-project.

Delete Repositories:🗑️

    delrepo repo1 repo2

   This will delete the repositories repo1 and repo2 from your GitHub account.

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

   Sahil Das: Creator and Lead Developer 💻

## Bugs and Feedback 🐞

If you encounter any issues or have suggestions for improvements, please open an issue on the GitHub Repository. We'd love to hear from you! 😄

Happy automating! 🚀

now write little about the project
