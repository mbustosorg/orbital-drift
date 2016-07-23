/*

 Copyright (C) 2016 Mauricio Bustos (m@bustos.org), Matthew Yeager
 
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

class Path {

  float transitioningRatio = 0.0;
  
  Path(Entity entity) {
    for (int i = 0; i < EntityTransitions.TrailCount; i++) {
      trails[i] = new Entity(entity.symbol, entity.name, entity.sector, entity.sectorIndex, entity.industry, entity.longitude, entity.latitude, 
                             entity.x, entity.y, entity.z, entity.rotation, entity.rotationIncrement);
      trails[i].fillColor = EntityTransitions.Colors[entity.sectorIndex];
    }
  }

  void advance() {
    trailIndex++;
    if (trailIndex == EntityTransitions.TrailCount) trailIndex = 0;
    int nextIndex = trailIndex + 1;
    if (nextIndex == EntityTransitions.TrailCount) nextIndex = 0;
    Entity entity = trails[trailIndex];
    trails[nextIndex] = new Entity(entity.symbol, entity.name, entity.sector, entity.sectorIndex, entity.industry, entity.longitude, entity.latitude, 
                                   entity.x, entity.y, entity.z, 
                                   new Rotation(random(-EntityTransitions.AngleBoundary, EntityTransitions.AngleBoundary), random(-EntityTransitions.AngleBoundary, EntityTransitions.AngleBoundary), random(-EntityTransitions.AngleBoundary, EntityTransitions.AngleBoundary)), 
                                   new Rotation(0.0, 0.0, random(-EntityTransitions.AngularRotationBoundary, EntityTransitions.AngularRotationBoundary)));
    trails[nextIndex].fillColor = EntityTransitions.Colors[entity.sectorIndex];
    trails[nextIndex].rotation.increment(trails[nextIndex].rotationIncrement);
    Entity currentEntity = trails[nextIndex];
    pushMatrix();
    translate(0.0 * (1.0 - transitioningRatio) + currentEntity.categoryCenter.x * transitioningRatio, 0.0 * (1.0 - transitioningRatio) + currentEntity.categoryCenter.y * transitioningRatio, 0.0);
    rotateX(currentEntity.rotation.x);
    rotateY(currentEntity.rotation.y);
    rotateZ(currentEntity.rotation.z);
    translate(currentEntity.ZeroMarketSize - currentEntity.ZeroMarketSize / 1.5 * transitioningRatio, 0.0, 0.0);
    currentEntity.x = modelX(0, 0, 0);
    currentEntity.y = modelY(0, 0, 0);
    currentEntity.z = modelZ(0, 0, 0);
    popMatrix();
  }

  void display() {
    int trailCursor = trailIndex;
    for (int i = 0; i < EntityTransitions.TrailCount; i++) {
      if (transitionDelay > 0) transitionDelay--;
      else {
        if (transitioning && transitioningStep < EntityTransitions.MaxTransitionStep - 1) transitioningStep += 1;
        else if (!transitioning && transitioningStep > 0) transitioningStep -= 1;
      }
      transitioningRatio = EntityTransitions.TransitionSteps[transitioningStep];
      trails[trailCursor].rotation.increment(trails[trailCursor].rotationIncrement);
      trails[trailCursor].draw();
      trailCursor--;
      if (trailCursor < 0) trailCursor = EntityTransitions.TrailCount - 1;
    }
  }

  Entity[] trails = new Entity[EntityTransitions.TrailCount];
  int trailIndex = 0;

  boolean transitioning = false;
  int transitionDelay = 0;
  int transitioningStep = 0;
}