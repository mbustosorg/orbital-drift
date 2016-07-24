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
        
  }

  void keyPressed() {
    println("key: ", key);
    if (key == ' ') {
      for (Path path : paths) {
        path.transitioning = !path.transitioning;
        path.transitionDelay = int(random(0, 1000));
      }
    } else if (key == 'f') {
      cameraInit = new PVector(currentCamera.x, currentCamera.y, currentCamera.z);
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
    }
  }

  void update_and_draw(float delta, boolean is_paused) {
    if (!is_paused) {
      super.update(delta);
      pivot += PivotSpeed;
    }
    noFill();
    stroke(55, 55, 55);
    strokeWeight(5);
    ellipse(MarketCenter.x, MarketCenter.y, ZeroMarketSize * 2, ZeroMarketSize * 2);
    noStroke();

    for (Path path : paths) {
      path.advance();
      if (!is_paused) {
        path.display();
      }
    }

    if (follow != null) {
      Entity first = follow.trails[paths.get(0).trailIndex];
      translate(first.position.x, first.position.y, first.position.z);
      fill(first.fillColor);
      sphere(3);
      if (!is_paused) {
        cameraTransition += 5;
        if (cameraTransition > 998) cameraTransition = 998;
      }
      float factor = EntityTransitions.TransitionSteps[cameraTransition];
      currentCamera = new PVector(factor * first.position.x * 1.5 + (1.0 - factor) * cameraInit.x, 
                                  factor * first.position.y * 1.5 + (1.0 - factor) * cameraInit.y,  
                                  factor * first.position.z * 1.5 + (1.0 - factor) * cameraInit.z);
    } else {
      if (!is_paused) {
        cameraTransition -= 5;
        if (cameraTransition < 0) cameraTransition = 0;
      }
      float factor = EntityTransitions.TransitionSteps[cameraTransition];
      currentCamera = new PVector(factor * cameraInit.x + (1.0 - factor) * sin(pivot) * 1000, 
                                  factor * cameraInit.y, 
                                  factor * cameraInit.z + (1.0 - factor) * cos(pivot) * 1000);
    }
    this.screen_manager.orbitalCamera.update(currentCamera.x, currentCamera.y, currentCamera.z);                                 
  }
}