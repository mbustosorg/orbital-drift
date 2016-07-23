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
  
  private float pivot = 0.0;
  
  public PerformanceScreen() {
    super("Performance", 15000);
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
      if (follow == null) {
        follow = paths.get(int(random(0, entities.size() - 1)));
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
      //camera(sin(pivot) * 1000, 0, cos(pivot) * 1000, // Eye
      camera(sin(pivot) * 750, -400, cos(pivot) * 750,
             0, 0, 0,                                 // Center
             0, 1, 0);                                // Up 
    }
  }
}