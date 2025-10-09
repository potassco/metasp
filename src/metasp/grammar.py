from dataclasses import dataclass, field
from typing import List, Dict, Any, Sequence, Tuple, Optional, Union
import clorm
import logging
import pprint
import metasp.clorm_db as clorm_db

log = logging.getLogger(__name__)


# -------- Metasp Grammar
@dataclass
class Arg:
    key: str
    value: str


@dataclass
class Constructor:
    # type_name: str
    name: str  # e.g., "until"
    arity: int
    args: Dict[int, Arg] = field(default_factory=dict)


@dataclass
class DefinedAs:
    pattern: str
    expansion: str


@dataclass
class Type:
    name: str
    super_types: List[str] = field(default_factory=list)
    constructors: Dict[Tuple[str, int], Constructor] = field(default_factory=dict)


@dataclass
class Var:
    name: str
    type: Type


class Grammar:

    def __init__(self) -> None:
        self.types: Dict[str, Type] = {}
        self.syntactic_sugar: List[DefinedAs] = []
        self.variables: List[Arg] = []
        self.add_base_types()

    def add_base_types(self) -> None:
        type_atom = Type(name="atom")
        self.add_type(type_atom)

    def add_type(self, type_def: Type) -> None:
        if type_def.name in self.types:
            raise ValueError(f"Type '{type_def.name}' is already defined.")
        self.types[type_def.name] = type_def

    def add_syntactic_sugar(self, sugar: DefinedAs) -> None:
        self.syntactic_sugar.append(sugar)

    def add_var(self, var_name: str, var_type: Type) -> None:
        if var_type.name not in self.types:
            raise ValueError(f"Type '{var_type.name}' is not defined in the grammar.")
        self.variables.append(Var(name=var_name, type=var_type))

    @classmethod
    def from_asp_files(cls, asp_files: Sequence[str]) -> "Grammar":
        grammar = Grammar()
        # clorm_ctrl = clorm.Control(unifier=[UNIFIERS])
        try:
            fb = clorm.parse_fact_files(asp_files, clorm_db.UNIFIERS, raise_nonfact=True, raise_nomatch=True)
        except clorm.UnifierNoMatchError as e:
            log.warning("Error parsing grammar ASP files: %s", e)
            fb = clorm.parse_fact_files(asp_files, clorm_db.UNIFIERS)
        except clorm.orm.symbols_facts.FactParserError as e:
            log.warning("Grammar contains rules which will be ignored %s", e)
            fb = clorm.parse_fact_files(asp_files, clorm_db.UNIFIERS)

        for t in fb.query(clorm_db.Type).all():
            print(f"----------Type: {t.name}")
            type_def = Type(name=t.name)
            for c in fb.query(clorm_db.Constructor).where(clorm_db.Constructor.type == t.name).all():
                print(f"----------Constructor: {c.type} {c.id} {c.kind}")
                args = {
                    a.index: Arg(key=a.key, value=a.value)
                    for a in fb.query(clorm_db.Arg).where(clorm_db.Arg.cons_id == c.id).all()
                }
                constructor = Constructor(name=c.id.name, arity=c.id.arity, args=args)

                type_def.constructors[(c.id.name, c.id.arity)] = constructor

            grammar.add_type(type_def)

        for type_def in grammar.types.values():
            for c in fb.query(clorm_db.Subtype).where(clorm_db.Subtype.sub == type_def.name).all():
                type_def.super_types.append(c.sup)

        for var in fb.query(clorm_db.Var).all():
            grammar.add_var(var.name, grammar.types[var.type])

        for defined in fb.query(clorm_db.DefinedAs).all():
            sugar = DefinedAs(pattern=defined.lhs, expansion=defined.rhs)
            grammar.add_syntactic_sugar(sugar)

        # Parse the ASP program to populate the Grammar instance
        # This is a placeholder for actual parsing logic
        # For example, you might use clingo to parse and extract types and constructors
        print(grammar)
        return grammar

    def __str__(self) -> str:
        # Use the built-in repr() for a more readable output
        return pprint.pformat(self.__dict__, indent=2, width=120)
