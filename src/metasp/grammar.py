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
class Constructor:
    type_name: str
    name: str
    arity: int
    args: Dict[int, List[Arg]] = field(default_factory=dict)


@dataclass
class DefinedAs:
    type: str
    pattern: str
    expansion: str


@dataclass
class Type:
    name: str
    super_types: List[str] = field(default_factory=list)
    sub_types: List[str] = field(default_factory=list)
    constructors: Dict[Tuple[str, int], Constructor] = field(default_factory=dict)
    allow_in_head: bool = False
    allow_in_body: bool = False

    @property
    def all_types(self) -> List[str]:
        return self.super_types + [self.name]

    @property
    def is_base_type(self) -> bool:
        return self.name in ["atom", "number", "string"]


@dataclass
class Var:
    name: str
    type: Type


class Grammar:

    def __init__(self) -> None:
        self.types: Dict[str, Type] = {}
        self.syntactic_sugar: List[DefinedAs] = []
        self.variables: Dict[str, List[Var]] = {}
        self._prefix = "__"
        self.add_base_types()

    def add_base_types(self) -> None:
        type_atom = Type(name="atom")
        self.add_type(type_atom)

        type_number = Type(name="number")
        self.add_type(type_number)

        type_string = Type(name="string")
        self.add_type(type_string)

        # type_head = Type(name="head")
        # self.add_type(type_head)

        # type_body = Type(name="body")
        # self.add_type(type_body)

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

    def add_syntactic_sugar(self, sugar: DefinedAs) -> None:
        self.syntactic_sugar.append(sugar)

    def add_var(self, var_name: str, var_type: Type) -> None:
        if var_type.name not in self.types:
            raise ValueError(f"Type '{var_type.name}' is not defined in the grammar.")
        if var_name not in self.variables:
            self.variables[var_name] = []
        self.variables[var_name].append(Var(name=var_name, type=var_type))  # Allow multiple types for the same variable

    def is_variable(self, s: Symbol) -> bool:
        if s.type != SymbolType.Function or len(s.arguments) != 0:
            return False
        return s.name in self.variables

    def is_atom(self, s: Symbol) -> bool:
        if s.type != SymbolType.Function or s.name.startswith(self._prefix):
            return False
        # log.info( f"Matched atom {s}")
        constructor_keys = self.get_constructors_keys()
        if (s.name, len(s.arguments)) in constructor_keys:
            log.warning(
                f"Symbol `{s}` looks like a constructor but is missing the & prefix. Did you forget it?. Will be considered as atom."
            )
        return True

    def apply_sugar_with_vars(self, sugar_expansion: Symbol, matched_variables: Dict[str, Symbol]) -> Symbol:
        # print(f"Replacing pattern symbol {sugar_expansion} with matched variables {matched_variables}")
        if sugar_expansion.type != SymbolType.Function:
            log.warning(f"Unexpected expansion symbol type {sugar_expansion}.")
            return sugar_expansion
        if self.is_variable(sugar_expansion):
            return matched_variables[sugar_expansion.name]
            # return matched_variables[sugar_expansion.name].symbol_with_prefix()
        new_args = [self.apply_sugar_with_vars(arg, matched_variables) for arg in sugar_expansion.arguments]
        return Function(sugar_expansion.name, new_args, True)

    def get_fl_type(self, s: Symbol, check_sugar: bool = False) -> Optional[Type]:
        # --------- Base cases
        if s.type == SymbolType.Number:
            return self.types.get("number", None)
        if s.type == SymbolType.String:
            return self.types.get("string", None)
        if s.type != SymbolType.Function:
            raise ValueError(f"Unexpected symbol type {s}.")
        # Maybe handle reserved names here
        if self.is_atom(s):
            return self.types.get("atom", None)

        # --------- Constructor case
        name = s.name[len(self._prefix) :]
        arity = len(s.arguments)
        constructor = self.get_constructor(name, arity)
        if constructor is not None:
            return self.types.get(constructor.type_name, None)

        if check_sugar:
            sugar = self.find_sugar(s)
            if sugar is not None:
                return self.get_fl_type(sugar.expansion.symbol, check_sugar=True)

        return None

    def find_sugar(
        self, s: Symbol, as_type: Optional[str] = None, match_variables: Optional[Dict[str, Symbol]] = None
    ) -> Optional[DefinedAs]:
        if match_variables is None:
            match_variables = {}
        if s.type != SymbolType.Function:
            return None

        for sugar in self.syntactic_sugar:
            if as_type is not None and sugar.type != as_type:
                continue
            if self.match_sugar_pattern(sugar.pattern.symbol, s, match_variables):
                return sugar
        return None

    def name_without_prefix(self, s: Symbol) -> str:
        if s.type != SymbolType.Function:
            raise ValueError(f"Unexpected symbol type {s}.")
        if not s.name.startswith(self._prefix):
            return s.name
        return s.name[len(self._prefix) :]  # Remove prefix

    def match_sugar_pattern(self, pattern_symbol: Symbol, symbol: Symbol, matched_variables: Dict[str, Symbol]) -> bool:
        if self.is_variable(pattern_symbol):
            variables = self.variables[pattern_symbol.name]
            if len(variables) == 0:
                raise ValueError(f"Variable {pattern_symbol.name} not defined in grammar.")
            var = variables[0]
            # TODO here I should make it softer to include possible sugar
            symbol_type = self.get_fl_type(symbol, check_sugar=True)
            if var.type.name not in symbol_type.all_types:
                # print(f"  ->Variable {pattern_symbol.name} type mismatch, {var.type.name} != {symbol_type.name}")
                return False
            matched_variables[pattern_symbol.name] = symbol
            return True
        if self.is_atom(pattern_symbol):
            log.warning(f"Pattern {pattern_symbol} is atom, pehaps you meant to use a variable?")
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
            # print(f"  ->Matching argument {p_arg} with {s_arg}")
            if not self.match_sugar_pattern(p_arg, s_arg, matched_variables):
                return False
        return True

    @lru_cache(maxsize=None)
    def get_constructors_keys(self) -> List[Tuple[str, int]]:
        keys = []
        for type_def in self.types.values():
            keys.extend(type_def.constructors.keys())
        return keys

    @lru_cache(maxsize=None)
    def get_constructor(self, name: str, arity: int) -> Optional[Constructor]:
        for type_def in self.types.values():
            constructor = type_def.constructors.get((str(name), arity), None)
            if constructor is not None:
                return constructor
        return None

    def check_grammar(self) -> bool:
        # Check that there are no two constructors with the same name and arity in different types
        seen = set()
        for type_def in self.types.values():
            for constructor in type_def.constructors.values():
                if (constructor.name, constructor.arity) in seen:
                    log.error(f"Constructor '{constructor.name}/{constructor.arity}' is defined in multiple types.")
                    return False
                seen.add((constructor.name, constructor.arity))

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

        grammar.asp_str = fb.asp_str(commented=True)
        for t in fb.query(clorm_db.Type).all():
            type_def = Type(name=t.name)
            for c in fb.query(clorm_db.Constructor).where(clorm_db.Constructor.type == t.name).all():
                args = {}
                for a in fb.query(clorm_db.Arg).where(clorm_db.Arg.cons_id == c.id).all():
                    if a.index not in args:
                        args[a.index] = []
                    args[a.index].append(Arg(key=a.key, value=a.value))
                constructor = Constructor(type_name=t.name, name=c.id.name, arity=c.id.arity, args=args)

                type_def.constructors[(c.id.name, c.id.arity)] = constructor

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

        for var in fb.query(clorm_db.Var).all():
            if var.type not in grammar.types:
                raise ValueError(f"Type '{var.type}' for variable '{var.name}' is not defined in the grammar.")
            grammar.add_var(var.name, grammar.types[var.type])

        for defined in fb.query(clorm_db.DefinedAs).all():
            sugar = DefinedAs(type=defined.type, pattern=defined.lhs, expansion=defined.rhs)
            grammar.add_syntactic_sugar(sugar)

        log.debug(grammar)
        log.info(grammar.asp_str)
        if not grammar.check_grammar():
            raise ValueError("Grammar check failed. Please fix the issues in the grammar definition.")
        return grammar

    def __str__(self) -> str:
        return pprint.pformat(self.__dict__, indent=2, width=120)
