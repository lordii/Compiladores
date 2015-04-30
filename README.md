# Compiladores
Compiladores - Trabajo Practico

## Definición del lenguaje

#### Estructura Básica

```
(Declaración de variables)
(Acciones)
-------------------------
(Acciones)
```

#### Identificadores

Los identificadores serán cualquier secuencia de letras y números siempre y cuando empiece por una letra.
La longitud máxima para un identificador será de 15 caracteres.

#### Asignaciones

```
a=b;
```

#### Decimales

```
0.9
.9
9.
```

#### Constantes

Usan la palabra reservada CONST

```
CONST a=30;
```

#### Declaraciones de variables

```
DEFVAR
    id:tipo, id:tipo;
ENDDEF
-------------------------
DEFVAR
    id:tipo, id:tipo;
    id:tipo, id:tipo;
ENDDEF
```

#### Strings

Máximo 30 caracteres

```
b="string";
```

Se puede concatenar con "++" un número máximo de 2 strings

#### In/Out

```
PUT "string";
GET variable;
```

#### If

```
IF (condicion) THEN
    (hacer);
ENDIF
-------------------------
IF (condicion) THEN
    (hacer);
ELSE 
    (hacer);
ENDIF
```

#### Repeat Until

```
REPEAT
(hacer)
UNTIL (condicion);
```

#### UnaryIf

```
Identificador = (condicion ? exp_ver; exp_fal);
```

#### QEqual

```
Identificador = QEqual(expresion, lista);
```

#### Comentarios

Los comentarios van entre /! -- !/

