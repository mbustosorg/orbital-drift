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

class Geography extends Screen {
  private int state_index = 0;
  // transition stage between scenes
  private float[] state_times = new float[] {10500, 750, 3000, 750};
  // Linear transition, wait, grow radius, wait
  private float state_time = 0.0;
  // Current time on this state
  private float WorldRadius = 400.0;
  private float pivot = 0.0;
  private float PivotStep = -0.00001;

  private float[] entity_transition_times;
  // How long should each item spend moving

  public Geography() {
    super("Geography", 15000);
    // Duration = Sum of state_times
  }

  void setup(ScreenManager screen_manager) {
    super.setup(screen_manager);
    this.screens_next = new Screen[] {new Sector2d()};
    this.screens_chance = new int[] {100};
    this.entity_transition_times = new float[this.screen_manager.entities.size()];
    for (int i = 0; i < this.entity_transition_times.length; i++) {
      this.entity_transition_times[i] = random(3000);
    }
  }

  void update_and_draw(float delta) {
    super.update(delta);
    for (int i = 0; i < this.screen_manager.entities.size(); i++) {
      Entity e = this.screen_manager.entities.get(i);
      if (this.state_index == 0) {
        // Moving entities
        float latitude = e.latitude * PI / 180.0;
        float longitude = e.longitude * PI / 180.0;
        float x = -WorldRadius * cos(latitude) * cos(longitude);
        float y = -WorldRadius * sin(latitude);
        float z = WorldRadius * cos(latitude) * sin(longitude);
        PVector endPosition = new PVector (x, y, z);
        
        float scale = EntityTransitions.cubicInOut(this.entity_transition_times[i], this.state_time, this.state_times[this.state_index] - this.entity_transition_times[i]);
        e.position = e.initPosition.mult(1 - scale).add(endPosition.mult(scale));
      } else if (this.state_index == 2) {
        // Growing entities
        e.radius = max(5.0, map(e.capitalization, 0.0, 550, 5, 25) * EntityTransitions.linear_interpolation(this.entity_transition_times[i], this.state_time, this.state_times[this.state_index]));
      }

      e.draw();
      if (pivot > -PI) {
        pivot += PivotStep;
        camera(sin(pivot) * 750, -WorldRadius, cos(pivot) * 750, 
          0, 0, 0, 
          0, 1, 0);
      }
    }

    this.state_time += delta;
    if (this.state_time > this.state_times[this.state_index]) {
      this.state_index++;
      this.state_time = 0.0;
    }
  }
}