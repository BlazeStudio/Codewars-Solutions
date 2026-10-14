# Simple Interactive Interpreter
# https://www.codewars.com/kata/52ffcfa4aff455b3c2000750

# Task
#
# You will create an interpreter which takes inputs described below and produces outputs, storing state in between each input.
#
# If you're not sure where to start with this kata, check out my Simpler Interactive Interpreter (http://www.codewars.com/dojo/katas/53005a7b26d12be55c000243) kata, which greatly simplifies the interpreter by removing functions.
#
# Note that the eval command has been disabled.
#
# Concepts
#
# The interpreter will take inputs in the language described under the language header below. This section will give an overview of the language constructs.
#
# Variables
#
# Any identifier which is not a keyword or a function name will be treated as a variable. If the identifier is on the left hand side of an assignment operator, the result of the right hand side will be stored in the variable. If a variable occurs as part of an expression, the value held in the variable will be substituted when the expression is evaluated.
#
# Variables are implicitly declared the first time they are assigned to.
#
# Example: Initializing a variable to a constant value and using the variable in another expression (Each line starting with a '>' indicates a separate call to the input method of the interpreter, other lines represent output)
#
# >x = 7
#     7
# >x + 6
#     13
#
# Referencing a non-existent variable will cause the interpreter to throw an error. The interpreter should be able to continue accepting input even after throwing.
#
# Example: Referencing a non-existent variable
#
# >y + 7
#     ERROR: Invalid identifier. No variable with name 'y' was found."
#
# Assignments
#
# An assignment is an expression that has an identifier on left side of an = operator, and any expression on the right. Such expressions should store the value of the right hand side in the specified variable and return the result.
#
# Example: Assigning a constant to a variable
#
# x = 7
#     7
#
# You should also be able to chain and nest assignments. Note that the assignment operator is one of the few that is right associative.
#
# Example: Chained assignments. The statement below should set both x and y to 7.
#
# x = y = 7
#     7
#
# Example: Nested assignments. The statement below should set y to 3, but it only outputs the final result.
#
# x = 13 + (y = 3)
#     16
#
# Operator Precedence
#
# Operator precedence will follow the common order. There is a table in the Language section below that explicitly states the operators and their relative precedence.
#
# Functions
#
# Functions are declared by the fn keyword followed by a name, an optional arguments list, the => operator, and finally an expression. All function variables are local to the function. That is, the only variable names allowed in the function body are those declared by the arguments list. If a function has an argument called 'x', and there is also a global variable called 'x', the function should use the value of the supplied argument, not the value of the global variable, when evaluating the expression. References to variables not found in the argument list should result in an error when the function is defined.
#
# Example: declare a function to calculate the average of two variables and call it. (Each line starting with a '>' indicates a separate call to the input method of the interpreter, other lines represent output)
#
# >fn avg => (x + y) / 2
#     ERROR: Unknown identifier 'x'
# >fn avg x y => (x + y) / 2
# >a = 2
#     2
# >b = 4
#     4
# >avg a b
#     3
#
# Example: declare a function with an invalid variable name in the function body
#
# >fn add x y => x + z
#     ERROR: Invalid identifier 'z' in function body.
#
# Example: chain method calls (hint: function calls are right associative!)
#
# >fn echo x => x
# >fn add x y => x + y
# >add echo 4 echo 3
#     7
#
# Name conflicts
#
# Because variable and function names share the same grammar, conflicts are possible. Precedence will be given to the first object declared. That is, if a variable is declared, then subsequent declaration of a function with the same name should result in an error. Likewise, declaration of a function followed by the initialization of a variable with the same name should result in an error.
#
# Declaration of function with the same name as an existing function should overwrite the old function with the new one.
#
# Example: Overwriting a function
#
# >fn inc x => x + 1
# >a = 0
#     0
# >a = inc a
#     1
# >fn inc x => x + 2
# >a = inc a
#     3
#
# Input
#
# Input will conform to either the function production or the expression production in the grammar below.
#
# Output
#
# * Output for a valid function declaration will be an empty string (null in Java).
# * Output for a valid expression will be the result of the expression.
# * Output for input consisting entirely of whitespace will be an empty string (null in Java).
# * All other cases will throw an error.
#
# -- In Haskell that is:
# Right (Nothing, Interpreter)
# Right (Just Double, Interpreter)
# Right (Nothing, Interpreter)
# Left String
#
# Language
#
# Grammar
#
# This section specifies the grammar for the interpreter language in EBNF syntax (http://en.wikipedia.org/wiki/Extended_Backus%E2%80%93Naur_Form)
# Whitespace (one or more) is required:
# * between the fn keyword and the function name in function definitions
# * to separate the function name from the parameter list in function definitions
# * to separate the parameters in function definitions
# * to separate the arguments in function calls
#
# Whitespace (zero or more) is allowed:
# * at the start and end of the input
# * between operators (including =) and their operands
# * before and after => (start of the function body) in function definitions
#
# whitespace      ::= ' ' { whitespace }
#
# function        ::= 'fn'  whitespace  fn-name { whitespace identifier } '=>' expression
# fn-name         ::= identifier
#
# expression      ::= factor | expression operator expression
# factor          ::= number | identifier | assignment | '(' expression ')' | function-call
# assignment      ::= identifier '=' expression
# function-call   ::= fn-name { whitespace expression }
#
# operator        ::= '+' | '-' | '*' | '/' | '%'
#
# identifier      ::= (letter | '_') { identifier-char }
# identifier-char ::= '_' | letter | digit
#
# number          ::= { digit } '.' digit { digit } | digit { digit } ['.']
#
# letter          ::= 'a' | 'b' | ... | 'y' | 'z' | 'A' | 'B' | ... | 'Y' | 'Z'
# digit           ::= '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9'
#
# Operator Precedence
#
# The following table lists the language's operators grouped in order of precedence. Operators within each group have equal precedence.
#
# Category  | Operators
# ------------- | -------------
# Multiplicative  | *, /, %
# Additive  | +, -
# Assignment | =
# Function | =>
#
# Division
#
# You should use float division instead of integer division.

