from _global import EPSILON
import math

class Vector:

    def __init__(self, lst):
        self._values = list(lst)  #这里将用户传进来的列表复制一份，以防止用户在外部对内部泪飙进行更改

    
    def __len__(self):
        return len(self._values)
    
    @classmethod
    def zero(cls, dim):
        #返回一个dim维的零向量
        return cls([0] * dim)
    
    def norm(self):
        #返回向量的模
        return math.sqrt(sum(e**2 for e in self))
    
    def normalize(self):
        #返回单位向量
        #return Vector([e / self.norm for e in self]) 此方法多次计算模的数值
        #return 1 / self.norm() * Vector(self._values)
        #实现魔法方法truediv后，可以如下表示
        if self.norm() < EPSILON:
            raise ZeroDivisionError('Normalize error! norm is zero.')
        return Vector(self._values) / self.norm()
    
    def underlying_list(self):
        ''' 返回向量的底层列表的副本（即传进来的列表），自带apeend功能，'''
        return self._values[:]
        
    
    def __add__(self, another):
        #首先判断自身和传入进来的维度是相等的，才可以进行向量的加法
        assert len(self) == len(another), \
            'Error in adding Length of vectors must be same!'
        #return Vector([a + b for a, b in zip(self.__values, another.__values)])  在没有迭代器的情况下
        return Vector([a + b for a, b in zip(self, another)])

    def __sub__(self, another):
        assert len(self) == len(another), \
            'Error in adding Length of vectors must be same!'
        return Vector([a - b for a, b in zip(self, another)])
    
    def dot(self, another):
        ''' 向量点乘，返回结果标量'''
        assert len(self) == len(another), 'Error in dot product. Length of vectors must be same'
        return sum(a * b for a, b in zip(self, another))
    
    def __mul__(self, k):
        #返回数量乘法的结果向量 self * k
        return Vector([k*e for e in self])
    
    def __rmul__(self, k):
        #返回数量乘法的结果 k * self
        return  self * k

    def __truediv__(self, k):
        #返回的是数量除法，其实就是数量乘法
        return (1 / k) * self
    
    def __pos__(self):
        #返回向量取正的结果
        return 1 * self
    
    def __neg__(self):
        #返回向量取负的结果向量
        return -1 * self

    #实现迭代器
    def __iter__(self):
        return self._values.__iter__()
    

    def __getitem__(self, index):
        return self._values[index]

    def __repr__(self):
        return "Vector({})".format(self._values)

    def __str__(self):
        return "({})".format(", ".join(str(e) for e in self._values))




#测试程序
if __name__ == '__main__':
    vec = Vector([5, 2])
    print(vec)
    print(len(vec))
    print('vec[0] = {}, vec[1] = {}'.format(vec[0], vec[1]))

    vec2 = Vector([3, 1])
    zero2 = Vector.zero(2)

    print('{} + {} = {}'. format(vec, vec2, vec + vec2))
    print('{} - {} = {}'. format(vec, vec2, vec - vec2))
    print('{} * {} = {}'. format(vec, 3, vec * 3))
    print('{} * {} = {}'. format(vec, 3, 3 * vec))
    print('+{} = {}'.format(vec, +vec))
    print('-{} = {}'.format(vec, -vec))
    print(zero2)
    print(vec + zero2)
    print('norm({}) = {}'.format(vec, vec.norm()))
    print('normalize {} is {}'.format(vec, vec.normalize()))
    print(vec.normalize().norm())
    try:
        zero2.normalize()
    except:
        print('Cannot normalize zero vector {}'.format(zero2))

    print('{} dot {} = {}'.format(vec, vec2, vec.dot(vec2)))
    










