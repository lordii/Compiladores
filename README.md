# Compiladores
Compiladores - Trabajo Practico

## Definicion del lenguaje

#### If

```
IF (condicion) THEN
    (hacer);
END
-------------------------
IF (condicion) THEN
    (hacer);
ELSE 
    (hacer);
END

```

#### Asiganaciones

```
a=b;
```

#### Decimales

```
a=0.9;
a=.9;
a=9.;
```

####Constantes

Usan la palabra reservada CONST

```
CONST a=30;
```

#### In/Out

```
PUT "string";
GET variable;
```

#### Declaraciones de variables

```
DEFVAR
    id:tipo, id:tipo
ENDDEF
-------------------------
DEFVAR
    id:tipo, id:tipo
    id:tipo, id:tipo
ENDDEF

```

#### Strings

Maximo 30 caracteres

```
b="string";
```

Se puede concatenar con "++" un numero maximo de 2 strings

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