import re

def tokenize(expression):
    if expression == "":
        return []
    regex = re.compile(r"\s*(=>|[-+*/%=()]|[A-Za-z_][A-Za-z0-9_]*|[0-9]*\.?[0-9]+)\s*")
    tokens = regex.findall(expression)
    return [s for s in tokens if not s.isspace()]


class Interpreter:
    def __init__(self):
        self.vars = {}
        self.functions = {}
        self.tokens = []
        self.pos = 0

    def input(self, expression):
        if not expression or not expression.strip():
            return ""
        
        stripped = expression.strip()
        
        if stripped.startswith("fn ") or stripped.startswith("fn\t"):
            return self._define_function(stripped)
        
        self.tokens = tokenize(expression)
        self.pos = 0
        result = self._parse_expression()
        
        if self.pos < len(self.tokens):
            raise Exception("ERROR: Unexpected token")
        
        return self._format_number(result)

    def _format_number(self, num):
        if num == int(num):
            return int(num)
        return num

    def _peek(self):
        if self.pos < len(self.tokens):
            return self.tokens[self.pos]
        return None

    def _next(self):
        tok = self.tokens[self.pos]
        self.pos += 1
        return tok

    def _define_function(self, expression):
        match = re.match(r'fn\s+([A-Za-z_][A-Za-z0-9_]*)\s*(.*?)\s*=>\s*(.+)', expression)
        if not match:
            raise Exception("ERROR: Invalid function definition")
        
        fn_name = match.group(1)
        params_str = match.group(2).strip()
        body = match.group(3).strip()
        
        params = params_str.split() if params_str else []
        
        if len(params) != len(set(params)):
            raise Exception("ERROR: Duplicate parameter names")
        
        for p in params:
            if not re.match(r'^[A-Za-z_][A-Za-z0-9_]*$', p):
                raise Exception("ERROR: Invalid parameter name")
        
        body_tokens = tokenize(body)
        for tok in body_tokens:
            if re.match(r'^[A-Za-z_][A-Za-z0-9_]*$', tok):
                if tok not in params:
                    raise Exception(f"ERROR: Invalid identifier '{tok}' in function body.")
        
        if fn_name in self.vars:
            raise Exception(f"ERROR: Name conflict for '{fn_name}'")
        
        self.functions[fn_name] = (params, body)
        return ""

    def _parse_expression(self):
        return self._parse_assignment()

    def _parse_assignment(self):
        save = self.pos
        tok = self._peek()
        
        if tok and re.match(r'^[A-Za-z_][A-Za-z0-9_]*$', tok):
            if self.pos + 1 < len(self.tokens) and self.tokens[self.pos + 1] == "=":
                name = self._next()
                self._next()
                val = self._parse_expression()
                if name in self.functions:
                    raise Exception(f"ERROR: Name conflict for '{name}'")
                self.vars[name] = val
                return val
        
        self.pos = save
        return self._parse_additive()

    def _parse_additive(self):
        left = self._parse_multiplicative()
        while True:
            op = self._peek()
            if op in ("+", "-"):
                self._next()
                right = self._parse_multiplicative()
                if op == "+":
                    left = left + right
                else:
                    left = left - right
            else:
                break
        return left

    def _parse_multiplicative(self):
        left = self._parse_factor()
        while True:
            op = self._peek()
            if op in ("*", "/", "%"):
                self._next()
                right = self._parse_factor()
                if op == "*":
                    left = left * right
                elif op == "/":
                    left = left / right
                else:
                    left = left % right
            else:
                break
        return left

    def _parse_factor(self):
        tok = self._peek()
        
        if tok is None:
            raise Exception("ERROR: Unexpected end of input")
        
        if tok == "(":
            self._next()
            val = self._parse_expression()
            if self._peek() != ")":
                raise Exception("ERROR: Expected )")
            self._next()
            return val
        
        if re.match(r'^[0-9]*\.?[0-9]+$', tok):
            self._next()
            return float(tok)
        
        if re.match(r'^[A-Za-z_][A-Za-z0-9_]*$', tok):
            self._next()
            
            if tok in self.functions:
                params, body = self.functions[tok]
                args = []
                for _ in params:
                    args.append(self._parse_expression())
                return self._eval_function(params, body, args)
            
            if tok in self.vars:
                return self.vars[tok]
            
            raise Exception(f"ERROR: Invalid identifier. No variable with name '{tok}' was found.")
        
        raise Exception(f"ERROR: Unexpected token '{tok}'")

    def _eval_function(self, params, body, args):
        if len(args) != len(params):
            raise Exception("ERROR: Wrong number of arguments")
        
        body_tokens = tokenize(body)
        
        saved_tokens = self.tokens
        saved_pos = self.pos
        
        new_tokens = []
        for tok in body_tokens:
            if tok in params:
                idx = params.index(tok)
                new_tokens.append(str(args[idx]))
            else:
                new_tokens.append(tok)
        
        self.tokens = new_tokens
        self.pos = 0
        
        result = self._parse_expression()
        
        self.tokens = saved_tokens
        self.pos = saved_pos
        
        return result
