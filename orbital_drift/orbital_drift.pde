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
float AngularRotationBoundary = 0.04;
float pivot = 0.0;

void setup() {
  size(1000, 1000, P3D);
  //frameRate(100);

  for (int i = 0; i < 500; i++) {
    paths.add(new Path(400, 400, 
      new Rotation(random(-AngleBoundary, AngleBoundary), random(-AngleBoundary, AngleBoundary), random(-AngleBoundary, AngleBoundary)), 
      random(180, 220), 
      new Rotation(0.0, 0.0, random(-AngularRotationBoundary, AngularRotationBoundary)), color(random(1, 200), random(1, 200), random(1, 200))));
  }

  points.add(new Point(10, 100, 0));
  points.add(new Point(10, 50, 0));
  points.add(new Point(50, 10, 0));
  points.add(new Point(100, 10, 0));
}

void draw() {
  background(0);
  pivot += 0.015;
  noFill();
  float t = map(mouseX, 0, width, -5, 5);
  curveTightness(t);
  stroke(255, 255, 255);
  ellipse(points.get(0).x, points.get(0).y, 2, 2);
  ellipse(points.get(1).x, points.get(1).y, 2, 2);
  ellipse(points.get(2).x, points.get(2).y, 2, 2);
  ellipse(points.get(3).x, points.get(3).y, 2, 2);
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
    path.size = float(mouseY) / 5.0;
    path.rotate(path.rotationIncrement);
    path.display();
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

  Path(float initX, float initY, Rotation initRotation, float initRadius, Rotation initRotationIncrement, color initColor) {
    radius = initRadius;
    center = new Point(initX, initY, 0.0);
    rotation = initRotation;
    rotationIncrement = initRotationIncrement;
    pathColor = initColor;
  }

  void display() {
    for (int i = 0; i < 30; i++) {
      pushMatrix();
      translate(center.x, center.y, 0.0);
      rotateX(rotation.x);
      rotateY(rotation.y + pivot);
      rotateZ(rotation.z + i * 0.008);
      translate(radius, 0.0, 0.0);
      fill(pathColor, (30.0 - float(i)) / 30.0 * 255.0);
      ellipse(0, 0, (30.0 - float(i)) / 30.0 * size, (30.0 - float(i)) / 30.0 * size);
      //sphere(size);
      popMatrix();
    }
  }

  void rotate(Rotation increment) {
    rotation.increment(increment);
  }

  float size = 5;
  float radius;
  Rotation rotation;
  Rotation rotationIncrement;
  Point center;
  color pathColor;
}