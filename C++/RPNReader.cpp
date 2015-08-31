// Copyright 2015 Jeffrey Glabe
// RPNReader.cpp
// Note: Division by 0 returns a NaN
#include "RPNReader.h"

#include <iostream>
#include <vector>
#include <stack>

RPNReader::RPNReader(std::vector<Token> inputTokens) {
	tokensVector_ = inputTokens;
}

std::vector<Token> RPNReader::getTokens() {
	return tokensVector_;
}

double RPNReader::divide(double dividend, double divisor) {
	if (divisor == 0) {
		return NAN;
	} else {
		return (dividend / divisor);
	}
}

// converts tokensVector_ from infix to postfix notation
// eg: 3+4*2 --> 3 4 2 * +
void RPNReader::parse() {
	std::stack<Token> operatorStack;
	std::vector<Token> outputVector;

	for (auto it = tokensVector_.begin(); it != tokensVector_.end(); it++) {
		Token currentToken = *it;

		if (currentToken.isOperator()) {
			switch (currentToken.isLeftAssoc()) {
				case true:
					while (!operatorStack.empty() && operatorStack.top().isOperator()) {
						Token currentOperator = operatorStack.top();

						if (currentToken.getPrecedence() <= currentOperator.getPrecedence()) {
							outputVector.push_back(currentOperator);
							operatorStack.pop();
						} else {
							break;
						}
					}
					break;
				case false:
					while (!operatorStack.empty() && operatorStack.top().isOperator()) {
						Token currentOperator = operatorStack.top();

						if (currentToken.getPrecedence() < currentOperator.getPrecedence()) {
							outputVector.push_back(currentOperator);
							operatorStack.pop();
						} else {
							break;
						}
					}
					break;
				default:
					break;
			}
			operatorStack.push(currentToken);
		} else if (currentToken.getVal() == "(") {
			operatorStack.push(currentToken);

		} else if (currentToken.getVal() == ")") {
			while (!operatorStack.empty() && operatorStack.top().getVal() != "(") {
				outputVector.push_back(operatorStack.top());
				operatorStack.pop();
			}
			operatorStack.pop();
		} else {
			outputVector.push_back(currentToken);
		}
	}

	while (!operatorStack.empty()) {
		outputVector.push_back(operatorStack.top());
		operatorStack.pop();
	}

	tokensVector_ = outputVector;
}

// reads tokensVector_ and processes the expression into a double
double RPNReader::readRPN() {
	std::stack<Token> tokensStack;

	for (auto it = tokensVector_.begin(); it != tokensVector_.end(); it++) {
		Token currentToken = *it;

		if (currentToken.getVal().length() == 0) { continue; }

		if (!currentToken.isOperator()) {
			tokensStack.push(currentToken);
		} else {
			Token secondToken = tokensStack.top();
			tokensStack.pop();
			double secondOperand = std::strtod(secondToken.getVal().c_str(), NULL);

			Token firstToken = tokensStack.top();
			tokensStack.pop();
			double firstOperand = std::strtod(firstToken.getVal().c_str(), NULL);

			double result =
				currentToken.getVal() == "-" ? (firstOperand - secondOperand):
				currentToken.getVal() == "*" ? (firstOperand * secondOperand):
				currentToken.getVal() == "/" ? divide(firstOperand, secondOperand):
				currentToken.getVal() == "^" ? (pow(firstOperand, secondOperand)):
				                               (firstOperand + secondOperand);

			Token newToken(std::to_string(result));
			tokensStack.push(newToken);
		}
	}
	Token output = tokensStack.top();
	return std::strtod(output.getVal().c_str(), NULL);
}

// used for debugging
void RPNReader::printTokens() {
	for (auto it = tokensVector_.begin(); it != tokensVector_.end(); it++) {
		std::cout << (*it).getVal() << " ";
	}
	std::cout << std::endl;
}
