"""
Grammar module for representing and manipulating types, expressions, macros, and variables.
"""

import logging
import pprint
from collections.abc import Sequence
from dataclasses import dataclass, field
from functools import lru_cache

import clorm
from clorm import Raw
from clingo import Function, Symbol, SymbolType

from metasp import clorm_db

log = logging.getLogger(__name__)

BASE_TYPES = {
    SymbolType.Number: "number",
    SymbolType.String: "string",
    SymbolType.Infimum: "infimum",
    SymbolType.Supremum: "supremum",
}


@dataclass
class Arg:
    """
    Represents an argument of an expression.
    """

    key: str
    value: Raw


@dataclass
class Expression:
    """
    Represents an expression in the grammar.
    """

    type_name: str
    name: str
    arity: int
    args: dict[int, list[Arg]] = field(default_factory=dict)


@dataclass
class Macro:
    """
    Represents a macro in the grammar.
    """

    type: str
    pattern: Raw
    expansion: Raw


@dataclass
class Var:
    """
    Represents a variable in the grammar.
    """

    name: str
    type_var: str


# pylint: disable=too-many-instance-attributes
@dataclass
class Type:
    """
    Represents a type in the grammar.

    A type can have super types, sub types, expressions, macros, and variables associated with it.

    Attributes:
        name: The name of the type.
        super_types: A list of super types of this type.
        sub_types: A list of sub types of this type.
        expressions: A dictionary of expressions associated with this type.
        allow_in_head: Whether this type is allowed in the head of a rule.
        allow_in_body: Whether this type is allowed in the body of a rule.
        macros: A list of macros associated with this type.
        variables: A dictionary of variables associated with this type.
    """

    name: str
    super_types: list[str] = field(default_factory=list)
    sub_types: list[str] = field(default_factory=list)
    expressions: dict[tuple[str, int], Expression] = field(default_factory=dict)
    allow_in_head: bool = False
    allow_in_body: bool = False
    macros: list[Macro] = field(default_factory=list)
    variables: dict[str, list[Var]] = field(default_factory=dict)

    @property
    def all_types(self) -> list[str]:
        """
        Returns a list of all types including the super types and the type itself.
        """
        return self.super_types + [self.name]

    @property
    def is_base_type(self) -> bool:
        """
        Returns True if the type is a base type, False otherwise.
        """
        return self.name in ["atom", "number", "string", "tuple", "infimum", "supremum", "symbol"]

    def is_variable(self, s: Symbol) -> bool:
        """
        Returns True if the given symbol represents a variable of this type, False otherwise.
        """
        if s.type != SymbolType.Function or len(s.arguments) != 0:
            return False
        return s.name in self.variables


