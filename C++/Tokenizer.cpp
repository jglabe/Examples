// Copyright 2015 Jeffrey Glabe
// Tokenize.cpp
#include "Tokenizer.h"

#include <string>
#include <vector>
#include <iostream>

Tokenizer::Tokenizer(std::string inputString) {
	inputString_ = inputString;
}

const std::vector<Token> Tokenizer::getTokens(void) {
	return tokens_;
}

void Tokenizer::tokenize(void) {
	const std::string delimiter = " ";
	std::string stringCopy = inputString_;

	size_t pos = 0;
	while ((pos = stringCopy.find(delimiter)) != std::string::npos) {
		Token t(stringCopy.substr(0, pos));
		tokens_.push_back(t);
		stringCopy.erase(0, pos + delimiter.length());
	}
	Token t(stringCopy);
	tokens_.push_back(t);
}

// used in debugging
void Tokenizer::printTokens() {
	for (auto it = tokens_.begin(); it != tokens_.end(); it++) {
		std::cout << (*it).getVal() << " ";
	}
	std::cout << std::endl;
}
