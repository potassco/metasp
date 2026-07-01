# Safety

In a metasp type declaration, the provided safety property of
expression arguments induces a safety definition for input programs.

Given an input rule, we define the set of safe body atoms of the rule
as the set of atoms not int the scope of default negation, which occur
as a top-level literal of the rule, or are reachable through safe
arguments of metasp expressions.

For an input rule `r`, we define a corresponding set of so-called
simplified rules that consist of one rule for each atom occurring in
the head of the given rule, forming the head of the corresponding
simplified rule, the body of which consists of the conjunction of all
safe body atoms of the rule `r`.

So, taking as example the following rule

```
&until(a(X),&next(a(Y))) :- not b(Y), &next(c(Y)), &until(d(Y),&next(e(X))).
```

the set of simplified rules corresponding to this rule would be

```
a(X) :- c(Y), e(X).
a(Y) :- c(Y), e(X).
```

We define a rule to be safe, if the set of corresponding simplified
rules are safe with regard to the standard safety definition of clingo.
We say that a program is safe, if all of its rules are safe.

# Generated Externals

The generation of externals are necessary in order to protect the
input program from simplifications `gringo` performs during
grounding. These simplifications are stable model preserving with
regard to standard ASP semantics, but not necessarily with regard to
the extended semantics one can define using metasp.

External generation is closely related to the safety definition
presented above.  For any input program, we generate a set of so
called body external and a set of head external statements for each
corresponding simplified rule.

In the set of head externals, we have one external statement for each
simplified rule, with the head and bodies of the external statement
being the same as the simplified rule.

In the set body externals we have for each rule of the input program
one external statement for each metasp expression occurring in the
body of the rule. This aforementioned expression forms the head of the
external, with the body of the external being that of (one of) the
corresponding simplified rule.

To see a concrete example, consider again the example rule

```
&until(a(X),&next(a(Y))) :- not b(Y), &next(c(Y)), &until(d(Y),&next(e(X))).
```

with corresponding simplified rules

```
a(X) :- c(Y), e(X).
a(Y) :- c(Y), e(X).
```

We will have one head external for each simplified rule

```
#external a(X): c(Y), e(X).
#external a(Y): c(Y), e(X).
```

And we will have one body external for each body expression

```
#external &next(c(Y)): c(Y), e(X).
#external &until(d(Y),&next(e(X))): c(Y), e(X).
```

Finally, we provide some intuition on how why this grounding method
will result in a correct grounding of the program with regard to the
safety definition induced by metasp type declarations.

The goal of our approach is to calculate the unique stable of the set
of simplified rules, and use the atoms in this stable model to ground
our original program - this method is correct if the input program is
safe.

The head externals will, in effect cause the grounder to derive unique
stable model of the set of simplified rules corresponding to the input
program, but in the form of ground external statements (or facts),
with one caveat. Gringo will not execute this grounding as we would
desire for rules who's body contain a non-atomic expression, as it will
not (necessarily) see any rules with this expression in its head, and will
therefore discard the rule.

To protect such rules from simplification, we have the set of body
externals. These externals rectify the previous issue by protecting
rules with expression in their bodies from simplification, but only
for such substitutions of variables as allowed by the unique stable
model of the simplified program.
