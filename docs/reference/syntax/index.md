---
icon: "material/pen-plus"
---


# Grammar definition

Metasp extends the syntax of standard clingo by allowing metasp type
declarations anywhere a clingo statement may be used. Such a statement
declares a type over formulas by defining expressions that may
construct a formula of the declared type, it's subtypes, macro
expressions, and where these type of formulas may occur. When
declaring an expression, one also defines various properties of the
arguments of such an expression, such as it's expected type and
safety. The latter induces a safety definition that is checked during
preprocessing, and is used for the generation of externals that protects
unwanted from simplification during grounding. To  The metasp expressions
occurring in an input program are type checked against the respective
type declaration.

In the following, we provide a BNF grammar describing the syntax of
metasp type declarations.

## BNF Grammar: `metasp_type`

We use extended BNF notation: `*` = zero or more, `+` = one or more, `?` = optional,
`( … )` = grouping. Literals are in `"double quotes"`.

### Top-level

```bnf
metasp_type
  ::= "#type" identifier "{" metasp_type_keyword* "}" "."

metasp_type_keyword
  ::= metasp_expression_definitions
    | metasp_subtypes
    | metasp_macros
    | metasp_occurrence
```

### `expressions` keyword

```bnf
metasp_expression_definitions
  ::= "expressions" ":" "{" ( metasp_expression_definition ";" )* "}" ";"

metasp_expression_definition
  ::= metasp_signature
    | metasp_signature ":" "{" metasp_argument_definitions? "}"

metasp_argument_definitions
  ::= metasp_argument_definition+

metasp_argument_definition
  ::= metasp_keyword_arg? ( "," metasp_keyword_arg )* ";"

metasp_keyword_arg
  ::= identifier ":" identifier
```

### `subtypes` keyword

```bnf
metasp_subtypes
  ::= "subtypes" ":" "{" ( identifier ";" )* "}" ";"
```

### `macros` keyword

```bnf
metasp_macros
  ::= "macros" ":" "{" metasp_macro_definition* metasp_macro_where? "}" ";"

metasp_macro_definition
  ::= metasp_macro_func_or_id ":" metasp_macro_func_or_id ";"

metasp_macro_func_or_id
  ::= metasp_const_function
    | identifier

metasp_macro_where
  ::= "where" ":" "{" ( metasp_keyword_arg ";" )* "}" ";"
```

### `occurrence` keyword

```bnf
metasp_occurrence
  ::= "occurrence" ":" theory_atom_type ";"

theory_atom_type
  ::= "head" | "body" | "any" | "directive"
```

### Shared sub-productions

```bnf
metasp_signature
  ::= metasp_atom_identifier "/" number

metasp_atom_identifier
  ::= classical_negation? "&" identifier

classical_negation
  ::= "-"

metasp_const_function
  ::= "&" identifier ( "(" const_terms? ")" )?

const_terms
  ::= const_term ( "," const_term )*

const_term
  ::= clingo_const_term | metasp_const_function
```

!!! note

    The `clingo_const_term` and `identifier` productions are
    the same as in the standard clingo language; constant term being a
    term that contains no variables.

!!! tip

    Make sure to include a `;` after each entry to avoid syntax errors.
    Only use `,` to separate multiple entries in the same argument definition.


