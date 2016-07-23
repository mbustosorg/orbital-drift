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
  
  private Path follow = null;
  private float PivotSpeed = -0.01;
  private PVector MarketCenter = new PVector(0, 0, 0);
  private int ZeroMarketSize = 200;
  
  int cameraTransition = 0;
  PVector currentCamera = new PVector(0, 0, 0);
  private float pivot = 0.0;
  PVector cameraInit = new PVector(sin(pivot) * 1000, 0, cos(pivot) * 1000);
  
  public PerformanceScreen() {
    super("Performance", 100000.0);
      // Duration = Sum of state_times
        
    for (int i = 0; i < 1 / EntityTransitions.TransitioningStep - 1; i++) {
      float step = float(i) / (1.0 / EntityTransitions.TransitioningStep / 2.0);
      if (step < 1) {
        EntityTransitions.TransitionSteps[i] = step * step * step / 2.0;
      } else {
        step -= 2;
        EntityTransitions.TransitionSteps[i] = (step * step * step + 2) / 2.0;      
      }
    }
  }

  void keyPressed() {
    println("key: ", key);
    if (key == ' ') {
      for (Path path : paths) {
        path.transitioning = !path.transitioning;
        path.transitionDelay = int(random(0, 1000));
      }
    } else if (key == 'f') {
      if (follow == null) {
        follow = paths.get(int(random(0, this.screen_manager.entities.size() - 1)));
      } else follow = null;
    }
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
    for (Path path : paths) {
      path.transitioning = !path.transitioning;
      path.transitionDelay = int(random(0, 1000));
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
      PVector first = follow.trails[paths.get(0).trailIndex].position;
      translate(first.x, first.y, first.z);
      lights();
      sphere(3);
      cameraTransition += 4;
      if (cameraTransition > 998) cameraTransition = 998;
      float factor = EntityTransitions.TransitionSteps[cameraTransition];
      currentCamera = new PVector(factor * first.x * 1.5 + (1.0 - factor) * cameraInit.x, 
                                  factor * first.y * 1.5 + (1.0 - factor) * cameraInit.y,  
                                  factor * first.z * 1.5 + (1.0 - factor) * cameraInit.z);
    } else {
      cameraTransition -= 4;
      if (cameraTransition < 0) cameraTransition = 0;
      float factor = EntityTransitions.TransitionSteps[cameraTransition];
      currentCamera = new PVector(factor * cameraInit.x + (1.0 - factor) * sin(pivot) * 1000, 
                                  factor * cameraInit.y, 
                                  factor * cameraInit.z + (1.0 - factor) * cos(pivot) * 1000);
    }
    camera(currentCamera.x, currentCamera.y, currentCamera.z,
           0, 0, 0,                                 
           0, 1, 0);                                 
  }
}