class Grammar:
    """
    Represents a grammar consisting of types and their relationships.

    Attributes:
        types: A dictionary of type names to Type objects.
    """

    def __init__(self) -> None:
        """
        Initializes a new instance of the Grammar class.
        """
        self.types: dict[str, Type] = {}
        self._prefix = "__"
        self._prefix_sugar = "&"
        self.add_base_types()

    def all_types(self, t: Type) -> list[str]:
        """
        Returns all types related to type. Doing a closure on the supertypes.
        """

        all_types_str = set(t.all_types)
        all_types_extended = set([])
        for st in all_types_str:
            if st == str(t.name):
                all_types_extended.add(st)
            else:
                st_type = self.get_type(st)
                if st_type is not None:
                    all_types_extended.update(self.all_types(st_type))
        return [str(s) for s in all_types_extended]

    def all_sub_types(self, t: Type) -> list[str]:
        """
        Returns all subtypes of the given type, including the type itself.
        """
        all_sub_types = set(t.sub_types).union(set([t.name]))
        for st in t.sub_types:
            st_type = self.get_type(st)
            if st_type is not None:
                all_sub_types.update(self.all_sub_types(st_type))
        return list(all_sub_types)

    def get_type(self, type_name: str) -> Type:
        """
        Returns the Type object corresponding to the given type name.
        Raises a RuntimeError if the type is not defined in the grammar.

        Args:
            type_name (str): The string of the type
        """
        if not type_name in self.types:
            log.error("Type '%s' is not defined in the grammar.", type_name)
            raise RuntimeError(f"Type '{type_name}' is not defined in the grammar but used in the syntax.")
        return self.types[type_name]

    # pylint: disable=too-many-locals
    # pylint: disable=too-many-branches
    @classmethod
    def from_asp_files(cls, asp_files: Sequence[str]) -> "Grammar":
        """
        Loads a Grammar object from the given ASP files.
        Raises a ValueError if no ASP files are provided.

        Args:
            asp_files (Sequence[str]): A sequence of ASP file paths to load the grammar from.
        Returns:
            Grammar: The loaded Grammar object.
        """
        log.debug("Loading grammar from ASP files: %s", asp_files)
        if len(asp_files) == 0:
            log.error("Syntax encoding files were not provided to load the grammar.")
            raise ValueError("Syntax encoding files were not provided to load the grammar.")
        grammar = Grammar()
        try:
            fb = clorm.parse_fact_files(asp_files, clorm_db.UNIFIERS, raise_nonfact=True, raise_nomatch=True)
        except clorm.UnifierNoMatchError as e:
            log.warning("Error parsing grammar ASP files: %s", e)
            fb = clorm.parse_fact_files(asp_files, clorm_db.UNIFIERS)
        except clorm.orm.symbols_facts.FactParserError as e:
            log.warning("Grammar contains rules which will be ignored %s", e)
            fb = clorm.parse_fact_files(asp_files, clorm_db.UNIFIERS)

        # grammar.asp_str = fb.asp_str(commented=True)
        for t in fb.query(clorm_db.Type).all():
            type_def = Type(name=t.name)
            for c in fb.query(clorm_db.Expression).where(clorm_db.Expression.type == t.name).all():
                args: dict[int, list[Arg]] = {}
                for arg_fact in fb.query(clorm_db.Arg).where(clorm_db.Arg.cons_id == c.id).all():
                    if arg_fact.index not in args:
                        args[arg_fact.index] = []
                    args[arg_fact.index].append(Arg(key=arg_fact.key, value=arg_fact.value))
                expression_name = c.id.name
                if not expression_name.startswith(grammar._prefix):
                    raise ValueError(
                        f"Expression name '{expression_name}' must start with prefix '{grammar._prefix_sugar}'."
                    )
                expression_name = expression_name[len(grammar._prefix) :]  # Remove prefix
                expression = Expression(type_name=t.name, name=expression_name, arity=c.id.arity, args=args)

                type_def.expressions[(expression_name, c.id.arity)] = expression

            grammar.add_type(type_def)

        for type_def in grammar.types.values():
            for subtype_fact in fb.query(clorm_db.Subtype).where(clorm_db.Subtype.sub == type_def.name).all():
                type_def.super_types.append(subtype_fact.sup)
            for subtype_fact in fb.query(clorm_db.Subtype).where(clorm_db.Subtype.sup == type_def.name).all():
                type_def.sub_types.append(subtype_fact.sub)

        for type_def in grammar.types.values():
            for allow_fact in fb.query(clorm_db.Allow).where(clorm_db.Allow.type == type_def.name).all():
                position = str(allow_fact.position)
                if position not in ["head", "body"]:
                    raise ValueError(f"Unknown allow position '{position}' for type '{type_def.name}'.")
                if position == "head":
                    type_def.allow_in_head = True
                if position == "body":
                    type_def.allow_in_body = True

            for var in fb.query(clorm_db.Var).where(clorm_db.Var.type == type_def.name).all():
                if var.type_var not in grammar.types and var.type_var != "any":
                    raise ValueError(f"Type '{var.type_var}' is not defined in the grammar.")
                if var.name not in type_def.variables:
                    type_def.variables[var.name] = []
                type_def.variables[var.name].append(
                    Var(name=var.name, type_var=var.type_var)
                )  # Allow multiple types for the same variable

            for defined in fb.query(clorm_db.Macro).where(clorm_db.Macro.type == type_def.name).all():
                macro = Macro(type=defined.type, pattern=defined.lhs, expansion=defined.rhs)
                type_def.macros.append(macro)

        log.debug(grammar)
        log.debug(grammar.asp_str)
        # if not grammar.check_grammar():
        # We dont check that the grammar does not redefine things now
        # raise ValueError("Grammar check failed. Please fix the issues in the grammar definition.")
        return grammar

    def __str__(self) -> str:
        """
        Returns a pretty-printed string representation of the Grammar object.
        """
        return pprint.pformat(self.__dict__, indent=2, width=120)

    def add_base_types(self) -> None:
        """
        Adds the base types to the grammar.
        """
        type_symbol = Type(name="symbol", sub_types=["atom", "number", "string", "infimum", "supremum"])
        type_atom = Type(name="atom", super_types=["symbol"], allow_in_head=True, allow_in_body=True)
        type_number = Type(name="number", super_types=["symbol"])
        type_string = Type(name="string", super_types=["symbol"])
        type_infimum = Type(name="infimum", super_types=["symbol"])
        type_supremum = Type(name="supremum", super_types=["symbol"])

        self.add_type(type_symbol)
        self.add_type(type_atom)
        self.add_type(type_number)
        self.add_type(type_string)
        self.add_type(type_infimum)
        self.add_type(type_supremum)

    def add_type(self, type_def: Type) -> None:
        """
        Adds a new type to the grammar.

        Args:
            type_def (Type): The type definition to add.

        Raises:
            ValueError: If the type is already defined.
        """
        if type_def.name in self.types:
            raise ValueError(f"Type '{type_def.name}' is already defined.")
        self.types[type_def.name] = type_def

    def allowed_types_in_position(self, position: str | None = None) -> list[str]:
        """
        Returns a list of allowed types in the given position.
        If position is None, returns all types allowed in either head or body.

        Args:
            position (str | None): The position to check for allowed types. Can be "head", "body", or None.

        Returns:
            list[str]: A list of allowed type names.
        """
        assert position in [None, "head", "body"], f"Unknown position '{position}'"
        allowed = []
        for type_def in self.types.values():
            if position is None:
                if type_def.allow_in_head or type_def.allow_in_body:
                    allowed.append(type_def.name)
            elif position == "head" and type_def.allow_in_head or position == "body" and type_def.allow_in_body:
                allowed.append(type_def.name)
        return allowed

    def is_atom(self, s: Symbol) -> bool:
        """
        Determines if the given symbol is considered an atom.
        For this it should not start with & (the prefix used for expressions).

        Args:
            s (Symbol): The symbol to check.

        Returns:
            bool: True if the symbol is an atom, False otherwise.
        """
        if s.type != SymbolType.Function or s.name.startswith(self._prefix):
            return False
        expression_keys = self.get_expressions_keys(include_sugar=True)
        if (s.name, len(s.arguments)) in expression_keys:
            log.warning(
                "⚠️Symbol `%s` looks like a expression but is missing the & prefix.\n"
                "Did you forget it?. Will be considered as an atom.",
                s,
            )
        return True

    def apply_sugar_with_vars(self, t: str, sugar_expansion: Symbol, matched_variables: dict[str, Symbol]) -> Symbol:
        """
        Applies the sugar expansion to the given symbol, replacing variables with matched values.

        Args:
            t (str): The type of the symbol.
            sugar_expansion (Symbol): The sugar expansion to apply.
            matched_variables (dict[str, Symbol]): A dictionary mapping variable names to their matched symbols.

        Returns:
            Symbol: The resulting symbol after applying the sugar expansion.
        """
        if sugar_expansion.type != SymbolType.Function:
            return sugar_expansion
        type_def = self.get_type(t)
        if type_def.is_variable(sugar_expansion):
            return matched_variables[sugar_expansion.name]
            # return matched_variables[sugar_expansion.name].symbol_with_prefix()
        new_args = [self.apply_sugar_with_vars(t, arg, matched_variables) for arg in sugar_expansion.arguments]
        return Function(sugar_expansion.name, new_args, True)

    def get_fl_type_sugar(self, s: Symbol, as_type: str | None) -> Type | None:
        """
        Checks if there is a sugar expansion for the given symbol as the specified type.

        Args:
            s (Symbol): The symbol to check for sugar.
            as_type (str): The type to check the sugar against.

        Returns:
            Type | None: The type of the sugar expansion if found, otherwise None.
        """
        log.debug("Checking for sugar for symbol %s as type %s", s, as_type)
        sugar = self.find_macro(s, as_type=as_type)
        if sugar is not None:
            log.debug("Found sugar %s->%s for symbol %s", sugar.pattern, sugar.expansion, s)
            log.debug("Will return the type of the expansion %s", sugar.expansion)
            return self.get_fl_type(sugar.expansion.symbol, check_sugar=True)
        log.debug("No sugar found for symbol %s as type %s", s, as_type)
        return None

    # pylint: disable=too-many-branches,too-many-return-statements
    def get_fl_type(self, s: Symbol, check_sugar: bool = False, as_type: str | None = None) -> Type | None:
        """
        Gets the type of the given symbol, optionally checking for sugar expansions.

        Args:
            s (Symbol): The symbol to get the type for.
            check_sugar (bool, optional): Whether to check for sugar expansions
                if the type doesn't match. Defaults to False.
            as_type (str | None, optional): The expected type to match against. Defaults to None.

        Returns:
            Type | None: The type of the symbol if found, otherwise None.
        """
        log.debug("Getting type for symbol %s with check_sugar=%s and as_type=%s", s, check_sugar, as_type)
        # --------- Base cases
        symbol_is_base_type = s.type in BASE_TYPES
        if symbol_is_base_type:  # Cases for the base types (excluding atom)
            type_name = BASE_TYPES[s.type]
            if as_type is not None and as_type != type_name:
                log.debug(
                    "Symbol %s is a base type %s trying to match with %s, checking sugar",
                    s,
                    type_name,
                    as_type,
                )
                if check_sugar:
                    return self.get_fl_type_sugar(s, as_type=as_type)
                log.debug("No sugar found for symbol %s, returning None", s)
                return None
            return self.types.get(type_name, None)

        if self.is_atom(s):
            log.debug("Symbol %s is an atom", s)
            if as_type is not None and as_type != "atom":
                log.debug("Symbol %s is an atom trying to match with %s, checking sugar", s, as_type)
                if check_sugar:
                    return self.get_fl_type_sugar(s, as_type=as_type)
                log.debug("No sugar found for symbol %s, returning None", s)
                return None
            return self.types.get("atom", None)

        if as_type is not None and as_type in list(BASE_TYPES.values()) + ["atom"]:
            log.debug("Symbol %s is a function, but the expected type is %s so it can't match", s, as_type)
            if check_sugar:
                return self.get_fl_type_sugar(s, as_type=as_type)
            log.debug("No sugar found for symbol %s, returning None", s)
            return None

        log.debug("Symbol %s is a function, checking for expression or sugar", s)
        # --------- Expression case
        name = s.name[len(self._prefix) :]
        arity = len(s.arguments)
        expression = self.get_expression(name, arity)
        if expression is not None:
            if as_type is not None and as_type != expression.type_name:
                return None
            return self.types.get(expression.type_name, None)

        if check_sugar:
            return self.get_fl_type_sugar(s, as_type=as_type)
        return None

    def find_macro(
        self, s: Symbol, as_type: str | None = None, match_variables: dict[str, Symbol] | None = None
    ) -> Macro | None:
        """
        Finds a macro for the given symbol, optionally matching it against the specified type and variables.

        Args:
            s (Symbol): The symbol to find a macro for.
            as_type (str | None, optional): The expected type to match against. Defaults to None.
            match_variables (dict[str, Symbol] | None, optional): A dictionary of variables to match against.
                    Defaults to None.

        Returns:
            Macro | None: The matching macro if found, otherwise None.
        """
        if match_variables is None:
            match_variables = {}
        # if s.type != SymbolType.Function:
        # return None
        log.debug("Finding macro for symbol %s as type %s", s, as_type)
        for type_def in self.types.values():
            for sugar in type_def.macros:
                # if as_type is not None and sugar.type != as_type:
                if as_type is not None:
                    valid_types = self.get_type(as_type).sub_types + [as_type]
                    # log.debug("Looking for sugar in type %s and its subtypes %s", as_type, valid_types)
                    if sugar.type not in valid_types:
                        continue
                if self.match_sugar_pattern(type_def, sugar.pattern.symbol, s, match_variables):
                    return sugar
        log.debug("No macro found for symbol %s as type %s", s, as_type)
        return None

    def name_without_prefix(self, s: Symbol) -> str:
        """
        Returns the name of the symbol without the prefix used for expressions.

        Args:
            s (Symbol): The symbol to get the name for.

        Returns:
            str: The name of the symbol without the prefix.
        """
        if s.type != SymbolType.Function:
            raise ValueError(f"Unexpected symbol type {s}.")
        if not s.name.startswith(self._prefix):
            return s.name
        return s.name[len(self._prefix) :]  # Remove prefix

    def match_sugar_pattern(
        self, type_def: Type, pattern_symbol: Symbol, symbol: Symbol, matched_variables: dict[str, Symbol]
    ) -> bool:
        """
        Matches the given symbol against a sugar pattern, updating matched variables if successful.

        Args:
            type_def (Type): The type definition containing the pattern.
            pattern_symbol (Symbol): The pattern symbol to match against.
            symbol (Symbol): The symbol to match.
            matched_variables (dict[str, Symbol]): A dictionary of matched variables to update.

        Returns:
            bool: True if the symbol matches the pattern, False otherwise.
        """
        log.debug("Matching pattern symbol %s with symbol %s", pattern_symbol, symbol)
        if type_def.is_variable(pattern_symbol):
            log.debug("Pattern symbol %s is a variable, checking type", pattern_symbol)
            variables = type_def.variables[pattern_symbol.name]
            if len(variables) == 0:
                raise ValueError(f"Variable {pattern_symbol.name} not defined in grammar.")
            var_types = [v.type_var for v in variables]
            log.debug("Variable types for %s: %s", pattern_symbol.name, var_types)
            # TODO here I should make it softer to include possible sugar
            # TODO This is giving an infinite recursion issue.
            for main_v in var_types:
                for v in self.all_sub_types(self.get_type(main_v)):
                    log.debug("Checking if symbol %s is of type %s", symbol, v)
                    symbol_type = self.get_fl_type(symbol, check_sugar=True, as_type=v)
                    if symbol_type is None:
                        continue
                    matched_variables[pattern_symbol.name] = symbol
                    return True

            log.debug("  Variable %s type mismatch, expected %s", pattern_symbol.name, var_types)
            return False

        if self.is_atom(pattern_symbol):
            log.warning("Pattern %s is an atom, pehaps you meant to use a variable?", pattern_symbol)
        # TODO what if symbol is not a function?
        if symbol.type == SymbolType.Number:
            # Notice that number should only match with a variable which is handled above
            return False
        if (symbol.name, len(symbol.arguments)) != (
            pattern_symbol.name,
            len(pattern_symbol.arguments),
        ):
            # log.debug(
            #     "  ->Name or arity mismatch: %s/%s != %s/%s",
            #     symbol.name, len(symbol.arguments), pattern_symbol.name, len(pattern_symbol.arguments)
            # )
            return False
        log.debug(
            "  ->Matched sugar pattern %s with formula %s, will check arguments",
            pattern_symbol,
            symbol,
        )

        for p_arg, s_arg in zip(pattern_symbol.arguments, symbol.arguments):
            if not self.match_sugar_pattern(type_def, p_arg, s_arg, matched_variables):
                return False
        return True

    @lru_cache(maxsize=128)
    def get_expressions_keys(self, include_sugar: bool = False) -> list[tuple[str, int]]:
        """
        Gets the keys of all expressions, optionally including sugar macros.

        Args:
            include_sugar (bool, optional): Whether to include sugar macros. Defaults to False.

        Returns:
            list[tuple[str, int]]: A list of expression keys as (name, arity) tuples.
        """
        keys: list[tuple[str, int]] = []
        for type_def in self.types.values():
            keys.extend(type_def.expressions.keys())
            if include_sugar:
                for sugar in type_def.macros:
                    pattern = sugar.pattern.symbol
                    if pattern.name.startswith(self._prefix):
                        keys.append((pattern.name[len(self._prefix) :], len(pattern.arguments)))
        return keys

    @lru_cache(maxsize=128)
    def get_expression(self, name: str, arity: int) -> Expression | None:
        """
        Retrieves an expression by its name and arity.

        Args:
            name (str): The name of the expression.
            arity (int): The arity of the expression.

        Returns:
            Expression | None: The matching expression if found, otherwise None.
        """
        for type_def in self.types.values():
            expression = type_def.expressions.get((str(name), arity), None)
            if expression is not None:
                return expression
        return None

    def check_grammar(self) -> bool:
        """
        Checks the grammar for consistency, ensuring that no two expressions
        with the same name and arity are defined in different types.

        Returns:
            bool: True if the grammar is consistent, False otherwise.
        """
        seen = set()
        for type_def in self.types.values():
            for expression in type_def.expressions.values():
                if (expression.name, expression.arity) in seen:
                    log.error(
                        "Expression '%s/%s' is defined in multiple types.",
                        expression.name,
                        expression.arity,
                    )
                    return False
                seen.add((expression.name, expression.arity))

        return True

    @property
    def asp_str(self) -> str:
        """
        Generates the ASP representation of the grammar.

        Returns:
            str: The ASP string representing the grammar.
        """
        asp_str = "\n%%%%%%%%%%%% GRAMMAR DEFINITION %%%%%%%%%%%%\n"

        for t in self.types.values():
            fb = clorm.FactBase()
            asp_str += f"%----------- TYPE {t.name} \n"
            fb.add(clorm_db.Type(name=t.name))  # type: ignore[no-untyped-call]
            if t.allow_in_head:
                fb.add(clorm_db.Allow(type=t.name, position="head"))  # type: ignore[no-untyped-call]
            if t.allow_in_body:
                fb.add(clorm_db.Allow(type=t.name, position="body"))  # type: ignore[no-untyped-call]

            for st in t.sub_types:
                fb.add(clorm_db.Subtype(sub=st, sup=t.name))  # type: ignore[no-untyped-call]

            for expr in t.expressions.values():
                fb.add(
                    clorm_db.Expression(  # type: ignore[no-untyped-call]
                        type=t.name,
                        id=clorm_db.ExpressionID(  # type: ignore[no-untyped-call]
                            name=f"{self._prefix}{expr.name}", arity=expr.arity
                        ),
                    )
                )
                for index, args in expr.args.items():
                    for arg in args:
                        fb.add(
                            clorm_db.Arg(  # type: ignore[no-untyped-call]
                                cons_id=clorm_db.ExpressionID(  # type: ignore[no-untyped-call]
                                    name=f"{self._prefix}{expr.name}", arity=expr.arity
                                ),
                                index=index,
                                key=arg.key,
                                value=arg.value,
                            )
                        )

            for v in t.variables.values():
                for var in v:
                    fb.add(
                        clorm_db.Var(type=t.name, name=var.name, type_var=var.type_var)  # type: ignore[no-untyped-call]
                    )

            for macro in t.macros:
                fb.add(
                    clorm_db.Macro(type=macro.type, lhs=macro.pattern, rhs=macro.expansion)  # type: ignore[no-untyped-call]
                )

            asp_str += fb.asp_str()

        return asp_str