!!! example

    Below we provide a type declaration for a fragment of Temporal Equilibrium Logic [TEL](../../examples/tel.md).

    === "Input"

        ```
        #type tel {
          expressions: {
            &true/0;
            &not/1: { type: tel, safety: unsafe; };
            &initial/0;
            &next/1: {
              type: tel, safety: safe;
            };
            &prev/1: {
              type: tel, safety: safe;
            };
            &until/2: {
              type: tel, safety: unsafe;
              type: tel, safety:   safe;
            };
          };
          subtypes: { atom; };
          macros:   { &final: &not(&next(&true)); };
          occurrence: any;
        }.
        ```

        This declares the `tel` type, with expressions `&true`, `&initial`,
        `&not(tel)`, `&next(tel)`, `&prev(tel)` and `&until(tel,tel)`.

        Since `atom` is declared as a subtype of `tel`, any atom is also of type `tel`.

        The macro declaration defines the expression `&final` to expand to `&not(&next(&true))`.

        Finally, a formula of type `tel` may occur in place `any`, that is
        anywhere an atom may occur in the input language of clingo.

        Therefore, the following input program would be well-typed.

        ```
        &next(a) :- &initial.
        ```

        The expression `&initial` found in the body is well typed, as it is of
        type `tel` and `tel` formulas may occur anywhere, including the body
        of a rule.  The expression `&next(a)` is well-typed, as the expression
        `&next/1` expects it's arguments to be of type `tel`. The argument
        atom `a` is indeed of type `tel`, as atoms are declared as being a
        subtype of `tel`. Finally, `&next(a)` may indeed occur anywhere,
        including the head of a rule.

        On the other hand, the following program is not well-typed and would raise an error.

        ```
        &next(f(&initial)).
        ```

        This is due to the fact that `&initial` occurs as an argument of an
        atom `f/1`, which is not an allowed occurrence.

    === "Parse tree"

        The parse tree of our grammar definition according to the provided
        grammar would be the following:

        ```
        0:0   - 20:0    source_file
        0:0   - 19:2      metasp_type
        0:0   - 0:5         "#type"
        0:6   - 0:9         name: identifier `tel`
        0:10  - 0:11        "{"
        1:2   - 15:4        expressions: metasp_expression_definitions
        1:2   - 1:13          "expressions"
        1:13  - 1:14          ":"
        1:15  - 1:16          "{"
        2:4   - 2:11          metasp_expression_definition
        2:4   - 2:11            signature: metasp_signature
        2:4   - 2:5               "&"
        2:5   - 2:9               name: identifier `true`
        2:9   - 2:10              "/"
        2:10  - 2:11              arity: number `0`
        2:11  - 2:12          ";"
        3:4   - 3:42          metasp_expression_definition
        3:4   - 3:10            signature: metasp_signature
        3:4   - 3:5               "&"
        3:5   - 3:8               name: identifier `not`
        3:8   - 3:9               "/"
        3:9   - 3:10              arity: number `1`
        3:10  - 3:11            ":"
        3:12  - 3:13            "{"
        3:14  - 3:40            arguments: metasp_argument_definitions
        3:14  - 3:40              metasp_argument_definition
        3:14  - 3:23                metasp_keyword_arg
        3:14  - 3:18                  name: identifier `type`
        3:18  - 3:19                  ":"
        3:20  - 3:23                  value: identifier `tel`
        3:23  - 3:24                ","
        3:25  - 3:39                metasp_keyword_arg
        3:25  - 3:31                  name: identifier `safety`
        3:31  - 3:32                  ":"
        3:33  - 3:39                  value: identifier `unsafe`
        3:39  - 3:40                ";"
        3:41  - 3:42            "}"
        3:42  - 3:43          ";"
        4:4   - 4:14          metasp_expression_definition
        4:4   - 4:14            signature: metasp_signature
        4:4   - 4:5               "&"
        4:5   - 4:12              name: identifier `initial`
        4:12  - 4:13              "/"
        4:13  - 4:14              arity: number `0`
        4:14  - 4:15          ";"
        5:4   - 7:5           metasp_expression_definition
        5:4   - 5:11            signature: metasp_signature
        5:4   - 5:5               "&"
        5:5   - 5:9               name: identifier `next`
        5:9   - 5:10              "/"
        5:10  - 5:11              arity: number `1`
        5:11  - 5:12            ":"
        5:13  - 5:14            "{"
        6:6   - 6:30            arguments: metasp_argument_definitions
        6:6   - 6:30              metasp_argument_definition
        6:6   - 6:15                metasp_keyword_arg
        6:6   - 6:10                  name: identifier `type`
        6:10  - 6:11                  ":"
        6:12  - 6:15                  value: identifier `tel`
        6:15  - 6:16                ","
        6:17  - 6:29                metasp_keyword_arg
        6:17  - 6:23                  name: identifier `safety`
        6:23  - 6:24                  ":"
        6:25  - 6:29                  value: identifier `safe`
        6:29  - 6:30                ";"
        7:4   - 7:5             "}"
        7:5   - 7:6           ";"
        8:4   - 10:5          metasp_expression_definition
        8:4   - 8:11            signature: metasp_signature
        8:4   - 8:5               "&"
        8:5   - 8:9               name: identifier `prev`
        8:9   - 8:10              "/"
        8:10  - 8:11              arity: number `1`
        8:11  - 8:12            ":"
        8:13  - 8:14            "{"
        9:6   - 9:30            arguments: metasp_argument_definitions
        9:6   - 9:30              metasp_argument_definition
        9:6   - 9:15                metasp_keyword_arg
        9:6   - 9:10                  name: identifier `type`
        9:10  - 9:11                  ":"
        9:12  - 9:15                  value: identifier `tel`
        9:15  - 9:16                ","
        9:17  - 9:29                metasp_keyword_arg
        9:17  - 9:23                  name: identifier `safety`
        9:23  - 9:24                  ":"
        9:25  - 9:29                  value: identifier `safe`
        9:29  - 9:30                ";"
        10:4  - 10:5            "}"
        10:5  - 10:6          ";"
        11:4  - 14:5          metasp_expression_definition
        11:4  - 11:12           signature: metasp_signature
        11:4  - 11:5              "&"
        11:5  - 11:10             name: identifier `until`
        11:10 - 11:11             "/"
        11:11 - 11:12             arity: number `2`
        11:12 - 11:13           ":"
        11:14 - 11:15           "{"
        12:6  - 13:32           arguments: metasp_argument_definitions
        12:6  - 12:32             metasp_argument_definition
        12:6  - 12:15               metasp_keyword_arg
        12:6  - 12:10                 name: identifier `type`
        12:10 - 12:11                 ":"
        12:12 - 12:15                 value: identifier `tel`
        12:15 - 12:16               ","
        12:17 - 12:31               metasp_keyword_arg
        12:17 - 12:23                 name: identifier `safety`
        12:23 - 12:24                 ":"
        12:25 - 12:31                 value: identifier `unsafe`
        12:31 - 12:32               ";"
        13:6  - 13:32             metasp_argument_definition
        13:6  - 13:15               metasp_keyword_arg
        13:6  - 13:10                 name: identifier `type`
        13:10 - 13:11                 ":"
        13:12 - 13:15                 value: identifier `tel`
        13:15 - 13:16               ","
        13:17 - 13:31               metasp_keyword_arg
        13:17 - 13:23                 name: identifier `safety`
        13:23 - 13:24                 ":"
        13:27 - 13:31                 value: identifier `safe`
        13:31 - 13:32               ";"
        14:4  - 14:5            "}"
        14:5  - 14:6          ";"
        15:2  - 15:3          "}"
        15:3  - 15:4          ";"
        16:2  - 16:22       subtypes: metasp_subtypes
        16:2  - 16:10         "subtypes"
        16:10 - 16:11         ":"
        16:12 - 16:13         "{"
        16:14 - 16:18         identifier `atom`
        16:18 - 16:19         ";"
        16:20 - 16:21         "}"
        16:21 - 16:22         ";"
        17:2  - 17:44       macros: metasp_macros
        17:2  - 17:8          "macros"
        17:8  - 17:9          ":"
        17:12 - 17:13         "{"
        17:14 - 17:41         metasp_macro_definition
        17:14 - 17:20           metasp_function
        17:14 - 17:15             "&"
        17:15 - 17:20             name: identifier `final`
        17:20 - 17:21           ":"
        17:22 - 17:40           metasp_function
        17:22 - 17:23             "&"
        17:23 - 17:26             name: identifier `not`
        17:26 - 17:27             "("
        17:27 - 17:39             arguments: terms
        17:27 - 17:39               metasp_function
        17:27 - 17:28                 "&"
        17:28 - 17:32                 name: identifier `next`
        17:32 - 17:33                 "("
        17:33 - 17:38                 arguments: terms
        17:33 - 17:38                   metasp_function
        17:33 - 17:34                     "&"
        17:34 - 17:38                     name: identifier `true`
        17:38 - 17:39                 ")"
        17:39 - 17:40             ")"
        17:40 - 17:41           ";"
        17:42 - 17:43         "}"
        17:43 - 17:44         ";"
        18:2  - 18:18       occurrence: metasp_occurrence
        18:2  - 18:12         "occurrence"
        18:12 - 18:13         ":"
        18:14 - 18:17         theory_atom_type `any`
        18:17 - 18:18         ";"
        19:0  - 19:1        "}"
        19:1  - 19:2        "."
        ```
