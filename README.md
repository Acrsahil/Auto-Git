# **Auto-Git** 🚀

Auto-Git is a set of command-line utilities for managing GitHub repositories and their contents directly from the terminal. It simplifies common GitHub tasks such as creating, deleting, and listing repositories, as well as listing the contents of those repositories.

![autogit](https://github.com/user-attachments/assets/457b361d-d48c-4d22-99a0-78175b36a820)

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

Follow these steps to install Auto-Git:

### **Step 1: Clone the Repository**

Clone this repository to your local machine by running:

```
git clone https://github.com/Acrsahil/Auto-Git.git
cd Auto-Git
```

## Step 2: Install Dependencies

Make sure you have python3 and pip installed

## Setup Instructions ⚙️

Before using Git-Auto, ensure that you have configured your GitHub access token for authentication.
Step 1: Generate GitHub Personal Access Token

    Visit your GitHub Personal Access Tokens page.
    Click Generate new token.
    Select the necessary permissions (e.g., repo for full repository access).
    Save the token securely.

## Step 3: Run to install

    ./install.py

It will ask you to input your GitHub username and access token.

## Examples

#### Create a Repository:📂

    gmkdir new-awesome-project

This will create a new repository named new-awesome-project.

#### Delete Repositories:🗑️

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

## **Guide** 📚

Below is a step-by-step guide to help you get started with Auto-Git:

### **Step 1: Overview**
![Step 1](guide/1.png)

### **Step 2: Installation**
![Step 2](guide/2.png)

### **Step 3: Setup**
![Step 3](guide/3.png)

### **Step 4: Using the Create Repository Command**
![Step 4](guide/4.png)

### **Step 5: Using the Delete Repository Command**
![Step 5](guide/5.png)

### **Step 6: Listing Repositories**
![Step 6](guide/6.png)

### **Step 7: Listing Repository Contents**
![Step 7](guide/7.png)

### **Step 8: Checking Requirements**
![Step 8](guide/8.png)

### **Step 9: Resolving Errors**
![Step 9](guide/9.png)

### **Step 10: Exiting Auto-Git**
![Step 10](guide/10.png)

### **Step 11: Advanced Features**
![Step 11](guide/11.png)

### **Step 12: Summary**
![Step 12](guide/12.png)    

## Authors 👨‍💻👩‍💻

Sahil Das: Creator and Lead Developer 💻

## Bugs and Feedback 🐞

If you encounter any issues or have suggestions for improvements, please open an issue on the GitHub Repository. We'd love to hear from you! 😄

Happy automating! 🚀
