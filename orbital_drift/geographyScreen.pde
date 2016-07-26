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
import java.util.Collections;

class Geography extends Screen {
  private int state_index = 0;
  // transition stage between scenes
  private float[] state_times = new float[] {8500, 750, 3000, 750};
  // Linear transition, wait, grow radius, wait
  private float state_time = 0.0;
  // Current time on this state
  private float WorldRadius = 200.0;
  private int EntityRadiusLowerBound = 3;
  private int EntityRadiusUpperBound = 10;
  private int pivot = 0;

  private float[] entity_transition_times;
  // How long should each item spend moving

  public Geography() {
    super("Geography", 13000);
    // Duration = Sum of state_times
  }

  void setup(ScreenManager screen_manager) {
    super.setup(screen_manager);
    this.screens_next = new Screen[] {new Sector2d()};
    this.screens_chance = new int[] {100};
    this.entity_transition_times = new float[this.screen_manager.entities.size()];
    Collections.sort(this.screen_manager.entities);
    for (int i = 0; i < this.entity_transition_times.length; i++) {
      this.entity_transition_times[i] = 5.5 * i;
    }
  }

  void update_and_draw(float delta, boolean is_paused) {
    if (!is_paused) {
      super.update(delta);
    }
    for (int i = 0; i < this.screen_manager.entities.size(); i++) {
      Entity e = this.screen_manager.entities.get(i);
      if (!is_paused) {
        if (this.state_index == 0) {
          // Moving entities
          float latitude = random(e.latitude - 0.01, e.latitude + 0.01) * PI / 180.0;
          float longitude = random(e.longitude - 0.01, e.longitude + 0.01) * PI / 180.0;
          float x = -WorldRadius * cos(latitude) * cos(longitude);
          float y = -WorldRadius * sin(latitude);
          float z = WorldRadius * cos(latitude) * sin(longitude);

          float t = this.state_time > this.entity_transition_times[i] ? this.state_time - this.entity_transition_times[i] : 0.0;
          float d = this.state_times[this.state_index] - this.entity_transition_times[i];
          d = d < t ? t : d;
          e.position.x = EntityTransitions.CUBIC_IN.calcEasing(t, e.initPosition.x, x - e.initPosition.x, d);
          e.position.y = EntityTransitions.LINEAR.calcEasing(t, e.initPosition.y, y - e.initPosition.y, d);
          e.position.z = EntityTransitions.CUBIC_IN.calcEasing(t, e.initPosition.x, x - e.initPosition.x, d);
        } else if (this.state_index == 2) {
          // Growing entities
          float t = this.state_time > this.entity_transition_times[i] ? this.state_time - this.entity_transition_times[i] : 0.0;
          float d = this.state_times[this.state_index] - this.entity_transition_times[i];
          float cap = map(e.capitalization, 0.0, 550, EntityRadiusLowerBound, EntityRadiusUpperBound);
          e.radius = max(EntityRadiusLowerBound, EntityTransitions.BOUNCE_IN_OUT.calcEasing(t, 3.0, cap - 3.0, d));
        }
      }
      e.draw();
    }

    if (!is_paused) {
      pivot += 2;
      this.state_time += delta;
    }

    if (pivot < EntityTransitions.MaxTransitionStep - 2) {
      this.screen_manager.orbitalCamera.orbitalUpdate(pivot, 400, -WorldRadius);
    }

    if (!is_paused && this.state_time > this.state_times[this.state_index]) {
      this.state_index++;
      this.state_time = 0.0;
    }
  }
}