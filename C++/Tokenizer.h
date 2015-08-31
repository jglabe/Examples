// Copyright 2015 Jeffrey Glabe
// Tokenizer: Takes an input string and converts it
// into a vector of class Token. Uses a single whitespace
// as a delimiter.
// Note: By the time the string is passed to the tokenizer
// constructor, it should have the numbers and operators delimited by
// single whitespaces. This is done by the Calculator class.
#ifndef TOKENIZER_H
#define TOKENIZER_H

#include <vector>
#include <string>
#include "Token.h"

// Sample usage:
// Tokenizer t("3 + 4 * 2 - (5 * 1) ");
// t.tokenize();
// std::vector<Token> tokens = t.getTokens();
class Tokenizer {
public:
	explicit Tokenizer(std::string inputString);
	void tokenize(void);
	const std::vector<Token> getTokens(void);
	void printTokens();

private:
	std::string inputString_;
	std::vector<Token> tokens_;
};










#endif  // TOKENIZER_H
