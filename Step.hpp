#pragma once
#include "Base.hpp"

class Step {
	Base* whichBase;
	int pos;
	bool border;
public:
	Step(Base*& which, int p, bool bord) : whichBase(which), pos(p), border(bord) {}
	int getPos() {
		return pos;
	}
	void setPos(int p) {
		pos = p;
	}
	Base* getBase() {
		return whichBase;
	}
	virtual ~Step() {
		//delete whichBase;
	}
	bool getBorder() {
		return border;
	}
};

class HorizontalStep : public Step {
public:
	HorizontalStep(Base* which, int p, bool b) : Step(which, p, b) {}
};

class VerticalStep : public Step {
public:
	VerticalStep(Base* which, int p, bool b) : Step(which, p, b) {}
};

class NocutStep : public Step {
public:
	NocutStep(Base* which, bool b) : Step(which, -1, b) {}
};