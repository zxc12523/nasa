x1, y1, r1 = map(int, input().split(' '))
x2, y2, r2 = map(int, input().split(' '))
r1 **= 2
r2 **= 2
ans = [0, 0, 0, 0]
for i in range(int(input())):
    a, b = map(int, input().split(' '))
    d1 = (a-x1)**2 + (b-y1) **2
    d2 = (a-x2)**2 + (b-y2) **2
    if d1 <= r1 and d2 <= r2:
        ans[0] += 1
    elif d1 <= r1:
        ans[1] += 1
    elif d2 <= r2:
        ans[2] += 1
    else:
        ans[3] += 1
for i in ans:
    print(i)