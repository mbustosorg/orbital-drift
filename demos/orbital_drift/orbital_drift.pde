/* 

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

ArrayList<PVector> points = new ArrayList<PVector>();

ArrayList<Path> paths = new ArrayList<Path>();

float AngleBoundary = 2.2;
float AngularRotationBoundary = 0.05;
float TransitioningStep = 0.001;
int MaxTransitionStep = int(1 / TransitioningStep);
float[] TransitionSteps = new float[MaxTransitionStep];
Path follow = null;
float PivotSpeed = 0.01;
PVector MarketCenter = new PVector(0, 0, 0);
int ZeroMarketSize = 200;
int TrailCount = 30;
int UniverseSize = 500;
int cameraTransition = 0;
PVector currentCamera = new PVector(0, 0, 0);
float pivot = 0.0;
PVector cameraInit = new PVector(sin(pivot) * 1000, 0, cos(pivot) * 1000);

color[] Colors = {#a6cee3, #1f78b4, #b2df8a, #33a02c, #fb9a99, #e31a1c, #fdbf6f, #ff7f00, #cab2d6, #6a3d9a};

void setup() {
  fullScreen(P3D);
  //size(1000, 1000, P3D);
  for (int i = 0; i < 1 / TransitioningStep - 1; i++) {
    float step = float(i) / (1.0 / TransitioningStep / 2.0);
    if (step < 1) {
      TransitionSteps[i] = step * step * step / 2.0;
    } else {
      step -= 2;
      TransitionSteps[i] = (step * step * step + 2) / 2.0;      
    }
  }

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
  stroke(55, 55, 55);
  strokeWeight(5);
  ellipse(MarketCenter.x, MarketCenter.y, ZeroMarketSize * 2, ZeroMarketSize * 2);
  noStroke();
  for (Path path : paths) {
    path.advance();
    path.display();
  }
  if (follow != null) {
    PVector first = follow.trails[paths.get(0).trailIndex].model;
    translate(first.x, first.y, first.z);
    lights();
    fill(Colors[follow.trails[paths.get(0).trailIndex].category], 255.0);
    sphere(3);
    cameraTransition += 4;
    if (cameraTransition > 998) cameraTransition = 998;
    float factor = TransitionSteps[cameraTransition];
    currentCamera = new PVector(factor * first.x * 1.5 + (1.0 - factor) * cameraInit.x, 
                                factor * first.y * 1.5 + (1.0 - factor) * cameraInit.y,  
                                factor * first.z * 1.5 + (1.0 - factor) * cameraInit.z);
  } else {
    cameraTransition -= 4;
    if (cameraTransition < 0) cameraTransition = 0;
    float factor = TransitionSteps[cameraTransition];
    currentCamera = new PVector(factor * cameraInit.x + (1.0 - factor) * sin(pivot) * 1000, 
                                factor * cameraInit.y, 
                                factor * cameraInit.z + (1.0 - factor) * cos(pivot) * 1000);
  }
  camera(currentCamera.x, currentCamera.y, currentCamera.z,
         0, 0, 0,                                 
         0, 1, 0);                                 
}

void keyPressed() {
  if (key == ' ') {
    for (Path path : paths) {
      path.transitioning = !path.transitioning;
      path.transitionDelay = int(random(0, 1000));
    }
  } else if (key == 'f') {
    cameraInit = new PVector(currentCamera.x, currentCamera.y, currentCamera.z);
    if (follow == null) {
      follow = paths.get(int(random(0, UniverseSize - 1)));
    } else follow = null;
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
  
  Rotation scaled(float scale) {
    return new Rotation(x / scale, y / scale, z / scale);
  }

  float x;
  float y;
  float z;
}

class PathPoint {

  PathPoint(PVector initMarketCenter, Rotation initRotation, float initRadius, Rotation initRotationIncrement, int initCategory, float transitioningRatio) {
    sphereRadius = initRadius;
    center = initMarketCenter;
    category = initCategory;
    categoryCenter = new PVector(center.x + sphereRadius * 1.5 * cos(category * PI / 5), center.y + sphereRadius * 1.5 * sin(category * PI / 5), 0.0);
    rotation = initRotation;
    rotationIncrement = initRotationIncrement;
    pushMatrix();
    translate(center.x * (1.0 - transitioningRatio) + categoryCenter.x * transitioningRatio, center.y * (1.0 - transitioningRatio) + categoryCenter.y * transitioningRatio, 0.0);
    rotateX(rotation.x);
    rotateY(rotation.y + pivot);
    rotateZ(rotation.z);
    translate(sphereRadius - sphereRadius / 1.5 * transitioningRatio, 0.0, 0.0);
    model = new PVector(modelX(0, 0, 0), modelY(0, 0, 0), modelZ(0, 0, 0));
    popMatrix();
  }

  void display(int index, float transitioningRatio) {
    pushMatrix();
    translate(model.x, model.y, model.z);
    rotateX(rotation.x);
    rotateY(rotation.y + pivot);
    rotateZ(rotation.z);
    float trail = (float(TrailCount) - float(index)) / float(TrailCount);
    fill(Colors[category], trail * 255.0);
    ellipse(0, 0, trail * size, trail * size);
    //quad(trail * size, trail * size, 
    //     0.25 * trail * size, -3.0 * trail * size, 
    //     -0.25 * trail * size, -3.0 * trail * size, 
    //     -trail * size, trail * size);
    popMatrix();
  }

  PVector model;
  PVector center;
  PVector categoryCenter;
  Rotation rotation;
  float sphereRadius;
  int category = 0;
  float size = 5.0;

  Rotation rotationIncrement;
}

class Path {

  Path(PVector initMarketCenter, Rotation initRotation, float initRadius, Rotation initRotationIncrement, int initCategory) {
    for (int i = 0; i < TrailCount; i++) {
      trails[i] = new PathPoint(initMarketCenter, initRotation, initRadius, initRotationIncrement, initCategory, 0.0);
    }
  }

  void display() {
    int trailCursor = trailIndex;
    for (int i = 0; i < TrailCount; i++) {
      if (transitionDelay > 0) transitionDelay--;
      else {
        if (transitioning && transitioningStep < MaxTransitionStep - 1) transitioningStep += 1;
        else if (!transitioning && transitioningStep > 0) transitioningStep -= 1;
      }
      trails[trailCursor].display(i, TransitionSteps[transitioningStep]);
      trailCursor--;
      if (trailCursor < 0) trailCursor = TrailCount - 1;
    }
  }

  void advance() {
    trailIndex++;
    if (trailIndex == TrailCount) trailIndex = 0;
    int nextIndex = trailIndex + 1;
    if (nextIndex == TrailCount) nextIndex = 0;
    trails[nextIndex] = new PathPoint(trails[trailIndex].center, trails[trailIndex].rotation, trails[trailIndex].sphereRadius, trails[trailIndex].rotationIncrement, trails[trailIndex].category, TransitionSteps[transitioningStep]);
    trails[nextIndex].rotation.increment(trails[nextIndex].rotationIncrement);

  }

  PathPoint[] trails = new PathPoint[TrailCount];
  int trailIndex = 0;

  boolean transitioning = false;
  int transitionDelay = 0;
  int transitioningStep = 0;
}