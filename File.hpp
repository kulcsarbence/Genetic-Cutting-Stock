#pragma once
#include <fstream>
#include <string>
#include <vector>
#include "Base.hpp"


class File {
	/*This class can read from and write to CSV files.*/
private:
	std::string filedir;
public:
	File(std::string file):filedir(file){}
	std::vector<std::shared_ptr<Base>> readStockFromCSV() {
		/*Returns a vector containing the rectangles stored in the CSV file.*/
		std::ifstream file(filedir);
		std::string line;
		std::vector<std::shared_ptr<Base>> toReturn;
		while (std::getline(file,line)) {
			std::vector<double> temp;
			std::string delimiter = ",";
			size_t pos = 0;
			std::string token;
			std::cout << "Line: " << line << std::endl;
			while ((pos = line.find(delimiter)) != std::string::npos) {
				token = line.substr(0, pos);
				std::cout << "Token: " << token << std::endl;
				temp.push_back(std::stod(token));
				line.erase(0, pos + delimiter.length());
			}
			for (auto a : temp) {
				std::cout << "Temp element: " << a << std::endl;
			}
			std::cout << std::endl;
			for (int i = 0; i < temp[2]; i++) {
				toReturn.push_back(std::make_shared<Base>( Base(temp[1], temp[0], 0, 0)));
			}
		}
		file.close();
		return toReturn;
	}
	void writeStockToCSV(std::vector<std::shared_ptr<Base>> stock) {
		/*Generates a file that is going to contain the rectangles stored in the 'stock' vector*/
		std::ofstream file(filedir);
		int counter = 0;
		std::shared_ptr<Base> currElement{ stock[0] };
		for (auto element : stock) {
			if (element->getHeight() == currElement->getHeight() && element->getWidth() == currElement->getWidth()) {
				counter++;
				currElement = element;
			}
			else {
				file << std::to_string(currElement->getWidth()) << "," << std::to_string(currElement->getHeight()) << "," << std::to_string(counter) << "," << "\n";
				counter = 1;
				currElement = element;
			}
		}
		file << std::to_string(currElement->getWidth()) << "," << std::to_string(currElement->getHeight()) << "," << std::to_string(counter) << "," << "\n";
		
		file.close();
	}
};