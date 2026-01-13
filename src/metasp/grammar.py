from dataclasses import dataclass, field
from functools import lru_cache
from typing import List, Dict, Any, Sequence, Tuple, Optional, Union
import clorm
import logging
import pprint
import metasp.clorm_db as clorm_db
from clingo import Symbol, SymbolType, Function

log = logging.getLogger(__name__)


@dataclass
class Arg:
    key: str
    value: str


@dataclass
class Expression:
    type_name: str
    name: str
    arity: int
    args: Dict[int, List[Arg]] = field(default_factory=dict)


@dataclass
class Macro:
    type: str
    pattern: str
    expansion: str


@dataclass
class Var:
    name: str
    type_var: str


@dataclass
class Type:
    name: str
    super_types: List[str] = field(default_factory=list)
    sub_types: List[str] = field(default_factory=list)
    expressions: Dict[Tuple[str, int], Expression] = field(default_factory=dict)
    allow_in_head: bool = False
    allow_in_body: bool = False
    macros: List[Macro] = field(default_factory=list)
    variables: Dict[str, List[Var]] = field(default_factory=dict)

    @property
    def all_types(self) -> List[str]:
        return self.super_types + [self.name]

    @property
    def is_base_type(self) -> bool:
        return self.name in ["function", "number", "string", "tuple", "infimum", "sumpremum", "symbol"]

    def is_variable(self, s: Symbol) -> bool:
        if s.type != SymbolType.Function or len(s.arguments) != 0:
            return False
        return s.name in self.variables


