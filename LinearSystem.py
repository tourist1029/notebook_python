from Matrix import Matrix
from Vector import Vector

class LinearSystem:

    def __init__(self, A, b):
        assert A.row_num() == len(b), "row number of A must be equal to the length of b"
        self._m = A.row_num()
        self._n = A.col_num()
        assert self._m == self._n # 后面可以省略这个限制

        #定义增广矩阵, 添加对b是向量还是矩阵的判断
        if isinstance(b, Vector):
            self.Ab = [Vector(A.row_vector(i).underlying_list() + [b[i]])
                        for i in range(self._m)]
        if isinstance(b, Matrix):
            self.Ab = [Vector(A.row_vector(i).underlying_list() + b.row_vector(i).underlying_list())
                        for i in range(self._m)]

    
    def _max_row(self, index, n):
        best , ret = self.Ab[index][index], index
        for i in range(index+1, n):
            if self.Ab[i][index] < best:
                best, ret = self.Ab[i][index], i

        return ret

    
    def _forward(self):
        n = self._m
        for i in range(n):
            #Ab[i][i]为主元
            max_row = self._max_row(i, n)
            self.Ab[i], self.Ab[max_row] = self.Ab[max_row], self.Ab[i]

            #将主元归一
            self.Ab[i] = self.Ab[i] / self.Ab[i][i]  #TODO: self.Ab[i][i] ==0
            for j in range(i+1, n):
                self.Ab[j] = self.Ab[j] - self.Ab[j][i] * self.Ab[i]  #使得主元[i][i]这一列下面的元素通过乘以Ab[j][i],进行相减变为1

    def _backward(self):

        n = self._m
        for i in range(n-1, -1, -1):
            #Ab[i][i]为主元
            for j in range(i-1, -1, -1):
                self.Ab[j] = self.Ab[j] - self.Ab[j][i] * self.Ab[i]
    
    
    def gauss_jordan_elimination(self):

        self._forward()
        self._backward()

    def fancy_print(self):

        for i in range(self._m):
            print(' '.join(str(self.Ab[i][j]) for j in range(self._n)), end=' ')
            print('|', self.Ab[i][-1])


# if __name__ == '__main__':
#     A = Matrix([[1,2,4], [3,7,2], [2,3,3]])
#     b = Vector([7, -11, 1])
#     ls = LinearSystem(A, b)
#     ls.gauss_jordan_elimination()
#     ls.fancy_print()


    

