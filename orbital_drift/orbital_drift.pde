/* //<>//

 Copyright (C) 2016 Mauricio Bustos (m@bustos.org)
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
 */

ArrayList<Point> points = new ArrayList<Point>();

ArrayList<Path> paths = new ArrayList<Path>();

float AngleBoundary = 2.2;
float AngularRotationBoundary = 0.05;
float TransitioningStep = 0.0005;
float PivotSpeed = 0.00;
Point MarketCenter = new Point(400, 400, 0);
int ZeroMarketSize = 200;
int TrailCount = 30;
int UniverseSize = 500 ;

float pivot = 0.0;

color[] Colors = {#a6cee3, #1f78b4, #b2df8a, #33a02c, #fb9a99, #e31a1c, #fdbf6f, #ff7f00, #cab2d6, #6a3d9a};

void setup() {
  size(1000, 1000, P3D);
  //  camera(mouseX * 2, mouseY * 2, (height/2.0) / tan(PI*30.0 / 180.0),   // Eye 
  //         //width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0),   // Eye default
  //         width/2.0, height/2.0, 0,                                     // Center
  //         0, 1, 0);                                                     // Up 


  for (int i = 0; i < UniverseSize; i++) {
    paths.add(new Path(MarketCenter, 
      new Rotation(random(-AngleBoundary, AngleBoundary), random(-AngleBoundary, AngleBoundary), random(-AngleBoundary, AngleBoundary)), 
      random(ZeroMarketSize - 20, ZeroMarketSize + 20), 
      new Rotation(0.0, 0.0, random(-AngularRotationBoundary, AngularRotationBoundary)), int(random(0, 1) * 10)));
  }

}

void draw() {
  background(0);
  lights();
  pivot += PivotSpeed;
  noFill();
  camera(mouseX * 2, mouseY * 2, (height/2.0) / tan(PI*30.0 / 180.0),   // Eye 
  //width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0),   // Eye default
         width/2.0, height/2.0, 0,                                     // Center
         0, 1, 0);                                                     // Up 

  stroke(55, 55, 55);
  strokeWeight(5);
  ellipse(MarketCenter.x, MarketCenter.y, ZeroMarketSize * 2, ZeroMarketSize * 2);
  noStroke();
  for (Path path : paths) {
    //path.rotationIncrement.z = float(mouseX) / 2500.0;
    //path.size = 5.0; //float(mouseY) / 5.0;
    path.advance();
    path.display();
  }
}

void keyPressed() {
  for (Path path : paths) {
    path.transitioning = !path.transitioning;
    path.transitionDelay = int(random(0, 1000));
  }
}

class Rotation {

  Rotation(float initX, float initY, float initZ) {
    x = initX;
    y = initY;
    z = initZ;
  }

  void increment(Rotation increment) {
    x = incremented(x, increment.x);
    y = incremented(y, increment.y);
    z = incremented(z, increment.z);
  }

  float incremented(float angle, float increment) {
    float newAngle = angle + increment;
    if (newAngle > TWO_PI) newAngle -= TWO_PI;
    else if (newAngle < TWO_PI) newAngle += TWO_PI;
    return newAngle;
  }

  float x;
  float y;
  float z;
}

class Point {

  Point(float initX, float initY, float initZ) {
    x = initX;
    y = initY;
    z = initZ;
  }

  float x;
  float y;
  float z;
}

class PathPoint {

  PathPoint(Point initMarketCenter, Rotation initRotation, float initRadius, Rotation initRotationIncrement, int initCategory, float transitioningRatio) {
    sphereRadius = initRadius;
    center = initMarketCenter;
    categoryCenter = new Point(int((initCategory - initCategory % 3) * 50), int(initCategory % 3 * 200), 0.0);
    rotation = initRotation;
    rotationIncrement = initRotationIncrement;
    category = initCategory;
    pushMatrix();
    translate(center.x + categoryCenter.x * transitioningRatio, center.y + categoryCenter.y * transitioningRatio, 0.0);
    rotateX(rotation.x);
    rotateY(rotation.y + pivot);
    rotateZ(rotation.z);
    translate(sphereRadius - sphereRadius / 1.5 * transitioningRatio, 0.0, 0.0);
    model = new Point(modelX(0, 0, 0), modelY(0, 0, 0), modelZ(0, 0, 0));
    popMatrix();
  }

  void display(int index, float transitioningRatio) {
    pushMatrix();
    translate(model.x, model.y, model.z);
    rotateX(rotation.x);
    rotateY(rotation.y + pivot);
    rotateZ(rotation.z + index * 0.008);
    float trail = (float(TrailCount) - float(index)) / float(TrailCount);
    fill(Colors[category], trail * 255.0);
    ellipse(0, 0, trail * size, trail * size);
    //sphere(size);
    popMatrix();
  }

  Point model;
  Point center;
  Point categoryCenter;
  Rotation rotation;
  float sphereRadius;
  int category = 0;
  float size = 5;

  Rotation rotationIncrement;
}

class Path {

  Path(Point initMarketCenter, Rotation initRotation, float initRadius, Rotation initRotationIncrement, int initCategory) {
    for (int i = 0; i < TrailCount; i++) {
      trails[i] = new PathPoint(initMarketCenter, initRotation, initRadius, initRotationIncrement, initCategory, 0.0);
    }
  }

  void display() {
    int trailCursor = trailIndex;
    for (int i = 0; i < TrailCount; i++) {
      if (transitionDelay > 0) transitionDelay--;
      else {
        if (transitioning && transitioningRatio < 1.0) transitioningRatio += TransitioningStep;
        else if (!transitioning && transitioningRatio > 0.0) transitioningRatio -= TransitioningStep;
      }
      trails[trailCursor].display(i, transitioningRatio);
      trailCursor--;
      if (trailCursor < 0) trailCursor = TrailCount - 1;
    }
  }

  void advance() {
    if (trailIndex == TrailCount - 1) {
      trails[0] = new PathPoint(trails[trailIndex].center, trails[trailIndex].rotation, trails[trailIndex].sphereRadius, trails[trailIndex].rotationIncrement, trails[trailIndex].category, transitioningRatio);
      trails[0].rotation.increment(trails[0].rotationIncrement);
    } else { 
      trails[trailIndex + 1] = new PathPoint(trails[trailIndex].center, trails[trailIndex].rotation, trails[trailIndex].sphereRadius, trails[trailIndex].rotationIncrement, trails[trailIndex].category, transitioningRatio);
      trails[trailIndex + 1].rotation.increment(trails[trailIndex + 1].rotationIncrement);
    }
    trailIndex++;
    if (trailIndex == TrailCount) trailIndex = 0;
  }

  PathPoint[] trails = new PathPoint[TrailCount];
  int trailIndex = 0;

  boolean transitioning = false;
  int transitionDelay = 0;
  float transitioningRatio = 0.0;
}