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

class PerformanceScreen extends Screen {
  
  private ArrayList<Path> paths = new ArrayList<Path>();
  
  private float AngleBoundary = 2.2;
  private float AngularRotationBoundary = 0.05;
  private Path follow = null;
  private float PivotSpeed = -0.01;
  private PVector MarketCenter = new PVector(0, 0, 0);
  private int ZeroMarketSize = 200;
  
  private float pivot = 0.0;
  
  public PerformanceScreen() {
    super("Performance", 15000);
      // Duration = Sum of state_times
  }

  void setup(ScreenManager screen_manager) {
    super.setup(screen_manager);

    this.screens_next = new Screen[] {new Geography()};
    this.screens_chance = new int[] {100};

    for (int i = 0; i < this.screen_manager.entities.size(); i++) {
      paths.add(new Path(this.screen_manager.entities.get(i)));
      Entity e = this.screen_manager.entities.get(i);
      e.draw();
    }
  }

  void update_and_draw(float delta) {
    super.update(delta);

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
      fill(follow.trails[paths.get(0).trailIndex].fillColor, 255.0);
      sphere(3);
      camera(first.x * 1.5, first.y * 1.5, first.z * 1.5, // Eye
             0, 0, 0,                                 // Center
             0, 1, 0);                                // Up 
    } else {
      camera(sin(pivot) * 1000, 0, cos(pivot) * 1000, // Eye
             0, 0, 0,                                 // Center
             0, 1, 0);                                // Up 
    }
    
    for (int i = 0; i < this.screen_manager.entities.size(); i++) {
      Entity e = this.screen_manager.entities.get(i);
      e.draw();
    }

  }
}
class Path {

  private int TrailCount = 30;
  private float TransitioningStep = 0.001;
  private int MaxTransitionStep = int(1 / TransitioningStep);
  private float[] TransitionSteps = new float[MaxTransitionStep];

  Path(Entity entity) {
    for (int i = 0; i < TrailCount; i++) {
      trails[i] = new Entity(entity.symbol, entity.name, entity.sector, entity.sectorIndex, entity.industry, entity.longitude, entity.latitude, 
                             entity.position.x, entity.position.y, entity.position.z, entity.rotation, entity.rotationIncrement);
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
      trails[trailCursor].draw();
      trailCursor--;
      if (trailCursor < 0) trailCursor = TrailCount - 1;
    }
  }

  void advance() {
    trailIndex++;
    if (trailIndex == TrailCount) trailIndex = 0;
    int nextIndex = trailIndex + 1;
    if (nextIndex == TrailCount) nextIndex = 0;
    Entity entity = trails[trailIndex];
    trails[nextIndex] = new Entity(entity.symbol, entity.name, entity.sector, entity.sectorIndex, entity.industry, entity.longitude, entity.latitude, 
                             entity.position.x, entity.position.y, entity.position.z, entity.rotation, entity.rotationIncrement);
    trails[nextIndex].rotation.increment(trails[nextIndex].rotationIncrement);

  }

  Entity[] trails = new Entity[TrailCount];
  int trailIndex = 0;

  boolean transitioning = false;
  int transitionDelay = 0;
  int transitioningStep = 0;
}