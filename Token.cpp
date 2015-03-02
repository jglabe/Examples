// Copyright 2015 Jeffrey Glabe
// Token.cpp

#include <string>
#include "Token.h"

const std::string validOperators = "+-*/^";

Token::Token(std::string inputValue) {
	tokenVal_ = inputValue;
}

// Returns precedence value of operator. Used to determine order of operations.
int Token::getPrecedence() {
	if (tokenVal_ == "+" || tokenVal_ == "-")
		return 0;
	else if (tokenVal_ == "*" || tokenVal_ == "/")
		return 1;
	else if (tokenVal_ == "^")
		return 2;
	else
		return -1;
}

bool Token::isOperator() {
	return (!tokenVal_.empty() &&
		   validOperators.find(tokenVal_) != std::string::npos);
}

// returns whether an operator is left or right-associative.
// exponentiation is currently the only supported right-associative
// operator.
bool Token::isLeftAssoc() {
	return tokenVal_ != "^";
}

std::string Token::getVal(void) {
	return tokenVal_;
}
