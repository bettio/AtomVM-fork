/**
 * This file is part of AtomVM.
 *
 * Copyright 2023 Paul Guyot <pguyot@kallisys.net>
 *
 * @name Passing a non-term to a function expecting a term
 * @kind problem
 * @problem.severity error
 * @id atomvm/non-term-to-term-func
 * @tags correctness
 * @precision high
 *
 * SPDX-License-Identifier: Apache-2.0 OR LGPL-2.1-or-later
 */

import cpp

predicate isNotTermOrAtom(Expr expr) {
  expr.getExplicitlyConverted().getType().getName() != "term" and
  not (
    expr.isInMacroExpansion() and
    expr.isConstant() and
    // Allow for %_ATOM and TERM_% macros until these include an explicit cast to term
    exists(MacroInvocation mi |
      expr = mi.getAGeneratedElement() and
      (mi.toString().matches("%_ATOM") or mi.toString().matches("TERM_%"))
    )
  ) and
  (
    not expr instanceof ConditionalExpr
    or
    isNotTermOrAtom(expr.(ConditionalExpr).getThen()) and
    isNotTermOrAtom(expr.(ConditionalExpr).getElse())
  )
}

from FunctionCall functioncall, Type expected_type, Expr expr, int i
where
  functioncall.getExpectedParameterType(i) = expected_type and
  expected_type.getName() = "term" and
  functioncall.getArgument(i) = expr and
  isNotTermOrAtom(expr)
select expr, "Passing a non-term to a function expecting a term, without an explicit cast"
