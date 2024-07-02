import hashlib
import time

def compute_hash_with_nonce(prefix, difficulty):
    nonce = 0
    target = '0' * difficulty  # 目标值，即哈希值以几个0开头
    start_time = time.time()

    while True:
        # 将prefix和nonce合并后进行哈希运算
        text = f'{prefix}{nonce}'.encode()
        sha256_hash = hashlib.sha256(text).hexdigest()

        # 检查哈希值是否满足条件
        if sha256_hash.startswith(target):
            time_taken = time.time() - start_time
            print(f'花费时间: {time_taken:.4f}秒')
            print(f'满足条件的nonce: {nonce}')
            print(f'哈希值: {sha256_hash}')
            break

        nonce += 1

# 调用函数，传入'greatgeoff'作为prefix
print("第一问")
compute_hash_with_nonce('greatgeoff',4)
print("第二问")
compute_hash_with_nonce('greatgeoff',5)

