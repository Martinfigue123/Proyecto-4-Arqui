
from clases import VarNode, BinOpNode, AssignmentNode

class Parser:
    def __init__(self, tokens):
        self.tokens = tokens
        self.pos = 0 # posición actual en la lista de tokens
    
    def consume(self, expected_type = None):
        # consumir el siguiente token y avanzar la posición
        if self.pos >= len(self.tokens):
            raise ValueError("No hay más tokens para consumir")
        
        current_token = self.tokens[self.pos]
        self.pos += 1

        if expected_type and current_token[0] != expected_type:
            # Para mejorar la claridad de errores, usa SyntaxError
            raise SyntaxError(f"Se esperaba un token de tipo {expected_type}, pero se encontró {current_token[0]} ({current_token[1]})")
        
        return current_token
    
    def peek(self, offset = 0):
        # mirar el token en la posición actual + offset sin consumirlo
        index = self.pos + offset
        if index >= len(self.tokens):
            return ('EOF', None) # Devuelve un token EOF predecible
        return self.tokens[index]
    
    def parse_assignment(self):
        # parsear una asignación del tipo: result = expression
        target_token = self.consume('ID')
        target_node = VarNode(target_token[1])
        self.consume('ASSIGN')
        expression_node = self.parse_expression()
        return AssignmentNode(target_node, expression_node)
    
    def parse_expression(self):
        # parsear suma y resta
        left_node = self.parse_term()

        while True:
            next_token = self.peek()
            if next_token[0] in ('OP_ADD', 'OP_SUB'):
                op_token = self.consume()
                right_node = self.parse_term()
                left_node = BinOpNode(left_node, op_token[1], right_node)
            else:
                break
        
        return left_node
    
    def parse_term(self):
        # parsear términos (variables o expresiones entre paréntesis)
        next_token = self.peek()
        
        if next_token[0] == 'ID':
            var_token = self.consume('ID')
            return VarNode(var_token[1])
        
        elif next_token[0] == 'PAR_IZQ':
            self.consume('PAR_IZQ')
            expr_node = self.parse_expression()
            self.consume('PAR_DER')
            return expr_node
        
        else:
            # Usar SyntaxError para errores de análisis
            raise SyntaxError(f"Token inesperado al inicio del término: {next_token}")
    
    def parse(self):
        ast_root = self.parse_assignment()
        # Se asume que el token final es ('EOF', None)
        if self.peek()[0] != 'EOF': 
            raise SyntaxError("Tokens inesperados después de la asignación")
        return ast_root
    
# esto es para probar el codigo se puede borrar
if __name__ == '__main__':
    # Tokens de: result a + b - (c + d)
    test_tokens = [
        ('ID', 'result'), ('ASSIGN', '='), 
        ('ID', 'a'), ('OP_ADD', '+'), ('ID', 'b'), 
        ('OP_SUB', '-'), ('PAR_IZQ', '('), 
        ('ID', 'c'), ('OP_ADD', '+'), ('ID', 'd'), 
        ('PAR_DER', ')'), ('EOF', None)
    ]
    
    print("--- Análisis Sintáctico (Parser) ---")
    
    try:
        parser = Parser(test_tokens)
        ast_root = parser.parse()
        
        print("\n¡AST CONSTRUIDO CON ÉXITO!")
        print("Estructura del AST (Usando __repr__):")
        
        # Para visualizar el AST sin depender de __repr__ (si no está bien definido)
        def print_ast(node, level=0):
            indent = '  ' * level
            if isinstance(node, AssignmentNode):
                print(f"{indent}ASIGNACIÓN: {node.variable.name} = ...")
                print_ast(node.expression, level + 1)
            elif isinstance(node, BinOpNode):
                print(f"{indent}OP: {node.op}")
                print(f"{indent}  Izquierda:")
                print_ast(node.left, level + 2)
                print(f"{indent}  Derecha:")
                print_ast(node.right, level + 2)
            elif isinstance(node, VarNode):
                print(f"{indent}VAR: {node.name}")
            else:
                 print(f"{indent}Nodo Desconocido: {node}")

        print_ast(ast_root) 
        
    except (SyntaxError, ValueError) as e:
        print(f"\n¡FALLÓ EL ANÁLISIS SINTÁCTICO!: {e}")