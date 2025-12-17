#!/usr/bin/env python3
"""批量测试所有角色"""
import subprocess
import time

roles = [
    ("教务", "账号3"),
    ("管理员", "账号1")
]

print("=" * 70)
print("🔍 批量测试剩余角色")
print("=" * 70)
print("\n请依次用以下账号登录并点击侧边栏功能：")
for role, account in roles:
    print(f"  - {role} ({account}/123456)")

print("\n开始60秒监控...")
subprocess.run([".venv/bin/python", "test_all_features.py"])
