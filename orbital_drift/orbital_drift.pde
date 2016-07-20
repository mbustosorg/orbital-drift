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
float TransitioningStep = 0.001;
float PivotSpeed = 0.00;
Point MarketCenter = new Point(400, 400, 0);
int ZeroMarketSize = 200;

float pivot = 0.0;

color[] Colors = {#a6cee3, #1f78b4, #b2df8a, #33a02c, #fb9a99, #e31a1c, #fdbf6f, #ff7f00, #cab2d6, #6a3d9a};

void setup() {
  size(1000, 1000, P3D);
//  camera(mouseX * 2, mouseY * 2, (height/2.0) / tan(PI*30.0 / 180.0),   // Eye 
//         //width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0),   // Eye default
//         width/2.0, height/2.0, 0,                                     // Center
//         0, 1, 0);                                                     // Up 


  for (int i = 0; i < 500; i++) {
    paths.add(new Path(MarketCenter, 
      new Rotation(random(-AngleBoundary, AngleBoundary), random(-AngleBoundary, AngleBoundary), random(-AngleBoundary, AngleBoundary)), 
      random(ZeroMarketSize - 20, ZeroMarketSize + 20), 
      new Rotation(0.0, 0.0, random(-AngularRotationBoundary, AngularRotationBoundary)), int(random(0, 1) * 10)));
  }

  points.add(new Point(10, 100, 0));
  points.add(new Point(10, 50, 0));
  points.add(new Point(50, 10, 0));
  points.add(new Point(100, 10, 0));
}

void draw() {
  background(0);
  textSize(32);
  fill(150);
  text("S&P 500", width - 200, 200);
  pivot += PivotSpeed;
  noFill();
  float t = map(mouseX, 0, width, -5, 5);
  //camera(mouseX * 2, mouseY * 2, (height/2.0) / tan(PI*30.0 / 180.0),   // Eye 
         //width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0),   // Eye default
  //       width/2.0, height/2.0, 0,                                     // Center
  //       0, 1, 0);                                                     // Up 
  
  curveTightness(t);
  stroke(255, 255, 255);
  ellipse(points.get(0).x, points.get(0).y, 2, 2);
  ellipse(points.get(1).x, points.get(1).y, 2, 2);
  ellipse(points.get(2).x, points.get(2).y, 2, 2);
  ellipse(points.get(3).x, points.get(3).y, 2, 2);
  stroke(55, 55, 55);
  strokeWeight(5);
  ellipse(MarketCenter.x, MarketCenter.y, ZeroMarketSize * 2, ZeroMarketSize * 2);
  strokeWeight(1);
  stroke(255, 0, 0);
  bezier(points.get(0).x, points.get(0).y, points.get(0).z, 
    points.get(1).x, points.get(1).y, points.get(1).z, 
    points.get(2).x, points.get(2).y, points.get(2).z, 
    points.get(3).x, points.get(3).y, points.get(3).z
    );
  fill(200, 0, 0);
  stroke(200, 200, 200);
  noStroke();
  lights();
  for (Path path : paths) {
    //path.rotationIncrement.z = float(mouseX) / 2500.0;
    path.size = 5.0; //float(mouseY) / 5.0;
    path.rotate(path.rotationIncrement);
    path.display();
  }
}

void keyPressed() {
  for (Path path : paths) {
    path.transitioning = !path.transitioning;
    path.transitionDelay = int(random(0, 1000));
  }
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

class Path {

  Path(Point initMarketCenter, Rotation initRotation, float initRadius, Rotation initRotationIncrement, int initCategory) {
    sphereRadius = initRadius;
    center = initMarketCenter;
    categoryCenter = new Point(int((initCategory - initCategory % 3) * 50), int(initCategory % 3 * 200), 0.0);
    rotation = initRotation;
    rotationIncrement = initRotationIncrement;
    if (rotationIncrement.z < 0.0) rotationDirection = -1.0; 
    category = initCategory;
  }

  void display() {
    float trail = 1.0;
    for (int i = 0; i < 30; i++) {
      pushMatrix();
      if (transitionDelay > 0) transitionDelay--;
      else {
        if (transitioning && transitioningRatio < 1.0) transitioningRatio += TransitioningStep;
        else if (!transitioning && transitioningRatio > 0.0) transitioningRatio -= TransitioningStep;
      }
      translate(center.x + categoryCenter.x * transitioningRatio, center.y + categoryCenter.y * transitioningRatio, 0.0);
      rotateX(rotation.x);
      rotateY(rotation.y + pivot);
      rotateZ(rotation.z + i * 0.008);
      translate(sphereRadius - sphereRadius / 1.5 * transitioningRatio, 0.0, 0.0);
      trail = (30.0 - float(i)) / 30.0;
      if (rotationDirection > 0.0) trail = 1.0 - trail;
      fill(Colors[category], trail * 255.0);
      ellipse(0, 0, trail * size, trail * size);
      //sphere(size);
      popMatrix();
    }
  }

  void rotate(Rotation increment) {
    rotation.increment(increment);
  }

  float rotationDirection = 1.0;
  float size = 5;
  float sphereRadius;
  Rotation rotation;
  Rotation rotationIncrement;
  Point center;
  Point categoryCenter;
  int category;
  
  boolean transitioning = false;
  int transitionDelay = 0;
  float transitioningRatio = 0.0;

}