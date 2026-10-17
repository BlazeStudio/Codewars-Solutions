# Tiny Three-Pass Compiler
# https://www.codewars.com/kata/5265b0885fda8eac5900093b

# You are writing a three-pass compiler for a simple programming language into a small assembly language.
#
# The programming language has this syntax:
#
#     function   ::= '[' arg-list ']' expression
#
#     arg-list   ::= /* nothing */
#                  | variable arg-list
#
#     expression ::= term
#                  | expression '+' term
#                  | expression '-' term
#
#     term       ::= factor
#                  | term '*' factor
#                  | term '/' factor
#
#     factor     ::= number
#                  | variable
#                  | '(' expression ')'
#
# Variables are strings of alphabetic characters.  Numbers are strings of decimal digits representing integers.  So, for example, a function which computes a2 + b2 might look like:
#
#     [ a b ] a*a + b*b
#
# A function which computes the average of two numbers might look like:
#
#     [ first second ] (first + second) / 2
#
# You need write a three-pass compiler.  All test cases will be valid programs, so you needn't concentrate on error-handling.
#
# The first pass will be the method pass1 which takes a string representing a function in the original programming language and will return a (JSON) object that represents that Abstract Syntax Tree.  The Abstract Syntax Tree must use the following representations:
#
#     { 'op': '+', 'a': a, 'b': b }    // add subtree a to subtree b
#     { 'op': '-', 'a': a, 'b': b }    // subtract subtree b from subtree a
#     { 'op': '*', 'a': a, 'b': b }    // multiply subtree a by subtree b
#     { 'op': '/', 'a': a, 'b': b }    // divide subtree a from subtree b
#     { 'op': 'arg', 'n': n }          // reference to n-th argument, n integer
#     { 'op': 'imm', 'n': n }          // immediate value n, n integer
#
#   // Each node is of type 'Ast' and has the following methods:
#   // Ast has method 'op()' returning 'String'
#   // BinOp has methods 'a()' and 'b()', both return 'Ast'
#   // UnOp has method 'n()' returning 'int'
#   new BinOp('+', a, b)       // add subtree a to subtree b
#   new BinOp('-', a, b)       // subtract subtree b from subtree a
#   new BinOp('*', a, b)       // multiply subtree a by subtree b
#   new BinOp('/', a, b)       // divide subtree a from subtree b
#   new UnOp('arg', n)         // reference to n-th argument, n integer
#   new UnOp('imm', n)         // immediate value n, n integer
#
#   // Each node is of type 'AST' and has the following fields:
#   // 'string op', 'AST* a', 'AST* b', and 'int n'
#   AST ("+", a, b)       // add subtree a to subtree b
#   AST ("-", a, b)       // subtract subtree b from subtree a
#   AST ("*", a, b)       // multiply subtree a by subtree b
#   AST ("/", a, b)       // divide subtree a from subtree b
#   AST ("arg", n)        // reference to n-th argument, n integer
#   AST ("imm", n)        // immediate value n, n integer
#
#   // Each node is a struct of type 'AST' and has the following fields:
#   // 'enum op op', 'AST* a', 'AST* b', and 'int n' (unused fields are 0)
#   Bin (add, a, b)       // add subtree a to subtree b
#   Bin (sub, a, b)       // subtract subtree b from subtree a
#   Bin (mul, a, b)       // multiply subtree a by subtree b
#   Bin (div, a, b)       // divide subtree a from subtree b
#   Arg (n)               // reference to n-th argument, n integer
#   Imm (n)               // immediate value n, n integer
#
# Note: arguments are indexed from zero.  So, for example, the function
#
# [ x y ] ( x + y ) / 2 would look like:
#
#     { 'op': '/', 'a': { 'op': '+', 'a': { 'op': 'arg', 'n': 0 },
#                                    'b': { 'op': 'arg', 'n': 1 } },
#                  'b': { 'op': 'imm', 'n': 2 } }
#
# The second pass of the compiler will be called pass2.  This pass will take the output from pass1 and return a new Abstract Syntax Tree (with the same format) with all constant expressions reduced as much as possible.  So, if for example, the function is [ x ] x + 2*5, the result of pass1 would be:
#
#     { 'op': '+', 'a': { 'op': 'arg', 'n': 0 },
#                  'b': { 'op': '*', 'a': { 'op': 'imm', 'n': 2 },
#                                    'b': { 'op': 'imm', 'n': 5 } } }
#
# This would be passed into pass2 which would return:
#
#     { 'op': '+', 'a': { 'op': 'arg', 'n': 0 },
#                  'b': { 'op': 'imm', 'n': 10 } }
#
# The third pass of the compiler is pass3.  The pass3 method takes in an Abstract Syntax Tree and returns an array of strings.  Each string is an assembly directive.  You are working on a small processor with two registers (R0 and R1), a stack, and an array of input arguments.  The result of a function is expected to be in R0.  The processor supports the following instructions:
#
#     "IM n"     // load the constant value n into R0
#     "AR n"     // load the n-th input argument into R0
#     "SW"       // swap R0 and R1
#     "PU"       // push R0 onto the stack
#     "PO"       // pop the top value off of the stack into R0
#     "AD"       // add R1 to R0 and put the result in R0
#     "SU"       // subtract R1 from R0 and put the result in R0
#     "MU"       // multiply R0 by R1 and put the result in R0
#     "DI"       // divide R0 by R1 and put the result in R0
#
# So, one possible return value from pass3 given the Abstract Syntax Tree shown above from pass2 is:
#
#     [ "IM 10", "SW", "AR 0", "AD" ]
#
# Here is a simulator for the target machine.  It takes an array of assembly instructions and an array of arguments and returns the result.
# def simulate(asm, argv):
#     r0, r1 = None, None
#     stack = []
#     for ins in asm:
#         if ins[:2] == 'IM' or ins[:2] == 'AR':
#             ins, n = ins[:2], int(ins[2:])
#         if ins == 'IM':   r0 = n
#         elif ins == 'AR': r0 = argv[n]
#         elif ins == 'SW': r0, r1 = r1, r0
#         elif ins == 'PU': stack.append(r0)
#         elif ins == 'PO': r0 = stack.pop()
#         elif ins == 'AD': r0 += r1
#         elif ins == 'SU': r0 -= r1
#         elif ins == 'MU': r0 *= r1
#         elif ins == 'DI': r0 /= r1
#     return r0
#
# #include <stdlib.h>
# #include <string.h>
#
# // stack push (int) and pop () function defintions
#
# int simulate (const char *ins, const int *args) {
#   int r0 = 0, r1 = 0, t;
#   for (; ins && *ins; (ins = strchr (ins, '\n')) ? ++ins : 0x60d1510f)
#          if (!memcmp (ins, "IM", 2)) r0 = atoi (ins+3);
#     else if (!memcmp (ins, "AR", 2)) r0 = args[atoi (ins+3)];
#     else if (!memcmp (ins, "SW", 2)) t = r0, r0 = r1, r1 = t;
#     else if (!memcmp (ins, "PU", 2)) push (r0);
#     else if (!memcmp (ins, "PO", 2)) r0 = pop ();
#     else if (!memcmp (ins, "AD", 2)) r0 += r1;
#     else if (!memcmp (ins, "SU", 2)) r0 -= r1;
#     else if (!memcmp (ins, "MU", 2)) r0 *= r1;
#     else if (!memcmp (ins, "DI", 2)) r0 /= r1;
#   return r0;
# }

