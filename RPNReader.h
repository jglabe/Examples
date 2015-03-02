// Copyright 2015 Jeffrey Glabe
// RPNReader: Takes a vector of tokens and can convert it from infix
// to postfix format using the shunting-yard algorithm.
// Can then read the expression in postfix format and return the answer
// as a double.
#ifndef RPNREADER_H
#define RPNREADER_H

#include <vector>
#include "Token.h"

// RPNReader converts infix to postfix notation and
// reads postfix notation into a double. Sample usage:
// RPNReader reader(inputTokens)
// reader.parse();
// std::cout << reader.readRPN() << std::endl;
class RPNReader {
public:
	explicit RPNReader(std::vector<Token> inputTokens);
	void parse();
	double readRPN();
	std::vector<Token> getTokens();
	void printTokens();

private:
	std::vector<Token> tokensVector_;
	double divide(double, double);
};






#endif  // RPNREADER_H
