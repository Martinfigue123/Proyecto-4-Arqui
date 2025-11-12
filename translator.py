from clases import VarNode, BinOpNode, AssignmentNode
from analisis import tokenize
from parser import Parser

class CodeGenerator:
    def __init__(self):
        self.assembly_code = []
        self.variables_used = set()
        self.line_count = 0
        self.mem_access_count = 0
        
        self.registers = ['A', 'B']
        self.reg_pool = self.registers.copy()
        
        self.temp_mem_addr = 6 
        self.temp_vars_created = [] #

    def alloc_register(self):
        """Asigna un registro (A o B)."""
        if not self.reg_pool:
            raise Exception("¡Error del compilador! No hay suficientes registros físicos.")
        return self.reg_pool.pop(0) # Devuelve A o B

    def free_register(self, reg):
        """Devuelve un registro (A o B) al pool."""
        if reg not in self.registers:
             raise Exception(f"Registro desconocido {reg}")
        if reg not in self.reg_pool:
            self.reg_pool.insert(0, reg) # Devuelve al inicio del pool

    def add_line(self, instruction):
        self.assembly_code.append(instruction)
        self.line_count += 1
        if instruction.strip().startswith("LOAD") or instruction.strip().startswith("STORE"):
            self.mem_access_count += 1

    def generate(self, root_node):
        if not isinstance(root_node, AssignmentNode):
            raise TypeError("La raíz del AST debe ser un AssignmentNode.")
        
        final_reg = self._generate_expression(root_node.expression)
        
        target_var = root_node.variable.name
        self.variables_used.add(target_var)
        self.add_line(f"STORE {final_reg}, {target_var}")
        
        self.free_register(final_reg)
        
        data_block = self._build_data_block()
        final_code = "\n".join(self.assembly_code) + "\n" + data_block
        return final_code

    def _generate_expression(self, node):
        """
        Recorre recursivamente el AST, manejando solo 2 registros (A y B)
        y derramando a memoria (spill) si es necesario.
        """
        
        if isinstance(node, VarNode):
            reg = self.alloc_register() # Obtiene 'A'
            self.variables_used.add(node.name)
            self.add_line(f"LOAD {reg}, {node.name}")
            return reg 

        if isinstance(node, BinOpNode):
            
            left_reg = self._generate_expression(node.left)
        
            # Genera una etiqueta de variable única para esta dirección temporal
            temp_addr = self.temp_mem_addr
            self.temp_mem_addr += 1 # Prepara el siguiente slot
            temp_var_label = f"temp{temp_addr}" 
            self.temp_vars_created.append(temp_var_label) # Guarda para el bloque DATA
            
            self.add_line(f"STORE {left_reg}, {temp_var_label}") # Guarda A en DM[6] (temp6)
            self.free_register(left_reg) 

            right_reg = self._generate_expression(node.right) 
            
            self.add_line(f"MOV B, {right_reg}")
            self.free_register(right_reg) 
            
            left_reg = self.alloc_register() 
            self.add_line(f"LOAD {left_reg}, {temp_var_label}")
            
            op_map = {'+': 'ADD', '-': 'SUB'}
            if node.op in op_map:
                self.add_line(f"{op_map[node.op]} {left_reg}, B")
            else:
                raise ValueError(f"Operador no soportado: {node.op}")

            self.free_register('B')
            return left_reg 

    def _build_data_block(self):
        lines = ["DATA:"]
        self.variables_used.add('result')
        self.variables_used.add('error') 

        # Añade variables usadas
        for var in sorted(list(self.variables_used)):
            if var == 'result' or var == 'error':
                lines.append(f"{var} 0") 
            else:
                lines.append(f"{var} 1") 
        
        # Añade variables temporales
        for temp_var in self.temp_vars_created:
            lines.append(f"{temp_var} 0")
        
        return "\n".join(lines)

# Bloque de Prueba
if __name__ == '__main__':
    test_expression = "result a + b - (c + d)"
    print(f"--- Generador de Código para: '{test_expression}' ---")
    try:
        tokens = tokenize(test_expression)
        parser = Parser(tokens)
        ast_root = parser.parse()
        codegen = CodeGenerator()
        assembly_output = codegen.generate(ast_root)
        print("\n--- CÓDIGO ASSEMBLY GENERADO (Corregido V3) ---")
        print(assembly_output)
        print("\n--- ESTADÍSTICAS DEL COMPILADOR ---")
        print(f"Total de líneas generadas (sin DATA): {codegen.line_count}")
        print(f"Total de accesos a memoria (LOAD/STORE): {codegen.mem_access_count}")
    except (ValueError, SyntaxError, TypeError, Exception) as e:
        print(f"\n¡FALLÓ LA COMPILACIÓN!: {e}")