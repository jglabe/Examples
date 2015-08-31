#include <iostream>
#include "Calculator.h"
using namespace std;

int main(void) {

	std::string expression = "3+4*2/(1 - 5)^2^3";
	Calculator c(expression);
	cout << c.solve() << endl;

	int x;
	cin >> x;
	
	return 0;
}