// Copyright 2015 Jeffrey Glabe
// The Calculator class encapsulates both a tokenizer and a RPNReader into
// a single Calculator object. Also formats the string (ensures a single
// whitespace character delimits each token). Sample usage:
// Calculator c("3+4*2/(1 - 5)^2^3");
// std::cout << c.solve();
#ifndef CALCULATOR_H
#define CALCULATOR_H


#include <memory>
#include <string>
#include "Tokenizer.h"
#include "RPNReader.h"

// see comments at top of file
class Calculator {
public:
	explicit Calculator(std::string);
	double solve();

private:
	void formatString();
	std::unique_ptr<Tokenizer> tokenizer_;
	std::unique_ptr<RPNReader> reader_;
	std::string inputString_;
};








#endif  // CALCULATOR_H
