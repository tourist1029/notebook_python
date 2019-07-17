from Vector import Vector

class Matrix:

    def __init__(self, list2d):
        self._values = [row[:] for row in list2d]

    @classmethod
    def zero(cls, r, c):
        ''' 返回一个r行 c列的0矩阵'''
        return cls(([[0] * c for _ in range(r)]))
    
    @classmethod
    def identity(cls, n):
        ''' 返回一个N行N列的单位矩阵'''
        m = [[0] * n for _ in range(n)]
        for i in range(n):
            m[i][i] = 1

        return cls(m)
    
    def T(self):
        ''' 返回矩阵的转置矩阵'''
        return Matrix([[e for e in self.col_vector(i)] for i in range(self.col_num())])
    
    
    def __repr__(self):
        return 'Matrix({})'.format(self._values)

    def __add__(self, another):
        ''' 返回两个矩阵的加法结果'''
        assert self.shape() == another.shape(), 'Error in adding. Shape of matrix must be same'
        return Matrix([[a + b for a, b in zip(self.row_vector(i), another.row_vector(i))] 
                        for i in range(self.row_num())])

    def __sub__(self, another):
        ''' 返回两个矩阵的减法结果'''
        assert self.shape() == another.shape(), 'Error in adding. Shape of matrix must be same'
        return Matrix([[a - b for a, b in zip(self.row_vector(i), another.row_vector(i))] 
                        for i in range(self.row_num())])

    def dot(self, another):
        ''' 返回矩阵乘法'''
        if isinstance(another, Vector):
            #矩阵和向量的乘法
            assert self.col_num() == len(another), \
                'Error in Matrix-Vector Multiplication'
            return Vector([self.row_vector(i).dot(another) for i in range(self.row_num())])

        if isinstance(another, Matrix):
            #矩阵和矩阵的乘法
            assert self.col_num() == another.row_num(), \
                'Error in Matrix-Matrix Multiplication.'
            return  Matrix([[self.row_vector(i).dot(another.col_vector(j)) for j in range(another.col_num())] for i in range(self.row_num())])

    
    
    def __mul__(self, k):
        ''' 返回矩阵数量乘法结果'''
        return Matrix([[e * k for e in self.row_vector(i)] for i in range(self.row_num())])

    def __truediv__(self, k):
        ''' 返回数量除法的结果矩阵 self / k'''
        return (1 / k) * self

    def __pos__(self):
        ''' 返回矩阵取正的结果'''
        return 1 * self 

    def __neg__(self):
        '''返回矩阵去负的结果'''
        return -1 * self

    def __rmul__(self, k):
        ''' 返回矩阵的数量乘法 k * self'''
        return self * k 
    
    def row_vector(self, index):
        ''' 返回矩阵的第index个行向量'''
        return Vector(self._values[index])
    
    def col_vector(self, index):
        ''' 返回军阵的第index个列向量'''
        return Vector([row[index] for row in self._values])
    
    def __getitem__(self, pos):
        '''返回矩阵pos位置的元素, pos为元组数据'''
        r, c = pos
        return self._values[r][c]
    
    __str__ = __repr__

    def size(self):
        r, c = self.shape()
        return r * c
    
    def row_num(self):
        return self.shape()[0]

    __len__ = row_num

    def col_num(self):
        return self.shape()[1]
    
    def shape(self):
        '''返回矩阵的形状：（行数， 列数）'''
        return len(self._values), len(self._values[0])

    














if __name__ == '__main__':
    matrix = Matrix([[1,2], [3,4]])
    print(matrix)
    print(matrix.size())
    print('len(Matrix) is {}'.format(len(matrix)))
    print('Matrix[0][1] = {}'.format(matrix[0, 1]))

    matrix2 = Matrix([[5,6], [7,8]])

    print('add: {} + {} = {}'.format(matrix, matrix2, matrix + matrix2))
    print('substract: {} - {} = {}'.format(matrix, matrix2, matrix - matrix2))
    print('scalar-mul: {} * {} = {}'.format(matrix, 2, matrix*2))
    print('scalar-mul: {} * {} = {}'.format(2, matrix, 2*matrix))
    print('zero_2_3: {}'.format(Matrix.zero(2, 3)))

    T = Matrix([[1.5, 0], [0, 2]])
    p = Vector([5, 3])
    P = Matrix([[0, 4, 5], [0, 0, 3]])

    print('T.dot(p) = {}'.format(T.dot(p)))
    print('T.dot(P) = {}'.format(T.dot(P)))

    print('P . T = {}'.format(P.T()))

    I = Matrix.identity(2)
    print(I)
    
    








