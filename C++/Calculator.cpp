// Copyright 2015 Jeffrey Glabe
// Calculator.cpp
// Note: formatString() cannot differentiate between a negative number
// and a subtraction operator followed by a number. Therefore it is important
// that a subtraction operation contains a single whitespace character between
// the - and the number. (-4 is negative four, - 4 is subtract four).

#include <memory>
#include <vector>
#include <string>
#include "Calculator.h"

const std::string validOperators = "+-*/^";

Calculator::Calculator(std::string inputString) {
	inputString_ = inputString;
}

// Formats the input string, ensuring that a there is a single
// whitespace character between each token before string is passed
// to the tokenizer.
void Calculator::formatString() {
	for (std::string::size_type i = 0; i < inputString_.length(); i++) {
		// handling digits
		if (isdigit(inputString_[i])) {
			while ( isdigit(inputString_[i]) || inputString_[i] == '.' ) {
				i++;
			}
			if (inputString_[i] != ' ') {
				inputString_.insert(i, " ");
			}
		  // handling parens
		} else if (inputString_[i] == '(' || inputString_[i] == ')') {
			if (inputString_[++i] != ' ') {
				inputString_.insert(i, " ");
			}
		}
		// handling operators
		std::string::size_type operatorIndex;
		operatorIndex = validOperators.find(inputString_[i]);
		if (operatorIndex != std::string::npos) {
			// handling negative numbers
			if (inputString_[i] == '-' && isdigit(inputString_[++i])) {
				while (isdigit(inputString_[i]) || inputString_[i] == '.') {
					i++;
				}
				if (inputString_[i] != ' ') {
					inputString_.insert(i, " ");
				}
			}
			// handling all other operators
			if (inputString_[++i] != ' ') {
				inputString_.insert(i, " ");
			}
		}
	}
}

double Calculator::solve() {
	formatString();
	tokenizer_ = std::make_unique<Tokenizer>(inputString_);
	tokenizer_->tokenize();
	std::vector<Token> tokensVector = tokenizer_->getTokens();

	reader_ = std::make_unique<RPNReader>(tokensVector);
	reader_->parse();
	return reader_->readRPN();
}
