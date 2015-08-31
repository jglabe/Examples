// Copyright 2015 Jeffrey Glabe
// Class Token: Encapsulates a number or an operator
// along with appropriate methods needed to parse.
// A token can be a whole number, a decimal number, or
// an operator (+-/*^).
#ifndef TOKEN_H
#define TOKEN_H

#include <string>

class Token {
public:
	explicit Token(std::string);
	int getPrecedence();
	bool isOperator();
	bool isLeftAssoc();
	std::string getVal();

private:
	std::string tokenVal_;
};











#endif  // TOKEN_H
