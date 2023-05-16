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

from FunctionCall functioncall, Type expected_type, Expr expr, int i
where
  functioncall.getExpectedParameterType(i) = expected_type and
  expected_type.getName() = "term" and
  expr.getExplicitlyConverted().getType().getName() != "term" and
  (
    not expr instanceof ConditionalExpr
    or
    (
      expr.(ConditionalExpr).getThen().getExplicitlyConverted().getType().getName() != "term" and
      not expr.(ConditionalExpr).getThen().isInMacroExpansion() // handle ATOM macros
      or
      expr.(ConditionalExpr).getElse().getExplicitlyConverted().getType().getName() != "term" and
      not expr.(ConditionalExpr).getElse().isInMacroExpansion() // handle ATOM macros
    )
  ) and
  not expr.isInMacroExpansion() and // handle ATOM macros
  functioncall.getArgument(i) = expr
select functioncall, "Passing a non-term to a function expecting a term, without an explicit cast"
