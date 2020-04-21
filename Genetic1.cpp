// Genetic1.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
//#define _CRTDBG_MAP_ALLOC
//#include <stdlib.h>
//#include <crtdbg.h>
#include <vector>
#include <iostream>
#include <random>
#include <algorithm>
#include <functional>
#include <iostream>
#include <fstream>
#include <Windows.h>
#include <string>
#include "File.hpp"
#include "Step.hpp"
#include "Base.hpp"
#include "Entity.hpp"


void fv() {
	//_CrtDumpMemoryLeaks();
}



int main(int argc, char* argv[])
{
	//todo: mi van ha 23 550x1000 megy bele? akkor alapbol 50es ratioval akar dolgozni, ami rossz!
	//cutWidthtel is mukodjon, szerintem azzal most hibasan mukodik
	//mem szivargas ne legyen
	//csinaljon output fajlt h mit hol kell kivagni...
	//cnt sorrend igazodjon az LKO cucchoz itt lentebb
	//ha tul sokaig szamol, induljon elolrol, ne legyen az hibas mukodes, talan ehhez a mem szivargast meg kene szuntetni, mert a masodik
	//futasnal mindig belassul
	
	
	//Kitorlunk mindent a ready mappabol
	std::string command = "del /Q ";
	std::string cur_dir(argv[0]);
	int pos = cur_dir.find_last_of("/\\");
	std::string path = cur_dir.substr(0, pos) + "\\*.svg";
	std::cout << path << std::endl;
	system(command.append(path).c_str());
	//vege a torlesnek

	int ratio;
	int mutationChanceC = 7;
	int generation = 0;
	std::ifstream basicInput("exchange.txt");
	std::string line;
	std::getline(basicInput, line);
	int ww = std::stoi(line);
	std::getline(basicInput, line);
	int hh = std::stoi(line);
	std::getline(basicInput, line);
	int cutWidth = std::stoi(line);
	std::getline(basicInput, line);
	int populationSize = std::stoi(line);
	std::getline(basicInput, line);
	int genS = std::stoi(line);
	basicInput.close();
	
	Base* alap = new Base(ww, hh, 0, 0);
	std::vector<Base*> baseVector;
	baseVector.push_back(alap);
	std::vector<Entity*> population;
	std::vector<Entity*> readyPop;
	std::vector<Base*> theseToBeCut;
	std::vector<int> cnt;
	/*for (int i = 0; i < 100; i++) {
		theseToBeCut.push_back(new Base(60, 60, 0, 0));
	}*/
	File toBeCut("tobecut.csv");
	theseToBeCut = toBeCut.readStockFromCSV();
	/*theseToBeCut.push_back(new Base(200, 200, 0, 0));

	theseToBeCut.push_back(new Base(200, 200, 0, 0));

	theseToBeCut.push_back(new Base(100, 100, 0, 0));
	theseToBeCut.push_back(new Base(100, 100, 0, 0));
	theseToBeCut.push_back(new Base(100, 100, 0, 0));
	theseToBeCut.push_back(new Base(50, 50, 0, 0));
	theseToBeCut.push_back(new Base(50, 50, 0, 0));
	theseToBeCut.push_back(new Base(50, 50, 0, 0));
	theseToBeCut.push_back(new Base(200, 200, 0, 0));*/
	/*cnt.push_back(23);
	cnt.push_back(3);
	cnt.push_back(1);
	cnt.push_back(2);
	cnt.push_back(1);
	cnt.push_back(3);*/

	/*std::sort(theseToBeCut.begin(), theseToBeCut.end(), [](Base* a, Base* b) {return std::abs(a->getHeight()-a->getWidth()) > std::abs(b->getHeight()-b->getWidth()) ? true : 
		std::abs(a->getHeight()-a->getWidth())==std::abs(b->getHeight()-b->getWidth()) ? a->getHeight()*a->getWidth()
		>b->getHeight()*b->getWidth() ? true : false : false ; });*/
	std::sort(theseToBeCut.begin(), theseToBeCut.end(), [](Base* a, Base* b) {return a->getWidth()*a->getHeight() > b->getWidth()*b->getHeight(); });
	for (auto a : theseToBeCut) {
		std::cout << a->getHeight() << ", " << a->getWidth() << "\n";
	}
	int itemTypeCounter = 1;
	int currentWidth = theseToBeCut[0]->getWidth();
	int currentHeight = theseToBeCut[0]->getHeight();
	for (int i = 0; i < theseToBeCut.size() - 1; i++) {
		currentWidth = theseToBeCut[i]->getWidth();
		currentHeight = theseToBeCut[i]->getHeight();
		if (theseToBeCut[i + 1]->getHeight() == currentHeight && theseToBeCut[i + 1]->getWidth() == currentWidth) {
			itemTypeCounter++;
		}
		else {
			cnt.push_back(itemTypeCounter);
			itemTypeCounter = 1;
		}
	}
	cnt.push_back(itemTypeCounter);



	std::vector<int> items;
	for (int i = 0; i < theseToBeCut.size(); i++) {
		items.push_back(theseToBeCut[i]->getWidth());
		items.push_back(theseToBeCut[i]->getHeight());
	}

	std::sort(items.begin(), items.end(), [](int a, int b) {return a < b; });


	//ratio = LKOarr(items);
	ratio = LKO(theseToBeCut[0]->getWidth(), theseToBeCut[0]->getHeight());

	std::cout << "Ratio: " << ratio << std::endl;

	for (int i = 0; i < populationSize; i++) {
		population.push_back(new Entity(baseVector, cutWidth, theseToBeCut, cnt, ratio));
		population[i]->calculateFitness(false);
		population[i]->makeCuts();
		population[i]->calculateFitness(false);
	}
	int fittestPos = 0;
	int fittestValue = 0;
	int leastfitPos = 0;
	int leastfitValue = 0;
	std::vector<Entity*> newGen;

	//while (fittestValue < theseToBeCut.size()) {
	while((/*readyPop.size()<=populationSize/2 && */generation<genS)){


		int chosenEntityPos = 0;

		for (int k = 0; k < population.size(); k++) {
			bool canMate = false;
			chosenEntityPos = 0;
			int counter = 0;
			while (!canMate || population[chosenEntityPos]->getatMax() == true) {

				chosenEntityPos = getRandom(0, population.size() -1);

				/*if (population[chosenEntityPos]->getFitness() >=
				getRandom(std::round(fittestValue - fittestValue / 10), fittestValue)
				) {
				canMate = true;
				}*/
				//std::cout << leastfitValue << std::endl;
				//std::cout << fittestValue << std::endl;
				if (population[chosenEntityPos]->getFitness() >=
					getRandom((leastfitValue+fittestValue)/2, fittestValue
					)) {
					canMate = true;
				}

				counter++;
				if (counter > population.size() * 10) {
					canMate = true;
				}

			}
			
				newGen.push_back(population[chosenEntityPos]->reproduce());
			
		}

		int mutationChance = 0;
		for (int j = 0; j < newGen.size(); j++) {
			mutationChance = getRandom(0, 100);
			newGen[j]->calculateFitness(false);
			if(newGen[j]->getatMax()==false){
				int before = newGen[j]->getFitness();
				int befSize = newGen[j]->getBaseVect().size();
				newGen[j]->makeCuts();
				newGen[j]->calculateFitness(false);
				int after = newGen[j]->getFitness();
				int afSize = newGen[j]->getBaseVect().size();
				if (after <= before && (newGen[j]->getBaseVect().size() >= 2 * theseToBeCut.size() || (afSize<=befSize && newGen[j]->getBaseVect().size()>=(theseToBeCut.size()/2) ) )) {
					//std::cout << "baseVectSize: " << newGen[j]->getBaseVect().size() << "\t theseToBeCut size: " << theseToBeCut.size() << std::endl;
					newGen[j] = new Entity(baseVector, cutWidth, theseToBeCut, cnt, ratio);
					newGen[j]->calculateFitness(false);
				}
			}
			newGen[j]->calculateFitness(false);
			if (mutationChance > (100 - mutationChanceC)) {
				newGen[j]->mutate();
			}
		}


		/*for (auto d : population) {
			delete d;
		}*/
		for (auto p : population) {
			if (p->getatMax() == true) {
				readyPop.push_back(p);
			}
		}
		population.clear();
		/*for (int j = 0; j < newGen.size(); j++) {
		population.push_back(newGen[j]);
		}*/
		population = newGen;
		/*for (auto d : newGen) {
		delete d;
		}*/
		newGen.clear();
		if(population.size()>0){
		fittestPos = 0;
		fittestValue = population[fittestPos]->getFitness();
		for (int j = 0; j < population.size(); j++) {
			if (population[j]->getFitness() > population[fittestPos]->getFitness()) {
				fittestPos = j;
				fittestValue = population[j]->getFitness();
			}
		}
		leastfitPos = 0;
		leastfitValue = population[leastfitPos]->getFitness();
		for (int j = 0; j < population.size(); j++) {
			if (population[j]->getFitness() < population[leastfitPos]->getFitness()) {
				leastfitPos = j;
				leastfitValue = population[j]->getFitness();
			}
		}
		
		std::cout << leastfitPos << std::endl;
		std::cout << leastfitValue << std::endl;
		
		std::cout << "StepSize " << population[fittestPos]->getSteps().size() << std::endl;


		std::ofstream file;
		file.open("temp.svg");
		file << "<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\"\n\"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">";
		file << "<svg " << "xmlns=\"http://www.w3.org/2000/svg\"" << " width=\"" << alap->getWidth() << "\" " <<
			"height=\"" << alap->getHeight() << "\">";
		for (auto a : population[fittestPos]->getBaseVect()) {
			//std::cout << "Szelessege: " << a->getWidth() << "  Magassaga: " << a->getHeight() << std::endl;
			//std::cout << "X pozicioja: " << a->getX() << "  Y pozicioja: " << a->getY() << std::endl;
			file << "<rect x=\"" << a->getX() << "\" " <<
				"y=\"" << a->getY() << "\" " << "width=\"" << a->getWidth() << "\" "
				<< "height=\"" << a->getHeight() << "\" " <<
				"style=\"fill:" << (a->getAccepted() == true ? "red" : "blue") << "; stroke:pink; stroke - width:1; fill - opacity:0.1; stroke - opacity:0.9\" />";
		}
		file << " <text x=\"0\" y=\"15\" fill=\"white\">" << "Waste percentage: " << population[fittestPos]->getWastePercentage() << "%" << "</text> ";
		file << "</svg>";
		file.close();

		}
		std::cout << "Population size: " << population.size() << std::endl;

		std::ofstream file4("progress.txt");
		file4 << std::to_string(generation);
		file4.close();
		generation++;
		std::cout << "Readypop size: " << readyPop.size() << std::endl;
		std::cout << "Generation: " << generation << ", highest fitness: " << fittestValue << "\tLowest fitness: "<<leastfitValue<< std::endl;
		
		//	}
	}
	int area = 0;
	/*for (int a1 = 0; a1 < population[fittestPos]->getBaseVect().size(); a1++) {
	for (int a2 = 0; a2 < population[fittestPos]->getBaseVect()[a1]->getHeight(); a2++) {
	for (int a3 = 0; a3 < population[fittestPos]->getBaseVect()[a1]->getWidth(); a3++) {
	std::cout << "X";
	area++;
	}
	std::cout << std::endl;
	}
	std::cout << std::endl;
	}*/
	//
	// ez
	/*if (readyPop.size() > populationSize / 2) {
		std::ofstream fileP("progress.txt");
		fileP << std::to_string(9999999);
		fileP.close();
	}*/

	if(readyPop.size()>0){
	for (auto a : readyPop) {
		a->calculateFitness(false);
		double fitness = 0;
		fitness = fitness + (100 - a->getWastePercentage());
		a->setFitness((int)fitness*100);
	}

	std::cout << "Total area: " << area;
	fittestPos = 0;
	fittestValue = readyPop[fittestPos]->getFitness();
	for (int j = 0; j < readyPop.size(); j++) {
		if (readyPop[j]->getFitness() > readyPop[fittestPos]->getFitness()) {
			fittestPos = j;
			fittestValue = readyPop[j]->getFitness();
		}
	}
	leastfitPos = 0;
	leastfitValue = readyPop[leastfitPos]->getFitness();
	for (int j = 0; j < readyPop.size(); j++) {
		if (readyPop[j]->getFitness() < readyPop[leastfitPos]->getFitness()) {
			leastfitPos = j;
			leastfitValue = readyPop[j]->getFitness();
		}
	}
	std::cout << leastfitPos << std::endl;
	std::cout << leastfitValue << std::endl;

	std::ofstream file;
	file.open("teszt.svg");
	file << "<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\"\n\"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">";
	file << "<svg " << "xmlns=\"http://www.w3.org/2000/svg\"" << " width=\"" << alap->getWidth() << "\" " <<
		"height=\"" << alap->getHeight() << "\">";
	for (auto a : readyPop[fittestPos]->getBaseVect()) {
		//std::cout << "Szelessege: " << a->getWidth() << "  Magassaga: " << a->getHeight() << std::endl;
		//std::cout << "X pozicioja: " << a->getX() << "  Y pozicioja: " << a->getY() << std::endl;
		file << "<rect x=\"" << a->getX() << "\" " <<
			"y=\"" << a->getY() << "\" " << "width=\"" << a->getWidth() << "\" "
			<< "height=\"" << a->getHeight() << "\" " <<
			"style=\"fill:"<<(a->getAccepted()==true ? "red" : "blue")<<"; stroke:pink; stroke - width:1; fill - opacity:0.1; stroke - opacity:0.9\" />";
	}
	file << " <text x=\"0\" y=\"15\" fill=\"white\">" << "Waste percentage: " << readyPop[fittestPos]->getWastePercentage() << "%" << "</text> ";
	file << "</svg>";
	file.close();

	std::ofstream file2;
	file2.open("rossz.svg");
	file2 << "<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\"\n\"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">";
	file2 << "<svg " << "xmlns=\"http://www.w3.org/2000/svg\"" << " width=\"" << alap->getWidth() << "\" " <<
		"height=\"" << alap->getHeight() << "\">";
	for (auto a : readyPop[leastfitPos]->getBaseVect()) {
		//std::cout << "Szelessege: " << a->getWidth() << "  Magassaga: " << a->getHeight() << std::endl;
		//std::cout << "X pozicioja: " << a->getX() << "  Y pozicioja: " << a->getY() << std::endl;
		file2 << "<rect x=\"" << a->getX() << "\" " <<
			"y=\"" << a->getY() << "\" " << "width=\"" << a->getWidth() << "\" "
			<< "height=\"" << a->getHeight() << "\" " <<
			"style=\"fill:" << (a->getAccepted() == true ? "red" : "blue") << "; stroke:pink; stroke - width:1; fill - opacity:0.1; stroke - opacity:0.9\" />";
	}
	file2 << " <text x=\"0\" y=\"15\" fill=\"white\">" << "Waste percentage: " << readyPop[leastfitPos]->getWastePercentage() << "%" << "</text> ";
	file2 << "</svg>";
	file2.close();

	
	std::ofstream file3("steps.csv");
	int soCounter = 1;
	for (int helper = 0; helper < readyPop[fittestPos]->getSteps().size(); helper++) {
		if (dynamic_cast<NocutStep*>(readyPop[fittestPos]->getSteps()[helper]) != nullptr) {
			//std::cout << "no cut step" << std::endl;
		}
		if (dynamic_cast<VerticalStep*>(readyPop[fittestPos]->getSteps()[helper]) != nullptr) {
			file3 << std::to_string(soCounter++) << ",0,";
			file3 << readyPop[fittestPos]->getSteps()[helper]->getBase()->getX()+ readyPop[fittestPos]->getSteps()[helper]->getPos() << ",";
			file3 << readyPop[fittestPos]->getSteps()[helper]->getBase()->getY() << ",";
			file3 << readyPop[fittestPos]->getSteps()[helper]->getPos() << ",";
			file3 << readyPop[fittestPos]->getSteps()[helper]->getBase()->getWidth() << ",";
			file3 << readyPop[fittestPos]->getSteps()[helper]->getBase()->getHeight() << ",";
			file3 << "\n";
		}
		if (dynamic_cast<HorizontalStep*>(readyPop[fittestPos]->getSteps()[helper]) != nullptr) {
			file3 << std::to_string(soCounter++) << ",1,";
			file3 << readyPop[fittestPos]->getSteps()[helper]->getBase()->getX() << ",";
			file3 << readyPop[fittestPos]->getSteps()[helper]->getBase()->getY()+ readyPop[fittestPos]->getSteps()[helper]->getPos() << ",";
			file3 << readyPop[fittestPos]->getSteps()[helper]->getPos() << ",";
			file3 << readyPop[fittestPos]->getSteps()[helper]->getBase()->getWidth() << ",";
			file3 << readyPop[fittestPos]->getSteps()[helper]->getBase()->getHeight() << ",";
			file3 << "\n";
		}
	}
	file3.close();
	readyPop[fittestPos]->calculateFitness(true);
	Entity* writeOut = new Entity(baseVector, cutWidth, theseToBeCut, cnt, ratio);
	writeOut->makeCutsByGivenSteps(readyPop[fittestPos]->getSteps());
	}
	else {
		std::cout << "nem vaghato ki" << std::endl;
		std::ofstream file4("progress.txt");
		file4 << std::to_string(-1);
		file4.close();
	}

	
	std::cout << "VEGE" << std::endl;

	for (auto d : baseVector) {
		delete d;
	}
	for (auto d : newGen) {
		delete d;
	}
	for (auto d : theseToBeCut) {
		delete d;
	}
	fv();
	return 0;
}

