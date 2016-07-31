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

  Path(Entity entity) {
    for (int i = 0; i < EntityTransitions.TrailCount; i++) {
      trails[i] = new Entity(entity.exchange, entity.symbol, entity.name, entity.sector, entity.sectorIndex, entity.industry, entity.capitalization, entity.longitude, entity.latitude, 
                             entity.position.x, entity.position.y, entity.position.z,
                             new Rotation(random(-EntityTransitions.AngleBoundary, EntityTransitions.AngleBoundary), random(-EntityTransitions.AngleBoundary, EntityTransitions.AngleBoundary), random(-EntityTransitions.AngleBoundary, EntityTransitions.AngleBoundary)), 
                             new Rotation(0.0, 0.0, random(-EntityTransitions.AngularRotationBoundary, EntityTransitions.AngularRotationBoundary)));
      trails[i].fillColor = EntityTransitions.Colors[entity.sectorIndex];
    }
  }

  void advance() {
    trailIndex++;
    if (trailIndex == EntityTransitions.TrailCount) trailIndex = 0;
    int nextIndex = trailIndex + 1;
    if (nextIndex == EntityTransitions.TrailCount) nextIndex = 0;
    Entity entity = trails[trailIndex];
    trails[nextIndex] = new Entity(entity.exchange, entity.symbol, entity.name, entity.sector, entity.sectorIndex, entity.industry, entity.capitalization, entity.longitude, entity.latitude, 
                                   entity.position.x, entity.position.y, entity.position.z,
                                   entity.rotation, entity.rotationIncrement);
    trails[nextIndex].fillColor = EntityTransitions.Colors[entity.sectorIndex];
    trails[nextIndex].rotation.increment(trails[nextIndex].rotationIncrement);
    Entity currentEntity = trails[nextIndex];
    pushMatrix();
    if (state == 0) {
      translate(entity.position.x * (1.0 - transitioningRatio) + center.x * transitioningRatio, 
                entity.position.y * (1.0 - transitioningRatio) + center.y * transitioningRatio, 
                entity.position.z * (1.0 - transitioningRatio) + center.z * transitioningRatio);
      rotateX(currentEntity.rotation.x);
      rotateY(currentEntity.rotation.y);
      rotateZ(currentEntity.rotation.z);
      translate(initialMarketSize * transitioningRatio, 0.0, 0.0);
    } else {
      translate(center.x * (1.0 - transitioningRatio) + currentEntity.categoryCenter.x * transitioningRatio, 
                center.x * (1.0 - transitioningRatio) + currentEntity.categoryCenter.y * transitioningRatio, 
                center.z * (1.0 - transitioningRatio));      
      rotateX(currentEntity.rotation.x);
      rotateY(currentEntity.rotation.y);
      rotateZ(currentEntity.rotation.z);
      //translate(initialMarketSize - EntityTransitions.ZeroMarketSize * EntityTransitions.SectorToCapRatio.get(currentEntity.sector) * transitioningRatio * 4.0, 0.0, 0.0);
      translate(initialMarketSize - EntityTransitions.ZeroMarketSize / 10.5 * transitioningRatio, 0.0, 0.0);
    }
    currentEntity.position.x = modelX(0, 0, 0);
    currentEntity.position.y = modelY(0, 0, 0);
    currentEntity.position.z = modelZ(0, 0, 0);
    popMatrix();
  }

  void zeroCenter() {
    center.x = 0.0;
    center.y = 0.0;
    center.z = 0.0;
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
      trails[trailCursor].trailIndex = i;
      trails[trailCursor].draw();
      trailCursor--;
      if (trailCursor < 0) trailCursor = EntityTransitions.TrailCount - 1;
    }
  }

  Entity[] trails = new Entity[EntityTransitions.TrailCount];
  int trailIndex = 0;
  float transitioningRatio = 0.0;
  PVector center = new PVector(0.0, 0.0, 0.0);  

  float initialMarketSize = random(EntityTransitions.ZeroMarketSize - 10, EntityTransitions.ZeroMarketSize + 10);
  int state = 0;
  boolean transitioning = false;
  int transitionDelay = 0;
  int transitioningStep = 0;
}