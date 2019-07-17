import math
import numpy as np
import matplotlib.pyplot as plt

#定义预设变量
k = 3 #曲线次数，k=3即，选区3次曲线
m = 7 #m值为通过的型值点的个数
n = m + k - 1#控制顶点数
nj = n + k + 1 #节点矢量总个数,如果通过的数据点数是n，则控制点数为n+2， 节点矢量为控制点数+次数+1，即，n+k+3
hx = k + 1 #常将两端点处重复度取为k+1

px = np.array([-80.0, -40.0, -20.0, -10.0, 30.0, 50.0, 70.0])
py = np.array([-60.0, 20.0, 10.0, 20.0, -20.0, 40.0, 30.0])

dx = np.array([0.0000, 0.0212, 0.0212, 0.0425, 0.0425, 0.0850, 0.0850, 0.1275, 0.1275, 0.17, 0.17, 0.255, 0.255, 0.34, 0.34, 0.425, 0.425, 0.51, 0.51, 0.68, 0.68, 0.85, 0.85, 1.02, 1.02, 1.19, 1.19, 1.36, 1.36, 1.53, 1.53, 1.615, 1.615, 1.655, 1.7 ])
dy = np.array([0.0000, 0.0454, -0.0209, 0.0614, -0.0291, 0.0835, -0.0384, 0.0986, -0.0444, 0.1093, -0.0496, 0.1222, -0.0595, 0.1275, -0.0675, 0.1292,-0.0727, 0.1284, -0.0758, 0.1214, -0.0761, 0.1090, -0.0709, 0.0969, -0.0624, 0.0741, -0.0510, 0.0524,-0.0367, 0.0286, -0.0209, 0.0156, -0.0119, 0.0167, 0.0000])

print(px.size)
print(py.size)

np.set_printoptions(precision=4)   #设置矩阵显示数据的显示精度

p12x = px[0] - px[1]
p12y = py[0] - py[1]
p12 = math.sqrt(p12x*p12x + p12y*p12y)
print('P1P2=', p12)

p23x = px[2] - px[3]
p23y = py[2] - py[3]
p23 = math.sqrt(p23x*p23x + p23y*p23y)
print('P2P3=', p23)

S=0
num = 0

#定义节点矢量数组
U = [] 
L = []  #存储计算的每段的弦长

#计算总弦长
for i in range(1, m):
    x = px[i-1] - px[i]
    y = py[i-1] - py[i]
    l = math.sqrt(x*x + y*y)
    print('the every length is :', l)
    L.append(l)
    S = S + l
    num = num + 1
#计算从k+1-n的其余节点矢量，3次的计算方法
def countUDirect(n, k, S, L, U):
    nu = 0
    #添加前k+1个节点矢量
    for a in range(k+1):
        U.append(0.0)
    
    for j in range(k+1, n):
        a = (k+1)/2 + nu
        l = L[0:int(a)-1]
        print('每个l的值', l)
        u = sum(l) / S
        U.append(u)
        nu = nu + 1
        print('单个节点和计算： ', sum(l))
        print('单个节点矢量计算：', u)
        
    #增加最后k+1）个节点矢量
    for k in range(k+1):
        U.append(1.0)

countUDirect(n, k, S, L, U)
    
print('总长度为：', S)
print('第一段节点向量值为：', p12/S)
print('第二段节点向量值为：', (p12+p23)/S)
print('循环次数为：', num)

num_u = len(U)

print(num_u)
#定义算子
A = []
B = []
C = []
E = []
F = []
    
#求解控制点矩阵替代值
for i in range(1, n+k-4):
    if (U[i+3]-U[i] == 0.0):
        A.append(0.0)
    else:
        A.append(((U[i+3]-U[i+2])*(U[i+3]-U[i+2]))/(U[i+3]-U[i]))
        
    if (U[i+4]-U[i+1] == 0.0) and (U[i+3]-U[i] == 0.0):
        B.append(0.0)
        
    if (U[i+4]-U[i+1] == 0.0) and (U[i+3]-U[i] != 0.0):
        B.append((((U[i+3]-U[i+2])*(U[i+2]-U[i]))/(U[i+3]-U[i])))
        
    if(U[i+3]-U[i] == 0 and (U[i+4]-U[i+1]) != 0.0):
        B.append((((U[i+2]-U[i+1])*(U[i+4]-U[i+2]))/(U[i+4]-U[i+1])))
    if (U[i+4]-U[i+1] != 0.0) and (U[i+3]-U[i] != 0.0):
        B.append((((U[i+3]-U[i+2])*(U[i+2]-U[i]))/(U[i+3]-U[i])) + (((U[i+2]-U[i+1])*(U[i+4]-U[i+2]))/(U[i+4]-U[i+1])))
    
    if (U[i+4]-U[i+1] == 0.0):
        C.append(0.0)
    else:
        C.append(((U[i+2]-U[i+1])*(U[i+2]-U[i+1]))/(U[i+4]-U[i+1]))
    E.append((U[i+3]-U[i+1])*px[i-1])
    F.append((U[i+3]-U[i+1])*py[i-1])

print('A的个数为：', len(A))
print(A)
print('B的个数为：', len(B))
print(B)
print('C的个数为：', len(C))
print(C)

#构造m介的单位矩阵
D = np.eye(m)
print('D is :')
print(D)
for i in range(m):
    D[i,i] = B[i]
    
for i in range(m-1):
    D[i, i+1] = C[i]
    
for i in range(m-1):
    D[i+1, i] = A[i]


print('After set value B is :')
print(D)


