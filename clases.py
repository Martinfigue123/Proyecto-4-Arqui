class Node:
    # clase base para todos los nodos del AST
    pass

class VarNode(Node):
    # nodo para variables
    def __init__(self, name):
        self.name = name
    
    def __repr__(self):
        return f"VarNode({self.name})"

class BinOpNode(Node):
    # nodo para operaciones binarias
    def __init__(self, left, op, right):
        self.left = left
        self.op = op
        self.right = right
    
    def __repr__(self):
        return f"BinOpNode(left={self.left}, op='{self.op}', right={self.right})" 

class AssignmentNode(Node):
    # nodo para asignaciones
    def __init__(self, variable, expression):
        self.variable = variable
        self.expression = expression
    
    def __repr__(self):
        return f"AssignmentNode(variable={self.variable}, expression={self.expression})"