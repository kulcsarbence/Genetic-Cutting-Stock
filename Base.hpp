#pragma once
int getRandom(int from, int to) {
	/*Returns a random number from the interval [from, to]*/
	std::random_device dev;
	std::mt19937 rng(dev());
	std::uniform_int_distribution<std::mt19937::result_type> dist6(from, to);
	int toReturn = std::round(dist6(rng));
	return toReturn;
}


int LKO(int a, int b)
{
	/*Returns the highest common divisor of numbers 'a' and 'b'*/
	if (a == 0)
		return b;
	return LKO(b % a, a);
}

int LKOarr(std::vector<int> arr)
{
	/*Returns the highest common divisor of all the numbers in the 'arr' vector*/
	int n = arr.size();
	int result = arr[0];
	for (int i = 1; i < n; i++)
	{
		result = LKO(arr[i], result);

		if (result == 1)
		{
			return 1;
		}
	}
	return result;
}


class Base {
	/*The main function of this class is to represent the actual planks, rectangles that we want to cut out of a bigger rectangle*/
	int width; //Represents the width of such a rectangle
	int height; //Represents the height of such a rectangle
	int absHeight; //Represents the absolute Y coordinate of the given rectangle's lower left-hand corner
	int absWidth; //Represents the absolute X coordinate of the given rectangle's lower left-hand corner
	bool accepted = false; //If 'True' then the rectangle corresponds to one of the planks that need to be cut out from the main rectangle
public:
	Base(int w, int h, int absH, int absW) : width(w), height(h), absHeight(absH), absWidth(absW) {
		if (width == 0 || height == 0) {
			std::cout << "NULL ERTEK, HIBA" << std::endl;
		}
	}
	int getX() {
		return absWidth;
	}
	int getY() {
		return absHeight;
	}
	void setAccepted(bool a) {
		accepted = a;
	}
	bool getAccepted() {
		return accepted;
	}
	int getWidth() {
		return width;
	}
	int getHeight() {
		return height;
	}
	std::vector<std::shared_ptr<Base>> horizontalCut(int h, int cutWidth) {
		/*This function performs a guillotine-horizontal cut on itself at the 'h'-th coordinate (on the Y axis) with the given cut width
		and returns two planks that are created during this process*/
		std::vector<std::shared_ptr<Base>> toReturn;
		if ((h - cutWidth) > 0) {
			int newAbsH = this->absHeight;
			int newAbsW = this->absWidth;
			std::shared_ptr<Base> ret1{ new Base(width, h - cutWidth, newAbsH, newAbsW) };
			toReturn.push_back(ret1);
		}
		if ((h + cutWidth) < height) {
			int newAbsH = this->absHeight + (h + cutWidth);
			int newAbsW = this->absWidth;
			std::shared_ptr<Base> ret2{ new Base(width, height - (h + cutWidth), newAbsH, newAbsW) };
			toReturn.push_back(ret2);
		}
		return toReturn;
	}
	std::vector<std::shared_ptr<Base>> verticalCut(int w, int cutWidth) {
		/*This function performs a guillotine-vertical cut on itself at the 'w'-th coordinate (on the X axis) with the given cut width
		and returns two planks that are created during this process*/
		std::vector<std::shared_ptr<Base>> toReturn;
		if ((w - cutWidth) > 0) {
			int newAbsH = this->absHeight;
			int newAbsW = this->absWidth;
			std::shared_ptr<Base> ret1{ new Base(w - cutWidth, height, newAbsH, newAbsW) };
			toReturn.push_back(ret1);
		}
		if ((w + cutWidth) < width) {
			int newAbsH = this->absHeight;
			int newAbsW = this->absWidth + w + cutWidth;
			std::shared_ptr<Base> ret2{ new Base(width - (w + cutWidth), height, newAbsH, newAbsW) };
			toReturn.push_back(ret2);
		}
		return toReturn;
	}
};