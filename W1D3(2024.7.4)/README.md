# 更新存款金额前三用户 代码运行逻辑
```
function updateTopUsers() internal {
    int index = -1;
    for (int i = 2; i >= 0; i--) {
        if (userBalances[msg.sender] > userBalances[topUsers[uint(i)]]) {
            index = i;  
        } else {
            break;
        }
    }
    if (index != -1) {
        // 右移数组元素，为新元素腾出空间
        for (int j = 2; j > index; j--) {
            topUsers[uint(j)] = topUsers[uint(j - 1)];
        }
        topUsers[uint(index)] = msg.sender;
    }
}
```
假设 topUsers 数组当前包含以下用户地址及其对应的余额
topUsers[0] = UserA (余额: 100)<br>
topUsers[1] = UserB (余额: 80)<br>
topUsers[2] = UserC (余额: 60)<br>
现在，假设 msg.sender 是 UserD，且 UserD 的余额为 90。<br>
## 初始化 index 为 -1：
```
int index = -1;
```
## 从 topUsers 数组的末尾开始遍历：
```
for (int i = 2; i >= 0; i--) {
    if (userBalances[msg.sender] > userBalances[topUsers[uint(i)]]) {
        index = i;  
    } else {
        break;
    }
}
```

当 i = 2 时，比较 UserD 的余额 (90) 和 UserC 的余额 (60)，因为 90 > 60，所以 index 更新为 2。<br>
当 i = 1 时，比较 UserD 的余额 (90) 和 UserB 的余额 (80)，因为 90 > 80，所以 index 更新为 1。<br>
当 i = 0 时，比较 UserD 的余额 (90) 和 UserA 的余额 (100)，因为 90 < 100，所以循环终止。<br>
## 检查 index 是否更新
```
if (index != -1) {
    // 右移数组元素，为新元素腾出空间
    for (int j = 2; j > index; j--) {
        topUsers[uint(j)] = topUsers[uint(j - 1)];
    }
    topUsers[uint(index)] = msg.sender;
}
```
因为 index 更新为 1，所以需要将 topUsers 数组中的元素右移，为 UserD 腾出空间。
当 j = 2 时，topUsers[2] 更新为 topUsers[1] (即 UserB)。
最后，将 topUsers[1] 更新为 msg.sender (即 UserD)。
## 更新后的 topUsers 数组
topUsers[0] = UserA (余额: 100)<br>
topUsers[1] = UserD (余额: 90)<br>
topUsers[2] = UserB (余额: 80)