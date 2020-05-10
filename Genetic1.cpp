/*Including some header files...*/
#include <stdlib.h>
#include <crtdbg.h>
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
#include <memory>




int main(int argc, char* argv[])
{
	/*The previous .svg files will get deleted*/
	std::string command = "del /Q ";
	std::string cur_dir(argv[0]);
	int pos = cur_dir.find_last_of("/\\");
	std::string path = cur_dir.substr(0, pos) + "\\*.svg";
	std::cout << path << std::endl;
	system(command.append(path).c_str());

	int ratio;
	int mutationChanceC = 7;
	int generation = 0;
	std::ifstream basicInput("exchange.txt"); //exchange.txt stores some pretty important parameters.
	std::string line;
	std::getline(basicInput, line);
	int ww = std::stoi(line); //ww is the width of the main rectangle
	std::getline(basicInput, line);
	int hh = std::stoi(line); //hh is the width of the main rectangle
	std::getline(basicInput, line);
	int cutWidth = std::stoi(line); //cutWidth is the width of the cuts
	std::getline(basicInput, line);
	int populationSize = std::stoi(line); //populationSize is the size of the population
	std::getline(basicInput, line);
	int genS = std::stoi(line); //genS is the number of generations
	basicInput.close();

	std::shared_ptr<Base> alap{ new Base(ww, hh, 0, 0) }; //'alap' is the MAIN/BASE rectangle
	std::vector<std::shared_ptr<Base>> baseVector;
	baseVector.push_back(alap);
	std::vector<std::shared_ptr<Entity>> population;  //'population' stores all the initial entities
	std::vector<std::shared_ptr<Entity>> readyPop; //'readyPop' stores all the entities that reached a solution. The best solution is going to be chosen from this vector.
	std::vector<std::shared_ptr<Base>> theseToBeCut; //'theseToBeCut' stores all the rectangles that we want to cut out.
	std::vector<int> cnt;
	File toBeCut("tobecut.csv");
	theseToBeCut = toBeCut.readStockFromCSV(); //The planks that we want to cut out are being read in.
	std::sort(theseToBeCut.begin(), theseToBeCut.end(), [](std::shared_ptr<Base> a, std::shared_ptr<Base> b) {return a->getWidth()*a->getHeight() > b->getWidth()*b->getHeight(); }); //The planks are sorted based on their area.
	for (auto a : theseToBeCut) {
		std::cout << a->getHeight() << ", " << a->getWidth() << "\n";
	}
	int itemTypeCounter = 1;
	int currentWidth = theseToBeCut[0]->getWidth();
	int currentHeight = theseToBeCut[0]->getHeight();
	for (int i = 0; i < theseToBeCut.size() - 1; i++) { //the 'cnt' vector gets loaded with new elements, this vector will help the entities to calculate their own fitness values
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

	ratio = LKO(theseToBeCut[0]->getWidth(), theseToBeCut[0]->getHeight()); //The ratio gets calculated. In the current version it is DEPRECATED.

	std::cout << "Ratio: " << ratio << std::endl; 

	for (int i = 0; i < populationSize; i++) { //The initial population is created. Every Entity is forced to make cuts.
		population.push_back(std::make_shared<Entity>( Entity(baseVector, cutWidth, theseToBeCut, cnt, ratio)));
		population[i]->calculateFitness(false);
		population[i]->makeCuts();
		population[i]->calculateFitness(false);
	}
	int fittestPos = 0;
	int fittestValue = 0;
	int leastfitPos = 0;
	int leastfitValue = 0;
	std::vector<std::shared_ptr<Entity>> newGen; //newGen will always hold the newest generation in every iteration.

	
	while(generation<genS){ //the iteration goes on until the current generation=genS

		int chosenEntityPos = 0; //the position of the Entity in the population vector, that gets to reproduce

		for (int k = 0; k < population.size(); k++) { //in this cycle the new generation is created, with the same size as its parent generation
			bool canMate = false;
			bool hiba = false;
			chosenEntityPos = 0;
			int counter = 0;
			while (!hiba && (!canMate || population[chosenEntityPos]->getatMax() == true)) {

				chosenEntityPos = getRandom(0, population.size() -1);
				if (population[chosenEntityPos]->getFitness() >=
					getRandom((leastfitValue+fittestValue)/2, fittestValue
					)) { //the higher an entities fitness is, the higher its chance is to reproduce
					canMate = true;
				}

				counter++;
				if (counter > population.size() * 10) { //if the cycle goes on for too long without any success, the 'hiba' boolean is given a new value, 'True'
					canMate = true;
					hiba = true;
				}

			}
			if (!hiba) {
				newGen.push_back(population[chosenEntityPos]->reproduce());
			}
			else { //if 'hiba' is True, then instead of reproducing an old Entity, a new Entity gets created.
				newGen.push_back(std::make_shared<Entity>( Entity(baseVector, cutWidth, theseToBeCut, cnt, ratio)));
			}
			
		}

		int mutationChance = 0; //this is a local variable, the real mutation chance is stored in the 'mutationChanceC' variable (by default it is set to 7%)
		for (int j = 0; j < newGen.size(); j++) {
			mutationChance = getRandom(0, 100);
			newGen[j]->calculateFitness(false);
			if(newGen[j]->getatMax()==false){ //If the current Entity has not yet reached a solution
				int before = newGen[j]->getFitness();
				int befSize = newGen[j]->getBaseVect().size();
				for(int q = 0; q<getRandom(1,theseToBeCut.size()) && newGen[j]->getatMax()==false; q++){ //The Entity is forced to make cuts 'q' times
				newGen[j]->calculateFitness(false);
				newGen[j]->makeCuts();
				newGen[j]->calculateFitness(false);
				}
				int after = newGen[j]->getFitness();
				int afSize = newGen[j]->getBaseVect().size();
				if (after <= before && (newGen[j]->getBaseVect().size() >= 3 * theseToBeCut.size() ) && getRandom(1,12)==5) { //if this special value is True, then the 'j'-th Entity gets replaced with a new Entity
					newGen[j] = std::make_shared<Entity>(  Entity(baseVector, cutWidth, theseToBeCut, cnt, ratio) );
					newGen[j]->calculateFitness(false);
				}
			}
			newGen[j]->calculateFitness(false);
			if (mutationChance > (100 - mutationChanceC)) {
				newGen[j]->mutate(); //The Entity is mutated by changing its 'stepVar' variable.
			}
		}


		
		for (auto p : population) { //Every Entity that has reached a solution is saved in the 'readyPop' vector.
			if (p->getatMax() == true) {
				readyPop.push_back(p);
			}
		}
		population.clear();
		population = newGen;
		newGen.clear();
		if(population.size()>0){
		fittestPos = 0;
		fittestValue = population[fittestPos]->getFitness();
		for (int j = 0; j < population.size(); j++) { //the fittest Entity's position and fitness value is calculated.
			if (population[j]->getFitness() > population[fittestPos]->getFitness()) {
				fittestPos = j;
				fittestValue = population[j]->getFitness();
			}
		}
		leastfitPos = 0;
		leastfitValue = population[leastfitPos]->getFitness();
		for (int j = 0; j < population.size(); j++) { //the most unfit Entity's position and fitness value is calculated.
			if (population[j]->getFitness() < population[leastfitPos]->getFitness()) {
				leastfitPos = j;
				leastfitValue = population[j]->getFitness();
			}
		}
		
		std::cout << leastfitPos << std::endl;
		std::cout << leastfitValue << std::endl;
		
		std::cout << "StepSize " << population[fittestPos]->getSteps().size() << std::endl;


		std::ofstream file;
		file.open("temp.svg"); //The current fittest Entity's solution is generated as an .SVG file
		file << "<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\"\n\"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">";
		file << "<svg " << "xmlns=\"http://www.w3.org/2000/svg\"" << " width=\"" << alap->getWidth() << "\" " <<
			"height=\"" << alap->getHeight() << "\">";
		for (auto a : population[fittestPos]->getBaseVect()) {
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

		std::ofstream file4("progress.txt"); //The text file is updated. If it reaches genS-1, the algorithm completed the task.
		file4 << std::to_string(generation);
		file4.close();
		generation++;
		std::cout << "Readypop size: " << readyPop.size() << std::endl;
		std::cout << "Generation: " << generation << ", highest fitness: " << fittestValue << "\tLowest fitness: "<<leastfitValue<< std::endl;
		
	}
	int area = 0;

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
	file.open("teszt.svg"); //The fittest Entity's solution (from the 'readyPop' vector) is generated as an .SVG file
	file << "<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\"\n\"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">";
	file << "<svg " << "xmlns=\"http://www.w3.org/2000/svg\"" << " width=\"" << alap->getWidth() << "\" " <<
		"height=\"" << alap->getHeight() << "\">";
	for (auto a : readyPop[fittestPos]->getBaseVect()) {
		file << "<rect x=\"" << a->getX() << "\" " <<
			"y=\"" << a->getY() << "\" " << "width=\"" << a->getWidth() << "\" "
			<< "height=\"" << a->getHeight() << "\" " <<
			"style=\"fill:"<<(a->getAccepted()==true ? "red" : "blue")<<"; stroke:pink; stroke - width:1; fill - opacity:0.1; stroke - opacity:0.9\" />";
	}
	file << " <text x=\"0\" y=\"15\" fill=\"white\">" << "Waste percentage: " << readyPop[fittestPos]->getWastePercentage() << "%" << "</text> ";
	file << "</svg>";
	file.close();

	std::ofstream file2;
	file2.open("rossz.svg"); //The most unfit Entity's solution (from the 'readyPop' vector) is generated as an .SVG file
	file2 << "<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\"\n\"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">";
	file2 << "<svg " << "xmlns=\"http://www.w3.org/2000/svg\"" << " width=\"" << alap->getWidth() << "\" " <<
		"height=\"" << alap->getHeight() << "\">";
	for (auto a : readyPop[leastfitPos]->getBaseVect()) {
		file2 << "<rect x=\"" << a->getX() << "\" " <<
			"y=\"" << a->getY() << "\" " << "width=\"" << a->getWidth() << "\" "
			<< "height=\"" << a->getHeight() << "\" " <<
			"style=\"fill:" << (a->getAccepted() == true ? "red" : "blue") << "; stroke:pink; stroke - width:1; fill - opacity:0.1; stroke - opacity:0.9\" />";
	}
	file2 << " <text x=\"0\" y=\"15\" fill=\"white\">" << "Waste percentage: " << readyPop[leastfitPos]->getWastePercentage() << "%" << "</text> ";
	file2 << "</svg>";
	file2.close();

	
	std::ofstream file3("steps.csv"); //The fittest Entity's steps are generated as a .CSV file
	int soCounter = 1;
	for (int helper = 0; helper < readyPop[fittestPos]->getSteps().size(); helper++) {
		if (std::dynamic_pointer_cast<std::shared_ptr<NocutStep>>(readyPop[fittestPos]->getSteps()[helper]) != nullptr) {
		}
		if (std::dynamic_pointer_cast<std::shared_ptr<VerticalStep>>(readyPop[fittestPos]->getSteps()[helper]) != nullptr) {
			file3 << std::to_string(soCounter++) << ",0,";
			file3 << readyPop[fittestPos]->getSteps()[helper]->getBase()->getX()+ readyPop[fittestPos]->getSteps()[helper]->getPos() << ",";
			file3 << readyPop[fittestPos]->getSteps()[helper]->getBase()->getY() << ",";
			file3 << readyPop[fittestPos]->getSteps()[helper]->getPos() << ",";
			file3 << readyPop[fittestPos]->getSteps()[helper]->getBase()->getWidth() << ",";
			file3 << readyPop[fittestPos]->getSteps()[helper]->getBase()->getHeight() << ",";
			file3 << "\n";
		}
		if (std::dynamic_pointer_cast<std::shared_ptr<HorizontalStep>>(readyPop[fittestPos]->getSteps()[helper]) != nullptr) {
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
	std::shared_ptr<Entity> writeOut{ new Entity(baseVector, cutWidth, theseToBeCut, cnt, ratio) };
	writeOut->makeCutsByGivenSteps(readyPop[fittestPos]->getSteps());
	}
	else { //If the task cannot be completed, e.g. the plank's area that we want to cut out is bigger than the MAIN PLANK's area
		std::cout << "nem vaghato ki" << std::endl;
		std::ofstream file4("progress.txt");
		file4 << std::to_string(-1); //Then the 'progress.txt' file's stored value is going to be -1
		file4.close();
	}

	std::cout << "VEGE" << std::endl; //End of the algorithm.

	return 0;
}

