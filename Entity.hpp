#pragma once
#include "Base.hpp"

class Entity {
	/*This class represents an entity from the population whose main task is to perform cuts in a semi-random order.
	As the fitness of the entity gets bigger, so does the chance for it to reproduce go higher.*/
	std::shared_ptr<Base> firstBaseVect; //The original big plank, from which everything needs to be cut out.
	std::vector<std::shared_ptr<Base>> baseVect; //A vector containing the current rectangles. After every makeCuts() method call, it gets refreshed with new elements
	std::vector<std::shared_ptr<Base>> whichBasesToBeCut; //A vector containing the items that are needed to be cut out from the 'firstBaseVect' rectangle
	std::vector<std::shared_ptr<Step>> steps; //A vector containing all the steps the given Entity has made.
	std::vector<int> cnt; //A vector that helps to process some calculations in the calculateFitness() method.
	int ratio; //The current ratio of the cutting sizes, DEPRECATED.
	double wastePercentage; //The percentage of the waste that derives from the cutting processes.
	int cutWidth; //The width of the cuts (symmetrical - it means that if cutWidth is 1, then 1+1=2 will be the actual cutWidth given how the blade works in real applications).
	int bigCounter = 0; //A counter that helps in some minor calculations.
	int stepVar; //The higher this variable's value is, the lower the chance for the Entity to cut into the next rectangle it stores in its 'baseVect' vector.
	int fitness = 0; //The fitness of the Entity.
	bool atMax = false; //If 'True' then the Entity has reached a solution.
public:
	void setFitness(int mennyire) {
		fitness = mennyire;
	}
	double getWastePercentage() {
		return wastePercentage;
	}
	bool getatMax() {
		return atMax;
	}
	Entity(std::vector<std::shared_ptr<Base>> baseV, int cutW, std::vector<std::shared_ptr<Base>> whichToBeCut, std::vector<int> cnt, int r) : baseVect(baseV), cutWidth(cutW) {
		firstBaseVect = baseV[0];
		this->cnt = cnt;
		ratio = r;
		whichBasesToBeCut = whichToBeCut;
		stepVar = 3;
	}
	Entity(std::shared_ptr<Base> firstBaseVect, std::vector<std::shared_ptr<Step>> stepss, int cutW, std::vector<std::shared_ptr<Base>> whichToBeCut, std::vector<int> cnt, int r) : cutWidth(cutW) {
		stepVar = 3;
		ratio = r;
		baseVect.push_back(firstBaseVect);
		this->cnt = cnt;
		whichBasesToBeCut = whichToBeCut;
		this->firstBaseVect = firstBaseVect;
		if (stepss.size() > 0) {
			makeCutsByGivenSteps(stepss);

		}
		else {
			calculateFitness(false);
			makeCuts();
		}
	}
	Entity(std::shared_ptr<Base> firstBaseVect, std::vector<std::shared_ptr<Base>> baseVV, std::vector<std::shared_ptr<Step>> stepss, int cutW, std::vector<std::shared_ptr<Base>> whichToBeCut, std::vector<int> cnt, int r, int s) : cutWidth(cutW) {
		stepVar = s;
		ratio = r;
		baseVect.push_back(firstBaseVect);
		this->cnt = cnt;
		whichBasesToBeCut = whichToBeCut;
		this->firstBaseVect = firstBaseVect;
		if (stepss.size() > 0) {
			this->steps = stepss;
			baseVect = baseVV;
		}
		else {
			calculateFitness(false);
			makeCuts();
		}
	}
	std::vector<std::shared_ptr<Base>> getBaseVect() {
		return baseVect;
	}
	std::vector<std::shared_ptr<Step>> getSteps() {
		return steps;
	}
	std::shared_ptr<Base> getFirstBaseVect() {
		return firstBaseVect;
	}
	std::shared_ptr<Entity> reproduce() {
		/*In the current version, this function returns a new Entity that derives from its parent.*/
		std::shared_ptr<Entity> toReturn;
		int ratioToGive = ratio;
		std::vector<std::shared_ptr<Step>> newSteps;
		int cuccli = steps.size();
		int crossOverPoint;
		if (steps.size() > 0 && steps.size() < (whichBasesToBeCut.size() * 30)) {
			crossOverPoint = getRandom(steps.size(), cuccli);
			while (steps[crossOverPoint - 1]->getBorder() == false) {
				crossOverPoint = getRandom(steps.size() , cuccli);
				ratioToGive = LKO(steps[crossOverPoint - 1]->getBase()->getHeight(), steps[crossOverPoint - 1]->getBase()->getWidth());
			}
		}
		else {
			crossOverPoint = 0;
			ratioToGive = LKO(firstBaseVect->getWidth(), firstBaseVect->getHeight());
		}
		for (int i = 0; i < crossOverPoint; i++) {
			newSteps.push_back(steps[i]);
		}
		toReturn = std::make_shared<Entity>(  Entity(firstBaseVect, baseVect, newSteps, cutWidth, whichBasesToBeCut, this->cnt, this->ratio, stepVar) );
		return toReturn;
	}
	void mutate() {
		/*This method mutates the 'stepVar' variable by changing its value by 1.*/
		int od = getRandom(1, 2);
		if (od == 2) {
			stepVar = stepVar - 1;
		}
		if (stepVar == 1 || od == 1) {
			stepVar = stepVar + 1;
		}
	}
	int getFitness() {
		return fitness;
	}
	int calculateFitness(bool check) {
		/*This method calculates the current fitness level of the Entity.
		The higher the number of the rectangles that the Entity managed to cut out, the higher its fitness value will become.*/
		atMax = false;
		int allArea = firstBaseVect->getHeight() * firstBaseVect->getWidth();
		int goodArea = 0;
		std::vector<std::shared_ptr<Base>> theseToBeCut = whichBasesToBeCut;
		std::vector<bool> alreadyWas;
		for (int j = 0; j < theseToBeCut.size(); j++) {
			alreadyWas.push_back(false);
		}

		if (check) {
			std::cout << "---------------------" << std::endl;
		}
		int cnter = 0;
		int temp = 0;
		int index = 0;
		fitness = 0;
		for (int i = 0; i < baseVect.size(); i++) {
			goodArea += baseVect[i]->getHeight() * baseVect[i]->getWidth();
			for (int j = 0; j < theseToBeCut.size(); j++) {
				if ((baseVect[i]->getHeight() == theseToBeCut[j]->getHeight()) && (baseVect[i]->getWidth() == theseToBeCut[j]->getWidth()) && !alreadyWas[j]) {
					fitness++;
					alreadyWas[j] = true;
					cnter++;
					baseVect[i]->setAccepted(true);
					break;
				}
				else if ((baseVect[i]->getHeight() == theseToBeCut[j]->getWidth()) && (baseVect[i]->getWidth() == theseToBeCut[j]->getHeight()) && !alreadyWas[j]) {
					fitness++;
					alreadyWas[j] = true;
					cnter++;
					baseVect[i]->setAccepted(true);
					break;
				}
			}
			if (cnter <= whichBasesToBeCut.size() && index <= cnt.size() -1) {
				temp = 0;
				for (int r = 0; r < index + 1; r++) {
					temp += cnt[r];
				}
				if (cnter >= temp) {
					if (cnter >= (temp + 1)) {
					}
					else {
						index++;
						if (temp < whichBasesToBeCut.size()) {
							ratio = LKO(whichBasesToBeCut[temp]->getWidth(), whichBasesToBeCut[temp]->getHeight());
						}
					}
				}
				this->bigCounter = cnter;
			}
		}
		if (fitness >= theseToBeCut.size()) {
			atMax = true;
		}

		int wasteMaximum = allArea - goodArea;
		double cucc = (((double)allArea - (double)goodArea) / (double)allArea) * 100;
		if (check) {
			return cucc;
		}
		fitness = fitness * 10;
		if (atMax) {
			wastePercentage = (double)(cucc);
		}
		return 0;
	}
	int totalArea() {
		/*Returns the total area of all the rectangles in the 'baseVect' container.*/
		int area = 0;
		for (int k = 0; k < baseVect.size(); k++) {
			area = area + baseVect[k]->getHeight() * baseVect[k]->getWidth();
		}
		return area;
	}
	void makeCutsByGivenSteps(std::vector<std::shared_ptr<Step>> stepps) {
		/*This method simulates the steps an Entity made using the 'stepps' vector.
		It also generates files corresponding to each step.*/
		std::vector<std::shared_ptr<Base>> newBaseVect;
		
		int vectCounter = 0;
		int someCounter = 0;

		for (int i = 0; i < stepps.size(); i++) {
			std::vector<std::shared_ptr<Base>> temp;
			std::cout << "Steppsben levo base: " << stepps[i]->getBase()->getWidth() << " * " << stepps[i]->getBase()->getHeight() << std::endl;
			
			if (std::dynamic_pointer_cast<std::shared_ptr<HorizontalStep>>(stepps[i]) != nullptr) {
				steps.push_back(stepps[i]);
				int whereToCut = stepps[i]->getPos();
				std::cout << "Horizontal step. " << " WhereToCut: " << whereToCut << std::endl;
				std::cout << "Ezen az elemen - width: " << baseVect[vectCounter]->getWidth() << " height: " << baseVect[vectCounter]->getHeight() << std::endl;
				std::cout << std::endl;

				temp = stepps[i]->getBase()->horizontalCut(whereToCut, cutWidth);
				if (temp.size() > 0) {

					newBaseVect.push_back(temp[0]);
				}
				if (temp.size() > 1) {
					newBaseVect.push_back(temp[1]);
				}
			}
			if (std::dynamic_pointer_cast<std::shared_ptr<VerticalStep>>(stepps[i]) != nullptr) {
				steps.push_back(stepps[i]);
				int whereToCut = stepps[i]->getPos();
				std::cout << "Vertical step. " << " WhereToCut: " << whereToCut << std::endl;
				std::cout << "Ezen az elemen - width: " << baseVect[vectCounter]->getWidth() << " height: " << baseVect[vectCounter]->getHeight() << std::endl;
				std::cout << std::endl;

				temp = stepps[i]->getBase()->verticalCut(whereToCut, cutWidth);
				if (temp.size() > 0) {
					newBaseVect.push_back(temp[0]);
				}
				if (temp.size() > 1) {
					newBaseVect.push_back(temp[1]);
				}

			}
			if (std::dynamic_pointer_cast<std::shared_ptr<NocutStep>>(stepps[i]) != nullptr) {
				steps.push_back(stepps[i]);
				newBaseVect.push_back(stepps[i]->getBase());
			}
			if (std::dynamic_pointer_cast<std::shared_ptr<VerticalStep>>(stepps[i]) != nullptr || std::dynamic_pointer_cast<std::shared_ptr<HorizontalStep>>(stepps[i]) != nullptr) {
				std::vector<std::shared_ptr<Base>> draw;
				draw = newBaseVect;
				if (stepps[i]->getBorder() == false) {
					for (int j = (temp.size()>1 ? i+1 : i) ; j < stepps.size(); j++) {
						draw.push_back(stepps[j]->getBase());
						if (stepps[j]->getBorder() == true) {
							break;
						}
					}
				}
				baseVect = draw;
				this->calculateFitness(false);
				std::ofstream file;
				file.open("temp" + std::to_string(someCounter++) + ".svg");
				file << "<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\"\n\"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">";
				file << "<svg " << "xmlns=\"http://www.w3.org/2000/svg\"" << " width=\"" << firstBaseVect->getWidth() << "\" " <<
					"height=\"" << firstBaseVect->getHeight() << "\">";
				for (auto a : baseVect) {
					file << "<rect x=\"" << a->getX() << "\" " <<
						"y=\"" << a->getY() << "\" " << "width=\"" << a->getWidth() << "\" "
						<< "height=\"" << a->getHeight() << "\" " <<
						"style=\"fill:" << (a->getAccepted() == true ? "red" : "blue") << "; stroke:pink; stroke - width:1; fill - opacity:0.1; stroke - opacity:0.9\" />";
				}

				file << "</svg>";
				file.close();
				draw.clear();
			}
			if (stepps[i]->getBorder()==true) {
				std::cout << "BORDER" << std::endl;

				vectCounter = 0;
				baseVect.clear();
				baseVect = newBaseVect;
				newBaseVect.clear();
			}
			

		}
		File rem{ "remaining.csv" };
		std::vector<std::shared_ptr<Base>> remaining;
		for (auto a : baseVect) {
			if (a->getAccepted() == false) {
				remaining.push_back(a);
			}
		}
		if(remaining.size()>0){
			rem.writeStockToCSV(remaining);
		}
		else {
			std::ofstream outf{ "remaining.csv" };
			outf << "";
			outf.close();
		}



	}
	void makeCuts() {
		/*This method performs some actual cuts on the rectangles in the 'baseVect' vector.*/
		std::vector<std::shared_ptr<Base>> newBaseVect;

		int howMuchToCut = (whichBasesToBeCut.size() - (fitness / 10));
		int alreadyCut = 0;
		for (int i = 0; i < baseVect.size(); i++) {
			std::vector<std::shared_ptr<Base>> temp;
			
			temp.clear();
			int whichStep = getRandom(1, stepVar);
			if (alreadyCut >= howMuchToCut) {
				whichStep = 3;
			}
			int toBeCutW = whichBasesToBeCut[bigCounter]->getWidth();
			int toBeCutH = whichBasesToBeCut[bigCounter]->getHeight();
			int baseW = baseVect[i]->getWidth();
			int baseH = baseVect[i]->getHeight();
			if (
				((baseW < toBeCutW || baseH < toBeCutH) && (baseW < toBeCutH || baseH < toBeCutW))
				) {
				whichStep = 3;
			}
			if (baseVect[i]->getAccepted() == true) {
				whichStep = 3;
			}
			int whereToCut = 0;
			if (whichStep == 1) {

				int melyik = getRandom(0, 1);
				if (melyik == 0) {
					whereToCut = whichBasesToBeCut[bigCounter]->getWidth() + cutWidth;
					if (whereToCut >= baseVect[i]->getHeight()) {
						whereToCut = whichBasesToBeCut[bigCounter]->getHeight() + cutWidth;
						if (whereToCut >= baseVect[i]->getHeight()) { whichStep = 3; }
					}
				}
				else {
					whereToCut = whichBasesToBeCut[bigCounter]->getHeight() + cutWidth;
					if (whereToCut >= baseVect[i]->getHeight()) {
						whereToCut = whichBasesToBeCut[bigCounter]->getWidth() + cutWidth;
						if (whereToCut >= baseVect[i]->getHeight()) { whichStep = 3; }
					}
				}
			}
			else if (whichStep == 2) {
				int melyik = getRandom(0, 1);
				if (melyik == 0) {
					whereToCut = whichBasesToBeCut[bigCounter]->getWidth() + cutWidth;
					if (whereToCut >= baseVect[i]->getWidth()) {
						whereToCut = whichBasesToBeCut[bigCounter]->getHeight() + cutWidth;
						if (whereToCut >= baseVect[i]->getWidth()) { whichStep = 3; }
					}
				}
				else {
					whereToCut = whichBasesToBeCut[bigCounter]->getHeight() + cutWidth;
					if (whereToCut >= baseVect[i]->getWidth()) {
						whereToCut = whichBasesToBeCut[bigCounter]->getWidth() + cutWidth;
						if (whereToCut >= baseVect[i]->getWidth()) { whichStep = 3; }
					}
				}
			}
			if (whichStep == 1) {
				bool b;
				if (i == (baseVect.size() - 1)) {
					b = true;
				}
				else {
					b = false;
				}
				steps.push_back(std::make_shared<HorizontalStep>( HorizontalStep(baseVect[i], whereToCut, b)));
				alreadyCut++;
				temp = baseVect[i]->horizontalCut(whereToCut, cutWidth);
				if (temp.size() > 0) {
					newBaseVect.push_back(temp[0]);

				}
				if (temp.size() > 1) {
					newBaseVect.push_back(temp[1]);
				}

			}
			else if (whichStep == 2) {
				bool b;
				if (i == (baseVect.size() - 1)) {
					b = true;
				}
				else {
					b = false;
				}
				steps.push_back(std::make_shared<VerticalStep>( VerticalStep(baseVect[i], whereToCut, b)));
				temp = baseVect[i]->verticalCut(whereToCut, cutWidth);
				alreadyCut++;
				if (temp.size() > 0) {
					newBaseVect.push_back(temp[0]);
				}
				if (temp.size() > 1) {
					newBaseVect.push_back(temp[1]);
				}

			}
			else if (whichStep > 2) {
				bool b;
				if (i == (baseVect.size() - 1)) {
					b = true;
				}
				else {
					b = false;
				}
				steps.push_back(std::make_shared<NocutStep>( NocutStep(baseVect[i], b)));
				newBaseVect.push_back(baseVect[i]);
			}


			

		}
		baseVect.clear();
		baseVect = newBaseVect;

		newBaseVect.clear();
	}
};