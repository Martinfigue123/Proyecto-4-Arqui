import re

token_specification = [
    ('ID', r'[a-g]|result|error'), # Variables (a, b, c, d, e, f, g, result, error)
    ('OP_ADD',   r'\+'), # Suma
    ('OP_SUB',   r'-'), # Resta
    ('PAR_IZQ',  r'\('), # Paréntesis izquierdo
    ('PAR_DER',  r'\)'), # Paréntesis derecho
    ('SPACE',    r'\s+'), # Espacios en blanco (a ignorar)
    ('MISMATCH', r'.'), # Cualquier otro caracter (error)
]

#Compilar las expresiones regulares
token_regex = '|'.join('(?P<%s>%s)' % (name, pattern) for name, pattern in token_specification)

def tokenize(x):
    tokens = []

    if x.strip().startswith("result"):

        # Remover la palabra "result"
        x = x.strip()[len("result"):].strip()

        # Agregar tokens para 'result' y '='
        tokens.append(('ID', 'result'))
        tokens.append(('ASSIGN', '='))
    
    for mo in re.finditer(token_regex, x):
        kind = mo.lastgroup
        value = mo.group(kind)

        if kind == 'SPACE':
            continue # Ignorar espacios en blanco
        elif kind == 'MISMATCH':
            raise ValueError(f'Caracter inesperado: {value}')
        else:
            tokens.append((kind, value))
    return tokens

# esto es para probar el codigo se puede borrar
test_expression = "result a + b - (c + d)"

print(f"--- Análisis de: '{test_expression}' ---")

try:
    token_list = tokenize(test_expression)
    
    print("\nTokens generados:")
    # Imprime la lista de tokens de forma clara
    for token in token_list:
        print(f"  Tipo: {token[0]:<10} | Valor: {token[1]}")

except ValueError as e:
    print(f"\n¡FALLÓ EL ANÁLISIS!: {e}")