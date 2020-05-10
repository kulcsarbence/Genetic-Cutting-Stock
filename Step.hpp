#pragma once
#include "Base.hpp"

class Step {
	/*Step classes represent the horizontal, vertical and nocut types of cuts.
	If an Entity makes a step, it gets stored in a Step class.
	This helps us to generate .svg files later on in the algorithm.
	It also made the debugging process a lot easier.*/
	std::shared_ptr<Base> whichBase;
	int pos;
	bool border;
public:
	Step(std::shared_ptr<Base> which, int p, bool bord) : whichBase(which), pos(p), border(bord) {}
	int getPos() {
		return pos;
	}
	void setPos(int p) {
		pos = p;
	}
	std::shared_ptr<Base> getBase() {
		return whichBase;
	}
	virtual ~Step() {}
	bool getBorder() {
		return border;
	}
};

class HorizontalStep : public Step {
public:
	HorizontalStep(std::shared_ptr<Base> which, int p, bool b) : Step(which, p, b) {}
};

class VerticalStep : public Step {
public:
	VerticalStep(std::shared_ptr<Base> which, int p, bool b) : Step(which, p, b) {}
};

class NocutStep : public Step {
public:
	NocutStep(std::shared_ptr<Base> which, bool b) : Step(which, -1, b) {}
};