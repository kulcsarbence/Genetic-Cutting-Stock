#pragma once
#include "Base.hpp"

class Entity {
	Base* firstBaseVect;
	std::vector<Base*> baseVect;
	std::vector<Base*> whichBasesToBeCut;
	std::vector<Step*> steps;
	std::vector<int> cnt;
	int ratio;
	double wastePercentage;
	int cutWidth;
	int bigCounter = 0;
	int stepVar;
	int fitness = 0;
	bool atMax = false;
	//	int badCounter = 0;
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
	~Entity() {
		//delete firstBaseVect;
		/*for (auto a : steps) {
			delete a;
		}*/
	}
	Entity(std::vector<Base*>& baseV, int cutW, std::vector<Base*>& whichToBeCut, std::vector<int> cnt, int r) : baseVect(baseV), cutWidth(cutW) {
		firstBaseVect = baseV[0];
		this->cnt = cnt;
		ratio = r;
		whichBasesToBeCut = whichToBeCut;
		stepVar = 3;
		//steps.clear();
	}
	Entity(Base* firstBaseVect, std::vector<Step*> stepss, int cutW, std::vector<Base*> whichToBeCut, std::vector<int> cnt, int r) : cutWidth(cutW) {
		//steps.clear();
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
		//calculateFitness();
	}
	Entity(Base*& firstBaseVect, std::vector<Base*>& baseVV, std::vector<Step*>& stepss, int cutW, std::vector<Base*>& whichToBeCut, std::vector<int> cnt, int r, int s) : cutWidth(cutW) {
		//steps.clear();
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
		//calculateFitness();
	}
	std::vector<Base*> getBaseVect() {
		return baseVect;
	}
	std::vector<Step*> getSteps() {
		return steps;
	}
	Base* getFirstBaseVect() {
		return firstBaseVect;
	}
	Entity* reproduce() {
		Entity* toReturn;
		int ratioToGive = ratio;
		std::vector<Step*> newSteps;
		//std::cout << "before" << std::endl;
		//int crossOverPoint = getRandom(1, steps.size()); //VIGYAZAT, ESZERINT LEGALABB EGY LEPES KELL LEGYEN MINDIG HAHA
		int cuccli = steps.size();
		int crossOverPoint;
		if (steps.size() > 0 && steps.size() < (whichBasesToBeCut.size() * 30)) {
			crossOverPoint = getRandom(steps.size(), cuccli);
			//std::cout << "kezdet" << std::endl;
			while (steps[crossOverPoint - 1]->getBorder() == false) {
				crossOverPoint = getRandom(steps.size() , cuccli);
				ratioToGive = LKO(steps[crossOverPoint - 1]->getBase()->getHeight(), steps[crossOverPoint - 1]->getBase()->getWidth());
				//std::cout << ratioToGive << std::endl;
			}
			//std::cout << "out of range" << std::endl;
		}
		else {
			crossOverPoint = 0;
			/*for (auto a : steps) {
				delete a;
			}*/ //ITT HIBA VAN!!!!! nezd meg, kiirja h van mit belepusholni ha ez ON
			ratioToGive = LKO(firstBaseVect->getWidth(), firstBaseVect->getHeight());
			/*while (steps[crossOverPoint - 1]->getBorder() == false) {
			crossOverPoint = getRandom(1, 2);
			}*/
		}
		/*if (getRandom(1, 10) == 5) {
		crossOverPoint = 1;
		}*/
		//	int crossOverPoint = 0;
		for (int i = 0; i < crossOverPoint; i++) {
			newSteps.push_back(steps[i]);
		}
		//steps.clear();
		//std::cout << "after" << std::endl;
		toReturn = new Entity(firstBaseVect, baseVect, newSteps, cutWidth, whichBasesToBeCut, this->cnt, this->ratio, stepVar);
		return toReturn;
	}
	void mutate() {
		int od = getRandom(1, 2);
		if (od == 2) {
			stepVar = stepVar - 1;
		}
		if (stepVar == 1 || od == 1) {
			stepVar = stepVar + 1;
		}
	}
	void mutateStep() {
		/*int whichStepToMutate = getRandom(0, steps.size() - 1);
		steps*/
	}
	int getFitness() {
		return fitness;
	}
	int calculateFitness(bool check) {
		atMax = false;
		int allArea = firstBaseVect->getHeight() * firstBaseVect->getWidth();
		int goodArea = 0;
		std::vector<Base*> theseToBeCut = whichBasesToBeCut;
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
					//theseToBeCut.erase(std::find(theseToBeCut.begin(), theseToBeCut.end(), element));
					alreadyWas[j] = true;
					cnter++;
					baseVect[i]->setAccepted(true);////
					if (check) {
						//std::cout << "Already was: " << theseToBeCut[j]->getWidth() << " x " << theseToBeCut[j]->getHeight() << std::endl;
					}
					break;
				}
				else if ((baseVect[i]->getHeight() == theseToBeCut[j]->getWidth()) && (baseVect[i]->getWidth() == theseToBeCut[j]->getHeight()) && !alreadyWas[j]) {
					fitness++;
					//theseToBeCut.erase(std::find(theseToBeCut.begin(), theseToBeCut.end(), element));
					alreadyWas[j] = true;
					cnter++;
					//std::cout<<"forditott"<<std::endl;
					//goodArea += theseToBeCut[j]->getHeight() * theseToBeCut[j]->getWidth();
					baseVect[i]->setAccepted(true);////
					if (check) {
						//std::cout << "Already was: " << theseToBeCut[j]->getWidth() << " x " << theseToBeCut[j]->getHeight() << std::endl;
					}
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
						//std::cout << "Cnter: " << cnter << std::endl << "Ratio: " << ratio << std::endl;
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
		//std::cout << cucc << std::endl;
		fitness = fitness * 10;
		if (atMax) {
			//fitness = fitness + (int)(100 - cucc)/10;
			wastePercentage = (double)(cucc);
		}
		return 0;
		/*for (int i = 0; i < baseVect.size(); i++) {
		int j = 0;
		bool feltetel = (baseVect[i]->getHeight() == theseToBeCut[j]->getHeight()) && (baseVect[i]->getWidth() == theseToBeCut[j]->getWidth());
		bool feltetelForditva = (baseVect[i]->getHeight() == theseToBeCut[j]->getWidth()) && (baseVect[i]->getWidth() == theseToBeCut[j]->getHeight());
		if (feltetel || feltetelForditva) {
		fitness++;
		theseToBeCut.erase(std::find(theseToBeCut.begin(), theseToBeCut.end(), theseToBeCut[j]));
		}
		while ((!feltetel) && (!feltetelForditva) && (j<theseToBeCut.size()-1)) {
		j++;
		feltetel = (baseVect[i]->getHeight() == theseToBeCut[j]->getHeight()) && (baseVect[i]->getWidth() == theseToBeCut[j]->getWidth());
		feltetelForditva = (baseVect[i]->getHeight() == theseToBeCut[j]->getWidth()) && (baseVect[i]->getWidth() == theseToBeCut[j]->getHeight());
		if (feltetel || feltetelForditva) {
		fitness++;
		theseToBeCut.erase(std::find(theseToBeCut.begin(), theseToBeCut.end(), theseToBeCut[j]));
		}
		}
		}*/
	}
	int totalArea() {
		int area = 0;
		for (int k = 0; k < baseVect.size(); k++) {
			area = area + baseVect[k]->getHeight() * baseVect[k]->getWidth();
		}
		return area;
	}
	void makeCutsByGivenSteps(std::vector<Step*> stepps) {
		std::vector<Base*> newBaseVect;
		
		int vectCounter = 0;
		int someCounter = 0;

		for (int i = 0; i < stepps.size(); i++) {
			std::vector<Base*> temp;
			for (auto a : temp) {
				delete a;
			}
			//std::cout << "VectCounter: " << vectCounter << std::endl;
			std::cout << "Steppsben levo base: " << stepps[i]->getBase()->getWidth() << " * " << stepps[i]->getBase()->getHeight() << std::endl;
			std::cout << "BaseVectben levo base: " << vectCounter <<" : "<< baseVect[vectCounter]->getWidth() << " * " << baseVect[vectCounter]->getHeight() << std::endl;
			
			if (dynamic_cast<HorizontalStep*>(stepps[i]) != nullptr) {
				steps.push_back(stepps[i]);
				int whereToCut = stepps[i]->getPos();
				std::cout << "Horizontal step. " << " WhereToCut: " << whereToCut << std::endl;
				std::cout << "Ezen az elemen - width: " << baseVect[vectCounter]->getWidth() << " height: " << baseVect[vectCounter]->getHeight() << std::endl;
				std::cout << std::endl;
				//IDEIGLENES MEGOLDAS:
				//IDEIGLENES MEGOLDAS:
				//IDEIGLENES MEGOLDAS:
				//IDEIGLENES MEGOLDAS:
				/*if (whereToCut > baseVect[vectCounter]->getHeight() || whereToCut < 0) {
					std::cout << "problem" << std::endl;
					whereToCut = getRandom(0, baseVect[vectCounter]->getHeight());
				}*/
				//
				//
				//
				//

				temp = stepps[i]->getBase()->horizontalCut(whereToCut, cutWidth);
				if (temp.size() > 0) {

					newBaseVect.push_back(temp[0]);
				}
				if (temp.size() > 1) {
					newBaseVect.push_back(temp[1]);
				}
				
				//vectCounter++;
			}
			if (dynamic_cast<VerticalStep*>(stepps[i]) != nullptr) {
				steps.push_back(stepps[i]);
				int whereToCut = stepps[i]->getPos();
				std::cout << "Vertical step. " << " WhereToCut: " << whereToCut << std::endl;
				std::cout << "Ezen az elemen - width: " << baseVect[vectCounter]->getWidth() << " height: " << baseVect[vectCounter]->getHeight() << std::endl;
				std::cout << std::endl;
				/*if (whereToCut > baseVect[vectCounter]->getWidth() || whereToCut < 0) {
					std::cout << "problem2" << std::endl;
					whereToCut = getRandom(0, baseVect[vectCounter]->getWidth());
				}*/

				temp = stepps[i]->getBase()->verticalCut(whereToCut, cutWidth);
				if (temp.size() > 0) {
					newBaseVect.push_back(temp[0]);
				}
				if (temp.size() > 1) {
					newBaseVect.push_back(temp[1]);
				}
				//vectCounter++;

			}
			if (dynamic_cast<NocutStep*>(stepps[i]) != nullptr) {
				steps.push_back(stepps[i]);
				newBaseVect.push_back(stepps[i]->getBase());
				//vectCounter++;
			}
			if (dynamic_cast<VerticalStep*>(stepps[i]) != nullptr || dynamic_cast<HorizontalStep*>(stepps[i]) != nullptr) {
				std::vector<Base*> draw;
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
					//std::cout << "Szelessege: " << a->getWidth() << "  Magassaga: " << a->getHeight() << std::endl;
					//std::cout << "X pozicioja: " << a->getX() << "  Y pozicioja: " << a->getY() << std::endl;
					file << "<rect x=\"" << a->getX() << "\" " <<
						"y=\"" << a->getY() << "\" " << "width=\"" << a->getWidth() << "\" "
						<< "height=\"" << a->getHeight() << "\" " <<
						"style=\"fill:" << (a->getAccepted() == true ? "red" : "blue") << "; stroke:pink; stroke - width:1; fill - opacity:0.1; stroke - opacity:0.9\" />";
				}
				//file << " <text x=\"0\" y=\"15\" fill=\"white\">" << "Waste percentage: " << wastePercentage << "%" << "</text> ";

				file << "</svg>";
				file.close();
				draw.clear();
			}
			//std::cout << "itt a hiba" << std::endl;
			
			/*if (i == (stepps.size() - 1)) {
				for (int j = vectCounter; j < baseVect.size(); j++) {
					std::cout << "Van mit belepusholni" << std::endl;
					newBaseVect.push_back(baseVect[j]);
				}
				vectCounter = 0;
				baseVect.clear();
				baseVect = newBaseVect;
				newBaseVect.clear();
			}*/
			if (stepps[i]->getBorder()==true) {
				std::cout << "BORDER" << std::endl;

				vectCounter = 0;
				baseVect.clear();
				baseVect = newBaseVect;
				

				
				
				
				newBaseVect.clear();

				

			}
			

		}
		File rem{ "remaining.csv" };
		std::vector<Base*> remaining;
		for (auto a : baseVect) {
			if (a->getAccepted() == false) {
				remaining.push_back(a);
			}
		}
		rem.writeStockToCSV(remaining);



	}
	void makeCuts() {
		//std::cout << "itt a problem" << std::endl;
		std::vector<Base*> newBaseVect;
		//calculateFitness(false);
		//int beforeFitness = getFitness();

		int howMuchToCut = (whichBasesToBeCut.size() - (fitness / 10));
		//std::cout << "hwc " << howMuchToCut << std::endl;
		int alreadyCut = 0;
		for (int i = 0; i < baseVect.size(); i++) {

			//std::cout << "eztet e   "<< whichBasesToBeCut[bigCounter]->getHeight() << std::endl;
			std::vector<Base*> temp;
			for (auto a : temp) {
				delete a;
			}
			temp.clear();
			int whichStep = getRandom(1, stepVar); //1 - horizontal, 2 - vertical, 3 - no cut
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
			/*if ((baseW == whichBasesToBeCut[bigCounter]->getWidth() && baseH == whichBasesToBeCut[bigCounter]->getHeight()) ||
				(baseW == whichBasesToBeCut[bigCounter]->getHeight() && baseH == whichBasesToBeCut[bigCounter]->getWidth())) {
				whichStep = 3;
			}*/
			/*if (baseVect[i]->getHeight() <= 2 * cutWidth || baseVect[i]->getWidth() <= 2 * cutWidth) {
				whichStep = 3;
			}*/
			if (baseVect[i]->getAccepted() == true) {
				whichStep = 3;
				/*if (getRandom(1, 100) == 50) {
				whichStep = getRandom(1, 2);
				baseVect[i]->setAccepted(false);
				}*/

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
			//std::cout << "wheretocut " << whereToCut << std::endl;
			if (whichStep == 1) {
				/*int whereToCut = getRandom(0, (int)baseVect[i]->getHeight()/ratio);
				while ((whereToCut*ratio + cutWidth) >= (baseVect[i]->getHeight()))
					whereToCut = getRandom(0, (int)baseVect[i]->getHeight() / ratio);*/



					/*while ((whereToCut * ratio) % ratio != cutWidth) {
						whereToCut = getRandom(0, baseVect[i]->getHeight() / ratio);
					}*/

					/*if (whereToCut <= 0) {
						whereToCut = 0;
					}
					else {
						whereToCut = whereToCut*ratio + cutWidth;
					}*/
					//std::cout << whereToCut << std::endl;
				bool b;
				if (i == (baseVect.size() - 1)) {
					b = true;
				}
				else {
					b = false;
				}
				steps.push_back(new HorizontalStep(baseVect[i], whereToCut, b));
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
				/*int whereToCut = getRandom(0, (int)baseVect[i]->getWidth() / ratio);
				while((whereToCut*ratio+cutWidth) >= (baseVect[i]->getWidth()))
				whereToCut = getRandom(0, (int)baseVect[i]->getWidth() / ratio);*/




				/*while ((whereToCut * ratio)%ratio != cutWidth) {
					whereToCut = getRandom(0, baseVect[i]->getWidth()/ratio);
				}*/
				/*if (whereToCut <= 0) {
					whereToCut = 0;
				}else{
				whereToCut = whereToCut*ratio + cutWidth;
				}*/
				//std::cout << whereToCut << std::endl;
				steps.push_back(new VerticalStep(baseVect[i], whereToCut, b));
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
				steps.push_back(new NocutStep(baseVect[i], b));
				newBaseVect.push_back(baseVect[i]);
			}


			

		}

		/*calculateFitness(false);
		int afterFitness = getFitness();

		if(afterFitness<=beforeFitness){
		badCounter++;
		}

		if (badCounter >= 11) {
		badCounter = 0;
		int flagCounter = 0;
		for (int t = steps.size() - 1; t >= 0 && flagCounter<=10; t--) {
		if (steps[t]->getBorder() == true) {
		flagCounter++;
		}
		if(flagCounter!=11){
		steps.pop_back();
		}
		}
		}*/
		baseVect.clear();
		baseVect = newBaseVect;

		newBaseVect.clear();


		//std::cout << "megse itt a problem" << std::endl;
	}
};