-------------------------------------------------------------------------------
-- HaskellCalc: An RPN calculator written in Haskell.
-- Input: A string of a mathematical expression in either infix or postfix format.
-- Returns: The computed result as a double.
-------------------------------------------------------------------------------

main = do
	putStrLn "Please enter an expression to evaluate."
	seq <- getLine
	print $ readRPN $ shuntingYard $ words seq
	
-------------------------------------------------------------------------------
-- Functions to determine the identity, association, and precedence of a token.
-- Used by the shunting-yard algorithm.
-------------------------------------------------------------------------------

-- Determining if a token is a number. 
isNum :: String -> Bool
isNum str
	| str == "-" = False -- distinguishing between minus operator and a negative
	| otherwise = all isDigit str
	where isDigit n
		| n `elem` ['0'..'9'] = True
		| n == '-'	      = isNum $ tail str -- handling negative numbers
		| n == '.'	      = isNum $ tail str -- handling decimals
		| otherwise 	      = False

-- Determining if a token is an operator.
isOp :: String -> Bool
isOp n = n `elem` ["+", "-", "*", "/", "^"]

-- Determining the associativity of an operator.
isLeftAssoc :: String -> Bool
isLeftAssoc "^" = False
isLeftAssoc  _  = True

-- Determining the precedence of an operator.
getPrecedence :: String -> Integer
getPrecedence n
	| n `elem` ["+", "-"] = 0
	| n `elem` ["*", "/"] = 1
	| n `elem` ["^"]      = 2
	| otherwise	      = -1
	
-------------------------------------------------------------------------------
-- E.W. Dijkstra's shunting yard algorithm.
--
-- Input: A list of string tokens in infix or postfix format.
-- Returns: A list of string tokens in postfix format.
-------------------------------------------------------------------------------
shuntingYard :: [String] -> [String]
shuntingYard xs = reverse $ parse xs ([], []) -- format is [input] ([operator stack], [output])
	where 
		parse [] 	([], outs) = outs -- base case
		parse []  ((o:ops), outs) = parse [] (ops, (o:outs)) -- no more tokens, pop operators onto output
		parse (x:xs) ([], [])
			| isNum x = parse (xs) ([], [x])
			| isOp x  = parse (xs) ([x], [])
		parse (x:xs) ((ops), outs)
			| isNum x  = parse xs (ops, (x:outs))
			| isOp x   = parse xs $ reconfigStack (x:ops, outs)
			| x == "(" = parse xs (x:ops, outs)
			| x == ")" = parse xs $ handleParens (ops, outs)

-- Called when a right parens is met. Pops operators off the operator stack
-- until a left parens is met, or returns an error if no left parens is found.
handleParens :: ([String], [String]) -> ([String], [String])
handleParens ([], _) = error "Unmatched parentheses."
handleParens (x:ops, outs)
	| x == "("  = (ops, outs)
	| otherwise = handleParens (ops, x:outs)

-- Called when the current token is an operator and there is at least one operator
-- on the operator stack. 
-- Rearranges the operator stack and output according to the rules of the shunting
-- yard algorithm.
reconfigStack :: ([String], [String]) -> ([String], [String])
reconfigStack (o1:[], outs) = ([o1], outs)
reconfigStack (o1:o2:xs, outs)
	| (isLeftAssoc o1 && (getPrecedence o1 == getPrecedence o2)) = reconfigStack (o1:xs, o2:outs)
	| (getPrecedence o1 < getPrecedence o2)                      = reconfigStack (o1:xs, o2:outs)
	| otherwise                                                  = (o1:o2:xs, outs)

-------------------------------------------------------------------------------
-- readRPN: parsing the postfix string.
-- 
-- Input: A list of strings in postfix format.
-- Returns: A double computed from the input string.
-------------------------------------------------------------------------------
readRPN :: [String] -> Double
readRPN = head . foldl folder []
	where 
		folder (x:y:ys) "*" = (x * y):ys
		folder (x:y:ys) "+" = (x + y):ys
		folder (x:y:ys) "-" = (y - x):ys
		folder (x:y:ys) "/" = (y / x):ys
		folder (x:y:ys) "^" = (y ** x):ys
		folder (x:xs)   "(" = error "Unmatched parentheses."
		folder xs num 	    = (read num :: Double):xs