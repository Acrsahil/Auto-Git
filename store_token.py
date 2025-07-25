import keyring

key = input("Enter a Token: ").strip()
# keyring.set_password("github", "personal_access_token", key)
# print("✅ Token stored securely in system keyring!")

token = keyring.get_password("github", "personal_access_token")
print(token)