class Grammar:

    def __init__(self) -> None:
        self.types: Dict[str, Type] = {}
        self._prefix = "__"
        self._prefix_sugar = "&"
        self.add_base_types()

    def add_base_types(self) -> None:
        type_symbol = Type(name="symbol", sub_types=["function", "number", "string", "tuple", "infimum", "sumpremum"])
        type_tuple = Type(name="tuple", super_types=["symbol"])
        type_function = Type(name="function", super_types=["symbol"], allow_in_head=True, allow_in_body=True)
        type_number = Type(name="number", super_types=["symbol"])
        type_string = Type(name="string", super_types=["symbol"])
        type_infimum = Type(name="infimum", super_types=["symbol"])
        type_sumpremum = Type(name="sumpremum", super_types=["symbol"])

        self.add_type(type_symbol)
        self.add_type(type_function)
        self.add_type(type_tuple)
        self.add_type(type_number)
        self.add_type(type_string)
        self.add_type(type_infimum)
        self.add_type(type_sumpremum)

    def allowed_types_in_position(self, position: str = None) -> List[str]:
        assert position in [None, "head", "body"], f"Unknown position '{position}'"
        allowed = []
        for type_def in self.types.values():
            if position is None:
                if type_def.allow_in_head or type_def.allow_in_body:
                    allowed.append(type_def.name)
            elif position == "head" and type_def.allow_in_head:
                allowed.append(type_def.name)
            elif position == "body" and type_def.allow_in_body:
                allowed.append(type_def.name)
        return allowed

    def add_type(self, type_def: Type) -> None:
        if type_def.name in self.types:
            raise ValueError(f"Type '{type_def.name}' is already defined.")
        self.types[type_def.name] = type_def

    # def add_macros(self, sugar: Macro) -> None:
    # self.macros.append(sugar)

    # def add_var(self,  var_name: str, var_type: str) -> None:
    #     if var_type not in self.types and var_type != "any":
    #         raise ValueError(f"Type '{var_type}' is not defined in the grammar.")
    #     if var_name not in self.variables:
    #         self.variables[var_name] = []
    #     self.variables[var_name].append(Var(name=var_name, type=var_type))  # Allow multiple types for the same variable

    def is_function(self, s: Symbol) -> bool:
        if s.type != SymbolType.Function or s.name.startswith(self._prefix):
            return False
        # log.info( f"Matched function {s}")
        expression_keys = self.get_expressions_keys(include_sugar=True)
        if (s.name, len(s.arguments)) in expression_keys:
            log.warning(
                f"⚠️Symbol `{s}` looks like a expression but is missing the & prefix. Did you forget it?. Will be considered as function."
            )
        return True

    def apply_sugar_with_vars(self, type: str, sugar_expansion: Symbol, matched_variables: Dict[str, Symbol]) -> Symbol:
        # print(f"Replacing pattern symbol {sugar_expansion} with matched variables {matched_variables}")
        if sugar_expansion.type != SymbolType.Function:
            return sugar_expansion
        type_def = self.types[type]
        if type_def.is_variable(sugar_expansion):
            return matched_variables[sugar_expansion.name]
            # return matched_variables[sugar_expansion.name].symbol_with_prefix()
        new_args = [self.apply_sugar_with_vars(type, arg, matched_variables) for arg in sugar_expansion.arguments]
        return Function(sugar_expansion.name, new_args, True)

    def get_fl_type(self, s: Symbol, check_sugar: bool = False, as_type: str | None = None) -> Optional[Type]:
        # --------- Base cases
        if s.type == SymbolType.Number:
            return self.types.get("number", None)
        if s.type == SymbolType.String:
            return self.types.get("string", None)
        # Maybe handle reserved names here
        if s.type == SymbolType.Function and s.name == "":
            return self.types.get("tuple", None)
        if s.type == SymbolType.Infimum:
            return self.types.get("infimum", None)
        if s.type == SymbolType.Supremum:
            return self.types.get("sumpremum", None)
        if self.is_function(s):
            return self.types.get("function", None)

        # --------- Expression case
        name = s.name[len(self._prefix) :]
        arity = len(s.arguments)
        expression = self.get_expression(name, arity)
        if expression is not None:
            return self.types.get(expression.type_name, None)

        if check_sugar:
            sugar = self.find_macro(s, as_type=as_type)
            if sugar is not None:
                log.debug("Found sugar %s->%s for symbol %s", sugar.pattern, sugar.expansion, s)
                log.debug("Will return the type of the expansion %s", sugar.expansion)
                return self.get_fl_type(sugar.expansion.symbol, check_sugar=True)

        return None

    def find_macro(
        self, s: Symbol, as_type: Optional[str] = None, match_variables: Optional[Dict[str, Symbol]] = None
    ) -> Optional[Macro]:
        if match_variables is None:
            match_variables = {}
        # if s.type != SymbolType.Function:
        # return None
        for type_def in self.types.values():
            for sugar in type_def.macros:
                if as_type is not None and sugar.type != as_type:
                    continue
                if self.match_sugar_pattern(type_def, sugar.pattern.symbol, s, match_variables):
                    return sugar
        return None

    def name_without_prefix(self, s: Symbol) -> str:
        if s.type != SymbolType.Function:
            raise ValueError(f"Unexpected symbol type {s}.")
        if not s.name.startswith(self._prefix):
            return s.name
        return s.name[len(self._prefix) :]  # Remove prefix

    def match_sugar_pattern(
        self, type_def: Type, pattern_symbol: Symbol, symbol: Symbol, matched_variables: Dict[str, Symbol]
    ) -> bool:
        # print(f"Matching pattern symbol {pattern_symbol} with symbol {symbol}")
        if type_def.is_variable(pattern_symbol):
            variables = type_def.variables[pattern_symbol.name]
            if len(variables) == 0:
                raise ValueError(f"Variable {pattern_symbol.name} not defined in grammar.")
            var_types = [v.type_var for v in variables]
            # TODO here I should make it softer to include possible sugar
            symbol_type = self.get_fl_type(symbol, check_sugar=True)

            valid_type = "any" in var_types or any(v in symbol_type.all_types for v in var_types)
            if not valid_type:
                # print(f"  ->Variable {pattern_symbol.name} type mismatch, {var.type.name} != {symbol_type.name}")
                return False
            matched_variables[pattern_symbol.name] = symbol
            return True
        if self.is_function(pattern_symbol):
            log.warning(f"Pattern {pattern_symbol} is function, pehaps you meant to use a variable?")
        # TODO what if symbol is not a function?
        if (symbol.name, len(symbol.arguments)) != (
            pattern_symbol.name,
            len(pattern_symbol.arguments),
        ):
            # log.debug(
            #     f"  ->Name or arity mismatch: {symbol.name}/{len(symbol.arguments)} != {pattern_symbol.name}/{len(pattern_symbol.arguments)}"
            # )
            return False
        log.debug(f"  ->Matched sugar pattern {pattern_symbol} with formula {symbol}, will check arguments")

        for p_arg, s_arg in zip(pattern_symbol.arguments, symbol.arguments):
            if not self.match_sugar_pattern(type_def, p_arg, s_arg, matched_variables):
                return False
        return True

    @lru_cache(maxsize=None)
    def get_expressions_keys(self, include_sugar: bool = False) -> List[Tuple[str, int]]:
        keys = []
        for type_def in self.types.values():
            keys.extend(type_def.expressions.keys())
            if include_sugar:
                for sugar in type_def.macros:
                    pattern = sugar.pattern.symbol
                    if pattern.name.startswith(self._prefix):
                        keys.append((pattern.name[len(self._prefix) :], len(pattern.arguments)))
        return keys

    @lru_cache(maxsize=None)
    def get_expression(self, name: str, arity: int) -> Optional[Expression]:
        for type_def in self.types.values():
            expression = type_def.expressions.get((str(name), arity), None)
            if expression is not None:
                return expression
        return None

    def check_grammar(self) -> bool:
        # Check that there are no two expressions with the same name and arity in different types
        seen = set()
        for type_def in self.types.values():
            for expression in type_def.expressions.values():
                if (expression.name, expression.arity) in seen:
                    log.error(f"Expression '{expression.name}/{expression.arity}' is defined in multiple types.")
                    return False
                seen.add((expression.name, expression.arity))

        return True

    @classmethod
    def from_asp_files(cls, asp_files: Sequence[str]) -> "Grammar":
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
                args = {}
                for a in fb.query(clorm_db.Arg).where(clorm_db.Arg.cons_id == c.id).all():
                    if a.index not in args:
                        args[a.index] = []
                    args[a.index].append(Arg(key=a.key, value=a.value))
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
            for c in fb.query(clorm_db.Subtype).where(clorm_db.Subtype.sub == type_def.name).all():
                type_def.super_types.append(c.sup)
            for c in fb.query(clorm_db.Subtype).where(clorm_db.Subtype.sup == type_def.name).all():
                type_def.sub_types.append(c.sub)

        for type_def in grammar.types.values():
            for c in fb.query(clorm_db.Allow).where(clorm_db.Allow.type == type_def.name).all():
                position = str(c.position)
                if position not in ["head", "body"]:
                    raise ValueError(f"Unknown allow position '{position}' for type '{type_def.name}'.")
                if position == "head":
                    type_def.allow_in_head = True
                if position == "body":
                    type_def.allow_in_body = True

            for var in fb.query(clorm_db.Var).where(clorm_db.Var.type == type_def.name).all():
                if var.type_var not in grammar.types and var.type_var != "any":
                    raise ValueError(f"Type '{var_type}' is not defined in the grammar.")
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
        if not grammar.check_grammar():
            raise ValueError("Grammar check failed. Please fix the issues in the grammar definition.")
        return grammar

    def __str__(self) -> str:
        return pprint.pformat(self.__dict__, indent=2, width=120)

    @property
    def asp_str(self) -> str:
        asp_str = "%%%%%%%%%%%% GRAMMAR DEFINITION %%%%%%%%%%%%\n"

        for t in self.types.values():
            fb = clorm.FactBase()
            asp_str += f"%----------- TYPE {t.name} \n"
            fb.add(clorm_db.Type(name=t.name))
            if t.allow_in_head:
                fb.add(clorm_db.Allow(type=t.name, position="head"))
            if t.allow_in_body:
                fb.add(clorm_db.Allow(type=t.name, position="body"))

            for st in t.sub_types:
                fb.add(clorm_db.Subtype(sub=st, sup=t.name))

            for expr in t.expressions.values():
                fb.add(
                    clorm_db.Expression(
                        type=t.name,
                        id=clorm_db.ExpressionID(name=f"{self._prefix}{expr.name}", arity=expr.arity),
                    )
                )
                for index, args in expr.args.items():
                    for arg in args:
                        fb.add(
                            clorm_db.Arg(
                                cons_id=clorm_db.ExpressionID(name=f"{self._prefix}{expr.name}", arity=expr.arity),
                                index=index,
                                key=arg.key,
                                value=arg.value,
                            )
                        )

            for v in t.variables.values():
                for var in v:
                    fb.add(clorm_db.Var(type=t.name, name=var.name, type_var=var.type_var))

            for macro in t.macros:
                fb.add(clorm_db.Macro(type=macro.type, lhs=macro.pattern, rhs=macro.expansion))

            asp_str += fb.asp_str()

        return asp_str
