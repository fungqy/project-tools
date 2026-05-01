"""生成密码哈希"""

import bcrypt

# 生成 admin123 的哈希
admin_hash = bcrypt.hashpw(b"admin123", bcrypt.gensalt()).decode()
print(f"admin123 哈希: {admin_hash}")

# 生成 user123 的哈希
user_hash = bcrypt.hashpw(b"user123", bcrypt.gensalt()).decode()
print(f"user123 哈希: {user_hash}")