import re

class Compiler(object):
    
    def compile(self, program):
        return self.pass3(self.pass2(self.pass1(program)))
        
    def tokenize(self, program):
        token_iter = (m.group(0) for m in re.finditer(r'[-+*/()[\]]|[A-Za-z]+|\d+', program))
        return [int(tok) if tok.isdigit() else tok for tok in token_iter]

    def pass1(self, program):
        tokens = self.tokenize(program)
        self.tokens = tokens
        self.pos = 0
        self.args = {}
        
        # parse arg-list
        assert self.tokens[self.pos] == '['
        self.pos += 1
        idx = 0
        while self.tokens[self.pos] != ']':
            self.args[self.tokens[self.pos]] = idx
            idx += 1
            self.pos += 1
        self.pos += 1  # skip ']'
        
        return self.parse_expr()
    
    def parse_expr(self):
        left = self.parse_term()
        while self.pos < len(self.tokens) and self.tokens[self.pos] in ('+', '-'):
            op = self.tokens[self.pos]
            self.pos += 1
            right = self.parse_term()
            left = {'op': op, 'a': left, 'b': right}
        return left
    
    def parse_term(self):
        left = self.parse_factor()
        while self.pos < len(self.tokens) and self.tokens[self.pos] in ('*', '/'):
            op = self.tokens[self.pos]
            self.pos += 1
            right = self.parse_factor()
            left = {'op': op, 'a': left, 'b': right}
        return left
    
    def parse_factor(self):
        tok = self.tokens[self.pos]
        if tok == '(':
            self.pos += 1
            expr = self.parse_expr()
            self.pos += 1  # skip ')'
            return expr
        self.pos += 1
        if isinstance(tok, int):
            return {'op': 'imm', 'n': tok}
        else:
            return {'op': 'arg', 'n': self.args[tok]}
        
    def pass2(self, ast):
        if ast['op'] in ('imm', 'arg'):
            return ast
        a = self.pass2(ast['a'])
        b = self.pass2(ast['b'])
        if a['op'] == 'imm' and b['op'] == 'imm':
            op = ast['op']
            if op == '+': n = a['n'] + b['n']
            elif op == '-': n = a['n'] - b['n']
            elif op == '*': n = a['n'] * b['n']
            elif op == '/': n = a['n'] // b['n']
            return {'op': 'imm', 'n': n}
        return {'op': ast['op'], 'a': a, 'b': b}
    
    def pass3(self, ast):
        self.asm = []
        self._compile(ast)
        return self.asm
    
    def _compile(self, ast):
        op = ast['op']
        if op == 'imm':
            self.asm.append('IM {}'.format(ast['n']))
            return
        if op == 'arg':
            self.asm.append('AR {}'.format(ast['n']))
            return
        
        # compile left into R0, push
        self._compile(ast['a'])
        self.asm.append('PU')
        # compile right into R0
        self._compile(ast['b'])
        # move right to R1, pop left into R0
        self.asm.append('SW')
        self.asm.append('PO')
        # now R0 = left, R1 = right
        if op == '+': self.asm.append('AD')
        elif op == '-': self.asm.append('SU')
        elif op == '*': self.asm.append('MU')
        elif op == '/': self.asm.append('DI')
