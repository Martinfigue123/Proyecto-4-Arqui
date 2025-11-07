from clases import VarNode, BinOpNode, AssignmentNode
from analisis import tokenize
from parser import Parser

class CodeGenerator:
    def __init__(self):
        # Lista para guardar las líneas de código assembly
        self.assembly_code = []
        # Pool de registros temporales disponibles (empezamos desde R7 hacia R1)
        self.register_pool = ['R7', 'R6', 'R5', 'R4', 'R3', 'R2', 'R1']
        
        # Estadísticas requeridas por el proyecto [cite: 25]
        self.line_count = 0
        self.mem_access_count = 0
        
        # Conjunto para rastrear qué variables se usan
        self.variables_used = set()

    def alloc_register(self):
        """Asigna un registro del pool."""
        if not self.register_pool:
            raise Exception("¡Error del compilador! No hay suficientes registros.")
        return self.register_pool.pop()

    def free_register(self, reg):
        """Devuelve un registro al pool."""
        self.register_pool.append(reg)

    def add_line(self, instruction):
        """Añade una línea de código assembly y actualiza estadísticas."""
        self.assembly_code.append(instruction)
        self.line_count += 1
        
        # Contabiliza accesos a memoria 
        if instruction.strip().startswith("LOAD") or instruction.strip().startswith("STORE"):
            self.mem_access_count += 1

    def generate(self, root_node):
        """Función principal para generar el código a partir del AST."""
        
        if not isinstance(root_node, AssignmentNode):
            raise TypeError("La raíz del AST debe ser un AssignmentNode.")
        
        # 1. Genera el código para la expresión (el lado derecho)
        # Esto devolverá el registro que contiene el resultado final
        final_reg = self._generate_expression(root_node.expression)
        
        # 2. Almacena el resultado final en la variable 'result' [cite: 23]
        target_var = root_node.variable.name
        self.variables_used.add(target_var)
        self.add_line(f"STORE {final_reg}, {target_var}")
        
        # 3. Libera el registro final
        self.free_register(final_reg)
        
        # 4. Construye el bloque DATA al final [cite: 16]
        data_block = self._build_data_block()
        
        # 5. Combina el código y el bloque DATA
        final_code = "\n".join(self.assembly_code) + "\n" + data_block
        return final_code

    def _generate_expression(self, node):
        """
        Recorre recursivamente el AST de la expresión (post-orden)
        y devuelve el registro que contiene el resultado de ese sub-árbol.
        """
        
        # Caso Base: Es una variable (a, b, c...)
        if isinstance(node, VarNode):
            reg = self.alloc_register()
            self.variables_used.add(node.name)
            # Carga el valor de la variable en el registro
            self.add_line(f"LOAD {reg}, {node.name}")
            return reg # Devuelve el registro que contiene el valor

        # Caso Recursivo: Es una operación (+, -)
        if isinstance(node, BinOpNode):
            # 1. Resuelve el sub-árbol izquierdo
            left_reg = self._generate_expression(node.left)
            # 2. Resuelve el sub-árbol derecho
            right_reg = self._generate_expression(node.right)
            
            # 3. Realiza la operación (para la entrega parcial)
            if node.op == '+':
                self.add_line(f"ADD {left_reg}, {right_reg}")
            elif node.op == '-':
                self.add_line(f"SUB {left_reg}, {right_reg}")
            else:
                # Esto se expandirá en la entrega final
                raise ValueError(f"Operador no soportado en entrega parcial: {node.op}")

            # 4. Optimización: El resultado está en 'left_reg',
            self.free_register(right_reg)
            
            # 5. Devuelve el registro que contiene el resultado de la operación
            return left_reg

    def _build_data_block(self):
        """Construye el bloque DATA basado en las variables usadas."""
        lines = ["DATA:"]
        
        # Asegura que 'result' y 'error' existan
        self.variables_used.add('result')
        self.variables_used.add('error') 

        for var in sorted(list(self.variables_used)):
            if var == 'result' or var == 'error':
                lines.append(f"{var} 0") 
            else:
                # Asigna un valor por defecto
                lines.append(f"{var} 1") 
        
        return "\n".join(lines)

# Bloque de Prueba se puede borrar 

if __name__ == '__main__':

    # La expresión de prueba de la Entrega Parcial
    test_expression = "result a + b - (c + d)"

    print(f"--- Generador de Código para: '{test_expression}' ---")

    try:
        # 1. Lexer
        tokens = tokenize(test_expression)
        
        # 2. Parser
        parser = Parser(tokens)
        ast_root = parser.parse()
        
        # 3. CodeGen
        codegen = CodeGenerator()
        assembly_output = codegen.generate(ast_root)
        
        print("\n--- CÓDIGO ASSEMBLY GENERADO ---")
        print(assembly_output)
        
        print("\n--- ESTADÍSTICAS DEL COMPILADOR ---")
        print(f"Total de líneas generadas (sin DATA): {codegen.line_count}")
        print(f"Total de accesos a memoria (LOAD/STORE): {codegen.mem_access_count}")

    except (ValueError, SyntaxError, TypeError, Exception) as e:
        print(f"\n¡FALLÓ LA COMPILACIÓN!: {e}")